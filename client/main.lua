require("wx")
require 'bit'
local colors = require 'colors'

local pixelsProto = require 'pixels'
local pixels = {
	pixelsProto("192.168.13.68", 4),
	pixelsProto("192.168.13.72", 5),
}
local frame, taskbar, menu, icon, timer
local _menus = {}
local quit

local function allPixels(fn)
	assert(type(fn)=='function')
    for _, _pixels in ipairs(pixels) do
    	fn(_pixels)
	end
end

local counter = 0

local effects = {
	strobo = function(pixel, speed)
		return function()
			for i=1,5 do
				local r,g,b = 0,0,0
				if counter%2==0 then
					r,g,b = 0,0,0
				else
					r,g,b = 255,255,255
				end
				--local h,s,l = math.sin(math.rad(counter/speed + i*(360/5)))*0.5+0.5, 1, 0.5
				--local r,g,b = colors.RGB888(colors.hsl2rgb(h,s,l))
				pixel.custom1(i, r, g, b)
			end
			counter = counter + 1
			if counter > 360*speed then
				counter = 0
			end
		end
	end,
	disco = function(pixel, speed)
		return function()
			for i=1,5 do
				local h,s,l = math.sin(math.rad(counter/speed + i*(360/5)))*0.5+0.5, 1, 0.5
				local r,g,b = colors.RGB888(colors.hsl2rgb(h,s,l))
				pixel.custom1(i, r, g, b)
			end
			counter = counter + 1
			if counter > 360*speed then
				counter = 0
			end
		end
	end,
	fire = function(pixel, speed)
		return function()
			for i=1,5 do
				local v0 = math.sin(math.rad(counter/speed*2 + i*(90/5)))
				local v1 = math.sin(math.rad(counter/speed + i*(360/5)))
				local h,s,l = v0*0.025+0.025, 1, v1*0.35+0.35
				local r,g,b = colors.hsl2rgb(h,s,l)
				local R,G,B = colors.RGB888(r,g,b)
				pixel.custom1(i, R, G, B)
				--print(h,s,l,' >> ', r,g,b, ' >> ' , R,G,B)
			end
			counter = counter + 1
			if counter > 360*speed then
				counter = 0
			end
		end
	end,
}

local ID_IDCOUNTER = wx.wxID_HIGHEST + 1
function NewID()
   	ID_IDCOUNTER = ID_IDCOUNTER + 1
    return ID_IDCOUNTER
end

local function _createMenu(parent)
	local function m(t)
		local t = t or {}
		assert(type(t)=='table')
		local menu = wx.wxMenu()

		for i,item in ipairs(t) do
			assert(type(item)=='table')

			if type(item.menu)=='table' then
	    		local submenu = m(item.menu)
				local id = item.id or NewID()
			    menu:Append(id, item.title, submenu, item.desc or '')
	    	else
				local id = item.id or NewID()
			    menu:Append(id, item.title, item.desc or '')
			    parent:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, item.fn)
	    	end
		end
		table.insert(_menus, menu)
		return menu
	end
	return m
end

local function main()
	local menuIDs = {
		exit = wx.wxID_EXIT,
		on = NewID(),
		off = NewID(),
		white = NewID(),
		red = NewID(),
		green = NewID(),
		interactive = NewID(),
	}

    frame = wx.wxFrame( wx.NULL,            -- no parent for toplevel windows
                        wx.wxID_ANY,          -- don't need a wxWindow ID
                        "Ambient Lighting", -- caption on the frame
                        wx.wxDefaultPosition, -- let system place the frame
                        wx.wxSize(1, 1),  -- set the size of the frame
                        bit.bor(wx.wxFRAME_NO_TASKBAR, wx.wxNO_FULL_REPAINT_ON_RESIZE) ) -- use default frame styles

    frame:Show(true)

    icon = wx.wxIcon()
    icon:LoadFile('led6.png', wx.wxBITMAP_TYPE_PNG)

    taskbar = wx.wxTaskBarIcon()
    taskbar:SetIcon(icon, 'Ambient Lighting')

	local function pickColor()
        local dlg = wx.wxColourDialog(frame)
        dlg:SetTitle("Color Picker")

        if (dlg:ShowModal() ~= wx.wxID_OK) then
            return
        end
		local color = dlg:GetColourData():GetColour()
		return {r = color:Red(), g = color:Green(), b = color:Blue()}
	end

	local timerID = NewID()
	timer = wx.wxTimer(taskbar, timerID)

	local function startTimer()
		if not timer:IsRunning() then
			timer:Start(1)
		end
	end

	local function stopTimer()
		if timer:IsRunning() then
			timer:Stop()
		end
	end

	local timerCID = NewID()
	timerC = wx.wxTimer(taskbar, timerCID)

	local function startTimerC()
		if not timerC:IsRunning() then
			timerC:Start(1)
		end
	end

	local function stopTimerC()
		if timerC:IsRunning() then
			timerC:Stop()
		end
	end

	local currentEffect

    taskbar:Connect(wx.wxEVT_TIMER, function(event)
    	local id = event:GetId()
    	if id == timerID then
    		pixels[1].interactive()
    	elseif id == timerCID then
    		if type(currentEffect)=='function' then
    			currentEffect()
    		end
    	end
    end)

    local M = _createMenu(taskbar)

    menu = M {
    	{title = 'All', desc = 'All panels',
    		menu = {
    			{title = 'On', desc = 'LEDs On', fn = function()
			    	stopTimer()
			    	allPixels(function(pixels)
				    	pixels.on()
			    	end)
    			end},
    			{title = 'Off', desc = 'LEDs Off', fn = function()
			    	stopTimer()
			    	allPixels(function(pixels)
				    	pixels.off()
			    	end)
    			end},
    			{title = 'White', desc = 'White color', fn = function()
			    	stopTimer()
			    	allPixels(function(pixels)
				    	pixels.white()
			    	end)
    			end},
    			{title = 'Red', desc = 'Red color', fn = function()
			    	stopTimer()
			    	allPixels(function(pixels)
				    	pixels.red()
			    	end)
    			end},
    			{title = 'Green', desc = 'Green color', fn = function()
			    	stopTimer()
			    	allPixels(function(pixels)
				    	pixels.green()
			    	end)
    			end},
    			{title = 'Custom', desc = 'Custom color', fn = function()
	    			local color = pickColor()
	    			if color then
				    	stopTimer()
			    		allPixels(function(pixels)
					    	pixels.custom(color.r, color.g, color.b)
			    		end)
			    	end
    			end},
    			{title = 'Interactive', desc = 'Interactive LEDs', fn = function()
			    	startTimer()
    			end},
    		},
    	},
    	{title = 'Front', desc = 'Front panel',
    		menu = {
    			{title = 'On', desc = 'LEDs On', fn = function()
			    	stopTimer()
			    	pixels[1].on()
    			end},
    			{title = 'Off', desc = 'LEDs Off', fn = function()
			    	stopTimer()
			    	pixels[1].off()
    			end},
    			{title = 'White', desc = 'White color', fn = function()
			    	stopTimer()
			    	pixels[1].white()
    			end},
    			{title = 'Red', desc = 'Red color', fn = function()
			    	stopTimer()
			    	pixels[1].red()
    			end},
    			{title = 'Green', desc = 'Green color', fn = function()
			    	stopTimer()
			    	pixels[1].green()
    			end},
    			{title = 'Custom', desc = 'Custom color', fn = function()
	    			local color = pickColor()
	    			if color then
				    	stopTimer()
				    	pixels[1].custom(color.r, color.g, color.b)
                	end
    			end},
    			{title = 'Interactive', desc = 'Interactive LEDs', fn = function()
			    	startTimer()
    			end},
    		},
    	},
    	{title = 'Back', desc = 'Back panel',
    		menu = {
    			{title = 'On', desc = 'LEDs On', fn = function()
			    	stopTimerC()
			    	pixels[2].on()
    			end},
    			{title = 'Off', desc = 'LEDs Off', fn = function()
			    	stopTimerC()
			    	pixels[2].off()
    			end},
    			{title = 'White', desc = 'White color', fn = function()
			    	stopTimerC()
			    	pixels[2].white()
    			end},
    			{title = 'Red', desc = 'Red color', fn = function()
			    	stopTimerC()
			    	pixels[2].red()
    			end},
    			{title = 'Green', desc = 'Green color', fn = function()
			    	stopTimerC()
			    	pixels[2].green()
    			end},
    			{title = 'Custom', desc = 'Custom color', fn = function()
	    			local color = pickColor()
	    			if color then
				    	stopTimerC()
				    	pixels[2].custom(color.r, color.g, color.b)
                	end
    			end},
    			{title = 'Disco', desc = 'Disco!', fn = function()
    				currentEffect = effects.disco(pixels[2], 0.5)
			    	startTimerC()
    			end},
    			{title = 'Fire', desc = 'Fire simulation', fn = function()
    				currentEffect = effects.fire(pixels[2], 0.1)
			    	startTimerC()
    			end},
    			{title = 'Strobo', desc = 'Stroboscope', fn = function()
    				currentEffect = effects.strobo(pixels[2], 0.01)
			    	startTimerC()
    			end},
    		},
    	},
    	{id = wx.wxID_EXIT, title = 'E&xit', desc = 'Quits the program', fn = function()
	    	stopTimer()
	    	stopTimerC()
    		quit()
	    	frame:Close(true)
    	end},
    }


   	taskbar:Connect(wx.wxEVT_TASKBAR_LEFT_UP, function(event)
    	taskbar:PopupMenu(menu)
    end)
   	taskbar:Connect(wx.wxEVT_TASKBAR_RIGHT_UP, function(event)
    	taskbar:PopupMenu(menu)
    end)

    for _, _pixels in ipairs(pixels) do
		_pixels.init()
		_pixels.off()
	end

	wx.wxGetApp():MainLoop()
end

function quit()
   	allPixels(function(pixels)
		pixels.quit()
	end)
	local app = wx.wxGetApp()
    app:ExitMainLoop()
end

main()
