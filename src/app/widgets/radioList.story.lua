
local RunService = game:GetService("RunService")

local root = script.Parent.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local container = require(script.Parent.container)

local radioList = require(script.Parent.radioList)

return function(frame: Frame): () -> ()
	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_deltaTime: number)
		plasma.start(rootNode, function()
			local list = {
				"First",
				"Second",
				"Third",
				"Fourth",
				"Fifth"
			}
			local currentSelection, setCurrentSelection = plasma.useState(list[1])

			container(function()
				local selection = radioList(list, currentSelection):selected()
				if selection then
					print("Selected", selection)
					setCurrentSelection(selection)
				end
			end)
		end)
	end)

	return function()
		heartbeatConnection:Disconnect()

		plasma.start(rootNode, function() end)
		rootNode = nil -- remove node state
	end
end