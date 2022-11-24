
local root = script.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local pluginActions = root.pluginActions
local positionModel = require(pluginActions.positionModel)

return plasma.widget(function(model: Model, cframe: CFrame, positionModelType: number)
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

		local clonedModel = refs.model :: PVInstance

		local function updateModel()
			if clonedModel == nil then
				return
			end

			positionModel.position(clonedModel, cframe, positionModelType)
		end

		plasma.useEffect(updateModel, cframe)
		plasma.useEffect(updateModel, positionModelType)
	end)
end)