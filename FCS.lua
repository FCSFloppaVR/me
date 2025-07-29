--// FCS Full Dev Menu //--

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

print("[FCS] Dev Menu Loaded ✅")
StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "[FCS] Dev Menu Loaded ✅";
	Color = Color3.fromRGB(0,255,255);
	Font = Enum.Font.GothamBold;
	FontSize = Enum.FontSize.Size24;
})

-- GUI Holder
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FCS_Menu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Watermark
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0,200,0,30)
Watermark.Position = UDim2.new(0,10,0,10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "FCS Dev Menu"
Watermark.TextColor3 = Color3.fromRGB(0,255,255)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 16
RunService.RenderStepped:Connect(function()
	Watermark.Text = string.format("FCS Dev Menu | FPS: %d | Ping: %dms",
		math.floor(1/RunService.RenderStepped:Wait()), math.random(30,70)) -- stub ping
end)

-- Tabs
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "FCS DEV MENU"
Header.TextColor3 = Color3.fromRGB(0,255,255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20

local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundTransparency = 1

local function createTabButton(name, xPos)
	local btn = Instance.new("TextButton", TabButtons)
	btn.Text = name
	btn.Size = UDim2.new(0, 100, 0, 25)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BorderSizePixel = 0
	return btn
end

local StuffBtn = createTabButton("Stuff", 0)
local SettingsBtn = createTabButton("Settings", 100)
local DebugBtn = createTabButton("Debug", 200)
local ConfigBtn = createTabButton("Configs", 300)

local Pages = {}
for _, name in ipairs({"Stuff","Settings","Debug","Configs"}) do
	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = name == "Stuff"
	Pages[name] = page
end

-- Checkbox factory
local function createCheckbox(parent, text, callback)
	local c = Instance.new("TextButton", parent)
	c.Size = UDim2.new(0, 350, 0, 25)
	c.BackgroundColor3 = Color3.fromRGB(30,30,30)
	c.BorderSizePixel = 0
	c.TextColor3 = Color3.new(1,1,1)
	c.Text = "[ ] "..text
	local state = false
	c.MouseButton1Click:Connect(function()
		state = not state
		c.Text = (state and "[X] " or "[ ] ")..text
		if callback then callback(state) end
	end)
	return c
end

-- ESP Settings
local espBoxColor = Color3.fromRGB(0,255,255)
local rainbow = false

-- Silent Aim Settings
local silentAim = false
local aimFov = 100
local smoothness = 0.2

-- Bunnyhop Settings
local bunnyhop = false

-- Stuff Tab
createCheckbox(Pages.Stuff,"ESP",function(v) _G.espEnabled = v end).Position = UDim2.new(0,10,0,0)
createCheckbox(Pages.Stuff,"Rainbow ESP",function(v) rainbow = v end).Position = UDim2.new(0,10,0,30)
createCheckbox(Pages.Stuff,"Head Track",function(v) _G.headTrack = v end).Position = UDim2.new(0,10,0,60)
createCheckbox(Pages.Stuff,"Silent Aim",function(v) silentAim = v end).Position = UDim2.new(0,10,0,90)
createCheckbox(Pages.Stuff,"Bunny Hop",function(v) bunnyhop = v end).Position = UDim2.new(0,10,0,120)

-- Bunnyhop loop
RunService.RenderStepped:Connect(function()
	if bunnyhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		keypress(0x20) -- requires exploit env
		task.wait()
		keyrelease(0x20)
	end
end)

-- Rainbow update
RunService.RenderStepped:Connect(function()
	if rainbow then
		local t = tick()
		espBoxColor = Color3.fromHSV((t*0.2)%1,1,1)
	end
end)

-- Config System
local function saveConfig()
	local data = {
		espColor = {espBoxColor.R*255, espBoxColor.G*255, espBoxColor.B*255},
		aimFov = aimFov,
		smooth = smoothness,
	}
	writefile("fcs_config.json", HttpService:JSONEncode(data))
end
local function loadConfig()
	if isfile("fcs_config.json") then
		local data = HttpService:JSONDecode(readfile("fcs_config.json"))
		espBoxColor = Color3.fromRGB(unpack(data.espColor))
		aimFov = data.aimFov
		smoothness = data.smooth
	end
end

local SaveBtn = Instance.new("TextButton", Pages.Configs)
SaveBtn.Text = "Save Config"
SaveBtn.Size = UDim2.new(0,150,0,30)
SaveBtn.Position = UDim2.new(0,10,0,10)
SaveBtn.MouseButton1Click:Connect(saveConfig)

local LoadBtn = Instance.new("TextButton", Pages.Configs)
LoadBtn.Text = "Load Config"
LoadBtn.Size = UDim2.new(0,150,0,30)
LoadBtn.Position = UDim2.new(0,170,0,10)
LoadBtn.MouseButton1Click:Connect(loadConfig)

-- Debug Tab
local DebugLabel = Instance.new("TextLabel", Pages.Debug)
DebugLabel.Size = UDim2.new(1,0,1,0)
DebugLabel.BackgroundTransparency = 1
DebugLabel.TextColor3 = Color3.new(1,1,1)
DebugLabel.TextScaled = true
RunService.RenderStepped:Connect(function()
	DebugLabel.Text = string.format("FPS: %d\nMemory: %.2f MB", math.floor(1/RunService.RenderStepped:Wait()), collectgarbage("count")/1024)
end)

-- Tab Switch
StuffBtn.MouseButton1Click:Connect(function()
	for k,v in pairs(Pages) do v.Visible = (k=="Stuff") end
end)
SettingsBtn.MouseButton1Click:Connect(function()
	for k,v in pairs(Pages) do v.Visible = (k=="Settings") end
end)
DebugBtn.MouseButton1Click:Connect(function()
	for k,v in pairs(Pages) do v.Visible = (k=="Debug") end
end)
ConfigBtn.MouseButton1Click:Connect(function()
	for k,v in pairs(Pages) do v.Visible = (k=="Configs") end
end)

-- Toggle GUI with P
UserInputService.InputBegan:Connect(function(input,gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
