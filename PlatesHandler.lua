--// Variables
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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

export type PlateObject = {
	Plate:Part,
	PlateId:number,
	OwnerId:number
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
		print("Generated PlateId:",PlateId)
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

local function GetPlateFromOwnerId(OwnerId:number)
	for i, v in Plates do
		if v["OwnerId"] == OwnerId then
			return v
		end
	end
end

local function HighlightPlate(Plate, Duration)
	if Plate and Plate.Plate and Plate.Plate:isA("BasePart") then
		local SelectionBox = Instance.new("SelectionBox")
		SelectionBox.Name = "HighlightSelectionBox"
		SelectionBox.Color3 = Color3.fromRGB(200)
		SelectionBox.LineThickness = .1
		SelectionBox.SurfaceColor3 = Color3.fromRGB(255)
		SelectionBox.SurfaceTransparency = .75
		SelectionBox.Transparency=0
		SelectionBox.Parent = Plate.Plate
		SelectionBox.Adornee = Plate.Plate
		---------------------------------
		if tonumber(Duration) then
			task.delay(Duration, function()
				if SelectionBox then SelectionBox:Destroy() end
			end)
		end
	end
end

local function ClearHighlight(Plate)
	if Plate and Plate.Plate and Plate.Plate:isA("BasePart") then
		for i, v in Plate.Plate:GetChildren() do
			if v.Name == "HighlightSelectionBox" then
				v:Destroy()
			end
		end
	end
end

local function RemovePlate(Plate:BasePart, i)
	local PlateInstance = Plate.Plate
	table.remove(Plates,i)
	
	HighlightPlate(Plate)	
	task.delay(.5, function()
		local TInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		local Tween1 = TweenService:Create(PlateInstance, TInfo, {Transparency = 1})
		Tween1:Play()
		for i, v:SelectionBox in pairs(PlateInstance:GetChildren()) do
			if v.Name=="HighlightSelectionBox" and v:IsA("SelectionBox") then
				local Tween2 = TweenService:Create(v, TInfo, {SurfaceTransparency = 1, Transparency = 1})
				Tween2:Play()
			end
		end
		task.wait(3)
		PlateInstance.CanCollide = false
		task.wait(1)
		PlateInstance:Destroy()
	end)
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
	if type(x)=="number" and Plates[x] then
		return Plates[x]
	elseif type(x)=="table" then
		local PlatesResult = {}
		for i, v in x do
			if typeof(v)=="number" and Plates[x] then
				table.insert(PlatesResult,Plates[x])
			end
		end
		return PlatesResult
	end
end

PlatesHandler.RemovePlateFromOwnerId = function(OwnerId)
	if type(OwnerId)=="number" then
		for i, v in Plates do
			if v.OwnerId==OwnerId then
				RemovePlate(v, i)
			end
		end
	elseif type(OwnerId)=="table" then
		for i, v in OwnerId do
			for m, p in Plates do
				if p.OwnerId==OwnerId then
					RemovePlate(p, m)
				end
			end
		end
	end
end

PlatesHandler.ClearPlates = function()
	for i, v in Plates do
		if v.Plate~=nil then v.Plate:Destroy() end
	end
	Plates = {}
	
	Settings.PlatesDir:ClearAllChildren()
end

PlatesHandler.HighlightPlate = HighlightPlate
PlatesHandler.ClearHighlight = ClearHighlight

--// Return

return PlatesHandler
