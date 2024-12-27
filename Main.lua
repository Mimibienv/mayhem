--!native

--// Variables
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlatesHandler = require(ServerScriptService:WaitForChild("PlatesHandler"))
local PlatesEvents = require(ServerScriptService:WaitForChild("PlatesEvents"))
local InfobarManager = require(ServerScriptService:WaitForChild("InfobarManager"))

local RequiredPlayersNumber = 1
local CurrentNumberOfPlayers = 0
local CurrentPlayers = {}
local CurrentNumberOfPlayersInGame = 0
local CurrentPlayersInGame = {}
local PlayersWinCount = 1

local MatchInProgess = false
local EventInProgress = false
local TotalEventsPlayed = 0

local sanity = nil -- TODO: therapy

local Events = PlatesEvents.Events
local EveryEventsName = PlatesEvents.Variables.EveryEventsName
local NumberOfEvents = PlatesEvents.Variables.NumberOfEvents

local IntermissionCooldown = 5
local TeleportCooldown = 5

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

local function InitPlayerCounts()
	CurrentPlayers = Players:GetPlayers()
	-- Dead players filtering
	for i, v in CurrentPlayers do
		if v==nil
			or v.Character==nil
			or not v.Character:FindFirstChildOfClass("Humanoid")
			or v.Character:FindFirstChildOfClass("Humanoid").Health<=0
			or not v.Character:FindFirstChild("Head")
		then table.remove(CurrentPlayers, i)
		end
	end
	-- /Dead players filtering
	CurrentNumberOfPlayers = #CurrentPlayers
	if CurrentNumberOfPlayers >= RequiredPlayersNumber then
		CurrentPlayersInGame = CurrentPlayers
		CurrentNumberOfPlayersInGame = CurrentNumberOfPlayers
		return true
	else
		-- Tell players that the required number of players condition to launch the match isn't met
		for i, v:Player in CurrentPlayers do
			local s, e = pcall(function()
				local Difference = RequiredPlayersNumber-CurrentNumberOfPlayers
				InfobarManager.BarText(1, v, tostring(Difference).." more player"..(Difference>1 and"s are" or " is").." required to start the match.")
				--v.PlayerGui.UserInterface.InfoBar.BarText1.Text = tostring(Difference).." more player"..(Difference>1 and"s are" or " is").." required to start the match."
			end)
			if not s then
				table.remove(CurrentPlayers, i)
			end
		end
		return false
	end
end

local function PickRandomEvent()
	return Events[EveryEventsName[math.random(1,NumberOfEvents)]]
end

local function MatchWon():()->boolean<chat<is|this<real?>>>
	if CurrentNumberOfPlayersInGame<=PlayersWinCount then
		return true
	end
	return false
end

local function HandleWin()
	PlatesHandler.ClearPlates()
	
	for i, winner:Player in CurrentPlayersInGame do
		--[[
		TODO: Handle winner's win, data, etc
		]]
		if winner and winner.Character and winner.Character:FindFirstChildOfClass("Humanoid") then
			winner.Character.Humanoid.Health=-727
		end
		
		task.wait(IntermissionCooldown)
	end
end


--// Connect


while not MatchInProgess and task.wait(1) do
	MatchInProgess = true
	
	local PlayerThreshold = InitPlayerCounts()
	print("Current players:", CurrentPlayers)
	
	for i, v:Player in CurrentPlayersInGame do
		if v then
			if v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
				v.Character.Humanoid.Died:Connect(function()
					table.remove(CurrentPlayersInGame,i)
					CurrentNumberOfPlayersInGame-=1
					PlatesHandler.RemovePlateFromOwnerId(v.UserId)
				end)
			else
				table.remove(CurrentPlayersInGame,i)
				CurrentNumberOfPlayersInGame-=1
				PlatesHandler.RemovePlateFromOwnerId(v.UserId)
			end
		end
	end
	
	if PlayerThreshold then
		local Reponse = PlatesHandler.GeneratePlates()
		repeat task.wait() until Reponse==true
		
		
		--TODO: Cooldown saying "starting in"
		TeleportAllPlayers()
		
		task.wait(TeleportCooldown)
		
		-- Match

		while task.wait(.25) and not EventInProgress do
			print("Current players in match:", CurrentNumberOfPlayersInGame, CurrentPlayersInGame)
			
			local RngEvent = PickRandomEvent()
			local Data = RngEvent.Data
			--print("RngEvent Picked:", RngEvent)
			
			if Data.playerEvent then
				EventInProgress = true
				
				--Algorithm Start--
				local min, max
				if Data.min then
					if Data.min<1 then
						min = math.round(CurrentNumberOfPlayers*Data.min)
					else
						min = Data.min
					end
					if min<1 then min=1 end
				else
					min=1
				end
				if Data.max then
					if Data.max<1 then
						max = (Data.max>=Data.min) and math.round(CurrentNumberOfPlayers*Data.max) or min
					else
						max = (Data.max>=Data.min) and Data.max or min
					end
					if max>CurrentNumberOfPlayers then max=CurrentNumberOfPlayers end
				else
					max=CurrentNumberOfPlayers
				end
				print("min, max =", min, max)
				
				local ChosenPlayers = RNGv2(1, CurrentNumberOfPlayers, math.random(min, max))
				print("Chosen Players for event:", ChosenPlayers)
				--Algorithm End--
				
				local AffectedPlates = {}
				for i, v in ChosenPlayers do
					local PlayerPlate = PlatesHandler.GetPlateFromIndex(v)  --GetPlateFromOwnerId(CurrentPlayers[v].UserId)
					if PlayerPlate~=nil then
						table.insert(AffectedPlates, PlayerPlate)
					end
				end
				print("Affected plates:", AffectedPlates)
				-- Bar info
				
				NumberOfAffectedPlates = #AffectedPlates
				InfobarManager.BarText(1, CurrentPlayersInGame, string.format(Data.description, NumberOfAffectedPlates, NumberOfAffectedPlates>1 and "s" or ""))
				
				InfobarManager.BarText(2, CurrentPlayersInGame, "Affected plates:")
				task.wait(1)
				for i, v in AffectedPlates do
					InfobarManager.BarText(2, CurrentPlayersInGame, " "..tostring(Players:GetPlayerByUserId(v.OwnerId).Name), true)
					PlatesHandler.HighlightPlate(v)
					task.wait(.5)
				end
				task.wait(1)
				
				for i, v in AffectedPlates do
					PlatesHandler.ClearHighlight(v)
					RngEvent.Event(v)
				end
				
				task.wait(Data.cooldown or 2)
				EventInProgress=false
				
				TotalEventsPlayed+=1
				if MatchWon() then
					HandleWin()
					break
				end
				
				
				print("\n------------------------\n")
			end
		end
		-- Match end
		
		print("\n========================\n")
	end
	
	MatchInProgess = false
end
