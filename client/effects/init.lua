local colors = require 'colors'
local counter = 0

local grabber = require 'grabber'
local easing = require 'effects/easing'
--local background = require 'effects/background' -- adds to every Pixel, if more than 255 then adds intensity for fifth Pixel
local screen = grabber.new()

local globalEasingFn = easeOutExpo --easeOutQuart

local interpolateSteps = 24 --40
local internalCounter = 0
local interpolateFn
local indexTranslate = {
	[1] = 3, -- left bottom
	[2] = 4, -- right bottom
	[3] = 2, -- left top
	[4] = 1, -- right top
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
			(destPixel[1] - srcPixel[1]), -- R
			(destPixel[2] - srcPixel[2]), -- G
			(destPixel[3] - srcPixel[3]), -- B
		}
		diff[i] = d
	end

	return function(step, easingFn)
		local stepValue
		if type(easingFn)=='function' then
			stepValue = easingFn(step)
			--if math.random(0, 1000) <= 500 then stepValue = easeSmootherstep(step) end
		else
			stepValue = step
		end

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
				srcPixel[1] + d[1]*stepValue, -- R
				srcPixel[2] + d[2]*stepValue, -- G
				srcPixel[3] + d[3]*stepValue, -- B
			}
			--print(i, d[1], d[2], d[3])
		end
		return out
	end
end

local effects = {
	interactive = function(pixels)
		return function()
	       	if internalCounter%interpolateSteps == 0 then
	       		-- prepare interpolate function
	       		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
	       		interpolateFn = interpolate(prevPixels, tmpPixels, interpolateSteps)
	       	end

	       	-- call interpolation function
	       	if type(interpolateFn)=="function" then
	       		-- map step into <0, 1> interval
	       		local stepValue = (internalCounter%interpolateSteps)/(interpolateSteps-1)

	       		-- *************************************************************************************
	       		-- obtain interpolated pixel colors
	       		-- *************************************************************************************

	       		prevPixels = interpolateFn(stepValue, globalEasingFn)
	       	end

	       	for index=1,4 do
	       		local pixel = prevPixels[indexTranslate[index]] or {0,0,0}
	       		local r,g,b = pixel[1], pixel[2], pixel[3]
	       		pixels.custom1(index, r, g, b)
	       		--pixels.poll()
	       	end
	       	internalCounter = internalCounter + 1
	    end
	end,
	interactiveInv = function(pixels)
		return function()
	       	if internalCounter%interpolateSteps == 0 then
	       		-- prepare interpolate function
	       		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
	       		interpolateFn = interpolate(prevPixels, tmpPixels, interpolateSteps)
	       	end

	       	-- call interpolation function
	       	if type(interpolateFn)=="function" then
	       		-- map step into <0, 1> interval
	       		local stepValue = (internalCounter%interpolateSteps)/(interpolateSteps-1)

	       		-- *************************************************************************************
	       		-- obtain interpolated pixel colors
	       		-- *************************************************************************************

	       		prevPixels = interpolateFn(stepValue, globalEasingFn)
	       	end

	       	for index=1,4 do
	       		local pixel = prevPixels[indexTranslate[index]] or {0,0,0}
	       		local r,g,b = pixel[1], pixel[2], pixel[3]
	       		pixels.custom1(index, 255-r, 255-g, 255-b)
	       		--pixels.poll()
	       	end
	       	internalCounter = internalCounter + 1
	    end
	end,
	interactiveTimeAdaptiveOld = function(pixels)
		return function()
			local _date = os.date("*t")
			local _daylight = _date.hour > 6 and _date.hour < 20
			local _midnight = _date.hour > 0 and _date.hour < 4

	       	if internalCounter%interpolateSteps == 0 then
	       		-- prepare interpolate function
	       		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
	       		interpolateFn = interpolate(prevPixels, tmpPixels, interpolateSteps)
	       	end

	       	-- call interpolation function
	       	if type(interpolateFn)=="function" then
	       		-- map step into <0, 1> interval
	       		local stepValue = (internalCounter%interpolateSteps)/(interpolateSteps-1)

	       		-- *************************************************************************************
	       		-- obtain interpolated pixel colors
	       		-- *************************************************************************************

	       		prevPixels = interpolateFn(stepValue, globalEasingFn)
	       	end

	       	for index=1,4 do
	       		local pixel = prevPixels[indexTranslate[index]] or {0,0,0}
	       		local r,g,b = pixel[1], pixel[2], pixel[3]


	       		if _daylight then
	       			pixels.custom1(index, r, g, b)
	       		else
	       			if _midnight then
	       				pixels.custom2(index, r+64, g+64, b+64) -- 196
	       			else
	       				pixels.custom2(index, r+32, g+32, b+32) -- 128
	       			end
	       		end
	       		--return 64,80,255
	       		--pixels.poll()
	       	end
	       	internalCounter = internalCounter + 1
	    end
	end,
	interactiveTimeAdaptive = function(pixels)
		return function()
			--tint.tick()
			local _date = os.date("*t")
			local _daylight = _date.hour > 6 and _date.hour < 20
			local _midnight = _date.hour > 0 and _date.hour < 4

	       	if internalCounter%interpolateSteps == 0 then
	       		-- prepare interpolate function
	       		local tmpPixels = interpolateTo2x2(screen.grab(4,4), 4, 4)
	       		interpolateFn = interpolate(prevPixels, tmpPixels, interpolateSteps)
	       	end

	       	-- call interpolation function
	       	if type(interpolateFn)=="function" then
	       		-- map step into <0, 1> interval
	       		local stepValue = (internalCounter%interpolateSteps)/(interpolateSteps-1)

	       		-- *************************************************************************************
	       		-- obtain interpolated pixel colors
	       		-- *************************************************************************************

	       		prevPixels = interpolateFn(stepValue, globalEasingFn)
	       	end

	       	for index=1,4 do
	       		local pixel = prevPixels[indexTranslate[index]] or {0,0,0}
	       		local r,g,b = pixel[1], pixel[2], pixel[3]

	       		--pixels.custom2(index, r+tint.tint[0], g+tint.tint[1], b+tint.tint[2])

	       		if _daylight then
	       			--pixels.custom1(index, r, g, b)
	       		else
	       			if _midnight then
	       				--pixels.custom1(index, math.max(r,64), math.max(g,128), math.max(b,255))
	       			else
	       				--pixels.custom1(index, math.max(r,32), math.max(g,40), math.max(b,128))
	       			end
	       		end
	       		pixels.custom2(index, r+_date.hour,  g+_date.min*2, b+_date.sec*3)
	       		--return 64,80,255
	       		--pixels.poll()
	       	end
	       	internalCounter = internalCounter + 1
	    end
	end,

	strobo = function(pixel, speed)
		return function()
			local step = 2/speed
			for i=1,4 do
				local r,g,b = 0,0,0
				--if counter%2==0 then
				if counter%step==0 then
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
			for i=1,4 do
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
			for i=1,4 do
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
	police = function(pixel, speed)
		return function()
			local red = 1
			local blue = 240
			--local v2 = easeSmoothstep( easeNormalize( math.sin(math.rad(counter/speed)) ) )
			local v2 =  math.sin(math.rad(counter/speed))*0.5+0.5
			for i=1,2 do
				local v0
				local v1
				if i%2==0 then
					v0 = red
					v1 = math.sin(math.rad(counter/speed + 180))
					pixel.custom1(i+2, 255*v2, 0, 0)
				else
					v0 = blue
					v1 = math.sin(math.rad(counter/speed))
					pixel.custom1(i+2, 0, 0, 255*v2)
				end
				local h,s,l = v0, 1, v1*0.66+0.33 --easeLinear(easeNormalize(v1))*0.33+0.25
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