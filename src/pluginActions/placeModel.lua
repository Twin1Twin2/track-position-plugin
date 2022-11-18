
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local root = script.Parent.Parent

local modules = root.modules
local Result = require(modules.Result)

return function(model: PVInstance, cframe: CFrame, parent: Instance?)
	parent = parent or workspace

	if model == nil then
		return Result.err("Model is nil!")
	elseif model:IsA("PVInstance") == false then
		return Result.err("Model is not a PVInstance!")
	end

	local clonedModel = model:Clone()
	clonedModel:PivotTo(cframe)
	clonedModel.Parent = parent

	ChangeHistoryService:SetWaypoint("PlaceModel")
end
