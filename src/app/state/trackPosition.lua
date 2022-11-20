
local root = script.Parent.Parent.Parent
local packages = root.packages
local rodux = require(packages.rodux)

local modules = root.modules
local tableUtil = require(modules.tableUtil)

local module = {}
local actions = {}
local actionHandlers = {}

export type TrackPositionState = {
	trackData: table | nil,

	trackPosition: number,
	pointIndex: number,

	moveHandlePosition: number,
	moveHandleDistance: number,

	moveIncrement: number,

	snapToPoints: number,
	clampToLength: number,

	isVisible: boolean,
}

local initialState = {
	trackData = nil,

	trackPosition = 0,
	pointIndex = 1,

	moveHandlePosition = 0,
	moveHandleDistance = 0,

	moveIncrement = 0,

	snapToPoints = true,
	clampToLength = true,

	isVisible = true,
}

-- SetTrackData
actions.setTrackData = rodux.makeActionCreator("SetTrackData", function(trackData: table | nil)
	return {
		trackData = trackData,
	}
end)

actionHandlers.SetTrackData = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.trackData = action.trackData

	return state
end

-- SetTrackPosition
actions.setTrackPosition = rodux.makeActionCreator("SetTrackPosition", function(trackPosition: number)
	return {
		trackPosition = trackPosition,
	}
end)

actionHandlers.SetTrackPosition = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	local trackData = state.trackData
	local pointIndex = state.pointIndex

	local trackPosition = action.trackPosition

	if trackData then
		local track = trackData.track

		local clampToLength = state.clampToLength
		local snapToPoints = state.snapToPoints

		if clampToLength then
			trackPosition = track:clampToLength(trackPosition)
		end

		pointIndex = track.hasher:getClosestIndex(trackPosition)

		if snapToPoints then
			trackPosition = track.hasher:getLengthData(pointIndex)
		end
	end

	state.trackPosition = trackPosition
	state.pointIndex = pointIndex

	return state
end

-- SetPointIndex
actions.setPointIndex = rodux.makeActionCreator("SetPointIndex", function(pointIndex: number)
	return {
		pointIndex = pointIndex,
	}
end)

actionHandlers.SetPointIndex = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	local trackData = state.trackData

	local pointIndex = action.pointIndex

	if trackData then
		local trackPosition = trackData.track.hasher:getLengthData(pointIndex)

		return actionHandlers.ResetTrackHandlesPosition(
			state,
			actions.resetTrackHandlesPosition(trackPosition)
		)
	else
		state.pointIndex = pointIndex

		return state
	end
end

-- SetMoveHandleDistance
actions.setMoveHandleDistance = rodux.makeActionCreator("SetMoveHandleDistance", function(moveHandleDistance: number)
	return {
		moveHandleDistance = moveHandleDistance,
	}
end)

actionHandlers.SetMoveHandleDistance = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.moveHandleDistance = action.moveHandleDistance

	return state
end

-- ResetTrackHandlesPosition
actions.resetTrackHandlesPosition = rodux.makeActionCreator("ResetTrackHandlesPosition", function(trackPosition: number)
	return {
		trackPosition = trackPosition or nil,
	}
end)

actionHandlers.ResetTrackHandlesPosition = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	local trackPosition = action.trackPosition or state.trackPosition

	state = actionHandlers.SetTrackPosition(
		state,
		actions.setTrackPosition(trackPosition)
	)

	state.moveHandlePosition = state.trackPosition
	state.moveHandleDistance = 0

	return state
end

-- ResetSnappedPosition
actions.resetSnappedPosition = rodux.makeActionCreator("ResetSnappedPosition", function()
	return {}
end)

actionHandlers.ResetSnappedPosition = function(state: TrackPositionState, _action)
	state = state or tableUtil.copy(initialState)

	local trackData = state.trackData
	local trackPosition = state.trackPosition

	if trackData then
		local track = trackData.track
		if trackPosition < 0 then
			trackPosition = 0
		elseif trackPosition > track.length then
			trackPosition = track.length
		end
	end

	return actionHandlers.resetTrackHandlesPosition(trackPosition)
end

-- SetMoveIncrement
actions.setMoveIncrement = rodux.makeActionCreator("SetMoveIncrement", function(moveIncrement: boolean)
	return {
		moveIncrement = moveIncrement,
	}
end)

actionHandlers.SetMoveIncrement = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.moveIncrement = action.moveIncrement

	return state
end

-- SetSnapToPoints
actions.setSnapToPoints = rodux.makeActionCreator("SetSnapToPoints", function(snapToPoints: boolean)
	return {
		snapToPoints = snapToPoints,
	}
end)

actionHandlers.SetSnapToPoints = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.snapToPoints = action.snapToPoints

	if state.snapToPoints == true then
		return actionHandlers.ResetSnappedPosition(
			state,
			actions.resetSnappedPosition()
		)
	end

	return state
end

-- SetClampToLength
actions.setClampToLength = rodux.makeActionCreator("SetClampToLength", function(clampToLength: boolean)
	return {
		clampToLength = clampToLength,
	}
end)

actionHandlers.SetClampToLength = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.clampToLength = action.clampToLength

	if state.clampToLength == true then
		return actionHandlers.ResetSnappedPosition(
			state,
			actions.resetSnappedPosition()
		)
	end

	return state
end

-- SetIsVisible
actions.setIsVisible = rodux.makeActionCreator("SetIsVisible", function(isVisible: boolean)
	return {
		isVisible = isVisible,
	}
end)

actionHandlers.SetIsVisible = function(state: TrackPositionState, action)
	state = state or tableUtil.copy(initialState)

	state.isVisible = action.isVisible

	return state
end

module.actions = actions

-- reducer
local reducer = rodux.createReducer(
	initialState,
	actionHandlers
)

module.reducer = reducer

return module