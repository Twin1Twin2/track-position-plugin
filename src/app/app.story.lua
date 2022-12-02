
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)
local rodux = require(packages.rodux)

local pluginState = require(root.pluginState)

local app = require(script.Parent.app)
local stateModule = require(script.Parent.state)

local widgets = script.Parent.widgets

local container = plasma.widget(function(fn)
	local refs = plasma.useInstance(function(ref)
		local frame = plasma.create("Frame", {
			[ref] = "containerFrame",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),

			plasma.create("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),

			plasma.create("UIListLayout", {
				[ref] = "listLayout",

				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 10),
			}),
		})

		return frame
	end)

	plasma.scope(fn)

	return refs.frame
end)

local appFrame = plasma.widget(function(fn)
	local refs = plasma.useInstance(function(ref)
		local frame = plasma.create("Frame", {
			[ref] = "containerFrame",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, -60),
		})

		return frame
	end)

	plasma.scope(fn)

	return refs.frame
end)


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
					appFrame(function()
						app(store)
					end)
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

