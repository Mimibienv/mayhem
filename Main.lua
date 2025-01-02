--!native

--// Variables
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlatesHandler = require(ServerScriptService:WaitForChild("PlatesHandler"))
local PlatesEvents = require(ServerScriptService:WaitForChild("PlatesEvents"))
local InfobarManager = require(ServerScriptService:WaitForChild("InfobarManager"))
local PlayersHandler = require(ServerScriptService:WaitForChild("PlayersHandler"))

local RequiredPlayersNumber = 1
local CurrentNumberOfPlayers = 0
local CurrentPlayers = {}
local CurrentNumberOfPlayersInGame = 0
local CurrentPlayersInGame = {}
local PlayersWinCount = 0

local MatchInProgess = false
local EventInProgress = false
local TotalEventsPlayed = 0

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
	local PlrRemovingThread = game.Players.PlayerRemoving:Connect(function(PlayerRemoved)
		local UID = PlayerRemoved.UserId
		for i, v:Player in CurrentPlayersInGame do
			if v.UserId == UID then
				table.remove(CurrentPlayersInGame,i)
				CurrentNumberOfPlayersInGame-=1
			end
		end
		PlatesHandler.RemovePlateFromOwnerId(UID)
	end)
	
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
			
			if Data.eventType == "Plate" or Data.eventType=="Player" then
				EventInProgress = true
				
				--Algorithm Start--
				local min, max
				if Data.min then
					if Data.min<1 then
						min = math.round(CurrentNumberOfPlayersInGame*Data.min)
					else
						min = Data.min
					end
					if min<1 then min=1 end
				else
					min=1
				end
				if Data.max then
					if Data.max<1 then
						max = (Data.max>=Data.min) and math.round(CurrentNumberOfPlayersInGame*Data.max) or min
					else
						max = (Data.max>=Data.min) and Data.max or min
					end
					if max>CurrentNumberOfPlayersInGame then max=CurrentNumberOfPlayersInGame end
				else
					max=CurrentNumberOfPlayersInGame
				end
				print("min, max =", min, max)
				
				local ChosenPlayers = RNGv2(1, CurrentNumberOfPlayersInGame, math.random(min, max))
				print("Chosen Players for event:", ChosenPlayers)
				--Algorithm End--
				
				local Affected = {}
				for i, v in ChosenPlayers do
					if Data.eventType == "Plate" then
						local PlayerPlate = PlatesHandler.GetPlateFromIndex(v)  --GetPlateFromOwnerId(CurrentPlayers[v].UserId)
						if PlayerPlate~=nil then
							table.insert(Affected, PlayerPlate)
						end
					elseif Data.eventType=="Player" then
						local Player = CurrentPlayersInGame[v]
						if Player~=nil then
							table.insert(Affected, Player)
						end
					end
				end
				print("Affected:", Affected)
				-- Bar info
				
				AffectedNumber = #Affected
				InfobarManager.BarText(1, CurrentPlayersInGame, string.format(Data.description, AffectedNumber, AffectedNumber>1 and "s" or ""))
				
				InfobarManager.BarText(2, CurrentPlayersInGame, string.format("Affected %s:", string.lower(Data.eventType)..(AffectedNumber>1 and "s" or "")))
				task.wait(1)
				local LoopedNumber = 0
				for i, v in Affected do
					if typeof(v)=="Instance" and Data.eventType=="Player" then
						InfobarManager.BarText(2, CurrentPlayersInGame, (LoopedNumber>=1 and ", " or " ")..tostring(v.Name), true)
						if Data.visualize then PlayersHandler.HighlightPlayer(v) end
					else
						InfobarManager.BarText(2, CurrentPlayersInGame, (LoopedNumber>=1 and ", " or " ")..tostring(Players:GetPlayerByUserId(v.OwnerId).Name), true)
						if Data.visualize then PlatesHandler.HighlightPlate(v) end
					end
					
					LoopedNumber += 1
					task.wait(.5)
				end
				task.wait(1)
				
				InfobarManager.BarClear(1, CurrentPlayersInGame)
				InfobarManager.BarClear(2, CurrentPlayersInGame)
				for i, v in Affected do
					(typeof(v)=="Instance" and Data.eventType=="Player" and PlayersHandler or PlatesHandler).ClearHighlight(v)
					local s, e = pcall(function()
						RngEvent.Event(v)
					end)
					if not s then warn("EVENT ERROR:", e) end
				end
				
			else -- (if global event)
				
				InfobarManager.BarText(1, CurrentPlayersInGame, Data.description)
				task.wait(2)
				InfobarManager.BarClear(1, CurrentPlayersInGame)
				local s, e = pcall(function()
					RngEvent.Event()
				end)
				if not s then warn("EVENT ERROR:", e) end
				
			end
			
			task.wait(Data.cooldown or 2)
			EventInProgress=false
			
			TotalEventsPlayed+=1
			if MatchWon() then
				HandleWin()
				break
			end
			
			
			print("\n------------------------\n")
			
		end -- while loop --> next event
		-- Match end
		
		PlrRemovingThread:Disconnect() -- Free Server RAM and CPU usage
		print("\n========================\n")
	end
	
	MatchInProgess = false
end
