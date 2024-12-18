--!native

--// Variables
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlatesHandler = require(ServerScriptService:WaitForChild("PlatesHandler"))
local PlatesEvents = require(ServerScriptService:WaitForChild("PlatesEvents"))

local RequiredPlayersNumber = 1
local CurrentNumberOfPlayers = 0
local CurrentPlayers = {}

local MatchInProgess = false
local EventInProgress = false

--// Functions
local function TeleportAllPlayers()
	for i, v in Players:GetPlayers() do
		local PlayerPlate = PlatesHandler.GetPlateFromOwnerId(v.UserId)
		if v~=nil and PlayerPlate~=nil and v.Character~=nil and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") then
			local TeleportCFrame = PlayerPlate.Plate.CFrame*CFrame.new(0, 3, 0)
			v.Character:PivotTo(TeleportCFrame)
		end
	end
end

local function CheckNumberOfPlayers()
	CurrentPlayers = Players:GetPlayers()
	CurrentNumberOfPlayers = #CurrentPlayers
	if CurrentNumberOfPlayers >= RequiredPlayersNumber then
		return true
	else
		for i, v:Player in CurrentPlayers do
			local s, e = pcall(function()
				local Difference = RequiredPlayersNumber-CurrentNumberOfPlayers
				v.PlayerGui.UserInterface.LobbyInfoBar.BarText.Text = tostring(Difference).." more player"..(Difference>1 and"s are" or " is").." required to start the match."
			end)
			if not s then
				table.remove(CurrentPlayers, v)
			end
		end
		return false
	end
end


--// Connect


while not MatchInProgess and task.wait(1) do
	MatchInProgess = true
	
	local PlayerThreshold = CheckNumberOfPlayers()
	print(CurrentPlayers)
	
	if PlayerThreshold then
		local Reponse = PlatesHandler.GeneratePlates()
		repeat task.wait() until Reponse==true
		TeleportAllPlayers()
		
		wait(3) -- Delay after all players got teleported
		
		-- for each event
		PlatesEvents.Events.RandomPlateColor.Event(PlatesHandler.GetPlateFromOwnerId(369742023))
		print("\n")
	end
	
	MatchInProgess = false
end
