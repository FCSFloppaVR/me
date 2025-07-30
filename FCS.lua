--// FCS MENU GUI (StarterGui > ScreenGui)

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- PLAYER
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- SETTINGS
local settings = {
    aimEnabled = false,
    headTracking = false,
    espEnabled = false,
    espColor = Color3.fromRGB(0, 255, 0),
    circleVisible = true,
    circleSize = 100,
    teamCheck = true,
    fpsBoost = false
}

-- GUI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FCS_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 350)
mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundTransparency = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "FCS MENU"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = mainFrame

local tabs = {"AIM", "visuals", "Discord", "settings"}
local contentFrames = {}

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0, 120, 1, 0)
tabFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
tabFrame.Parent = mainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = tabFrame

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.9, 0, 0, 30)
    tabButton.Position = UDim2.new(0.05, 0, 0, 45 * (i-1))
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabFrame

    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 10)
    tabBtnCorner.Parent = tabButton

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -120, 1, -40)
    content.Position = UDim2.new(0, 120, 0, 40)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = mainFrame
    contentFrames[tabName] = content

    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(contentFrames) do frame.Visible = false end
        content.Visible = true
    end)
end

-- Toggle menu with "P"
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.P then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- BUTTON CREATOR FUNCTION
local function createToggleButton(parent, text, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local function updateColor()
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0,255,0) or Color3.fromRGB(40,40,40)
    end

    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateColor()
    end)

    updateColor()
end

-- AIM TAB BUTTONS
createToggleButton(contentFrames["AIM"], "Enable Aimbot", "aimEnabled")
createToggleButton(contentFrames["AIM"], "Enable Head Tracking", "headTracking")

-- VISUAL TAB BUTTONS
createToggleButton(contentFrames["visuals"], "Enable ESP", "espEnabled")
createToggleButton(contentFrames["visuals"], "Enable FPS Boost", "fpsBoost")

-- DISCORD BUTTON
local discordButton = Instance.new("TextButton")
discordButton.Size = UDim2.new(0, 200, 0, 40)
discordButton.Position = UDim2.new(0, 20, 0, 20)
discordButton.Text = "Join Discord"
discordButton.Font = Enum.Font.SourceSans
discordButton.TextScaled = true
discordButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
discordButton.TextColor3 = Color3.new(1, 1, 1)
discordButton.Parent = contentFrames["Discord"]

local dcCorner = Instance.new("UICorner")
dcCorner.CornerRadius = UDim.new(0, 10)
dcCorner.Parent = discordButton

discordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/yourserver")
    StarterGui:SetCore("SendNotification", {
        Title = "Discord Link Copied",
        Text = "Paste it into your browser",
        Duration = 3
    })
end)

-- AIM CIRCLE
local aimCircle = Drawing.new("Circle")
aimCircle.Visible = settings.circleVisible
aimCircle.Radius = settings.circleSize
aimCircle.Color = Color3.new(1, 1, 1)
aimCircle.Thickness = 1
aimCircle.Filled = false

RunService.RenderStepped:Connect(function()
    aimCircle.Position = Vector2.new(mouse.X, mouse.Y)
end)

-- Aimbot Tracking
local function getClosestPlayerToCursor()
    local closest
    local shortest = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if dist < settings.circleSize and dist < shortest then
                    if not settings.teamCheck or plr.Team ~= player.Team then
                        closest = plr
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if settings.aimEnabled or settings.headTracking then
        local target = getClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position), 0.1)
        end
    end
end)

-- ESP HIGHLIGHT
local function drawBox(plr)
    if plr == player or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if not plr.Character:FindFirstChild("FCS_Box") then
        local highlight = Instance.new("Highlight", plr.Character)
        highlight.Name = "FCS_Box"
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = settings.espColor
        highlight.FillColor = settings.espColor
    end
end

RunService.RenderStepped:Connect(function()
    if settings.espEnabled then
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

-- FPS BOOST OPTION
if settings.fpsBoost then
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
        if obj:IsA("Part") or obj:IsA("MeshPart") then obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0 end
    end
end

--[[
To add new features:
- Add more toggle buttons using `createToggleButton(parent, text, settingKey)`
- Add sliders, dropdowns, or color pickers using similar layout
- Use setting keys from the settings table to control behavior
- Save/load preferences using DataStore (optional for later)
]]
