local zmq = require 'zmq'
local context = assert(zmq.context())

return function(hostname, numPixels)
local M = {}
local numPixels = numPixels or 4
local socket = assert(context.socket(zmq.ZMQ_REQ))

local poll
local pollingTimeout = 50

local function pixelPolling(timeout)
	poll.start()
end

local function setPixel(index, r, g, b)
	if type(r)=="number" and type(g)=="number" and type(b)=="number" then
		assert(socket.sendMultipart({tostring(index), tostring(r), tostring(g), tostring(b), ' '}))
	end
end

local counter = 0

local function trinketOn()
	for index=0,numPixels-1 do
		local r,g,b = (function(c)
			local b = (c >= 1) and 255 or 0
			return 64,80,255
		end)(1)

		counter = counter + 1
		setPixel(index, r,g,b)
		pixelPolling()
	end
end

local function trinketOff()
	for index=0,numPixels-1 do
		setPixel(index, 0,0,0)
		pixelPolling()
	end
end

local function trinketFn(fn)
	return function()
		for index=0,numPixels-1 do
			local r,g,b = fn()
			counter = counter + 1
			setPixel(index, r,g,b)
			pixelPolling()
		end
	end
end

local function init()
	assert(socket.connect(("tcp://%s:6042"):format(hostname or "192.168.13.68")))

	poll = zmq.poll {
		{socket, zmq.ZMQ_POLLIN, function(s)
			local result = assert(socket.recvMultipart())
		end},
	}

	trinketOn() -- turns on default LEDs mode on startup
end

local function quit()
	socket.disconnect()

	trinketOff() -- turns off LEDs on quit
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
M.blue = trinketFn(function(c)
	return 0,0,255
end)
M.custom = function(r,g,b)
	(trinketFn(function(c)
		return r or 0,g or 0,b or 0
	end))()
end
M.custom1 = function(index, r, g, b)
	setPixel(index-1, r, g, b)
	pixelPolling()
end
M.custom2 = function(index, r, g, b)
	setPixel(index-1, math.min(r,255), math.min(g,255), math.min(b,255))
	pixelPolling()
end
M.poll = function(timeout)
	poll.start(timeout)
end

return M

end
