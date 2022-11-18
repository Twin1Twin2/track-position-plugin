
local CFrameTrack = require(script.Parent.CFrameTrack)

local TrackDataHasher = require(script.Parent.TrackDataHasher)

local root = script.Parent.Parent

local modules = root.modules
local Result = require(modules.Result)

local pointsUtil = require(root.pointsUtil)
local pointsFromInstance = pointsUtil.getCFramePointsFromInstance

--- A line with points of spaced with varying distances
--- @class PointToPoint2CFrameTrack

--- @prop isCircuited boolean
--- @within PointToPoint2CFrameTrack

--- @prop circuitRemainder number
--- @within PointToPoint2CFrameTrack

--- @prop lengthWithoutCircuitRemainder boolean
--- @within PointToPoint2CFrameTrack

--- @interface PointToPoint2Data
--- @within PointToPoint2CFrameTrack
--- .points {CFrame}
--- .isCircuited boolean
--- .hashInterval number

export type PointToPoint2Data = {
	points: {CFrame},
	isCircuited: boolean,
	hashInterval: number,
}

local PointToPoint2CFrameTrack = {}
PointToPoint2CFrameTrack.__index = PointToPoint2CFrameTrack
setmetatable(PointToPoint2CFrameTrack, CFrameTrack)
PointToPoint2CFrameTrack.ClassName = "PointToPoint2CFrameTrack"

--- Constructor
--- @tag Constructor
--- @return PointToPoint2CFrameTrack
function PointToPoint2CFrameTrack.new(points: {CFrame}, hashInterval: number?, isCircuited: boolean?)
	if isCircuited == nil then
		isCircuited = false
	end

	local getLengthFunction = function(p1, p2)
		return (p1.Position - p2.Position).Magnitude
	end

	local hasher = TrackDataHasher.create(
		points,
		getLengthFunction,
		hashInterval
	)

	local length = hasher.length
	local circuitRemainder = 0
	local lengthWithoutCircuitRemainder = length

	if isCircuited == true then
		circuitRemainder = getLengthFunction(
			points[#points],
			points[1]
		)

		length = length + circuitRemainder
	end

	local self = setmetatable(CFrameTrack.new(), PointToPoint2CFrameTrack)

	self.hasher = hasher
	self.length = length

	self.isCircuited = isCircuited
	self.circuitRemainder = circuitRemainder
	self.lengthWithoutCircuitRemainder = lengthWithoutCircuitRemainder

	return self
end

--- Constructor
--- @tag Constructor
--- @param instance Instance
--- @return Result<PointToPoint2CFrameTrack, string>
function PointToPoint2CFrameTrack.fromInstance(instance: Instance)
	if typeof(instance) ~= "Instance" then
		return Result.err("Arg [1] is not an Instance!")
	end

	local data

	if instance:IsA("ModuleScript") then
		-- TODO: require moduleScript here then check table
		local dataResult = PointToPoint2CFrameTrack.getDataFromModuleScript(instance)
		if dataResult:isErr() then
			return Result.err(("Unable to convert track from ModuleScript: %s"):format(dataResult:unwrapErr()))
		end
	
		data = dataResult:unwrap()
	else -- model
		local dataResult = PointToPoint2CFrameTrack.getDataFromModel(instance)
		if dataResult:isErr() then
			return Result.err(("Unable to convert track from Model: %s"):format(dataResult:unwrapErr()))
		end

		data = dataResult:unwrap()
	end

	local points = data.points
	local hashInterval = data.hashInterval
	local isCircuited = data.isCircuited

	local newTrack = PointToPoint2CFrameTrack.new(points, hashInterval, isCircuited)

	return Result.ok(newTrack)
end

--- Gets data from a Model
--- @tag Constructor
--- @param instance Instance
--- @return Result<PointToPoint2Data, string>
function PointToPoint2CFrameTrack.getDataFromModel(instance: Instance)
	if typeof(instance) ~= "Instance" then
		return Result.err("Arg [1] is not an Instance!")
	end

	local pointsData = instance:FindFirstChild("Points")
	local isCircuitedValue = instance:FindFirstChild("IsCircuited")
	local hashIntervalValue = instance:FindFirstChild("HashInterval")

	if pointsData == nil then
		return Result.err("Missing Points! An Instance!")
	elseif not (isCircuitedValue ~= nil and isCircuitedValue:IsA("BoolValue")) then
		return Result.err("Missing IsCircuited! A BoolValue")
	end

	local hashInterval = 10

	if hashIntervalValue ~= nil then
		if hashIntervalValue:IsA("NumberValue") == false then
			return Result.err("Missing HashInterval! A NumberValue")
		end

		hashInterval = hashIntervalValue.Value

		if not (type(hashInterval) == "number" and hashInterval > 0) then
			return Result.err("HashInterval is not a number > 0!")
		end
	end

	local pointsResult = pointsFromInstance(pointsData)
	if pointsResult:isErr() then
		return pointsResult
	end

	return Result.ok({
		points = pointsResult:unwrap();
		isCircuited = isCircuitedValue.Value;
		hashInterval = hashInterval;
	})
end

function PointToPoint2CFrameTrack.getDataFromModuleScript(moduleScript)
	if not (typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript")) then
		return Result.err("Arg [1] is not a ModuleScript!")
	end

	local data = require(moduleScript)
	if type(data) ~= "table" then
		return Result.err("ModuleScript did not return a table!")
	end

	local points = data.points
	local isCircuited = data.isCircuited
	local hashInterval = data.hashInterval

	if type(points) ~= "table" then
		return Result.err("Missing Points! A table")
	elseif type(isCircuited) ~= "boolean" then
		return Result.err("Missing IsCircuited! A boolean")
	elseif not (type(hashInterval) == "number" and hashInterval > 0) then
		return Result.err("Missing HashInterval! A number > 0")
	end

	for index, point in pairs(points) do
		if typeof(point) ~= "CFrame" then
			return Result.err("Point " .. tostring(index) .. " is not a CFrame!")
		end
	end

	return Result.ok(data)
end

--- @private
function PointToPoint2CFrameTrack:Destroy()
	self.hasher:Destroy()

	CFrameTrack.Destroy(self)

	setmetatable(self, nil)
end

--- Gets the CFrame at the given position on the track
--- @return CFrame
function PointToPoint2CFrameTrack:getCFrame(position: number): CFrame
	local hasher = self.hasher
	local circuited = self.isCircuited
	local lengthWithoutCircuitRemainder = self.lengthWithoutCircuitRemainder

	if circuited == true then -- clamp position to track length
		position = self:clampToLength(position)
	end

	if circuited == true and position >= lengthWithoutCircuitRemainder then
		local points = hasher.trackData
		local p1 = points[#points]
		local p2 = points[1]
		local lerpValue = (position - lengthWithoutCircuitRemainder) / self.circuitRemainder

		return p1:Lerp(p2, lerpValue)
	end

	local p1, p2, difference = hasher:getData(position)

	if p1 == nil then -- position is <= 0
		return p2 * CFrame.new(0, 0, -difference)
	elseif p2 == nil then -- position is >= trackLength
		return p1 * CFrame.new(0, 0, -difference)
	else
		local lerpValue = 0
		local magnitude = hasher.getLengthFunction(p1, p2)

		if magnitude ~= 0 then
			lerpValue = difference / hasher.getLengthFunction(p1, p2)
		end

		return p1:Lerp(p2, lerpValue)
	end
end

return PointToPoint2CFrameTrack