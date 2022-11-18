
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local widgets = script.Parent.widgets
local scrollingFrame = require(widgets.scrollingFrame)

local selectTrackMenu = require(script.Parent.selectTrackMenu)

return function(frame: Frame): () -> ()
	local rootNode = plasma.new(frame)

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_deltaTime: number)
		plasma.start(rootNode, function()
			scrollingFrame(function()
				selectTrackMenu(function(trackData)
					if trackData then
						print("Closing menu with track: " .. trackData.name .. "; Length = " .. tostring(trackData.track.length))
					else
						print("Closing menu!")
					end
				end)
			end)
		end)
	end)

	return function()
		heartbeatConnection:Disconnect()

		plasma.start(rootNode, function() end)
		rootNode = nil -- remove node state
	end
end