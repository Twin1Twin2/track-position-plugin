
local getVector3FromInstance = require(script.Parent.getVector3FromInstance)

local root = script.Parent.Parent
local modules = root.modules
local Result = require(modules.Result)

--- @function getVector3OffsetFromInstance
--- @within Util
--- @param instance Instance
--- @return Result<Vector3, string>
return function(instance: Instance): Result.Result
	if typeof(instance) ~= "Instance" then
		return Result.err("value is not an Instance!")
	end

	if instance:IsA("Folder") == false then
		local getVector3Result = getVector3FromInstance(instance)

		if getVector3Result:isErr() then
			return Result.err(("unable to get convert to Vector3: %s"):format(getVector3Result:unwrapErr()))
		else
			return getVector3Result
		end
	end

	local originValue = instance:FindFirstChild("Origin")
	if originValue == nil then
		return Result.err("missing child \"Origin\"")
	end

	local originResult= getVector3FromInstance(originValue)
	if originResult:isErr() then
		return Result.err(("unable to convert \"Origin\" to Vector3: %s"):format(originResult:unwrapErr()))
	end

	local origin = originResult:unwrap()

	local offsetValue = instance:FindFirstChild("Offset")
	if offsetValue == nil then
		return Result.err("missing child \"Offset\"")
	end

	local offsetResult = getVector3FromInstance(offsetValue)
	if offsetResult:isErr() then
		return Result.err(("unable to convert \"Origin\" to Vector3: %s"):format(originResult:unwrapErr()))
	end

	local offset = offsetResult:unwrap()

	return Result.ok(offset - origin)
end