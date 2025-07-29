-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 300)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS MENU"
Header.TextColor3 = Color3.fromRGB(0, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20

-- Tabs
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1, 0, 0, 25)
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

-- Global Settings
_G.espEnabled = false
_G.headTrack = false
local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

-- ESP
local function createESPBox(plr, color)
	local char = plr.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then return end

	if char:FindFirstChild("FCS_Box") then char.FCS_Box:Destroy() end
	local box = Instance.new("BoxHandleAdornment")
	box.Name = "FCS_Box"
	box.Adornee = char
	box.Size = Vector3.new(4, 6, 2)
	box.Color3 = color
	box.AlwaysOnTop = true
	box.ZIndex = 1
	box.Transparency = 0.65
	box.Visible = true
	box.Parent = char
end

RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				createESPBox(plr, espBoxColor)
			end
		end
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("FCS_Box") then
				plr.Character.FCS_Box:Destroy()
			end
		end
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
		circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		circle.Radius = circleSize
		circle.Color = circleColor
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
						local headPos, visible = camera:WorldToViewportPoint(plr.Character.Head.Position)
						if visible then
							local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
							if dist < circleSize then
								camera.CFrame = CFrame.new(camera.CFrame.Position, plr.Character.Head.Position)
							end
						end
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)

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

-- Color Sliders
local function createColorSlider(parent, labelText, defaultColor, callback, offsetY)
	local label = Instance.new("TextLabel", parent)
	label.Text = labelText
	label.Size = UDim2.new(0, 100, 0, 20)
	label.Position = UDim2.new(0, 0, 0, offsetY)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1

	local preview = Instance.new("Frame", parent)
	preview.Size = UDim2.new(0, 20, 0, 20)
	preview.Position = UDim2.new(0, 260, 0, offsetY)
	preview.BackgroundColor3 = defaultColor

	local r = Instance.new("TextBox", parent)
	r.Size = UDim2.new(0, 50, 0, 20)
	r.Position = UDim2.new(0, 110, 0, offsetY)
	r.Text = tostring(defaultColor.R * 255)
	r.ClearTextOnFocus = false

	local g = r:Clone()
	g.Parent = parent
	g.Position = UDim2.new(0, 160, 0, offsetY)
	g.Text = tostring(defaultColor.G * 255)

	local b = r:Clone()
	b.Parent = parent
	b.Position = UDim2.new(0, 210, 0, offsetY)
	b.Text = tostring(defaultColor.B * 255)

	local function updateColor()
		local newColor = Color3.fromRGB(tonumber(r.Text) or 0, tonumber(g.Text) or 0, tonumber(b.Text) or 0)
		callback(newColor)
		preview.BackgroundColor3 = newColor
	end

	r.FocusLost:Connect(updateColor)
	g.FocusLost:Connect(updateColor)
	b.FocusLost:Connect(updateColor)
end

local function createSlider(parent, offsetY)
	local slider = Instance.new("TextBox", parent)
	slider.Size = UDim2.new(0, 200, 0, 25)
	slider.Position = UDim2.new(0, 0, 0, offsetY)
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

-- Populate Stuff Page
createCheckbox(Pages["Stuff"], "ESP").Position = UDim2.new(0, 10, 0, 0)
createCheckbox(Pages["Stuff"], "Head Track").Position = UDim2.new(0, 10, 0, 40)

-- Populate Settings
createColorSlider(Pages["Settings"], "ESP Color:", espBoxColor, function(color) espBoxColor = color end, 0)
createColorSlider(Pages["Settings"], "Circle Color:", circleColor, function(color) circleColor = color end, 40)
createSlider(Pages["Settings"], 80)

-- Tab Switching
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)
SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

-- Toggle Menu with P
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseIconEnabled = MainFrame.Visible
	end
end)
