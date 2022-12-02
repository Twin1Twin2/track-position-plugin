
local PositionModelType = {
	Normal = 0,
	UseLookVector = 1,
	UseVertical = 2,
}

local PositionModelTypeNames = {
	"Normal",
	"UseLookVector",
	"UseVertical",
}


local function getLookVectorCFrame(cframe: CFrame)
	local p = cframe.Position
	local lv = cframe.LookVector

	-- if is vertical (lv.X and lv.Z are 0) then
	-- just use the cframe
	if math.abs(lv.Y) > 0.9999 then
		return cframe
	end

	return CFrame.lookAt(p, p + lv)
end

local function getVerticalCFrame(cframe: CFrame)
	local p = cframe.Position
	local lv = cframe.LookVector

	local direction = Vector3.new(lv.X, 0, lv.Z).Unit

	-- if is vertical (lv.X and lv.Z are 0) then
	-- just use the cframe
	if direction.Magnitude == 0 then
		return cframe
	end

	return CFrame.lookAt(p, p + direction)
end

return {
	PositionModelType = PositionModelType,
	PositionModelTypeNames = PositionModelTypeNames,
	position = function(model: Model, cframe: CFrame, positionModelType: number, offset: Vector3?, flip: boolean)
		offset = offset or model:GetAttribute("PositionOffset") or Vector3.new(0, 0, 0)
		cframe = cframe * CFrame.new(offset)

		if positionModelType == PositionModelType.UseLookVector then
			cframe = getLookVectorCFrame(cframe)
		elseif positionModelType == PositionModelType.UseVertical then
			cframe = getVerticalCFrame(cframe)
		end

		model:PivotTo(cframe)
	end,
}