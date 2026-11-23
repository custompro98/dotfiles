#!/usr/bin/env bash
# Tests for bin/compose-project against temp repos and a stub docker. Runs on
# macOS and Linux (as a non-root user).
#   bash scripts/test_compose_project.sh
set -uo pipefail

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/compose-project"
FAILURES=0

assert() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then echo "ok   $desc"; else echo "FAIL $desc"; FAILURES=$((FAILURES + 1)); fi
}
fails() { ! "$@"; }

# A main checkout at $ROOT whose server/docker-compose.yaml pins `name: app`
# and keeps Postgres data in ./.pgdata (with some data in it), and a stub
# docker that records "$PWD $*" per call in $DOCKER_CALLS. `ps` prints
# $STUB_DOCKER_PS; `inspect` prints $STUB_DOCKER_MOUNTS (mount destinations,
# default the Postgres data directory).
make_repo() {
  TMP="$(cd "$(mktemp -d)" && pwd -P)"
  ROOT="$TMP/repo"
  mkdir -p "$ROOT/server" "$TMP/bin"
  git -C "$ROOT" init -q -b main
  git -C "$ROOT" config user.email test@example.com
  git -C "$ROOT" config user.name test
  printf 'name: app\n\nservices:\n  db:\n    volumes:\n      - ./.pgdata:/var/lib/postgresql/data\n' >"$ROOT/server/docker-compose.yaml"
  printf '.pgdata/\n.env*\n' >"$ROOT/.gitignore"
  git -C "$ROOT" add -A && git -C "$ROOT" commit -q -m init
  mkdir -p "$ROOT/server/.pgdata/base" && echo main-data >"$ROOT/server/.pgdata/base/PG_VERSION"
  export DOCKER_CALLS="$TMP/docker-calls"
  : >"$DOCKER_CALLS"
  unset STUB_DOCKER_PS STUB_DOCKER_MOUNTS
  cat >"$TMP/bin/docker" <<'EOF'
#!/usr/bin/env bash
echo "$PWD $*" >>"$DOCKER_CALLS"
case "$1" in
  ps) printf '%s\n' "${STUB_DOCKER_PS:-}" ;;
  inspect) printf '%s\n' "${STUB_DOCKER_MOUNTS:-/var/lib/postgresql/data}" ;;
esac
EOF
  chmod +x "$TMP/bin/docker"
}

# A worktree on a new branch at <path> (default $TMP/worktrees/<branch>), with
# an env file using the shared stack's OrbStack hostnames. Prints its path.
make_worktree() {
  local path="${2:-$TMP/worktrees/${1//\//-}}"
  git -C "$ROOT" worktree add -q -b "$1" "$path"
  cat >"$path/server/.env.overrides" <<'EOF'
# OrbStack hostnames
PG_HOST=db.app.orb.local
SQS_ENDPOINT=http://localstack.app.orb.local:4566
OTHER_HOST=db.appx.orb.local
EOF
  echo "$path"
}

# compose-project <args>, run from <dir>.
cp_in() {
  local dir="$1"
  shift
  (cd "$dir" && PATH="$TMP/bin:$PATH" "$BIN" "$@")
}

project_of() { sed -n 's/^COMPOSE_PROJECT_NAME=//p' "$1/server/.env.overrides"; }

test_setup_sets_project_and_hosts() {
  local wt f p
  wt="$(make_worktree feat/Thing_1)"
  f="$wt/server/.env.overrides"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  p="$(project_of "$wt")"
  assert "project named after the worktree, plus a hash" grep -qE '^app-feat-thing_1-[0-9a-f]{6}$' <<<"$p"
  assert "db host rewritten" grep -qx "PG_HOST=db.$p.orb.local" "$f"
  assert "endpoint rewritten" grep -qx "SQS_ENDPOINT=http://localstack.$p.orb.local:4566" "$f"
  assert "other projects' hosts untouched" grep -qx "OTHER_HOST=db.appx.orb.local" "$f"
  assert "comments kept" grep -q "^# OrbStack" "$f"
}

test_same_name_different_paths() {
  local a b
  a="$(make_worktree one "$TMP/a/feature")"
  b="$(make_worktree two "$TMP/b/feature")"
  cp_in "$a/server" setup .env.overrides >/dev/null
  cp_in "$b/server" setup .env.overrides >/dev/null
  assert "different projects" test "$(project_of "$a")" != "$(project_of "$b")"
  assert "both named after the directory" test "$(project_of "$a" | cut -c1-11)" = "app-feature"
}

test_project_stable() {
  local wt p
  wt="$(make_worktree feat)"
  cp_in "$wt/server" setup .env.overrides >/dev/null
  p="$(project_of "$wt")"
  cp_in "$wt/server" down >/dev/null
  assert "down targets the same project" grep -q " compose -p $p down" "$DOCKER_CALLS"
}

test_env_file_required() {
  local wt
  wt="$(make_worktree feat)"
  assert "fails without one" fails cp_in "$wt/server" setup
  assert "doesn't copy" test ! -e "$wt/server/.pgdata"
}

test_needs_orbstack_hostnames() {
  local wt
  wt="$(make_worktree feat)"
  printf 'PG_HOST=localhost\n' >"$wt/server/.env.overrides"
  assert "fails" fails cp_in "$wt/server" setup .env.overrides
  assert "says why" grep -q "orb.local" <<<"$(cp_in "$wt/server" setup .env.overrides 2>&1)"
  assert "doesn't copy" test ! -e "$wt/server/.pgdata"
  assert "env file untouched" test "$(cat "$wt/server/.env.overrides")" = "PG_HOST=localhost"
  assert "fails on a missing file" fails cp_in "$wt/server" setup .env.missing
  assert "doesn't create it" test ! -e "$wt/server/.env.missing"
}

test_setup_idempotent() {
  local wt before
  wt="$(make_worktree feat)"
  cp_in "$wt/server" setup .env.overrides >/dev/null
  before="$(cat "$wt/server/.env.overrides")"
  assert "exits 0 again" cp_in "$wt/server" setup .env.overrides
  assert "unchanged" test "$(cat "$wt/server/.env.overrides")" = "$before"
}

test_moves_hosts_from_an_earlier_project_name() {
  local wt f p
  wt="$(make_worktree feat)"
  f="$wt/server/.env.overrides"
  printf 'PG_HOST=db.app-feat.orb.local\nCOMPOSE_PROJECT_NAME=app-feat\n' >"$f"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  p="$(project_of "$wt")"
  assert "host follows the new name" grep -qx "PG_HOST=db.$p.orb.local" "$f"
  assert "one project line" test "$(grep -c '^COMPOSE_PROJECT_NAME=' "$f")" = 1
}

test_env_file_without_final_newline() {
  local wt f p
  wt="$(make_worktree feat)"
  f="$wt/server/.env.overrides"
  printf 'PG_HOST=db.app.orb.local' >"$f"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  p="$(project_of "$wt")"
  assert "last line intact" grep -qx "PG_HOST=db.$p.orb.local" "$f"
  assert "project on its own line" grep -qx "COMPOSE_PROJECT_NAME=$p" "$f"
}

test_long_name_truncated() {
  local wt p
  wt="$(make_worktree "feat/$(printf 'a%.0s' {1..80})")"
  cp_in "$wt/server" setup .env.overrides >/dev/null
  p="$(project_of "$wt")"
  assert "fits a DNS label" test "${#p}" -le 63
  assert "keeps the hash" grep -qE -- '-[0-9a-f]{6}$' <<<"$p"
}

test_quoted_name() {
  local wt
  wt="$(make_worktree feat)"
  sed -i.bak 's/^name: app$/name: "app" # pinned/' "$wt/server/docker-compose.yaml"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "reads the quoted name" grep -qE '^app-feat-' <<<"$(project_of "$wt")"
}

test_no_name_fails() {
  local wt
  wt="$(make_worktree feat)"
  sed -i.bak '/^name:/d' "$wt/server/docker-compose.yaml"
  assert "fails" fails cp_in "$wt/server" setup .env.overrides
}

test_no_compose_file_fails() {
  local wt
  wt="$(make_worktree feat)"
  assert "fails at the checkout root" fails cp_in "$wt" setup .env.overrides
}

test_main_checkout_untouched() {
  printf 'PG_HOST=db.app.orb.local\n' >"$ROOT/server/.env.overrides"
  export STUB_DOCKER_PS=abc123
  assert "setup exits 0" cp_in "$ROOT/server" setup .env.overrides
  assert "env file untouched" test "$(cat "$ROOT/server/.env.overrides")" = "PG_HOST=db.app.orb.local"
  assert "down exits 0" cp_in "$ROOT/server" down
  assert "docker not called" test ! -s "$DOCKER_CALLS"
}

test_copies_main_pgdata() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_DOCKER_PS=abc123
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "data copied" test "$(cat "$wt/server/.pgdata/base/PG_VERSION")" = main-data
  assert "looks in the main stack" grep -q "ps -q --filter label=com.docker.compose.project=app --filter label=com.docker.compose.project.working_dir=$ROOT/server$" "$DOCKER_CALLS"
  assert "stops then restarts the main db" test "$(grep -oE '(stop|start) abc123' "$DOCKER_CALLS" | tr '\n' ' ')" = "stop abc123 start abc123 "
  assert "copy is ignored by git" test -z "$(git -C "$wt" status --porcelain)"
}

test_other_main_containers_keep_running() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_DOCKER_PS=ls1 STUB_DOCKER_MOUNTS=/var/lib/localstack
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "data copied" test -f "$wt/server/.pgdata/base/PG_VERSION"
  assert "nothing stopped" fails grep -qE " (stop|start) " "$DOCKER_CALLS"
}

test_copy_without_running_db() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "data copied" test -f "$wt/server/.pgdata/base/PG_VERSION"
  assert "nothing stopped" fails grep -qE " (stop|start) " "$DOCKER_CALLS"
}

test_existing_copy_kept() {
  local wt
  wt="$(make_worktree feat)"
  mkdir -p "$wt/server/.pgdata" && echo mine >"$wt/server/.pgdata/PG_VERSION"
  export STUB_DOCKER_PS=abc123
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "not overwritten" test "$(cat "$wt/server/.pgdata/PG_VERSION")" = mine
  assert "main db not stopped" fails grep -q "stop" "$DOCKER_CALLS"
}

test_no_copy_when_compose_doesnt_use_pgdata() {
  local wt
  wt="$(make_worktree feat)"
  printf 'name: app\nservices:\n  db:\n    image: postgres\n' >"$wt/server/docker-compose.yaml"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "no copy" test ! -e "$wt/server/.pgdata"
}

test_no_copy_when_main_has_no_data() {
  local wt
  wt="$(make_worktree feat)"
  rm -rf "$ROOT/server/.pgdata"
  assert "exits 0" cp_in "$wt/server" setup .env.overrides
  assert "no copy" test ! -e "$wt/server/.pgdata"
}

test_failed_copy_restarts_main_db() {
  local wt before
  echo secret >"$ROOT/server/.pgdata/base/unreadable" && chmod 000 "$ROOT/server/.pgdata/base/unreadable"
  wt="$(make_worktree feat)"
  before="$(cat "$wt/server/.env.overrides")"
  export STUB_DOCKER_PS=abc123
  assert "fails" fails cp_in "$wt/server" setup .env.overrides
  assert "main db restarted" grep -q "start abc123" "$DOCKER_CALLS"
  assert "no partial copy" test ! -e "$wt/server/.pgdata"
  assert "env file untouched" test "$(cat "$wt/server/.env.overrides")" = "$before"
  chmod 600 "$ROOT/server/.pgdata/base/unreadable"
}

test_down() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" cp_in "$wt/server" down
  assert "downs only this worktree's project, volumes too" grep -qE "^$wt/server compose -p app-feat-[0-9a-f]{6} down -v --remove-orphans$" "$DOCKER_CALLS"
  assert "never the main checkout's" fails grep -q -- "-p app " "$DOCKER_CALLS"
}

test_usage() {
  local wt
  wt="$(make_worktree feat)"
  assert "no command fails" fails cp_in "$wt/server"
  assert "unknown command fails" fails cp_in "$wt/server" use
}

for t in $(declare -F | awk '$3 ~ /^test_/ { print $3 }'); do
  echo "# $t"
  make_repo
  "$t"
  rm -rf "$TMP"
done
[ "$FAILURES" -eq 0 ] || { echo "$FAILURES failed"; exit 1; }
