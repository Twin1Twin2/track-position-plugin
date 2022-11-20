
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)
local rodux = require(packages.rodux)

local app = require(script.Parent.app)
local stateModule = require(script.Parent.state)

local widgets = script.Parent.widgets
local container = require(widgets.container)

return function(frame: Frame): () -> ()
	local store = rodux.Store.new(stateModule.reducer, nil, {
		-- rodux.loggerMiddleware
	})

	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
		plasma.start(rootNode, function()
			local enabled, setEnabled = plasma.useState(false)

			container(function()
				if plasma.button("Toggle Enabled: " .. tostring(enabled)):clicked() then
					setEnabled(not enabled)
				end

				plasma.space()

				if enabled then
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

