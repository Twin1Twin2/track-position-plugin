
local packages = script.Parent.packages
local rodux = require(packages.rodux)

local module = {}

module.setPluginEnabled = rodux.makeActionCreator("SetPluginEnabled", function(pluginEnabled: number)
	return {
		pluginEnabled = pluginEnabled,
	}
end)

module.reducer = rodux.createReducer(false, {
	SetPluginEnabled = function(_state: number, action)
		return action.pluginEnabled
	end
})

return module