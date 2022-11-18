--!strict

local CFrameTrack = require(script.CFrameTrack)
local PointToPoint = require(script.PointToPoint)
local PointToPoint2 = require(script.PointToPoint2)

local trackUtil = script.util
local clampToTrackLength = require(trackUtil.clampToTrackLength)
local getHasPassedTrackEnd = require(trackUtil.getHasPassedTrackEnd)

local root = script.Parent

local modules = root.modules
local Result = require(modules.Result)

local util = root.util
local getValueObjectValue = require(util.getValueObjectValue)

--- Module for CFrameTrack
--- @class CFrameTrackModule

local module = {}

--- Clamps the given position in range of [0, length]
--- Includes length unlike modulus.
--- @function clampToTrackLength
--- @within CFrameTrackModule
--- @param position number
--- @param track CFrameTrack
--- @return number -- resulting position
module.clampToTrackLength = clampToTrackLength

--- Returns the direction which the given position passes the end of the track line.
--- Also returns the clamped position. See clampToTrackLength for more info.
--- @function getHasPassedTrackEnd
--- @within CFrameTrackModule
--- @param position number
--- @param length number
--- @param isCircuited boolean?
--- @return Option<boolean> -- Direction position passed track end
--- @return number -- resulting clamped position
module.getHasPassedTrackEnd = getHasPassedTrackEnd

--- @prop CFrameTrack CFrameTrack
--- @within CFrameTrackModule
module.CFrameTrack = CFrameTrack

--- @prop PointToPointCFrameTrack PointToPointCFrameTrack
--- @within CFrameTrackModule
module.PointToPoint = PointToPoint

--- @prop PointToPoint2CFrameTrack PointToPoint2CFrameTrack
--- @within CFrameTrackModule
module.PointToPoint2 = PointToPoint2

local trackClasses = {
	PointToPoint = PointToPoint,
	PointToPoint2 = PointToPoint2,
}

--- Creates a CFrameTrack from an Instance.
--- Returns a Result.
---
--- - Instance must have a `StringValue` named `TrackClass`!
---
--- #### Valid TrackClasses
--- | Name | ClassName |
--- | ---------- | -------- |
--- | `PointToPoint` | PointToPointCFrameTrack |
--- | `PointToPoint2` | PointToPoint2CFrameTrack |
---
--- @function createFromInstance
--- @within CFrameTrackModule
--- @param instance Instance
--- @return Result<CFrameTrack, string>
module.createFromInstance = function(instance: Instance): Result.Result
	if typeof(instance) ~= "Instance" then
		return Result.err("Arg [1] is not an Instance!")
	end

	local trackClassNameResult = getValueObjectValue(instance, "TrackClass", "StringValue")
	if trackClassNameResult:isErr() then
		return Result.err(("Unable to get TrackClass: %s"):format(trackClassNameResult:unwrapErr()))
	end

	local trackClassName = trackClassNameResult:unwrap()
	local trackClass = trackClasses[trackClassName]
	if trackClass == nil then
		return Result.err(("Invalid TrackClass: %s"):format(trackClassName))
	end

	return trackClass.fromInstance(instance)
end

return module