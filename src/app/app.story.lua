
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)
local rodux = require(packages.rodux)

local pluginState = require(root.pluginState)

local app = require(script.Parent.app)
local stateModule = require(script.Parent.state)

local widgets = script.Parent.widgets
local container = require(widgets.container)

return function(frame: Frame): () -> ()
	local store = rodux.Store.new(stateModule.reducer, nil, {
		-- rodux.loggerMiddleware
	})

	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_deltaTime: number)
		plasma.start(rootNode, function()
			local state = store:getState()
			local pluginEnabled = state.pluginEnabled

			container(function()
				if plasma.button("Toggle Enabled: " .. tostring(pluginEnabled)):clicked() then
					store:dispatch(pluginState.setPluginEnabled(not pluginEnabled))
				end

				plasma.space()

				if pluginEnabled then
					app(store)
				end
			end)
		end)
	end)

	return function()
		heartbeatConnection:Disconnect()

		plasma.start(rootNode, function() end)
		rootNode = nil
	end
end

