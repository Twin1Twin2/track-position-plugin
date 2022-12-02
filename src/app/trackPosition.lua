
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local trackPositionNode = require(script.Parent.trackPositionNode)
local moveHandle = require(script.Parent.moveHandle)

local stateModule = require(script.Parent.state)

local menuStateModule = stateModule.menu
local menuStateActions = menuStateModule.actions
local MenuState = menuStateModule.MenuState

local trackPositionActions = stateModule.trackPosition.actions

local pluginActions = root.pluginActions
local focusCamera = require(pluginActions.focusCamera)

local widgets = script.Parent.widgets
local selectedText = require(widgets.selectedText)
local button = require(widgets.button)
local buttonRow = require(widgets.buttonRow)
local textInput = require(widgets.textInput)
local incrementTextInput = require(widgets.incrementTextInput)

return plasma.widget(function(store)
	local state = store:getState()

	local trackPositionState = state.trackPosition

	local currentTrackData = trackPositionState.trackData
	local currentTrackPosition = trackPositionState.trackPosition
	local currentPointIndex = trackPositionState.pointIndex

	local currentMoveHandlePosition = trackPositionState.moveHandlePosition
	local currentMoveHandleDistance = trackPositionState.moveHandleDistance

	local currentMoveIncrement = trackPositionState.moveIncrement

	local currentSnapToPoints = trackPositionState.snapToPoints
	local currentClampToLength = trackPositionState.clampToLength

	local currentIsVisible = trackPositionState.isVisible

	plasma.label("Current Track:")
	local selectedTrackName = if currentTrackData then currentTrackData.name else "[NONE]"
	selectedText(selectedTrackName)

	buttonRow(function()
		local clearTrackButton = button({
			text = "Clear Track",
			bgColor = Color3.fromRGB(183, 28, 28),
		})
		if clearTrackButton:clicked() then
			store:dispatch(trackPositionActions.setTrackData(nil))
		end

		if button("Set Track"):clicked() then
			store:dispatch(menuStateActions.setMenuState(MenuState.SelectTrack))
		end
	end)

	plasma.label("Current Position:")
	local currentPositionWidget = incrementTextInput(tostring(currentTrackPosition))

	local function setCurrentPosition(newPosition: number)
		store:dispatch(trackPositionActions.resetTrackHandlesPosition(newPosition))
	end

	currentPositionWidget:focusLost(function(input: string, enterPressed: boolean)
		if enterPressed == false then
			return
		end

		local newPosition = tonumber(input)
		if newPosition == nil then
			return
		end

		setCurrentPosition(newPosition)
	end)

	if currentPositionWidget:incrementClicked() then
		setCurrentPosition(currentTrackPosition + currentMoveIncrement)
	end

	if currentPositionWidget:decrementClicked() then
		setCurrentPosition(currentTrackPosition - currentMoveIncrement)
	end

	plasma.label("Current Index:")
	local currentIndexWidget = incrementTextInput(tostring(currentPointIndex))

	local function setPointIndex(newIndex)
		if math.floor(newIndex) ~= newIndex then
			return
		end

		store:dispatch(trackPositionActions.setPointIndex(newIndex))
	end

	currentIndexWidget:focusLost(function(input: string, enterPressed: boolean)
		if enterPressed == false then
			return
		end

		local newIndex = tonumber(input)
		if newIndex == nil then
			return
		end

		setPointIndex(newIndex)
	end)

	if currentIndexWidget:incrementClicked() then
		setPointIndex(currentPointIndex + 1)
	end

	if currentIndexWidget:decrementClicked() then
		setPointIndex(currentPointIndex - 1)
	end

	plasma.label("Move Increment:")
	local moveIncrementWidget = textInput(tostring(currentMoveIncrement))

	moveIncrementWidget:focusLost(function(input: string, enterPressed: boolean)
		if enterPressed == false then
			return
		end

		local newDistance = tonumber(input)
		if newDistance == nil then
			return
		end

		if newDistance < 0 then
			return
		end

		store:dispatch(trackPositionActions.setMoveIncrement(newDistance))
	end)

	local snapToPointsCheckbox = plasma.checkbox("Snap to Points", {
		disabled = false,
		checked = currentSnapToPoints,
	})

	if snapToPointsCheckbox:clicked() then
		store:dispatch(trackPositionActions.setSnapToPoints(not currentSnapToPoints))
	end

	local clampToLengthCheckbox = plasma.checkbox("Clamp To Length", {
		disabled = false,
		checked = currentClampToLength,
	})

	if clampToLengthCheckbox:clicked() then
		store:dispatch(trackPositionActions.setClampToLength(not currentClampToLength))
	end

	plasma.space(0)

	local isVisibleCheckbox = plasma.checkbox("Is Visible", {
		disabled = false,
		checked = currentIsVisible,
	})

	if isVisibleCheckbox:clicked() then
		store:dispatch(trackPositionActions.setIsVisible(not currentIsVisible))
	end

	plasma.space(0)

	if button("Focus Camera To Cursor"):clicked() and currentTrackData ~= nil then
		local track = currentTrackData.track
		local trackPositionCFrame = track:getCFrame(currentTrackPosition)

		focusCamera(trackPositionCFrame)
	end

	if state.pluginEnabled and currentIsVisible == true and currentTrackData ~= nil then
		-- get cframe positions
		local track = currentTrackData.track
		local trackPositionCFrame = track:getCFrame(currentTrackPosition)
		local moveHandleCFrame = track:getCFrame(currentMoveHandlePosition) * CFrame.new(0, 0, -currentMoveHandleDistance)

		trackPositionNode(trackPositionCFrame)
		moveHandle(moveHandleCFrame, currentMoveIncrement):mouseDrag(function(distance: number, mouseUp: boolean)
			local newPosition = currentMoveHandlePosition + distance

			if mouseUp == true then
				-- resetTrackHandlesPosition(newPosition)
				store:dispatch(trackPositionActions.resetTrackHandlesPosition(newPosition))
			else
				-- setCurrentTrackPosition(newPosition)
				store:dispatch(trackPositionActions.setTrackPosition(newPosition))
				-- setMoveHandleDistance(distance)
				store:dispatch(trackPositionActions.setMoveHandleDistance(distance))
			end
		end)
	end
end)