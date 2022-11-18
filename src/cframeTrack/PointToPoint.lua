
local CFrameTrack = require(script.Parent.CFrameTrack)

local root = script.Parent.Parent

local modules = root.modules
local Result = require(modules.Result)

local pointsUtil = require(root.pointsUtil)
local pointsFromInstance = pointsUtil.getCFramePointsFromInstance

--- A line with equidistant points
--- @class PointToPointCFrameTrack

--- @interface PointToPointData
--- @within PointToPointCFrameTrack
--- .points {CFrame}
--- .isCircuited boolean
--- .distanceBetweenPoints number

export type PointToPointData = {
	points: {CFrame},
	isCircuited: boolean,
	distanceBetweenPoints: number,
}

local PointToPointCFrameTrack = {}
PointToPointCFrameTrack.__index = PointToPointCFrameTrack
setmetatable(PointToPointCFrameTrack, CFrameTrack)
PointToPointCFrameTrack.ClassName = "PointToPointCFrameTrack"

--- Constructor
--- @tag Constructor
--- @return PointToPointCFrameTrack
function PointToPointCFrameTrack.new()
	local self = setmetatable(CFrameTrack.new(), PointToPointCFrameTrack)

	self.points = {}

	self.distanceBetweenPoints = 1

	self.isCircuited = false
	self.circuitRemainder = 0
	self.lengthWithoutCircuitRemainder = 0

	return self
end

--- Constructor
--- Constructs a new PointToPointCFrameTrack from an Instance
--- @tag Constructor
--- @return Result<PointToPointCFrameTrack, string>
function PointToPointCFrameTrack.fromInstance(instance: Instance)
	if typeof(instance) ~= "Instance" then
		return Result.err("Arg [1] is not an Instance!")
	end

	local data

	if instance:IsA("ModuleScript") then
		-- TODO: require moduleScript here then check table
		local dataResult = PointToPointCFrameTrack.getDataFromModuleScript(instance)
		if dataResult:isErr() then
			return Result.err(("Unable to convert track from ModuleScript: %s"):format(dataResult:unwrapErr()))
		end
	
		data = dataResult:unwrap()
	else -- model
		local dataResult = PointToPointCFrameTrack.getDataFromModel(instance)
		if dataResult:isErr() then
			return Result.err(("Unable to convert track from Model: %s"):format(dataResult:unwrapErr()))
		end

		data = dataResult:unwrap()
	end

	local newTrack = PointToPointCFrameTrack.new()

	newTrack:_setData(data)

	return Result.ok(newTrack)
end

--- Gets data from a Model
--- @param instance Instance
--- @return Result<PointToPointData, string>
function PointToPointCFrameTrack.getDataFromModel(instance: Instance): Result.Result
	if typeof(instance) ~= "Instance" then
		return Result.err("Arg [1] is not an Instance!")
	end

	local pointsData = instance:FindFirstChild("Points")
	local distanceBetweenPointsValue = instance:FindFirstChild("DistanceBetweenPoints")
	local isCircuitedValue = instance:FindFirstChild("IsCircuited")

	if pointsData == nil then
		return Result.err("Missing Points! An Instance")
	elseif distanceBetweenPointsValue == nil then
		return Result.err("Missing DistanceBetweenPoints! A NumberValue")
	elseif not (isCircuitedValue ~= nil and isCircuitedValue:IsA("BoolValue")) then
		return Result.err("Missing IsCircuited! A BoolValue")
	end

	local pointsResult = pointsFromInstance(pointsData)

	if pointsResult:isErr() then
		return pointsResult
	end

	return Result.ok({
		points = pointsResult:unwrap(),
		distanceBetweenPoints = distanceBetweenPointsValue.Value,
		isCircuited = isCircuitedValue.Value,
	})
end

--- Gets PointToPointData from a ModuleScript
--- @param moduleScript ModuleScript
--- @return Result<PointToPointData, string>
function PointToPointCFrameTrack.getDataFromModuleScript(moduleScript: ModuleScript): Result.Result
	if not (typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript")) then
		return Result.err("Arg [1] is not a ModuleScript!")
	end

	-- TODO: pcall require
	local data = require(moduleScript)

	if type(data) ~= "table" then
		return Result.err("Module did not return a table!")
	end

	local points = data.points
	local distanceBetweenPoints = data.distanceBetweenPoints
	local isCircuited = data.isCircuited

	if type(points) ~= "table" then
		return Result.err("Missing Points! A table of CFrames!")
	elseif not (type(distanceBetweenPoints) == "number" and distanceBetweenPoints > 0) then
		return Result.err("Missing DistanceBetweenPoints! A number > 0")
	elseif type(isCircuited) ~= "boolean" then
		return Result.err("Missing IsCircuited! A boolean")
	end

	-- TODO: Return all errors
	-- Maybe move to t
	for index, point in ipairs(points) do
		if typeof(point) ~= "CFrame" then
			return Result.err("Point " .. tostring(index) .. " is not a CFrame!")
		end
	end

	return Result.ok(data)
end

--- @tag Deconstructor
function PointToPointCFrameTrack:Destroy()
	self.points = nil

	CFrameTrack.Destroy(self)

	setmetatable(self, nil)
end

--- @private
function PointToPointCFrameTrack:_setData(data: PointToPointData)
	local points = data.points
	local distanceBetweenPoints = data.distanceBetweenPoints
	local isCircuited = data.isCircuited

	if isCircuited == nil then
		isCircuited = self.isCircuited
	end

	local numPoints = #points
	local length = ((numPoints - 1) * distanceBetweenPoints)
	local lengthWithoutCircuitRemainder = length
	local circuitRemainder = 0

	assert(numPoints > 0,
		"Points is empty!")

	for index, point in pairs(points) do
		assert(typeof(point) == "CFrame",
			"Point " .. tostring(index) .. " is not a CFrame!")
	end

	if isCircuited == true then
		circuitRemainder = (points[numPoints].Position - points[1].Position).Magnitude
		length = length + circuitRemainder
	end

	self.points = points
	self.distanceBetweenPoints = distanceBetweenPoints
	self.length = length
	self.circuitRemainder = circuitRemainder
	self.lengthWithoutCircuitRemainder = lengthWithoutCircuitRemainder
	self.isCircuited = isCircuited

	return self
end

--- Returns a CFrame
--- @param position number
--- @return CFrame
function PointToPointCFrameTrack:getCFrame(position: number)
	local trackLength = self.length
	local points = self.points
	local numPoints = #points
	local isCircuited = self.isCircuited

	if isCircuited == false then
		if position >= trackLength then
			local difference = position - trackLength
			local cf = points[numPoints]
			return cf * CFrame.new(0, 0, -difference)
		elseif position <= 0 then
			local cf = points[1]
			return cf * CFrame.new(0, 0, -position)
		end
	end

	local circuitRemainder = self.circuitRemainder
	local lengthWithoutCircuitRemainder = self.lengthWithoutCircuitRemainder

	local p1, p2
	local lerpValue

	position = position % trackLength

	if isCircuited == true and position >= lengthWithoutCircuitRemainder then
		if circuitRemainder == 0 then
			return points[numPoints]
		else
			p1 = points[numPoints]
			p2 = points[1]
			lerpValue = (position - lengthWithoutCircuitRemainder) / circuitRemainder
		end
	else
		local distanceBetweenPoints = self.distanceBetweenPoints
		local pIndex = math.floor(position / distanceBetweenPoints) + 1
		p1 = points[pIndex]
		p2 = points[pIndex + 1]
		lerpValue = (position % distanceBetweenPoints) / distanceBetweenPoints
	end

	return p1:Lerp(p2, lerpValue)
end

export type PointToPointCFrameTrack = typeof(PointToPointCFrameTrack.new())

return PointToPointCFrameTrack