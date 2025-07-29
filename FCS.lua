-- [ SERVICES ]
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Debug: print + system chat
print("[FCS] Menu Loaded ✅")
game.StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "[FCS] Menu Loaded ✅";
	Color = Color3.fromRGB(0,255,255);
	Font = Enum.Font.SourceSansBold;
	FontSize = Enum.FontSize.Size24;
})

-- [ GUI CREATION ]
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

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
	btn.Size = UDim2.new(0, 160, 0, 25)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BorderSizePixel = 0
	return btn
end

local StuffBtn = createTabButton("Stuff", 0)
local SettingsBtn = createTabButton("Settings", 160)

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
		elseif labelText == "Silent Aim" then
			_G.silentAim = state
		end
	end)

	return checkbox
end

-- ESP Colors
local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

-- ESP Logic (Box ESP)
local function drawBox(plr)
	if plr == player or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
	if not plr.Character:FindFirstChild("FCS_Box") then
		local highlight = Instance.new("Highlight", plr.Character)
		highlight.Name = "FCS_Box"
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = espBoxColor
		highlight.FillColor = espBoxColor
	end
end

RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				drawBox(plr)
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
		circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
					if not plr.Character:FindFirstChild("Ragdoll") then
						local headPos, onscreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0,0.4,0))
						if onscreen then
							local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
							if dist < circleSize then
								workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.Head.Position + Vector3.new(0,0.4,0))
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

-- Silent Aim Logic
local function getClosestTargetToCrosshair(radius)
	local closest = nil
	local shortest = radius or 100
	local cam = workspace.CurrentCamera

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			if not plr.Character:FindFirstChild("Ragdoll") then
				local pos, onScreen = cam:WorldToViewportPoint(plr.Character.Head.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
					if dist < shortest then
						shortest = dist
						closest = plr
					end
				end
			end
		end
	end
	return closest
end

-- __namecall hook for Silent Aim
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if _G.silentAim and method == "FireServer" and typeof(args[1]) == "Vector3" then
		local target = getClosestTargetToCrosshair(100)
		if target and target.Character and target.Character:FindFirstChild("Head") then
			args[1] = target.Character.Head.Position + Vector3.new(0, 0.2, 0)
			return oldNamecall(self, unpack(args))
		end
	end

	return oldNamecall(self, ...)
end)

-- Settings Sliders
local function createColorSlider(parent, labelText, default, offsetY, callback)
	local label = Instance.new("TextLabel", parent)
	label.Text = labelText
	label.Size = UDim2.new(0, 60, 0, 20)
	label.Position = UDim2.new(0, 0, 0, offsetY)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1

	local slider = Instance.new("TextBox", parent)
	slider.Size = UDim2.new(0, 150, 0, 20)
	slider.Position = UDim2.new(0, 70, 0, offsetY)
	slider.Text = tostring(default)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.fromRGB(30,30,30)
	slider.ClearTextOnFocus = false

	slider.FocusLost:Connect(function()
		local val = tonumber(slider.Text)
		if val then callback(math.clamp(val,0,255)) end
	end)

	return slider
end

-- Settings Page
local r,g,b = 0,255,255
local preview = Instance.new("Frame", Pages["Settings"])
preview.Size = UDim2.new(0,50,0,50)
preview.Position = UDim2.new(0,230,0,0)
preview.BackgroundColor3 = Color3.fromRGB(r,g,b)

createColorSlider(Pages["Settings"], "Red:", r, 0, function(val) r=val preview.BackgroundColor3=Color3.fromRGB(r,g,b) espBoxColor=preview.BackgroundColor3 end)
createColorSlider(Pages["Settings"], "Green:", g, 30, function(val) g=val preview.BackgroundColor3=Color3.fromRGB(r,g,b) espBoxColor=preview.BackgroundColor3 end)
createColorSlider(Pages["Settings"], "Blue:", b, 60, function(val) b=val preview.BackgroundColor3=Color3.fromRGB(r,g,b) espBoxColor=preview.BackgroundColor3 end)

-- Populate Stuff Page
createCheckbox(Pages["Stuff"], "ESP").Position = UDim2.new(0, 10, 0, 0)
createCheckbox(Pages["Stuff"], "Head Track").Position = UDim2.new(0, 10, 0, 40)
createCheckbox(Pages["Stuff"], "Silent Aim").Position = UDim2.new(0, 10, 0, 80)

-- Tab Switching
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

-- Toggle GUI with P
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
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
