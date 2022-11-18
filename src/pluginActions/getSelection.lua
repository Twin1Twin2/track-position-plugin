
local Selection = game:GetService("Selection")

local root = script.Parent.Parent

local modules = root.modules
local Result = require(modules.Result)

return function()
	local selection = Selection:Get()[1]

	if selection == nil then
		return Result.err("Nothing selected!")
	end

	return Result.ok(selection)
end
