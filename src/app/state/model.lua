
local root = script.Parent.Parent.Parent
local packages = root.packages
local rodux = require(packages.rodux)

local modules = root.modules
local tableUtil = require(modules.tableUtil)

local pluginActions = root.pluginActions
local positionModel = require(pluginActions.positionModel)
local PositionModelTypeNames = positionModel.PositionModelTypeNames

local module = {}
local actions = {}
local actionHandlers = {}

export type ModelState = {
	model: Instance | nil,
	modelParent: Instance | nil,

	showPreview: boolean,

	positionModelType: string,
}

local initialState: ModelState = {
	model = nil,
	modelParent = workspace,

	showPreview = true,

	positionModelType = PositionModelTypeNames[1],
}

-- SetModel
actions.setModel = rodux.makeActionCreator("SetModel", function(model: Instance | nil)
	return {
		model = model,
	}
end)

actionHandlers.SetModel = function(state: ModelState, action)
	state = state or tableUtil.copy(initialState)

	state.model = action.model

	return state
end

-- SetModelParent
actions.setModelParent = rodux.makeActionCreator("SetModelParent", function(modelParent: Instance | nil)
	return {
		modelParent = modelParent,
	}
end)

actionHandlers.SetModelParent = function(state: ModelState, action)
	state = state or tableUtil.copy(initialState)

	state.modelParent = action.modelParent

	return state
end

-- SetShowPreview
actions.setShowPreview = rodux.makeActionCreator("SetShowPreview", function(showPreview: boolean)
	return {
		showPreview = showPreview,
	}
end)

actionHandlers.SetShowPreview = function(state: ModelState, action)
	state = state or tableUtil.copy(initialState)

	state.showPreview = action.showPreview

	return state
end

-- SetPositionModelType
actions.setPositionModelType = rodux.makeActionCreator("SetPositionModelType", function(positionModelType: string)
	return {
		positionModelType = positionModelType,
	}
end)

actionHandlers.SetPositionModelType = function(state: ModelState, action)
	state = state or PositionModelTypeNames[1]

	state.positionModelType = action.positionModelType

	return state
end

module.actions = actions

-- reducer
local reducer = rodux.createReducer(
	initialState,
	actionHandlers
)

module.reducer = reducer

return module