--// ESP LOGIC (Highlight Box) //--  
local function createESP(plr)
	if plr == player then return end
	local function applyHighlight(character)
		if not character:FindFirstChild("FCS_Box") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "FCS_Box"
			highlight.FillTransparency = 1
			highlight.OutlineColor = espBoxColor
			highlight.OutlineTransparency = 0
			highlight.Adornee = character
			highlight.Parent = character
		end
	end

	-- Apply to current character
	if plr.Character then
		applyHighlight(plr.Character)
	end

	-- Re-apply after respawn
	plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart", 5)
		applyHighlight(char)
	end)
end

-- Apply ESP to all current players
for _, otherPlayer in ipairs(Players:GetPlayers()) do
	createESP(otherPlayer)
end

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
