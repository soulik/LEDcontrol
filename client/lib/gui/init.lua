local config = require 'config'
require 'wx'
require 'bit'

local frame, taskbar, menu, icon
local timers = {}
local _menus = {}
local menuDef = {}
local interface
local M

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

local function createTimer(parent, fn)
	local o = {}
	local timerID = NewID(); o.id = timerID
    local timer = wx.wxTimer(parent, timerID); o.raw = timer

    o.start = function(time)
    	if not timer:IsRunning() then
    		timer:Start(time or 1)
    	end
    end

    o.stop = function()
    	if timer:IsRunning() then
    		timer:Stop()
    	end
    end

    -- dummy timer function
    o.fn = fn or function()
    end

    return o
end

M = {
	init = function(_interface)
		assert(type(_interface)=='table')
		interface = _interface
		interface.gui = M

        frame = wx.wxFrame( wx.NULL,            -- no parent for toplevel windows
                            wx.wxID_ANY,          -- don't need a wxWindow ID
                            "Ambient Lighting", -- caption on the frame
                            wx.wxDefaultPosition, -- let system place the frame
                            wx.wxSize(1, 1),  -- set the size of the frame
                            bit.bor(wx.wxFRAME_NO_TASKBAR, wx.wxNO_FULL_REPAINT_ON_RESIZE) ) -- use default frame styles

        frame:Show(true)

        taskbar = wx.wxTaskBarIcon()
        M.updateIcon('images/icon2.png')

        taskbar:Connect(wx.wxEVT_TIMER, function(event)
        	local id = event:GetId()
        	for _, timer in pairs(timers) do
        		if timer.id == id then
        			if (type(timer.fn)=='function') then
        				local result,msg = pcall(timer.fn)
				   		if not result then
				   			debug.print("Timer error: %s", msg)
				   		end
        			end
        		end
        	end
        end)

	end,

	run = function()
    	wx.wxGetApp():MainLoop()
	end,

   	pickColor = function()
		local dlg = wx.wxColourDialog(frame)
		dlg:SetTitle("Color Picker")

		if (dlg:ShowModal() ~= wx.wxID_OK) then
			return
		end
		local color = dlg:GetColourData():GetColour()
		return {r = color:Red(), g = color:Green(), b = color:Blue()}
	end,

	addTimer = function(fn)
		local timer = createTimer(taskbar, fn)
    	table.insert(timers, timer)
    	return timer
	end,

	startTimer = function(index, time)
		if type(index)=='number' then
			timers[index].start(time)
		else
			for i, timer in pairs(timers) do
				timer.start(time)
			end
		end
	end,

	stopTimer = function(index)
		if type(index)=='number' then
			timers[index].stop()
		else
			for i, timer in pairs(timers) do
				timer.stop()
			end
		end
	end,

	updateIcon = function(fname, text)
        icon = wx.wxIcon()
        icon:LoadFile(fname, wx.wxBITMAP_TYPE_PNG)
        taskbar:SetIcon(icon, text or 'Ambient Lighting')
	end,

	quit = function()
		local app = wx.wxGetApp()
	    app:ExitMainLoop()
	end,

	addPanel = function(panel)
		local p = panel(interface)
		assert(type(p)=='table')
        table.insert(menuDef, p)
	end,

	finishPanels = function()
        local menuObj = _createMenu(taskbar)
        table.insert(menuDef,
        	{id = wx.wxID_EXIT, title = 'E&xit', desc = 'Quits the program', fn = function()
    	    	M.stopTimer()
        		interface.quit()
    	    	frame:Close(true)
        	end}
        )

        menu = menuObj(menuDef)
       	taskbar:Connect(wx.wxEVT_TASKBAR_LEFT_UP, function(event)
        	taskbar:PopupMenu(menu)
        end)
       	taskbar:Connect(wx.wxEVT_TASKBAR_RIGHT_UP, function(event)
        	taskbar:PopupMenu(menu)
        end)
	end,
}


return M