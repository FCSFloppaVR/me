-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Global toggles
_G.espEnabled = false
_G.headTrack = false

-- Notificatiom
game.StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "[FCS MENU] Loaded successfully.";
	Color = Color3.fromRGB(0, 255, 255);
	Font = Enum.Font.SourceSansBold;
	FontSize = Enum.FontSize.Size24;
})

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FCS_Menu"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
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

-- Tabs
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

-- Pages
local Pages = {}
for _, name in ipairs({ "Stuff", "Settings" }) do
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	page.Parent = MainFrame
	Pages[name] = page
end

-- ESP & Head Track Checkboxes
local function createCheckbox(parent, labelText, yOffset)
	local checkbox = Instance.new("TextButton")
	checkbox.Size = UDim2.new(0, 280, 0, 30)
	checkbox.Position = UDim2.new(0, 10, 0, yOffset)
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

createCheckbox(Pages["Stuff"], "ESP", 0)
createCheckbox(Pages["Stuff"], "Head Track", 40)

-- Color & Radius Settings
local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

local function createColorSlider(parent, label, default, position, callback)
	local labelText = Instance.new("TextLabel")
	labelText.Position = position
	labelText.Size = UDim2.new(0, 100, 0, 20)
	labelText.Text = label
	labelText.BackgroundTransparency = 1
	labelText.TextColor3 = Color3.new(1, 1, 1)
	labelText.Parent = parent

	local red = Instance.new("TextBox")
	red.Size = UDim2.new(0, 30, 0, 20)
	red.Position = position + UDim2.new(0, 100, 0, 0)
	red.Text = tostring(default.R * 255)
	red.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	red.TextColor3 = Color3.new(1, 1, 1)
	red.Parent = parent

	local green = red:Clone()
	green.Position = red.Position + UDim2.new(0, 35, 0, 0)
	green.Text = tostring(default.G * 255)
	green.Parent = parent

	local blue = red:Clone()
	blue.Position = green.Position + UDim2.new(0, 35, 0, 0)
	blue.Text = tostring(default.B * 255)
	blue.Parent = parent

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 20, 0, 20)
	preview.Position = blue.Position + UDim2.new(0, 40, 0, 0)
	preview.BackgroundColor3 = default
	preview.Parent = parent

	local function updateColor()
		local r = tonumber(red.Text)
		local g = tonumber(green.Text)
		local b = tonumber(blue.Text)
		if r and g and b then
			local newColor = Color3.fromRGB(r, g, b)
			preview.BackgroundColor3 = newColor
			callback(newColor)
		end
	end

	red.FocusLost:Connect(updateColor)
	green.FocusLost:Connect(updateColor)
	blue.FocusLost:Connect(updateColor)
end

createColorSlider(Pages["Settings"], "ESP Color", espBoxColor, UDim2.new(0, 0, 0, 0), function(color)
	espBoxColor = color
end)

createColorSlider(Pages["Settings"], "Circle Color", circleColor, UDim2.new(0, 0, 0, 30), function(color)
	circleColor = color
end)

local radiusSlider = Instance.new("TextBox")
radiusSlider.Size = UDim2.new(0, 100, 0, 25)
radiusSlider.Position = UDim2.new(0, 0, 0, 60)
radiusSlider.Text = tostring(circleSize)
radiusSlider.TextColor3 = Color3.new(1, 1, 1)
radiusSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
radiusSlider.ClearTextOnFocus = false
radiusSlider.Parent = Pages["Settings"]

radiusSlider.FocusLost:Connect(function()
	local val = tonumber(radiusSlider.Text)
	if val then
		circleSize = val
	end
end)

-- Page switching
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

-- Input toggle (P) and ESC override
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseBehavior = MainFrame.Visible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
	end
end)

-- Prevent ESC menu from blocking GUI
ScreenGui.DisplayOrder = 10

-- ESP using BoxHandleAdornment
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

-- Head tracking circle
local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 1.5
circle.Filled = false

RunService.RenderStepped:Connect(function()
	if _G.headTrack then
		circle.Visible = true
		circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
					local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
					if onScreen and dist < circleSize then
						workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.Head.Position)
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)
