
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local app = require(script.Parent.app)

local widgets = script.Parent.widgets
local scrollingFrame = require(widgets.scrollingFrame)

return function(frame: Frame): () -> ()
	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
		plasma.start(rootNode, function()
			scrollingFrame(function()
				app()
			end)
		end)
	end)

	return function()
		heartbeatConnection:Disconnect()

		plasma.start(rootNode, function() end)
		rootNode = nil
	end
end

