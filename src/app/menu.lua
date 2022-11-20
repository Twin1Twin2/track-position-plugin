
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local trackPosition = require(script.Parent.trackPosition)
local model = require(script.Parent.model)

return plasma.widget(function(store)
	trackPosition(store)
	model(store)
end)