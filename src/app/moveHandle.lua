
local CoreGui = game:GetService("CoreGui")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

return plasma.widget(function(cframe: CFrame, snapIncrement: number)
	snapIncrement = snapIncrement or 0

	local mouseUp, setMouseUp = plasma.useState(false)
	local isDragging, setIsDragging = plasma.useState(false)
	local distanceDragged, setDistanceDragged = plasma.useState(0)

	plasma.portal(CoreGui, function()
		local refs = plasma.useInstance(function(ref)
			return plasma.create("Part", {
				[ref] = "moveHandleAdornee",

				Size = Vector3.new(1, 1, 2),
				Transparency = 1,
				Archivable = false,
				Locked = true,

				plasma.create("Handles", {
					[ref] = "moveHandles",

					Archivable = false,
					Color3 = Color3.fromRGB(255, 0, 0),
					Faces = Faces.new(Enum.NormalId.Front, Enum.NormalId.Back),
					Style = Enum.HandlesStyle.Movement,

					MouseButton1Down = function()
						-- self.handles.Faces = Faces.new(face)
						setIsDragging(true)
					end,

					MouseButton1Up = function()
						-- reset faces
						-- self.handles.Faces = Faces.new(Enum.NormalId.Front, Enum.NormalId.Back)

						setIsDragging(false)
						setMouseUp(true)

						-- self:_resetHandles()
					end,

					MouseDrag = function(face: Enum.NormalId, distance: number)
						-- update current track position cframe
						-- position handles X distance from current
						if face == Enum.NormalId.Back then
							distance = -distance
						end

						-- snap to grid
						local moveHandles = ref.moveHandles :: Handles
						local currentSnapIncrement = moveHandles:GetAttribute("SnapIncrement") or snapIncrement

						if currentSnapIncrement >= 0.01 then -- values < 0.01 mean snap is turned off
							local absDistance = math.abs(distance)
							local remainder = absDistance % currentSnapIncrement

							distance = (absDistance - remainder) * math.sign(distance)
						end

						setDistanceDragged(distance)
					end,
				}),
			})
		end)

		local moveHandleAdornee = refs.moveHandleAdornee :: Part
		moveHandleAdornee.CFrame = cframe

		local moveHandles = refs.moveHandles :: Handles
		moveHandles.Adornee = moveHandleAdornee

		plasma.useEffect(function()
			moveHandles:SetAttribute("SnapIncrement", snapIncrement)
		end, snapIncrement)

		return moveHandleAdornee
	end)

	return {
		mouseDrag = function(_self, callback: (distance: number, mouseUp: boolean) -> ())
			if isDragging == false and mouseUp == false then
				return
			end

			local currentDistanceDragged = distanceDragged
			local currentMouseUp = mouseUp

			if mouseUp then
				setMouseUp(false)
				setDistanceDragged(0)
			end

			callback(currentDistanceDragged, currentMouseUp)
		end,
	}
end)