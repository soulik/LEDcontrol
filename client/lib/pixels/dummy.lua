return function(hostname, numPixels)
local M = {}
local numPixels = numPixels or 4

local function setPixel(index, r, g, b)
	if type(r)=="number" and type(g)=="number" and type(b)=="number" then
	end
end

local counter = 0

local function pixelPolling()
end

local function trinketOn()
	for index=0,numPixels-1 do
		local r,g,b = (function(c)
			local b = (c >= 1) and 255 or 0
			return 64,80,255
		end)(1)

		counter = counter + 1
		setPixel(index, r,g,b)
	end
end

local function trinketOff()
	for index=0,numPixels-1 do
		setPixel(index, 0,0,0)
	end
end

local function trinketFn(fn)
	return function()
		for index=0,numPixels-1 do
			local r,g,b = fn()
			counter = counter + 1
			setPixel(index, r,g,b)
		end
	end
end


local function init()
end

local function quit()
end

M.init = init
M.quit = quit
M.on = trinketOn
M.off = trinketOff
M.white = trinketFn(function(c)
	return 255,255,255
end)
M.red = trinketFn(function(c)
	return 255,0,0
end)
M.green = trinketFn(function(c)
	return 0,255,0
end)
M.custom = function(r,g,b)
	(trinketFn(function(c)
		return r or 0,g or 0,b or 0
	end))()
end
M.custom1 = function(index, r, g, b)
	setPixel(index-1, r, g, b)
end
M.poll = pixelPolling

return M

end
