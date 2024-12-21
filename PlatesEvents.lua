--// Variables
local PlatesEvent = {
	Events = {};
	Functions = {};
	Variables = {};
}
local Events, Functions = table.unpack(PlatesEvent)
export type PlateObject<table> = {Plate:Part, PlateId:number, OwnerId:number}
export type EventObject<table> = {
	Data : {
		name : string|nil,          -- Name of the event
		description : string|nil,   -- Description of the event
		playerEvent : boolean|nil,  -- If this event happens to specific players/plates. If false, then it's global.
		min : number|nil;           -- Minimum affected players / Can be expressed in percentage [0;1].
		max : number|nil;           -- Maximum affected players / Can be expressed in percentage [0;1].
		yield : boolean|nil;        -- Tells if the main script should wait for the event to finish before continuing.
		visualize : boolean|nil;    -- Highlight the affected plates if true.
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
		playerEvent = true;
		min = 0.25;
		max = 0.5;
		yield = true;
		visualize = true;
	};
	Event = function(Plate:PlateObject)
		Plate.Plate.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	end;
}

--// Variables 

PlatesEvent.Variables["NumberOfEvents"] = 0
for i in PlatesEvent.Events do PlatesEvent.Variables["NumberOfEvents"]+=1 end

PlatesEvent.Variables["EveryEventsName"] = {}
for i in PlatesEvent.Events do table.insert(PlatesEvent.Variables["EveryEventsName"], i) end

--// Module connections


--// Return
return PlatesEvent
