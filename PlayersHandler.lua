--// Variables
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local R6BodyParts = {"Head", "Left Arm", "Left Leg", "Right Arm", "Right Leg", "Torso"}
local PlayersHandler = {}


--// Functions

PlayersHandler.HighlightPlayer = function(Player, Duration:number?, Red:true?|nil)	
	if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
		local Character = Player.Character
		for i, v in R6BodyParts do
			if Character:FindFirstChild(v) then
				local target = Character[v]
				
				local SelectionBox = Instance.new("SelectionBox")
				SelectionBox.Name = "HighlightSelectionBox"
				SelectionBox.Color3 = Red and Color3.fromRGB(200) or Color3.fromRGB(0,140,250)
				SelectionBox.LineThickness = .1
				SelectionBox.SurfaceColor3 = Red and Color3.fromRGB(255) or Color3.fromRGB(0,188,255)
				SelectionBox.SurfaceTransparency = .75
				SelectionBox.Transparency=0
				SelectionBox.Parent = target
				SelectionBox.Adornee = target
				---------------------------------
				if tonumber(Duration) then
					task.delay(Duration, function()
						if SelectionBox then SelectionBox:Destroy() end
					end)
				end
			end
		end
	end
end

PlayersHandler.ClearHighlight = function(Player)
	if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
		local Character = Player.Character
		for i, v in R6BodyParts do
			if Character:FindFirstChild(v) then
				local target = Character[v]
				for m, p in target:GetChildren() do
					if p.Name == "HighlightSelectionBox" then
						p:Destroy()
					end
				end
			end
		end
	end
end

--// Return

return PlayersHandler
