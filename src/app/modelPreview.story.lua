
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local modelPreview = require(script.Parent.modelPreview)

return function(frame: Frame): () -> ()
	local rootNode = plasma.new(frame)

	local testModel = Instance.new("Part")
	testModel.Anchored = true
	testModel.Size = Vector3.new(4, 4, 4)
	testModel.Name = "TestModel"

	local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
		plasma.start(rootNode, function()
			modelPreview(testModel, CFrame.new())
		end)
	end)

	return function()
		testModel:Destroy()

		heartbeatConnection:Disconnect()

		plasma.start(rootNode, function() end)
		rootNode = nil
	end
end

