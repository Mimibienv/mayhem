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

local Events = PlatesEvents.Events
local EveryEventsName = PlatesEvents.Variables.EveryEventsName
local NumberOfEvents = PlatesEvents.Variables.NumberOfEvents

--// Functions
local function RNGv2(min:number, max:number, n:number):()->{}
	local outcomes,results = {},{}
	for i=min,max do table.insert(outcomes, i) end
	for i = 1, n do
		local index = math.random(1, #outcomes)
		table.insert(results, outcomes[index])
		table.remove(outcomes, index)
	end
	return results
end

local function TeleportAllPlayers()
	for i, v in Players:GetPlayers() do
		local PlayerPlate = PlatesHandler.GetPlateFromOwnerId(v.UserId)
		if v~=nil and PlayerPlate~=nil and v.Character~=nil and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") then
			local TeleportCFrame = PlayerPlate.Plate.CFrame*CFrame.new(0, 3, 0)
			v.Character:PivotTo(TeleportCFrame)
		end
	end
end

local function UpdatePlayerCounts()
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

local function PickRandomEvent()
	return Events[EveryEventsName[math.random(1,NumberOfEvents)]]
end

--// Connect


while not MatchInProgess and task.wait(1) do
	MatchInProgess = true
	
	local PlayerThreshold = UpdatePlayerCounts()
	print("Current players:", CurrentPlayers)
	
	if PlayerThreshold then
		local Reponse = PlatesHandler.GeneratePlates()
		repeat task.wait() until Reponse==true
		TeleportAllPlayers()
		wait(3)
		
		local RngEvent = PickRandomEvent()
		local Data = RngEvent.Data
		print("RngEvent:", RngEvent)
		
		if Data.playerEvent~=nil and Data.playerEvent then
			local min, max												--------------------------------------
			if Data.min then																				--
				if Data.min<1 then																			--
					min = math.round(CurrentNumberOfPlayers*Data.min)										--
				else																						--
					min = Data.min																			--
				end																							--
				if min<1 then min=1 end																		--
			else																							--
				min=1																						--
			end																								--
			if Data.max then																				--
				if Data.max<1 then																			-- min / max
					max = (Data.max>=Data.min) and math.round(CurrentNumberOfPlayers*Data.max) or min		-- Algorithm
				else																						--
					max = (Data.max>=Data.min) and Data.max or min											--
				end																							--
				if max>CurrentNumberOfPlayers then max=CurrentNumberOfPlayers end							--
			else																							--
				max=CurrentNumberOfPlayers																	--
			end																								--
			print("min, max =", min, max)																	--
																											--
			local AffectedPlates = {}																		--
			local ChosenPlayers = RNGv2(1, CurrentNumberOfPlayers, math.random(min, max))					--
			print("Chosen Players:", ChosenPlayers)											------------------
			
			for i, v in ChosenPlayers do
				local PlayerPlate = PlatesHandler.GetPlateFromIndex(v)  --GetPlateFromOwnerId(CurrentPlayers[v].UserId)
				if PlayerPlate~=nil then
					table.insert(AffectedPlates, PlayerPlate)
				end
			end
			for i, v in AffectedPlates do
				RngEvent.Event(v)
			end
			print("Affected plates:", AffectedPlates)
		end
		
		--RngEvent.Event(PlatesHandler.GetPlateFromOwnerId(369742023))
		print("\n========================\n")
	end
	
	MatchInProgess = false
end
