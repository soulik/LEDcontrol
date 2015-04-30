local colors = require 'colors'
local counter = 0

local grabber = require 'grabber'
local screen = grabber.new()

local interpolateSteps = 4
local internalCounter = 0
local interpolateFn
local indexTranslate = {
	[0] = 4,
	[1] = 3,
	[2] = 1,
	[3] = 2,
}

local prevPixels = {}

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

local effects = {
	interactive = function(pixels)
       	if internalCounter%interpolateSteps == 0 then
       		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
       		interpolateFn = interpolate(prevPixels, tmpPixels, interpolateSteps)
       	end
       	if type(interpolateFn)=="function" then
       		prevPixels = interpolateFn(internalCounter%interpolateSteps)
       	end

       	for index=0,3 do
       		local pixel = prevPixels[indexTranslate[index]] or {0,0,0}
       		local r,g,b = pixel[1], pixel[2], pixel[3]
       		pixels.custom1(index, r, g, b)
       		--pixels.poll()
       	end
       	internalCounter = internalCounter + 1
	end,

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


return effects