
local root = script.Parent.Parent
local packages = root.packages
local rodux = require(packages.rodux)

local pluginState = require(root.pluginState)

local menu = require(script.menu)
local trackPosition = require(script.trackPosition)
local model = require(script.model)

local module = {}

module.menu = menu
module.trackPosition = trackPosition
module.model = model

local reducer = rodux.combineReducers({
	pluginEnabled = pluginState.reducer,

	menu = menu.reducer,
	trackPosition = trackPosition.reducer,
	model = model.reducer,
})

module.reducer = reducer

return module