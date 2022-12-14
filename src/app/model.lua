
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local stateModule = require(script.Parent.state)
local modelActions = stateModule.model.actions

local widgets = script.Parent.widgets
local selectedText = require(widgets.selectedText)
local button = require(widgets.button)
local buttonRow = require(widgets.buttonRow)
local radioList = require(widgets.radioList)

local modelPreview = require(script.Parent.modelPreview)

local pluginActions = root.pluginActions
local pvInstanceFromSelection = require(pluginActions.pvInstanceFromSelection)
local getSelection = require(pluginActions.getSelection)

local positionModel = require(pluginActions.positionModel)
local PositionModelType = positionModel.PositionModelType
local PositionModelTypeNames = positionModel.PositionModelTypeNames

local placeModel = require(pluginActions.placeModel)

return plasma.widget(function(store)
	local state = store:getState()

	local modelState = state.model

	local currentModel = modelState.model
	local currentModelParent = modelState.modelParent

	local showPreview = modelState.showPreview

	local positionModelTypeName = modelState.positionModelType

	local trackPositionState = state.trackPosition

	local currentTrackData = trackPositionState.trackData
	local currentTrackPosition = trackPositionState.trackPosition

	local currentIsVisible = trackPositionState.isVisible


	plasma.label("Current Model:")
	local currentModelName = if currentModel then currentModel.Name else "[NONE]"
	selectedText(currentModelName)

	buttonRow(function()
		local clearModelButton = button({
			text = "Clear Model",
			bgColor = Color3.fromRGB(183, 28, 28),
		})
		if clearModelButton:clicked() then
			store:dispatch(modelActions.setModel(nil))
		end

		if button("Set Model"):clicked() then
			local getSelectedResult = pvInstanceFromSelection()
			if getSelectedResult:isErr() then
				warn(("Unable to load from selection! %s"):format(getSelectedResult:unwrapErr()))
				return
			end

			local model = getSelectedResult:unwrap()

			store:dispatch(modelActions.setModel(model))
		end
	end)

	plasma.label("Current Parent:")
	local currentModelParentName = currentModelParent:GetFullName()
	selectedText(currentModelParentName)

	buttonRow(function()
		local clearParentButton = button({
			text = "Clear Parent",
			bgColor = Color3.fromRGB(183, 28, 28),
		})
		if clearParentButton:clicked() then
			store:dispatch(modelActions.setModelParent(workspace))
		end

		if button("Set Parent"):clicked() then
			local getSelectedResult = getSelection()
			if getSelectedResult:isErr() then
				warn(("Unable to load from selection! %s"):format(getSelectedResult:unwrapErr()))
				return
			end

			local selection = getSelectedResult:unwrap()

			store:dispatch(modelActions.setModelParent(selection))
		end
	end)

	local showPreviewCheckbox = plasma.checkbox("Show Preview", {
		disabled = false,
		checked = showPreview,
	})

	if showPreviewCheckbox:clicked() then
		store:dispatch(modelActions.setShowPreview(not showPreview))
	end

	plasma.label("Position Type:")

	local positionTypeNameRadioList = radioList(PositionModelTypeNames, positionModelTypeName)
	local positionTypeNameSelection = positionTypeNameRadioList:selected()
	if positionTypeNameSelection then
		store:dispatch(modelActions.setPositionModelType(positionTypeNameSelection))
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

		if buttonWidget:clicked() and currentModel and currentTrackData then
			local track = currentTrackData.track
			local trackPositionCFrame = track:getCFrame(currentTrackPosition)

			placeModel(
				currentModel,
				trackPositionCFrame,
				PositionModelType[positionModelTypeName],
				currentModelParent
			)
		end
	end)

	if currentIsVisible == true and currentTrackData ~= nil then
		-- get cframe positions
		local track = currentTrackData.track
		local trackPositionCFrame = track:getCFrame(currentTrackPosition)

		if showPreview and currentModel ~= nil then
			modelPreview(currentModel, trackPositionCFrame, PositionModelType[positionModelTypeName])
		end
	end

	plasma.space(10)
end)