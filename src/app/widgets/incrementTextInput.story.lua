
local RunService = game:GetService("RunService")

local root = script.Parent.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local container = require(script.Parent.container)
local incrementTextInput = require(script.Parent.incrementTextInput)

return function(frame: Frame): () -> ()
	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_deltaTime: number)
		plasma.start(rootNode, function()
			local currentInput, setCurrentInput = plasma.useState(0)
			local function setNewCurrentInput(input: string)
				local newValue = tonumber(input)
				if newValue == nil then
					return
				end

				setCurrentInput(newValue)
			end

			container(function()
				local widget = incrementTextInput(tostring(currentInput))

				widget:focusLost(function(input: string, enterPressed: boolean)
					if enterPressed == false then
						return
					end

					setNewCurrentInput(input)
				end)

				if widget:incrementClicked() then
					setCurrentInput(currentInput + 1)
				end

				if widget:decrementClicked() then
					setCurrentInput(currentInput - 1)
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