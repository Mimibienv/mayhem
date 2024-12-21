--// Variables
local Players = game:GetService("Players")

local Plates = {}
local PlatesHandler = {}

local Settings = {
	PlatesDir = workspace:WaitForChild("Plates");
	Origin = Vector3.new(0, 10, 0);
	Space = 10;
	DefaultPlateSize = 16;
	Grid = 7;
	--NumberOfPlates = 49;
}


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

local function GeneratePlates()
	local PlatesDir = Settings.PlatesDir
	local Grid = Settings.Grid
	local Origin = Settings.Origin
	local DefaultPlateSize = Settings.DefaultPlateSize
	local Space = Settings.Space
	local CurrentPlayers = Players:GetPlayers()
	
	local NumberOfPlates = RNGv2(1, Grid^2, #CurrentPlayers)	
	for Index, PlateId in NumberOfPlates do
		print("PlateId:",PlateId)
		local CurrentPlayer = CurrentPlayers[Index] or nil
		if CurrentPlayer==nil
			or CurrentPlayer.Character==nil
			or not CurrentPlayer.Character:FindFirstChildOfClass("Humanoid")
			or CurrentPlayer.Character:FindFirstChildOfClass("Humanoid").Health<=0
			or not CurrentPlayer.Character:FindFirstChild("Head")
		then print("Couldn't load plate") continue end
		--[[ How it works
		1) Plate-1 for an origin of 0 instead of 1
		2) Calculate its modulo grid for the x cuz every "grid" studs is a new line. Therefore, for Y it's gonna be the quotient (without the x rest)
		3) Multiply this unit number with the space between each plate. Therefore, it's the space between its size and space between both.
		4) Since we want it to be centered, we remove 1 to the grid and again, multiply it by the space between each plate center.
		   we remove 1 so that, if grid is 7, it's 6/2 so theres 3 on the right and 3 on the left. And if it's 8, it's 3.5 on right and 3.5 on left.
		]]
		local x = ((PlateId-1)%Grid)*(DefaultPlateSize+Space)  - ((Grid-1)/2)*(DefaultPlateSize+Space)
		local y = ((PlateId-1)//Grid)*(DefaultPlateSize+Space) - ((Grid-1)/2)*(DefaultPlateSize+Space)


		local PlateInstance = Instance.new("Part")
		PlateInstance.Anchored=true
		PlateInstance.Name=tostring(PlateId)
		PlateInstance.EnableFluidForces=false
		PlateInstance.Size=Vector3.new(DefaultPlateSize,1,DefaultPlateSize)
		PlateInstance.Parent=PlatesDir
		PlateInstance.Position=Origin + Vector3.new(x,0,y)
		
		Plates[Index]={
			["Plate"] = PlateInstance;
			["PlateId"] = PlateId;
			["OwnerId"] = CurrentPlayer.UserId
		}
	end
	
	return true -- success
end

local function GetPlateFromOwnerId(OwnerId:string)
	for i, v in Plates do
		if v["OwnerId"] == OwnerId then
			return v
		end
	end
end
local function GetPlateFromPlateId(OwnerId:string)
	for i, v in Plates do
		if v["PlateId"] == OwnerId then
			return v
		end
	end
end

--// Module connections

-- Set a default plate setting
PlatesHandler.SetSetting = function(setting, value)
	Settings[setting] = value
end

-- Get a default plate setting
PlatesHandler.GetSetting = function(setting)
	return Settings[setting]
end

-- Generate the plates
PlatesHandler.GeneratePlates = GeneratePlates

-- Get plate(s)
PlatesHandler.GetPlates = function(Index)
	return Plates
end
PlatesHandler.GetPlateFromOwnerId = function(x)
	if type(x)=="number" and Players:GetPlayerByUserId(x) then
		return GetPlateFromOwnerId(x)
	elseif type(x)=="table" then
		local PlatesResult = {}
		for i, v in x do
			if typeof(v)=="number" and Players:GetPlayerByUserId(v) then
				table.insert(PlatesResult,GetPlateFromOwnerId(v))
			end
		end
		return PlatesResult
	end
end
PlatesHandler.GetPlateFromIndex = function(x)
	if type(x)=="number" and Plates[x] then
		return Plates[x]
	elseif type(x)=="table" then
		local PlatesResult = {}
		for i, v in x do
			if typeof(v)=="number" and Plates[v] then
				table.insert(PlatesResult,Plates[v])
			end
		end
		return PlatesResult
	end
end
PlatesHandler.GetPlateFromPlateId = function(x)
	if type(x)=="number" and Players:GetPlayerByUserId(x) then
		return GetPlateFromPlateId(x)
	elseif type(x)=="table" then
		local PlatesResult = {}
		for i, v in x do
			if typeof(v)=="number" and Players:GetPlayerByUserId(v) then
				table.insert(PlatesResult,GetPlateFromPlateId(v))
			end
		end
		return PlatesResult
	end
end


PlatesHandler.ModifyPlate = function(PlateId,Function)
	
end

PlatesHandler.RemovePlate = function(PlateId)
	if type(PlateId)=="number" then
		local Plate = GetPlateFromPlateId(PlateId)
		if Plate then
			Plate.Plate:Destroy()
			table.remove(Plates,Plate)
		end
	elseif type(PlateId)=="table" then
		for i, v in PlateId do
			local Plate = GetPlateFromPlateId(v)
			if Plate then
				Plate.Plate:Destroy()
				table.remove(Plates,Plate)
			end
		end
	end
end

PlatesHandler.ClearPlates = function()
	for i, v in Plates do
		if v.Plate~=nil then v.Plate:Destroy() end
	end
	Plates = {}
end

--// Return
export type PlateObject = {Plate:Part, PlateId:number, OwnerId:number}
return PlatesHandler
