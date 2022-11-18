
local root = script.Parent.Parent
local modules = root.modules
local Result = require(modules.Result)

--- @function getReducedObjectValue
--- @within Util
--- @param instance Instance
--- @return Result<Instance, string>
return function(instance: Instance)
	if typeof(instance) ~= "Instance" then
		return Result.err("value is not an Instance!")
	end

	if instance:IsA("ObjectValue") then
		if instance.Value == nil then
			return Result.err("ObjectValue.Value not set! " .. instance:GetFullName())
		end

		instance = instance.Value
	end

	return Result.ok(instance)
end