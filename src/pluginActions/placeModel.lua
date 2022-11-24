
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local positionModel = require(script.Parent.positionModel)

local root = script.Parent.Parent

local modules = root.modules
local Result = require(modules.Result)

return function(model: PVInstance, cframe: CFrame, positionModelType: number?, parent: Instance?)
	positionModelType = if positionModelType == nil then positionModel.PositionModelType.Normal else positionModelType
	parent = parent or workspace

	if model == nil then
		return Result.err("Model is nil!")
	elseif model:IsA("PVInstance") == false then
		return Result.err("Model is not a PVInstance!")
	end

	local clonedModel = model:Clone()
	positionModel.position(clonedModel, cframe, positionModelType)
	clonedModel.Parent = parent

	ChangeHistoryService:SetWaypoint("PlaceModel")
end
