
local getCFrameFromInstance = require(script.Parent.getCFrameFromInstance)

local root = script.Parent.Parent
local modules = root.modules
local Result = require(modules.Result)

--- @function getCFrameOffsetFromInstance
--- @within Util
--- @param instance Instance
--- @return Result<CFrame, string>
return function(instance: Instance): Result.Result
	if typeof(instance) ~= "Instance" then
		return Result.err("value is not an Instance!")
	end

	if instance:IsA("Folder") == false then
		local getCFrameResult = getCFrameFromInstance(instance)

		if getCFrameResult:isErr() then
			return Result.err(("unable to get convert to CFrame: %s"):format(getCFrameResult:unwrapErr()))
		else
			return getCFrameResult
		end
	end

	local originValue = instance:FindFirstChild("Origin")
	if originValue == nil then
		return Result.err("missing child \"Origin\"")
	end

	local originResult= getCFrameFromInstance(originValue)
	if originResult:isErr() then
		return Result.err(("unable to convert \"Origin\" to CFrame: %s"):format(originResult:unwrapErr()))
	end

	local origin = originResult:unwrap()

	local offsetValue = instance:FindFirstChild("Offset")
	if offsetValue == nil then
		return Result.err("missing child \"Offset\"")
	end

	local offsetResult = getCFrameFromInstance(offsetValue)
	if offsetResult:isErr() then
		return Result.err(("unable to convert \"Origin\" to CFrame: %s"):format(originResult:unwrapErr()))
	end

	local offset = offsetResult:unwrap()

	return Result.ok(origin:ToObjectSpace(offset))
end