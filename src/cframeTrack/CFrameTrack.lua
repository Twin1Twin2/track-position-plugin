--!strict

local root = script.Parent.Parent

local modules = root.modules
local Option = require(modules.Option)

local cframeTrackUtil = script.Parent.util
local clampToTrackLength = require(cframeTrackUtil.clampToTrackLength)
local getHasPassedTrackEnd = require(cframeTrackUtil.getHasPassedTrackEnd)

--- @class CFrameTrack
--- Defines a track

--- @prop name string
--- @within CFrameTrack
--- @readonly

--- @prop length number
--- @within CFrameTrack
--- @readonly

--- @prop isCircuited boolean
--- @within CFrameTrack
--- @readonly

local CFrameTrack = {}
CFrameTrack.__index = CFrameTrack
CFrameTrack.ClassName = "CFrameTrack"

--- Constructor for CFrameTrack
--- @return CFrameTrack
--- @tag Constructor
function CFrameTrack.new()
	local self = setmetatable({}, CFrameTrack)

	self.length = 0
	self.isCircuited = false

	return self
end

--- Constructor.
--- Constructs a CFrameTrack from an Instance
--- @tag Constructor
--- @param _instance Instance
--- @error "Not Implemented"
function CFrameTrack.fromInstance(_instance: Instance)
	error("fromInstance() is not implemented!")
end

--- Deconstructor
--- @tag Deconstructor
function CFrameTrack:Destroy()
	setmetatable(self, nil)
end

--- Clamps the given position to this track's length
--- @param position number
--- @return any
function CFrameTrack:clampToLength(position: number): number
	return clampToTrackLength(position, self.length, self.isCircuited)
end

--- Returns the direction which the given position passes the end of the track line.
--- Also returns the clamped position. See clampToTrackLength for more info.
--- @param position number
--- @return Option<boolean>
--- @return number
function CFrameTrack:hasPassedEnd(position: number): (Option.Option, number)
	return getHasPassedTrackEnd(position, self.length, self.isCircuited);
end

--- Returns a CFrame from the given track position
--- @param _position number
--- @return CFrame
function CFrameTrack:getCFrame(_position: number): CFrame
	return CFrame.new()
end

export type CFrameTrack = typeof(CFrameTrack.new())

return CFrameTrack