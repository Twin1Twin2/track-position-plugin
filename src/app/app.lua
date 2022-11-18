
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local widgets = script.Parent.widgets
local selectedText = require(widgets.selectedText)
local button = require(widgets.button)
local buttonRow = require(widgets.buttonRow)
local textInput = require(widgets.textInput)

local selectTrackMenu = require(script.Parent.selectTrackMenu)

local trackPositionNode = require(script.Parent.trackPositionNode)
local moveHandle = require(script.Parent.moveHandle)
local modelPreview = require(script.Parent.modelPreview)

local pluginActions = root.pluginActions
local pvInstanceFromSelection = require(pluginActions.pvInstanceFromSelection)
local getSelection = require(pluginActions.getSelection)
local placeModel = require(pluginActions.placeModel)

local MenuState = {
	Main = 0,
	SelectTrack = 1,
	SelectModel = 2,
}

return plasma.widget(function()
	-- selected track
	local selectedTrackData, setSelectedTrackData = plasma.useState(nil)
	local selectedModel, setSelectedModel = plasma.useState(nil)
	local selectedModelParent, setSelectedModelParent = plasma.useState(workspace)

	local menuState, setMenuState = plasma.useState(MenuState.Main)

	local trackPosition, setTrackPosition = plasma.useState(0)
	local pointIndex, setPointIndex = plasma.useState(1)

	local moveHandlePosition, setMoveHandlePosition = plasma.useState(0)
	local moveHandleDistance, setMoveHandleDistance = plasma.useState(0)

	local moveIncrement, setMoveIncrement = plasma.useState(0)

	local snapToPoints, setSnapToPoints = plasma.useState(true)
	local clampToLength, setClampToLength = plasma.useState(true)

	local showPreview, setShowPreview = plasma.useState(true)

	local setCurrentTrackPosition = function(position: number)
		local newPointIndex = pointIndex

		if selectedTrackData then
			local track = selectedTrackData.track
			if clampToLength then
				position = track:clampToLength(position)
			end

			newPointIndex = track.hasher:getClosestIndex(position)

			if snapToPoints then
				position = track.hasher:getLengthData(newPointIndex)
			end
		end

		setTrackPosition(position)
		setPointIndex(newPointIndex)

		return position
	end

	local resetTrackHandlesPosition = function(position: number)
		position = position or trackPosition

		position = setCurrentTrackPosition(position)

		setMoveHandlePosition(position)
		setMoveHandleDistance(0)
	end

	local resetSnappedPosition = function()
		local position = trackPosition
		if selectedTrackData then
			local track = selectedTrackData.track
			if position < 0 then
				position = 0
			elseif position > track.length then
				position = track.length
			end
		end

		resetTrackHandlesPosition(position)
	end

	local isVisible, setIsVisible = plasma.useState(true)

	if menuState == MenuState.SelectTrack then
		selectTrackMenu(function(trackData)
			if trackData ~= nil then
				setSelectedTrackData(trackData)
			end

			setMenuState(MenuState.Main)
		end)
	else
		plasma.label("Current Track:")
		local selectedTrackName = if selectedTrackData then selectedTrackData.name else "[NONE]"
		selectedText(selectedTrackName)

		buttonRow(function()
			local clearTrackButton = button({
				text = "Clear Track",
				bgColor = Color3.fromRGB(183, 28, 28),
			})
			if clearTrackButton:clicked() then
				setSelectedTrackData(nil)
			end

			if button("Set Track"):clicked() then
				setMenuState(MenuState.SelectTrack)
			end
		end)

		plasma.label("Current Position:")
		local currentPositionWidget = textInput(tostring(trackPosition))

		currentPositionWidget:focusLost(function(input: string, enterPressed: boolean)
			if enterPressed == false then
				return
			end

			local newPosition = tonumber(input)
			if newPosition == nil then
				return
			end

			resetTrackHandlesPosition(newPosition)
		end)

		plasma.label("Current Index:")
		local currentIndexWidget = textInput(tostring(pointIndex))

		currentIndexWidget:focusLost(function(input: string, enterPressed: boolean)
			if enterPressed == false then
				return
			end

			local newIndex = tonumber(input)
			if newIndex == nil then
				return
			end

			if math.floor(newIndex) ~= newIndex then
				return
			end

			if selectedTrackData then
				local position = selectedTrackData.track.hasher:getLengthData(newIndex)
				resetTrackHandlesPosition(position)
			else
				setPointIndex(newIndex)
			end
		end)

		plasma.label("Move Increment:")
		local moveIncrementWidget = textInput(tostring(moveIncrement))

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

			setMoveIncrement(newDistance)
		end)

		local snapToPointsCheckbox = plasma.checkbox("Snap to Points", {
			disabled = false,
			checked = snapToPoints,
		})

		if snapToPointsCheckbox:clicked() then
			snapToPoints = not snapToPoints -- should only be active this frame
			setSnapToPoints(snapToPoints)

			if snapToPoints == true then
				resetSnappedPosition()
			end
		end

		local clampToLengthCheckbox = plasma.checkbox("Clamp To Length", {
			disabled = false,
			checked = clampToLength,
		})

		if clampToLengthCheckbox:clicked() then
			clampToLength = not clampToLength
			setClampToLength(clampToLength)

			if clampToLength == true then
				resetSnappedPosition()
			end
		end

		plasma.space(0)

		local isVisibleCheckbox = plasma.checkbox("Is Visible", {
			disabled = false,
			checked = isVisible,
		})

		if isVisibleCheckbox:clicked() then
			setIsVisible(not isVisible)
		end

		plasma.space(10)

		plasma.label("Current Model:")
		local selectedModelName = if selectedModel then selectedModel.Name else "[NONE]"
		selectedText(selectedModelName)

		buttonRow(function()
			local clearModelButton = button({
				text = "Clear Model",
				bgColor = Color3.fromRGB(183, 28, 28),
			})
			if clearModelButton:clicked() then
				setSelectedModel(nil)
			end

			if button("Set Model"):clicked() then
				local getSelectedResult = pvInstanceFromSelection()
				if getSelectedResult:isErr() then
					warn(("Unable to load from selection! %s"):format(getSelectedResult:unwrapErr()))
					return
				end

				local model = getSelectedResult:unwrap()

				setSelectedModel(model)
			end
		end)

		plasma.label("Current Parent:")
		local selectedModelParentName = selectedModelParent:GetFullName()
		selectedText(selectedModelParentName)

		buttonRow(function()
			local clearParentButton = button({
				text = "Clear Parent",
				bgColor = Color3.fromRGB(183, 28, 28),
			})
			if clearParentButton:clicked() then
				setSelectedModelParent(workspace)
			end

			if button("Set Parent"):clicked() then
				local getSelectedResult = getSelection()
				if getSelectedResult:isErr() then
					warn(("Unable to load from selection! %s"):format(getSelectedResult:unwrapErr()))
					return
				end

				local selection = getSelectedResult:unwrap()

				setSelectedModelParent(selection)
			end
		end)

		local showPreviewCheckbox = plasma.checkbox("Show Preview", {
			disabled = false,
			checked = showPreview,
		})

		if showPreviewCheckbox:clicked() then
			setShowPreview(not showPreview)
		end

		plasma.space(10)

		buttonRow({
			height = 48,
			alignment = Enum.HorizontalAlignment.Center
		}, function()
			local buttonWidget = button({
				text = "BUILD",
				height = 48,
				bgColor = Color3.fromRGB(0, 170, 255),
				paddingLeft = 40,
				paddingRight = 40,
			})

			if buttonWidget:clicked() and selectedModel and selectedTrackData then
				local track = selectedTrackData.track
				local trackPositionCFrame = track:getCFrame(trackPosition)

				placeModel(selectedModel, trackPositionCFrame, selectedModelParent)
			end
		end)

		plasma.space(10)
	end

	if isVisible == true and selectedTrackData ~= nil then
		-- get cframe positions
		local track = selectedTrackData.track
		local trackPositionCFrame = track:getCFrame(trackPosition)
		local moveHandleCFrame = track:getCFrame(moveHandlePosition) * CFrame.new(0, 0, -moveHandleDistance)

		trackPositionNode(trackPositionCFrame)
		moveHandle(moveHandleCFrame, moveIncrement):mouseDrag(function(distance: number, mouseUp: boolean)
			local newPosition = moveHandlePosition + distance

			if mouseUp == true then
				resetTrackHandlesPosition(newPosition)
			else
				setCurrentTrackPosition(newPosition)
				setMoveHandleDistance(distance)
			end
		end)

		if showPreview and selectedModel ~= nil then
			modelPreview(selectedModel, trackPositionCFrame)
		end
	end
end)