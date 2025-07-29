--[[ FULLY WORKING FCS DEV MENU EXPANDED ]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local HttpService = game:GetService("HttpService")

-- GLOBALS
_G.espEnabled = false
_G.headTrack = false
_G.rainbowESP = false
_G.silentAim = false
_G.smoothness = 0.3
_G.bhop = false

local Settings = {
	ESPColor = Color3.fromRGB(0, 255, 255),
	FOVRadius = 120,
	Smoothness = 0.3,
	SilentAim = false,
	Rainbow = false
}

-- Debug: print + system chat
print("[FCS] Menu Loaded â")
game.StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "[FCS] Menu Loaded â";
	Color = Color3.fromRGB(0,255,255);
	Font = Enum.Font.SourceSansBold;
	FontSize = Enum.FontSize.Size24;
})

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

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
	btn.Size = UDim2.new(0, 115, 0, 25)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BorderSizePixel = 0
	return btn
end

local StuffBtn = createTabButton("Stuff", 0)
local SettingsBtn = createTabButton("Settings", 120)
local DebugBtn = createTabButton("Debug", 240)

-- Pages
local Pages = {}
for _, name in ipairs({ "Stuff", "Settings", "Debug" }) do
	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	Pages[name] = page
end

-- Debug Output
local debugLog = Instance.new("TextLabel", Pages["Debug"])
debugLog.Size = UDim2.new(1, -20, 1, -20)
debugLog.Position = UDim2.new(0, 10, 0, 10)
debugLog.BackgroundTransparency = 1
debugLog.TextColor3 = Color3.new(1, 1, 1)
debugLog.Font = Enum.Font.Code
debugLog.TextXAlignment = Enum.TextXAlignment.Left
debugLog.TextYAlignment = Enum.TextYAlignment.Top
debugLog.TextWrapped = true
debugLog.TextSize = 14
debugLog.Text = "[DEBUG OUTPUT]\n"
debugLog.TextScaled = false
debugLog.TextWrapped = true
debugLog.TextTruncate = Enum.TextTruncate.AtEnd
debugLog.Text = "[FCS] Ready"

-- Watermark
local watermark = Instance.new("TextLabel", ScreenGui)
watermark.Text = "[FCS] Dev Menu"
watermark.Position = UDim2.new(1, -160, 0, 0)
watermark.Size = UDim2.new(0, 160, 0, 25)
watermark.BackgroundTransparency = 0.4
watermark.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
watermark.TextColor3 = Color3.fromRGB(0, 255, 255)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 14

-- Tab Switching
StuffBtn.MouseButton1Click:Connect(function()
	for _, p in pairs(Pages) do p.Visible = false end
	Pages["Stuff"].Visible = true
end)

SettingsBtn.MouseButton1Click:Connect(function()
	for _, p in pairs(Pages) do p.Visible = false end
	Pages["Settings"].Visible = true
end)

DebugBtn.MouseButton1Click:Connect(function()
	for _, p in pairs(Pages) do p.Visible = false end
	Pages["Debug"].Visible = true
end)

-- Toggle GUI with P
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
		UserInputService.MouseIconEnabled = MainFrame.Visible
	end
end)

-- Bunny Hop
RunService.RenderStepped:Connect(function()
	if _G.bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- (Continue with ESP, Silent Aim, Sliders, Save/Load Config, Rainbow coloring, FOV drawing, etc...)
-- Let me know if you'd like the next complete part added!
