local zmq = require 'zmq'
local context = assert(zmq.context())

return function(hostname, numPixels)
local M = {}
local numPixels = numPixels or 4
local socket = assert(context.socket(zmq.ZMQ_REQ))
local grabber = require 'grabber'
local screen = grabber.new()

local indexTranslate = {
	[0] = 4,
	[1] = 3,
	[2] = 1,
	[3] = 2,
}

local interpolateSteps = 8

local pixels = {}
local poll

local function interpolateTo2x2(pixels, swidth, sheight)
    local wmid,hmid = math.floor(swidth/2),math.floor(sheight/2)

	local out = {}
	for y=1,2 do
		for x=1,2 do
			local cSum = {0,0,0}
			local h0,h1,w0,w1
			if x==1 then
				w0,w1 = 0, wmid-1
			else
				w0,w1 = wmid, swidth-1
			end
			if y==1 then
				h0,h1 = 0, hmid-1
			else
				h0,h1 = hmid, sheight-1
			end

			local c = 0
			for y0 = h0,h1 do
				for x0 = w0,w1 do
					local pixel = pixels[y0*swidth + x0 + 1]
					cSum[1] = cSum[1] + pixel[1]
					cSum[2] = cSum[2] + pixel[2]
					cSum[3] = cSum[3] + pixel[3]
					c = c + 1
				end
			end
			cSum[1] = cSum[1] / c
			cSum[2] = cSum[2] / c
			cSum[3] = cSum[3] / c

			out[(y-1)*2 + x] = cSum
		end
	end
	return out
end

local function interpolate(srcPixels, destPixels, steps)
	local diff = {}
	for i,destPixel in ipairs(destPixels) do
		local srcPixel = srcPixels[i] or {0,0,0}
		local d = {
			(destPixel[1] - srcPixel[1])/steps,
			(destPixel[2] - srcPixel[2])/steps,
			(destPixel[3] - srcPixel[3])/steps,
		}
		diff[i] = d
	end
	return function(step)
		local out = {}
		local count
		if #srcPixels>0 then
			count = #srcPixels
		else
			count = #destPixels
		end

		for i=1,count do
			local srcPixel = srcPixels[i] or {0,0,0}
			local d = diff[i]
			out[i] = {
				srcPixel[1] + d[1]*step,
				srcPixel[2] + d[2]*step,
				srcPixel[3] + d[3]*step,
			}
			--print(i, d[1], d[2], d[3])
		end
		return out
	end
end


local function setPixel(index, r, g, b)
	if type(r)=="number" and type(g)=="number" and type(b)=="number" then
		assert(socket.sendMultipart({tostring(index), tostring(r), tostring(g), tostring(b), ' '}))
	end
end

local counter = 0
local internalCounter = 0
local interpolateFn

local function trinketInteractive()
   	if internalCounter%interpolateSteps == 0 then
   		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
   		interpolateFn = interpolate(pixels, tmpPixels, interpolateSteps)
   	end
   	if type(interpolateFn)=="function" then
   		pixels = interpolateFn(internalCounter%interpolateSteps)
   	end

   	for index=0,3 do
   		local pixel = pixels[indexTranslate[index]] or {0,0,0}
   		local r,g,b = pixel[1], pixel[2], pixel[3]
   		setPixel(index, r, g, b)
   		poll.start()
   	end
   	internalCounter = internalCounter + 1
end

local function trinketOn()
	for index=0,numPixels-1 do
		local r,g,b = (function(c)
			local b = (c >= 1) and 255 or 0
			return 64,80,255
		end)(1)

		counter = counter + 1
		setPixel(index, r,g,b)
		poll.start(50)
	end
end

local function trinketOff()
	for index=0,numPixels-1 do
		setPixel(index, 0,0,0)
		poll.start(50)
	end
end

local function trinketFn(fn)
	return function()
		for index=0,numPixels-1 do
			local r,g,b = fn()
			counter = counter + 1
			setPixel(index, r,g,b)
			poll.start(50)
		end
	end
end


local function init()

	--assert(socket.connect("tcp://192.168.13.68:6042"))
	--assert(socket.connect("tcp://192.168.13.72:6042"))
	assert(socket.connect(("tcp://%s:6042"):format(hostname or "192.168.13.68")))

	poll = zmq.poll()
	poll.add(socket, zmq.ZMQ_POLLIN, function(s)
		local result = assert(socket.recvMultipart())
	end)
end

local function quit()
	socket.disconnect()
end

M.init = init
M.quit = quit
M.on = trinketOn
M.off = trinketOff
M.interactive = trinketInteractive
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
	poll.start(50)
end

return M

end
