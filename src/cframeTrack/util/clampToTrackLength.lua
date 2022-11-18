
--- Clamps the given position in range of [0, length]
--- Includes length unlike modulus.
--- @function clampToTrackLength
--- @within CFrameTrackModule
--- @param position number
--- @param length number
--- @return number -- resulting position
return function(position: number, length: number, isCircuited: boolean?)
	if isCircuited == nil then
		isCircuited = false
	end

	if isCircuited == false and position == length then
		return position
	end

	return position % length
end