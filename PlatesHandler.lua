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
	NumberOfPlates = 49;
}


--// Functions
local function RNGv2(min:number, max:number, n:number)
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
	
	local NumberOfPlates = RNGv2(1, Grid^2, #Players:GetPlayers())	
	for Index, Plate in NumberOfPlates do
		print(Plate)
		--[[ How it works
		1) Plate-1 for an origin of 0 instead of 1
		2) Calculate its modulo grid for the x cuz every "grid" studs is a new line. Therefore, for Y it's gonna be the quotient (without the x rest)
		3) Multiply this unit number with the space between each plate. Therefore, it's the space between its size and space between both.
		4) Since we want it to be centered, we remove 1 to the grid and again, multiply it by the space between each plate center.
		   we remove 1 so that, if grid is 7, it's 6/2 so theres 3 on the right and 3 on the left. And if it's 8, it's 3.5 on right and 3.5 on left.
		]]
		local x = ((Plate-1)%Grid)*(DefaultPlateSize+Space)  - ((Grid-1)/2)*(DefaultPlateSize+Space)
		local y = ((Plate-1)//Grid)*(DefaultPlateSize+Space) - ((Grid-1)/2)*(DefaultPlateSize+Space)


		local PlateInstance = Instance.new("Part")
		PlateInstance.Anchored=true
		PlateInstance.Name=tostring(Plate)
		PlateInstance.EnableFluidForces=false
		PlateInstance.Size=Vector3.new(DefaultPlateSize,1,DefaultPlateSize)
		PlateInstance.Position=Origin + Vector3.new(x,0,y)
		PlateInstance.Parent=PlatesDir
		
		Plates[Plate]=PlateInstance
	end
end


--// Module connections
PlatesHandler.SetSetting = function(setting, value)
	Settings[setting] = value
end

PlatesHandler.GetSetting = function(setting)
	return Settings[setting]
end

PlatesHandler.GeneratePlates = function()
	GeneratePlates()
end

PlatesHandler.RemovePlate = function()
end

PlatesHandler.ClearPlates = function()
end

PlatesHandler.GetPlates = function()
end

PlatesHandler.ModifyPlate = function()
end

--// Return
return PlatesHandler
