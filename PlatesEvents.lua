--// Variables
local PlatesEvent = {
	Events = {};
	Functions = {};
}
local Events, Functions = table.unpack(PlatesEvent)
export type PlateObject<table> = {Plate:Part, PlateId:number, OwnerId:number}
export type EventObject<table> = {
	Data : {
		name : string|nil,
		description : string|nil,
		min : number|nil;
		max : number|nil;
		yield : boolean|nil;
		visualize : boolean|nil;
	},
	Event : (Plate<PlateObject>) -> (ExtraData<table>)
}

--// Functions


--// Events

PlatesEvent.Events["RandomPlateColor"] = {
	Data = {
		name = "name fr";
		description = "desc"; 
		subtitle = "'s plate will be colored";
		min = 1;
		max = 49;
		yield = true;
		visualize = true;
	};
	Event = function(Plate:PlateObject, ExtraData)
		Plate.Plate.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	end;
}


--// Module connections


--// Return
return PlatesEvent
