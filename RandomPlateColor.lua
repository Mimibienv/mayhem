return {
	Data = {
		name = "Random plate colors";
		description = "%* plate%* will be colored"; 
		playerEvent = true;
		min = 0.25;
		max = 0.5;
		cooldown = 2;
		visualize = true;
	};
	Event = function(Plate:PlateObject)
		Plate.Plate.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	end;
}
