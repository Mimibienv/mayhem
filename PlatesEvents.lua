--// Variables
local ServerStorage = game:GetService("ServerStorage")
local EventsDirectory = ServerStorage:WaitForChild("Events")

local PlatesEvent = {
	Events = {};
	Functions = {};
	Variables = {};
}

export type PlateObject<table> = {Plate:Part, PlateId:number, OwnerId:number}
export type EventObject<table> = {
	Data : {
		name : string|nil,          -- Name of the event
		description : string|nil,   -- Description of the event
		playerEvent : boolean|nil,  -- If this event happens to specific players/plates. If false, then it's global.
		min : number|nil;           -- Minimum affected players / Can be expressed in percentage [0;1].
		max : number|nil;           -- Maximum affected players / Can be expressed in percentage [0;1].
		cooldown : number|nil;      -- Tells if the main script should wait for the event to finish before continuing.
		visualize : boolean|nil;    -- Highlight the affected plates if true.
	},
	Event : (Plate<PlateObject>) -> (ExtraData<table>)
}

--// Functions


--// Events

for i, EventModule:ModuleScript in EventsDirectory:GetChildren() do
	PlatesEvent.Events[EventModule.Name]=require(EventModule)
end

--// Variables 

PlatesEvent.Variables["NumberOfEvents"] = 0
for i in PlatesEvent.Events do PlatesEvent.Variables["NumberOfEvents"]+=1 end

PlatesEvent.Variables["EveryEventsName"] = {}
for i in PlatesEvent.Events do table.insert(PlatesEvent.Variables["EveryEventsName"], i) end

--// Module connections


--// Return
return PlatesEvent
