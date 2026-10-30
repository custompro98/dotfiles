#!/usr/bin/env bun
// Print a workspace's merged Conductor settings as JSON. Later files win:
// root settings.toml, workspace settings.toml, root settings.local.toml,
// workspace settings.local.toml. Tables merge; everything else replaces.
const [workspace, root] = process.argv.slice(2);

const merge = (base: any, over: any): any => {
  if (!isTable(base) || !isTable(over)) return over;
  const out = { ...base };
  for (const [key, value] of Object.entries(over)) out[key] = merge(base[key], value);
  return out;
};

function isTable(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

let settings = {};
const dirs = root && root !== workspace ? [root, workspace] : [workspace];
for (const name of ["settings.toml", "settings.local.toml"]) {
  for (const dir of dirs) {
    const file = Bun.file(`${dir}/.conductor/${name}`);
    if (await file.exists()) settings = merge(settings, Bun.TOML.parse(await file.text()));
  }
}

console.log(JSON.stringify(settings));
