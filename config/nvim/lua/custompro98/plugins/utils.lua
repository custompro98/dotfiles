-- ** Plugin Utils ** --

local M = {}

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
function M.gh(repo)
	return "https://github.com/" .. repo
end

-- conform/nvim-lint name -> Mason package name
local mason_map = {
	["biome-check"] = "biome",
	["erb_format"] = "erb-formatter",
}

---@param tool string
---@return string|nil
local function tool_to_mason(tool)
	if mason_map[tool] then
		return mason_map[tool]
	end

	return tool
end

---@param tooling_by_ft table<string, table<string, string[] | string[][]>>
function M.all_tools(tooling_by_ft)
	local everything = {}

	for _, toolset in pairs(tooling_by_ft) do
		for _, toolist in pairs(toolset) do
			for _, member in ipairs(toolist) do
				if type(member) == "table" then
					for _, submember in ipairs(member) do
						local mason_name = tool_to_mason(submember)
						if mason_name then
							table.insert(everything, mason_name)
						end
					end
				else
					local mason_name = tool_to_mason(member)
					if mason_name then
						table.insert(everything, mason_name)
					end
				end
			end
		end
	end

	return everything
end

return M
