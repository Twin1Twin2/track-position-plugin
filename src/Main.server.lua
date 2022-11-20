
local DockWidgetHandler = require(script.Parent.DockWidgetHandler)

local app = script.Parent.app
local appWidget = require(app.app)
local appState = require(app.state)

local toolbar = plugin:CreateToolbar("TrackPosition Plugin")

local pluginButton = toolbar:CreateButton("Show UI", "", "", "")
pluginButton.ClickableWhenViewportHidden = true
DockWidgetHandler.new(
	plugin,
	pluginButton,
	"Track Position Plugin",
	"Track Position Plugin",
	appWidget,
	appState.reducer
)
