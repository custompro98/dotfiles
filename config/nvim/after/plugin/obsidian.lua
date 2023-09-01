local obsidian = require("obsidian")

obsidian.setup({
	dir = "~/Documents/Obsidian/Wizhire",
	daily_notes = {
		folder = "Daily",
		date_format = "%Y-%m-%d",
	},
	completion = {
		-- If using nvim-cmp, otherwise set to false
		nvim_cmp = true,
		-- Trigger completion at 2 chars
		min_chars = 2,
		-- Where to put new notes created from completion. Valid options are
		--  * "current_dir" - put new notes in same directory as the current buffer.
		--  * "notes_subdir" - put new notes in the default notes subdirectory.
		new_notes_location = "notes_subdir",

		-- Whether to add the output of the node_id_func to new notes in autocompletion.
		-- E.g. "[[Foo" completes to "[[foo|Foo]]" assuming "foo" is the ID of the note.
		prepend_note_id = false,
	},
	mappings = {
		-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
		["gf"] = require("obsidian.mapping").gf_passthrough(),
	},
	disable_frontmatter = true,
	follow_url_func = function(url)
		-- Open the URL in the default web browser.
		vim.fn.jobstart({ "open", url }) -- Mac OS
		-- vim.fn.jobstart({"xdg-open", url})  -- linux
	end,
	open_app_foreground = true,
	finder = "telescope.nvim",
	-- Accepted values are "current", "hsplit" and "vsplit"
	open_notes_in = "current",
})

vim.keymap.set("n", "<Leader>ot", "<Cmd>ObsidianToday<CR>")
vim.keymap.set("n", "<Leader>oy", "<Cmd>ObsidianYesterday<CR>")
vim.keymap.set("n", "<Leader>fo", "<Cmd>ObsidianQuickSwitch<CR>")
