-- radio_button_checked = "rbxassetid://7746261358"
-- radio_button_unchecked = "rbxassetid://7746261420"

local root = script.Parent.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

local container = require(script.Parent.container)

local radioButton = plasma.widget(function(text, options)
	options = options or {}

	local checked, setChecked = plasma.useState(false)
	local clicked, setClicked = plasma.useState(false)

	local refs = plasma.useInstance(function(ref)
		local style = plasma.useStyle()

		local RadioButton = plasma.create("Frame", {
			[ref] = "radioButton",
			BackgroundTransparency = 1,
			Name = "RadioButton",
			Size = UDim2.new(0, 30, 0, 30),
			AutomaticSize = Enum.AutomaticSize.X,

			plasma.create("ImageButton", {
				BackgroundColor3 = style.bg3, -- Color3.fromRGB(54, 54, 54),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 30, 0, 30),

				plasma.create("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),

				Activated = function()
					setClicked(true)
					setChecked(function(currentlyChecked)
						return not currentlyChecked
					end)
				end,
			}),

			plasma.create("TextLabel", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamMedium,
				TextColor3 = Color3.fromRGB(203, 203, 203),
				TextSize = 18,
				AutomaticSize = Enum.AutomaticSize.X,
				RichText = true,
			}),

			plasma.create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		return RadioButton
	end)

	local instance = refs.radioButton

	instance.TextLabel.Text = text
	instance.ImageButton.AutoButtonColor = not options.disabled

	plasma.useEffect(function()
		local isChecked
		if options.checked ~= nil then
			isChecked = options.checked
		else
			isChecked = checked
		end

		instance.ImageButton.Image = if isChecked then "rbxassetid://7746261358" else "rbxassetid://7746261420"
	end, options.checked, checked)

	plasma.useEffect(function()
		instance.ImageButton.ImageColor3 = options.disabled and Color3.fromRGB(112, 112, 112)
			or Color3.fromRGB(203, 203, 203)
	end, options.disabled)

	local handle = {
		checked = function()
			if options.checked or checked then
				return true
			end

			return false
		end,
		clicked = function()
			if clicked then
				setClicked(false)
				return true
			end

			return false
		end,
	}

	return handle
end)

return plasma.widget(function(list: {string}, current: string | nil)
	local selected, setSelected = plasma.useState(nil)

	container(function()
		for _, name in ipairs(list) do
			local button = radioButton(name, {
				checked = current == name,
				disabled = false,
			})

			if button:clicked() then
				setSelected(name)
			end
		end
	end)

	local handle = {
		selected = function()
			if selected ~= nil then
				setSelected(nil)
				return selected
			end

			return nil
		end
	}

	return handle
end)