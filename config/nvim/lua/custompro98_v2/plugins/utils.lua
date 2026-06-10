-- ** Plugin Utils ** --

local M = {}

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
function M.gh(repo)
	return "https://github.com/" .. repo
end

local mason_map = {
	["biome-check"] = "biome",
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
						if tool_to_mason(submember) then
							table.insert(everything, submember)
						end
					end
				else
					if tool_to_mason(member) then
						table.insert(everything, member)
					end
				end
			end
		end
	end

	return everything
end

return M
