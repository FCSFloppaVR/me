-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- GLOBAL FLAGS
_G.espEnabled = false
_G.headTrack = false

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FCS_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS MENU"
Header.TextColor3 = Color3.fromRGB(0, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20
Header.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local function createTabButton(name, xPos)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Size = UDim2.new(0, 150, 0, 25)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BorderSizePixel = 0
	btn.Parent = TabButtons
	return btn
end

local StuffBtn = createTabButton("Stuff", 0)
local SettingsBtn = createTabButton("Settings", 150)

local Pages = {}
for _, name in ipairs({"Stuff", "Settings"}) do
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	page.Parent = MainFrame
	Pages[name] = page
end

local function createCheckbox(parent, labelText)
	local checkbox = Instance.new("TextButton")
	checkbox.Size = UDim2.new(0, 280, 0, 30)
	checkbox.Position = UDim2.new(0, 10, 0, (#parent:GetChildren()-1)*35)
	checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	checkbox.BorderSizePixel = 0
	checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	checkbox.Font = Enum.Font.Gotham
	checkbox.TextSize = 14
	checkbox.Text = "[ ] " .. labelText
	checkbox.Parent = parent

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

-- Box ESP
local function createESPBox(player, color)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then return end

	if char:FindFirstChild("FCS_Box") then
		char.FCS_Box:Destroy()
	end

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
		local viewportSize = workspace.CurrentCamera.ViewportSize
		circle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
						local headPos = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
						local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
						if dist < circleSize then
							workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.Head.Position)
						end
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)

-- Settings: RGB sliders with color preview
local function createColorSlider(parent, labelText, defaultColor, callback, yOffset)
	local label = Instance.new("TextLabel")
	label.Text = labelText
	label.Position = UDim2.new(0, 0, 0, yOffset)
	label.Size = UDim2.new(0, 100, 0, 20)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = parent

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 20, 0, 20)
	preview.Position = UDim2.new(0, 260, 0, yOffset)
	preview.BackgroundColor3 = defaultColor
	preview.BorderSizePixel = 0
	preview.Parent = parent

	local sliders = {}
	local colors = {"R", "G", "B"}
	for i, channel in ipairs(colors) do
		local slider = Instance.new("TextBox")
		slider.Size = UDim2.new(0, 40, 0, 20)
		slider.Position = UDim2.new(0, 100 + (i - 1) * 50, 0, yOffset)
		slider.Text = tostring(defaultColor[channel:lower()] * 255)
		slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		slider.TextColor3 = Color3.new(1, 1, 1)
		slider.ClearTextOnFocus = false
		slider.Parent = parent

		table.insert(sliders, slider)
	end

	local function updateColor()
		local r = tonumber(sliders[1].Text) or 0
		local g = tonumber(sliders[2].Text) or 0
		local b = tonumber(sliders[3].Text) or 0
		r = math.clamp(r, 0, 255)
		g = math.clamp(g, 0, 255)
		b = math.clamp(b, 0, 255)
		local newColor = Color3.fromRGB(r, g, b)
		preview.BackgroundColor3 = newColor
		callback(newColor)
	end

	for _, slider in ipairs(sliders) do
		slider.FocusLost:Connect(updateColor)
	end
end

local function createSlider(parent, yOffset)
	local slider = Instance.new("TextBox")
	slider.Size = UDim2.new(0, 200, 0, 25)
	slider.Position = UDim2.new(0, 0, 0, yOffset)
	slider.Text = tostring(circleSize)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slider.ClearTextOnFocus = false
	slider.Parent = parent

	slider.FocusLost:Connect(function()
		local val = tonumber(slider.Text)
		if val then
			circleSize = val
		end
	end)
end

createCheckbox(Pages["Stuff"], "ESP")
createCheckbox(Pages["Stuff"], "Head Track")

createColorSlider(Pages["Settings"], "ESP Color", espBoxColor, function(color)
	espBoxColor = color
end, 0)

createColorSlider(Pages["Settings"], "Circle Color", circleColor, function(color)
	circleColor = color
end, 40)

createSlider(Pages["Settings"], 80)

StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseBehavior = MainFrame.Visible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
	end
end)
