local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true

-- Rounded corners
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS MENU"
Header.TextColor3 = Color3.fromRGB(0, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20

-- Tabs
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundTransparency = 1

local function createTabButton(name, xPos)
	local btn = Instance.new("TextButton", TabButtons)
	btn.Text = name
	btn.Size = UDim2.new(0, 150, 0, 25)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BorderSizePixel = 0
	return btn
end

local StuffBtn = createTabButton("Stuff", 0)
local SettingsBtn = createTabButton("Settings", 150)

-- Pages
local Pages = {}
for _, name in ipairs({ "Stuff", "Settings" }) do
	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	Pages[name] = page
end

-- Checkboxes
local function createCheckbox(parent, labelText)
	local checkbox = Instance.new("TextButton", parent)
	checkbox.Size = UDim2.new(0, 280, 0, 30)
	checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	checkbox.BorderSizePixel = 0
	checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	checkbox.Font = Enum.Font.Gotham
	checkbox.TextSize = 14
	checkbox.Text = "[ ] " .. labelText

	local state = false
	checkbox.MouseButton1Click:Connect(function()
		state = not state
		checkbox.Text = (state and "[X] " or "[ ] ") .. labelText
		if labelText == "ESP" then
			_G.espEnabled = state
		elseif labelText == "Head Track" then
			_G.headTrack = state
		end
	end)

	return checkbox
end

local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

-- ESP Logic
local function createESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and not plr.Character:FindFirstChild("Head"):FindFirstChild("FCS_Box") then
			local head = plr.Character:FindFirstChild("Head")
			if head then
				local box = Instance.new("BillboardGui", head)
				box.Name = "FCS_Box"
				box.Size = UDim2.new(0, 50, 0, 50)
				box.AlwaysOnTop = true
				local frame = Instance.new("Frame", box)
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.BackgroundColor3 = espBoxColor
				frame.BorderSizePixel = 0
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		createESP()
	end
end)

-- Head Tracking Circle
local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 1.5
circle.Filled = false

RunService.RenderStepped:Connect(function()
	if _G.headTrack then
		circle.Visible = true
		circle.Position = Vector2.new(mouse.X, mouse.Y)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					local headPos = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
					local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
					if dist < circleSize then
						workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.Head.Position)
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)

-- Settings - Color pickers and slider
local function createColorPicker(parent, labelText, defaultColor, callback)
	local label = Instance.new("TextLabel", parent)
	label.Text = labelText
	label.Size = UDim2.new(0, 100, 0, 20)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1

	local colorInput = Instance.new("TextBox", parent)
	colorInput.Size = UDim2.new(0, 100, 0, 20)
	colorInput.Position = UDim2.new(0, 110, 0, 0)
	colorInput.Text = tostring(defaultColor)
	colorInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	colorInput.TextColor3 = Color3.new(1, 1, 1)

	colorInput.FocusLost:Connect(function()
		local success, result = pcall(function()
			local r, g, b = string.match(colorInput.Text, "(%d+),%s*(%d+),%s*(%d+)")
			return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		end)
		if success and result then
			callback(result)
		end
	end)
end

local function createSlider(parent)
	local slider = Instance.new("TextBox", parent)
	slider.Size = UDim2.new(0, 200, 0, 25)
	slider.Position = UDim2.new(0, 0, 0, 30)
	slider.Text = tostring(circleSize)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slider.ClearTextOnFocus = false

	slider.FocusLost:Connect(function()
		local val = tonumber(slider.Text)
		if val then
			circleSize = val
		end
	end)
end

-- Populate "Stuff"
createCheckbox(Pages["Stuff"], "ESP").Position = UDim2.new(0, 10, 0, 0)
createCheckbox(Pages["Stuff"], "Head Track").Position = UDim2.new(0, 10, 0, 40)

-- Populate "Settings"
createColorPicker(Pages["Settings"], "ESP Color (r,g,b):", espBoxColor, function(color)
	espBoxColor = color
end)

createColorPicker(Pages["Settings"], "Circle Color (r,g,b):", circleColor, function(color)
	circleColor = color
end).Position = UDim2.new(0, 0, 0, 30)

createSlider(Pages["Settings"]).Position = UDim2.new(0, 0, 0, 60)

-- Tab Switching
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

-- Toggle GUI with \
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.BackSlash then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
