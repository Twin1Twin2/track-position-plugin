
local root = script.Parent.Parent.Parent
local packages = root.packages
local rodux = require(packages.rodux)

local modules = root.modules
local tableUtil = require(modules.tableUtil)

local module = {}
local actions = {}
local actionHandlers = {}

local MenuState = {
	Main = 0,
	SelectTrack = 1,
	SelectModel = 2,
}

module.MenuState = MenuState

local initialState = MenuState.Main

actions.setMenuState = rodux.makeActionCreator("SetMenuState", function(menuState: number)
	return {
		menuState = menuState,
	}
end)

actionHandlers.SetMenuState = function(_state: number, action)
	return action.menuState
end

-- reducer
local reducer = rodux.createReducer(
	initialState,
	actionHandlers
)

module.reducer = reducer
module.actions = actions

return module