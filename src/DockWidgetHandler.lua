
local RunService = game:GetService("RunService")

local packages = script.Parent.packages
local plasma = require(packages.plasma)
local rodux = require(packages.rodux)

local modules = script.Parent.modules
local Maid = require(modules.Maid)

--- @class DockWidgetHandler
--- *Description here*

local DockWidgetHandler = {}
DockWidgetHandler.__index = DockWidgetHandler
DockWidgetHandler.ClassName = "DockWidgetHandler"

--- @tag Constructor
--- @return DockWidgetHandler
function DockWidgetHandler.new(
	plugin: Plugin,
	button: PluginToolbarButton,
	name: string,
	title: string,
	widget,
	reducer
)
	local self = setmetatable({}, DockWidgetHandler)

	self.maid = Maid.new()

	self.plugin = plugin
	self.button = button

	self.name = name
	self.title = title

	self.widget = widget
	self.reducer = reducer

	self.isEnabled = false

	self.gui = nil
	self.node = nil


	local clickConnection = self.button.Click:Connect(function()
		self:toggleEnabled()
	end)
	self.maid:GiveTask(clickConnection)

	local unloadingConnection = self.plugin.Unloading:Connect(function()
		self:Destroy()
	end)
	self.maid:GiveTask(unloadingConnection)

	return self
end

function DockWidgetHandler:Destroy()
	self.maid:Destroy()
	self.maid = nil

	setmetatable(self, nil)
end

function DockWidgetHandler:toggleEnabled()
	if self.isEnabled == false then
		self:enable()
	else
		self:disable()
	end
end

function DockWidgetHandler:enable()
	if self.isEnabled == true then
		return
	end

	if self.gui == nil then
		self:_createGui()
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_deltaTime: number)
		plasma.start(self.node, function()
			self.widget(self.store)
		end)
	end)
	self.maid.updateConnection = heartbeatConnection

	self.gui.Enabled = true
	self.button:SetActive(true)
	self.isEnabled = true
end

function DockWidgetHandler:disable()
	if self.isEnabled == false then
		return
	end

	self.maid.updateConnection = nil
	plasma.start(self.node, function()
		self.widget(self.store)
	end)

	self.gui.Enabled = false
	self.button:SetActive(false)
	self.isEnabled = false
end

-- function DockWidgetHandler:close()
-- 	self:disable()

-- 	plasma.start(self.node, function() end) -- cleanup created instances (including handles)
-- end

function DockWidgetHandler:_createGui()
	local dockWidgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		200,
		300,
		150,
		150
	)
	local gui = self.plugin:CreateDockWidgetPluginGui(
		self.title,
		dockWidgetInfo
	)

	gui.Name = self.name
	gui.Title = self.title
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

	gui:BindToClose(function()
		print("Closing!")
		self:disable()
	end)

	self.store = rodux.Store.new(self.reducer, nil, {})

	self.node = plasma.new(gui)
	self.gui = gui
	self.maid:GiveTask(gui)
end

export type DockWidgetHandler = typeof(DockWidgetHandler.new())

return DockWidgetHandler