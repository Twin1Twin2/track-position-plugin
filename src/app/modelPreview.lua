
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

return plasma.widget(function(model: Model, cframe: CFrame)
	plasma.portal(workspace.CurrentCamera, function()
		local refs = plasma.useInstance(function(ref)
			local clonedModel = model:Clone()
			clonedModel.Archivable = false

			if clonedModel:IsA("BasePart") then
				clonedModel.Locked = true
			end

			for _, child in ipairs(clonedModel:GetDescendants()) do
				if child:IsA("BasePart") then
					child.Locked = true
				end
			end

			ref.model = clonedModel

			return clonedModel
		end)

		local clonedModel = refs.model
		plasma.useEffect(function()
			if clonedModel then
				clonedModel:PivotTo(cframe)
			end
		end, cframe)
	end)
end)