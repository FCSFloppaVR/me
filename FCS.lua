--// SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

--// GLOBAL FLAGS
_G.espEnabled = false
_G.headTrack = false

local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

--// GUI CREATION
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"

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

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS MENU"
Header.TextColor3 = Color3.fromRGB(0, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20

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

local Pages = {}
for _, name in ipairs({ "Stuff", "Settings" }) do
	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	Pages[name] = page
end

--// CHECKBOXES
local function createCheckbox(parent, labelText, yOffset)
	local checkbox = Instance.new("TextButton", parent)
	checkbox.Size = UDim2.new(0, 280, 0, 30)
	checkbox.Position = UDim2.new(0, 10, 0, yOffset)
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

createCheckbox(Pages["Stuff"], "ESP", 0)
createCheckbox(Pages["Stuff"], "Head Track", 40)

--// SETTINGS
local function createColorSlider(parent, labelText, defaultColor, yOffset, onChange)
	local label = Instance.new("TextLabel", parent)
	label.Text = labelText
	label.Size = UDim2.new(0, 100, 0, 20)
	label.Position = UDim2.new(0, 0, 0, yOffset)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1

	local box = Instance.new("Frame", parent)
	box.Position = UDim2.new(0, 220, 0, yOffset)
	box.Size = UDim2.new(0, 20, 0, 20)
	box.BackgroundColor3 = defaultColor

	local sliders = { "R", "G", "B" }
	local values = { defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255 }

	for i, channel in ipairs(sliders) do
		local slider = Instance.new("TextBox", parent)
		slider.Size = UDim2.new(0, 30, 0, 20)
		slider.Position = UDim2.new(0, 100 + ((i - 1) * 40), 0, yOffset)
		slider.Text = tostring(math.floor(values[i]))
		slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		slider.TextColor3 = Color3.new(1, 1, 1)
		slider.ClearTextOnFocus = false

		slider.FocusLost:Connect(function()
			local val = tonumber(slider.Text)
			if val and val >= 0 and val <= 255 then
				values[i] = val
				local color = Color3.fromRGB(values[1], values[2], values[3])
				onChange(color)
				box.BackgroundColor3 = color
			end
		end)
	end
end

createColorSlider(Pages["Settings"], "ESP Color:", espBoxColor, 0, function(c) espBoxColor = c end)
createColorSlider(Pages["Settings"], "Circle Color:", circleColor, 40, function(c) circleColor = c end)

local function createCircleSlider(parent)
	local slider = Instance.new("TextBox", parent)
	slider.Size = UDim2.new(0, 200, 0, 25)
	slider.Position = UDim2.new(0, 0, 0, 80)
	slider.Text = tostring(circleSize)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slider.ClearTextOnFocus = false

	slider.FocusLost:Connect(function()
		local val = tonumber(slider.Text)
		if val then circleSize = val end
	end)
end

createCircleSlider(Pages["Settings"])

--// TABS
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

--// TOGGLE MENU + MOUSE
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseBehavior = MainFrame.Visible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
	end
end)

--// ESP LOGIC
local function createESPBox(plr)
	local char = plr.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then return end

	if char:FindFirstChild("FCS_Box") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "FCS_Box"
	box.Adornee = char
	box.Size = Vector3.new(4, 6, 2)
	box.Color3 = espBoxColor
	box.AlwaysOnTop = true
	box.ZIndex = 1
	box.Transparency = 0.6
	box.Visible = true
	box.Parent = char
end

RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				createESPBox(plr)
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

--// HEAD TRACK CIRCLE
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
					local headPos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
					if onScreen then
						local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
						local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
						if dist < circleSize and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
							camera.CFrame = CFrame.new(camera.CFrame.Position, plr.Character.Head.Position)
						end
					end
				end
			end
	else
		circle.Visible = false
	end
end)
