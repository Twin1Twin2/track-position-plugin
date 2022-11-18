
local CoreGui = game:GetService("CoreGui")

local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

return plasma.widget(function(cframe: CFrame)
	plasma.portal(CoreGui, function()
		local refs = plasma.useInstance(function(ref)
			return plasma.create("Part", {
				[ref] = "trackPositionAdornee",

				Size = Vector3.new(1, 1, 2),
				Transparency = 1,
				Archivable = false,
				Locked = true,
				-- Parent = CoreGui

				plasma.create("SphereHandleAdornment", {
					[ref] = "trackNodeHandle",

					Archivable = false,
					Color3 = Color3.fromRGB(255, 255, 0),
					Radius = 1,
					AlwaysOnTop = true,
				}),

				plasma.create("ConeHandleAdornment", {
					[ref] = "trackDirectionHandle",

					Archivable = false,
					Color3 = Color3.fromRGB(255, 255, 0),
					Height = 4,
					Radius = 1,
					AlwaysOnTop = true,
				}),
			})
		end)

		local trackPositionAdornee = refs.trackPositionAdornee
		trackPositionAdornee.CFrame = cframe

		local trackNodeHandle = refs.trackNodeHandle
		trackNodeHandle.Adornee = trackPositionAdornee

		local trackDirectionHandle = refs.trackDirectionHandle
		trackDirectionHandle.Adornee = trackPositionAdornee

		return trackPositionAdornee
	end)
end)