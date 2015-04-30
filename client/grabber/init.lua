local bit = require 'bit'
local M = {}
local function gc(t, gc)
	assert(type(t)=="table" and type(gc)=="function")
	local proxy = newproxy(true); t.__proxy = proxy
	local p_mt = getmetatable(proxy)
	p_mt.__gc = gc
end
local windows = require 'grabber/windows'
local insert = table.insert
local band, rshift = bit.band, bit.rshift

M.new = function( dwidth, dheight, hwnd)
	local obj = {}
	local wnd = windows.GetConsoleWindow()
	windows.FreeConsole()
	local hdc = windows.GetDC(hwnd or 0) -- get the desktop device context
	local hDest = hdc.CreateCompatibleDC() -- create a device context to use yourself

	-- get the height and width of the screen
	local height = windows.GetSystemMetrics(windows.SM_CYVIRTUALSCREEN)
	local width = windows.GetSystemMetrics(windows.SM_CXVIRTUALSCREEN)
	local dwidth, dheight = dwidth or 4, dheight or 4

	print(("Screen dimensions: [%d, %d]"):format(width, height))

	-- create a bitmap
	local hbDesktop = hdc.CreateCompatibleBitmap(dwidth, dheight)

	-- use the previously created device context with the bitmap
	hDest.SelectObject(hbDesktop.raw)

	--hdc.SetStretchBltMode(windows.COLORONCOLOR)
	hDest.SetStretchBltMode(windows.COLORONCOLOR)

	obj.grab = function()
		-- copy from the desktop device context to the bitmap device context
		-- call this once per 'frame'
		assert(windows.StretchBlt(hDest.raw, 0,0, dwidth, dheight, hdc.raw, 0, 0, width, height, windows.SRCCOPY) ~= 0)
		--assert(windows.BitBlt(hDest.raw, 0,0, width, height, hdc.raw, 0, 0, windows.SRCCOPY) ~= 0)

		local pixels = {}
		for y=0,dheight-1 do
			for x=0,dwidth-1 do
				local color = hDest.GetPixel(x, y)
				insert(pixels,{band(color, 0xFF), rshift(band(color,0xFF00),8), rshift(band(color, 0xFF0000), 16),})
			end
		end
		return pixels
	end
	
	gc(obj, function()
	end)
	--wnd.SendMessage(windows.WM_CLOSE)
	return obj
end

return M
