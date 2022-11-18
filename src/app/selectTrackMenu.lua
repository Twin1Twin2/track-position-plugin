
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local pluginActions = root.pluginActions
local pointsFromSelection = require(pluginActions.pointsFromSelection)

local cframeTrack = require(root.cframeTrack)
local PointToPoint2 = cframeTrack.PointToPoint2

local widgets = script.Parent.widgets
local selectedText = require(widgets.selectedText)
local button = require(widgets.button)
local acceptCancelButtons = require(widgets.acceptCancelButtons)

return plasma.widget(function(closeMenuCallback)
	local selectedPointsData, setSelectedPointsData = plasma.useState(nil)

	plasma.label("Select Track:")

	local selectedTrackText = if selectedPointsData then selectedPointsData.name else "[NONE]"

	selectedText(selectedTrackText)

	if button("Load From Points"):clicked() then
		local pointsDataResult = pointsFromSelection()
		if pointsDataResult:isErr() then
			warn(("Unable to load from points! %s"):format(pointsDataResult:unwrapErr()))
			return
		end

		local pointsData = pointsDataResult:unwrap()

		setSelectedPointsData(pointsData)
	end

	plasma.space()

	local isCircuited, setIsCircuited = plasma.useState(false)
	local isCircuitedCheckbox = plasma.checkbox("Is Circuited", {
		disabled = false,
		checked = isCircuited,
	})

	if isCircuitedCheckbox:clicked() then
		setIsCircuited(not isCircuited)
	end

	plasma.space()

	acceptCancelButtons(
		function()
			if selectedPointsData ~= nil then
				local track = PointToPoint2.new(selectedPointsData.points, nil, isCircuited)

				closeMenuCallback({
					name = selectedPointsData.name,
					track = track,
				})
			end
		end,
		function()
			closeMenuCallback(nil)
		end
	)

	plasma.space()

	return {
	}
end)