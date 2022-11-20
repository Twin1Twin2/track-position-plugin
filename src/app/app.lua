
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local stateModule = require(script.Parent.state)

local menuStateModule = stateModule.menu
local menuStateActions = menuStateModule.actions
local MenuState = menuStateModule.MenuState

local trackPositionActions = stateModule.trackPosition.actions

local widgets = script.Parent.widgets
local scrollingFrame = require(widgets.scrollingFrame)

local menu = require(script.Parent.menu)
local selectTrackMenu = require(script.Parent.selectTrackMenu)

local app = plasma.widget(function(store)
	local state = store:getState()
	local menuState = state.menu

	if menuState == MenuState.SelectTrack then
		selectTrackMenu(function(trackData)
			if trackData ~= nil then
				store:dispatch(trackPositionActions.setTrackData(trackData))
			end

			store:dispatch(menuStateActions.setMenuState(MenuState.Main))
		end)
	else
		menu(store)
	end
end)

return plasma.widget(function(store)
	return scrollingFrame(function()
		app(store)
	end)
end)