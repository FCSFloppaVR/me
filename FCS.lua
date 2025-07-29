--// SERVICES //--
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// VARIABLES //--
local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// DEBUG MESSAGE //--
print("[FCS] Menu Loaded ✅")
game.StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "[FCS] Menu Loaded ✅",
	Color = Color3.fromRGB(0,255,255),
	Font = Enum.Font.SourceSansBold,
	FontSize = Enum.FontSize.Size24
})

--// GUI CREATION //--
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

--// GUI HEADER //--
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS MENU"
Header.TextColor3 = Color3.fromRGB(0, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20

--// TABS //--
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

--// PAGES //--
local Pages = {}
for _, name in ipairs({ "Stuff", "Settings" }) do
	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	Pages[name] = page
end

--// CHECKBOXES (Stuff Tab) //--
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

--// ESP SETTINGS //--
local espBoxColor = Color3.fromRGB(0, 255, 255)
local circleColor = Color3.fromRGB(0, 255, 255)
local circleSize = 100

--// SETTINGS: CIRCLE SIZE SLIDER //--
createNumberSlider(Pages["Settings"], "Circle Size:", circleSize, 90, function(val)
	local clamped = math.clamp(val, 10, 300)
	circleSize = clamped
end)



--// ESP LOGIC (Highlight Outline) //--
local function createESP(plr)
	if plr == player then return end

	local function applyHighlight(char)
		if not char:FindFirstChild("FCS_Box") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "FCS_Box"
			highlight.FillTransparency = 1
			highlight.OutlineColor = espBoxColor
			highlight.OutlineTransparency = 0
			highlight.Adornee = char
			highlight.Parent = char
		end
	end

	if plr.Character then
		applyHighlight(plr.Character)
	end

	plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart", 5)
		applyHighlight(char)
	end)
end

-- Apply ESP to existing players
for _, plr in ipairs(Players:GetPlayers()) do
	createESP(plr)
end

-- Handle new players
Players.PlayerAdded:Connect(createESP)

-- Update color or remove on disable
RunService.RenderStepped:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local box = plr.Character:FindFirstChild("FCS_Box")
			if _G.espEnabled then
				if box then
					box.OutlineColor = espBoxColor
				end
			else
				if box then
					box:Destroy()
				end
			end
		end
	end
end)


-- Handle new players joining
Players.PlayerAdded:Connect(function(newPlr)
	createESP(newPlr)
end)

-- Update ESP color if changed in settings
RunService.RenderStepped:Connect(function()
	if _G.espEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("FCS_Box") then
				local box = plr.Character.FCS_Box
				box.OutlineColor = espBoxColor
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("FCS_Box") then
				plr.Character.FCS_Box:Destroy()
			end
		end
	end
end)


--// HEAD TRACKING (Circle + Camera Lock) //--  
local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 1.5
circle.Filled = false
circle.Visible = false

RunService.RenderStepped:Connect(function()
	if _G.headTrack then
		circle.Visible = true
		circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		circle.Radius = circleSize
		circle.Color = circleColor

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and not plr.Character:FindFirstChild("Ragdoll") then
					local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0, 0.4, 0))
					if onScreen then
						local dist = (Vector2.new(headPos.X, headPos.Y) - circle.Position).Magnitude
						if dist < circleSize then
							workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.Head.Position + Vector3.new(0, 0.4, 0))
						end
					end
				end
			end
		end
	else
		circle.Visible = false
	end
end)

--// SETTINGS TAB (Color Sliders) //--
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
		if val then callback(math.clamp(val, 0, 255)) end
	end)

	return slider
end

--// SETTINGS TAB UI //--
local r, g, b = 0, 255, 255
local preview = Instance.new("Frame", Pages["Settings"])
preview.Size = UDim2.new(0, 50, 0, 50)
preview.Position = UDim2.new(0, 230, 0, 0)
preview.BackgroundColor3 = Color3.fromRGB(r, g, b)

createColorSlider(Pages["Settings"], "Red:", r, 0, function(val) r = val; preview.BackgroundColor3 = Color3.fromRGB(r, g, b); espBoxColor = preview.BackgroundColor3 end)
createColorSlider(Pages["Settings"], "Green:", g, 30, function(val) g = val; preview.BackgroundColor3 = Color3.fromRGB(r, g, b); espBoxColor = preview.BackgroundColor3 end)
createColorSlider(Pages["Settings"], "Blue:", b, 60, function(val) b = val; preview.BackgroundColor3 = Color3.fromRGB(r, g, b); espBoxColor = preview.BackgroundColor3 end)

--// ADD CHECKBOXES TO STUFF TAB //--
createCheckbox(Pages["Stuff"], "ESP").Position = UDim2.new(0, 10, 0, 0)
createCheckbox(Pages["Stuff"], "Head Track").Position = UDim2.new(0, 10, 0, 40)

--// TAB SWITCHING //--
StuffBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = true
	Pages["Settings"].Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	Pages["Stuff"].Visible = false
	Pages["Settings"].Visible = true
end)

--// TOGGLE GUI WITH KEY (P) //--
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseBehavior = MainFrame.Visible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = MainFrame.Visible
	end
end)
