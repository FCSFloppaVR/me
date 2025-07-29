local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FCS_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true

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

local function createCheckbox(parent, labelText, yPos)
	local checkbox = Instance.new("TextButton", parent)
	checkbox.Size = UDim2.new(0, 280, 0, 30)
	checkbox.Position = UDim2.new(0, 10, 0, yPos)
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

-- JJSploit-Style Box ESP
local function clearESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local part = plr.Character:FindFirstChild("HumanoidRootPart")
			if part then
				for _, ad in pairs(part:GetChildren()) do
					if ad:IsA("BoxHandleAdornment") and ad.Name == "FCS_Box" then
						ad:Destroy()
					end
				end
			end
		end
	end
end

local function createESP()
	clearESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character.HumanoidRootPart
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "FCS_Box"
			box.Size = root.Size + Vector3.new(1.5, 1.5, 1.5)
			box.Adornee = root
			box.AlwaysOnTop = true
			box.ZIndex = 5
			box.Color3 = espBoxColor
			box.Transparency = 0
			box.BorderSizePixel = 0
			box.Parent = root
		end
	end
end

RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		createESP()
	else
		clearESP()
	end
end)

-- Circle (centered)
local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 1.5
circle.Filled = false

RunService.RenderStepped:Connect(function()
	if _G.headTrack then
		circle.Visible = true
		circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
					if onScreen then
						local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
						if dist < circleSize then
							Camera.CFrame = CFrame.new(Camera.CFrame.Position, plr.Character.Head.Position)
						end
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)

-- Settings
local function createColorInput(parent, labelText, yPos, defaultColor, callback)
	local label = Instance.new("TextLabel", parent)
	label.Text = labelText
	label.Size = UDim2.new(0, 100, 0, 20)
	label.Position = UDim2.new(0, 0, 0, yPos)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1

	local colorInput = Instance.new("TextBox", parent)
	colorInput.Size = UDim2.new(0, 100, 0, 20)
	colorInput.Position = UDim2.new(0, 110, 0, yPos)
	colorInput.Text = string.format("%d, %d, %d", defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255)
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

local function createSlider(parent, yPos)
	local slider = Instance.new("TextBox", parent)
	slider.Size = UDim2.new(0, 200, 0, 25)
	slider.Position = UDim2.new(0, 0, 0, yPos)
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

-- Stuff Tab
createCheckbox(Pages["Stuff"], "ESP", 0)
createCheckbox(Pages["Stuff"], "Head Track", 40)

-- Settings Tab
createColorInput(Pages["Settings"], "ESP Color (r,g,b):", 0, espBoxColor, function(color)
	espBoxColor = color
end)

createColorInput(Pages["Settings"], "Circle Color (r,g,b):", 30, circleColor, function(color)
	circleColor = color
end)

createSlider(Pages["Settings"], 60)

-- Tab Switch
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

-- GUI toggle with \
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.BackSlash then
		MainFrame.Visible = not MainFrame.Visible
		if MainFrame.Visible then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
	end
end)
