
local root = script.Parent.Parent.Parent
local packages = root.packages
local plasma = require(packages.plasma)

return plasma.widget(function(text: string)
	local focused, setFocused = plasma.useState(false)
	local focusLost, setFocusLost = plasma.useState(false)

	local enterPressed, setEnterPressed = plasma.useState(false)

	local incrementClicked, setIncrementClicked = plasma.useState(false)
	local decrementClicked, setDecrementClicked = plasma.useState(false)

	local refs = plasma.useInstance(function(ref)
		local style = plasma.useStyle()

		local frame = plasma.create("Frame", {
			BackgroundColor3 = style.bg3,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 40),

			plasma.create("TextBox", {
				[ref] = "textBox",

				BackgroundColor3 = style.bg2,
				BorderSizePixel = 0,
				Font = Enum.Font.SourceSans,
				Size = UDim2.new(1, -40, 0, 40),
				TextColor3 = style.textColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 21,
				ClearTextOnFocus = false,

				plasma.create("UIPadding", {
					PaddingLeft = UDim.new(0, 20),
					PaddingRight = UDim.new(0, 20),
				}),

				plasma.create("UICorner"),

				Focused = function()
					setFocused(true)
				end,
				FocusLost = function(wasEnterPressed: boolean)
					setEnterPressed(wasEnterPressed)
					setFocused(false)
					setFocusLost(true)
				end,
			}),

			plasma.create("TextButton", {
				[ref] = "button",
				BackgroundColor3 = style.bg3,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 40, 0, 40),
				AutomaticSize = Enum.AutomaticSize.X,

				Font = Enum.Font.GothamMedium,
				TextColor3 = style.textColor,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextSize = 21,

				Text = "+",

				plasma.create("UICorner"),

				Activated = function()
					setIncrementClicked(true)
				end,
			}),
			plasma.create("TextButton", {
				[ref] = "button",
				BackgroundColor3 = style.bg3,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -40, 0, 0),
				Size = UDim2.new(0, 40, 0, 40),
				AutomaticSize = Enum.AutomaticSize.X,

				Font = Enum.Font.GothamMedium,
				TextColor3 = style.textColor,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextSize = 21,

				Text = "-",

				plasma.create("UICorner"),

				Activated = function()
					setDecrementClicked(true)
				end,
			})
		})

		return frame
	end)

	local textBox = refs.textBox
	if not focused and not enterPressed then
		textBox.Text = text
	end

	local handle = {
		focusLost = function(_self, callback: ((input: string, enterPressed: boolean) -> ()) | nil)
			if focusLost == false then
				return
			end

			local input = textBox.Text
			local currentEnterPressed = enterPressed

			setFocusLost(false)
			setEnterPressed(false)

			if callback then
				callback(input, currentEnterPressed)
			end

			return true
		end,
		incrementClicked = function(_self)
			if incrementClicked then
				setIncrementClicked(false)
				return true
			end

			return false
		end,
		decrementClicked = function(_self)
			if decrementClicked then
				setDecrementClicked(false)
				return true
			end

			return false
		end,
	}

	return handle
end)