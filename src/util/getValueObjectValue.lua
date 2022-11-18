
local modules = script.Parent.Parent.modules
local Result = require(modules.Result)

--- Returns the Value from a ValueObject (Instance that has a `.Value` property)
--- @function getValueObjectValue
--- @within Util
--- @param instance Instance
--- @return Result<any, string>
--- @error is not an Enum
return function(instance: Instance, childName: string, className: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return Result.err(("missing child %q!"):format(childName))
	elseif child:IsA(className) == false then
		return Result.err(("child %q is not a %q!"):format(childName, className))
	end

	return Result.ok(child.Value)
end