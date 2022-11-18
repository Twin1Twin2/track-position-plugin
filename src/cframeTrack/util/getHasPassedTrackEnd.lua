
local root = script.Parent.Parent.Parent

local modules = root.modules
local Option = require(modules.Option)

--- Returns the direction which the given position passes the end of the track line.
--- Also returns the clamped position. See clampToTrackLength for more info.
--- @function getHasPassedTrackEnd
--- @within CFrameTrackModule
--- @param position number
--- @param length number
--- @param isCircuited boolean?
--- @return Option<boolean> -- Direction position passed track end
--- @return number -- resulting clamped position
return function(position: number, length: number, isCircuited: boolean?): (Option.Option, number)
	if isCircuited == nil then
		isCircuited = false
	end

	if isCircuited == false and position == length then
		return Option.none(), length
	end

	if position < 0 then
		return Option.some(false), position % length
	elseif position >= length then
		return Option.some(true), position % length
	else
		return Option.none(), position
	end
end
