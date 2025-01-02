local Players = game:GetService("Players")
local InfobarManager = {}



InfobarManager.BarText = function(barNum:number, plrs:Player|{Player}, txt:string, add:false?|true)
	if not (barNum==1 or barNum==2) then return end
	if typeof(plrs)=="Instance" and plrs.Parent==Players then
		plrs.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text = add and plrs.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text..txt or txt
	elseif type(plrs)=="table" then
		for i, v in plrs do
			if typeof(v)=="Instance" and v.Parent==Players then
				v.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text = add and v.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text..txt or txt
			end
		end
	end
end


InfobarManager.BarClear = function(barNum:number, plrs:Player|{Player})
	if typeof(plrs)=="Instance" and plrs.Parent==Players then
		plrs.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text = ""
	elseif type(plrs)=="table" then
		for i, v in plrs do
			if typeof(v)=="Instance" and v.Parent==Players then
				v.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Text = ""
			end
		end
	end
end


InfobarManager.BarHide = function(barNum:number, plrs:Player|{Player})
	if typeof(plrs)=="Instance" and plrs.Parent==Players then
		plrs.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Visible = false
	elseif type(plrs)=="table" then
		for i, v in plrs do
			if typeof(v)=="Instance" and v.Parent==Players then
				v.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Visible = false
			end
		end
	end
end


InfobarManager.BarShow = function(barNum:number, plrs:Player|{Player})
	if typeof(plrs)=="Instance" and plrs.Parent==Players then
		plrs.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Visible = true
	elseif type(plrs)=="table" then
		for i, v in plrs do
			if typeof(v)=="Instance" and v.Parent==Players then
				v.PlayerGui.UserInterface.InfoBar["BarText"..tostring(barNum)].Visible = true
			end
		end
	end
end


return InfobarManager
