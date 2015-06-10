local colors = require 'colors'
local counter = 0

local easing = require 'effects/easing'

local globalEasingFn = easeOutExpo --easeOutQuart

local interpolateSteps = 512
local interpolateLeaps = 10
local internalCounter = 0
local interpolateFn

local tintDay 		= {0,0,0}
local tintNight 	= {32,40,128}
local tintMidnight 	= {64,88,196}

--local M = {}

local function interpolate2(srcTint, destTint, steps)
	local diff = {
		(destTint[1] - srcTint[1]), -- R
		(destTint[2] - srcTint[2]), -- G
		(destTint[3] - srcTint[3]), -- B
	}

	return function(step, easingFn)
		local stepValue
		if type(easingFn)=='function' then
			stepValue = easingFn(step)
		else
			stepValue = step
		end

		local out = {}
			out = {
				srcTint[1] + diff[1]*stepValue, -- R
				srcTint[2] + diff[2]*stepValue, -- G
				srcTint[3] + diff[3]*stepValue, -- B
			}
		return out
	end
end

local M = {
	local tint 		= {0,0,0}
	local finalTint = {0,0,0}
	local prevTint 	= {0,0,0}
	--local r = 0
	--local g = 0
	--local b = 0

	--[[
	init = function()
		tint 		= {0,0,0}
		finalTint 	= {0,0,0}
		prevTint 	= {0,0,0}

		this:timeAdaptive()
	end,
	--]]

	timeAdaptive = function()
		local _date = os.date("*t")
		local h = _date.hour
		--[[
		local isDay 		= h > 6 and h < 20
		local isMidnight 	= h > 23 and h < 4
		local isNight 		= !(isDay or isMidnight)

		prevTint = finalTint
		if isDay then
			finalTint = tintDay
		else if isNight then
			finalTint = tintNight
		else if isMidnight then
			finalTint = tintMidnight
		end
		]]--

		--finalTint = {_date.hour, _date.min*2, _date.sec*3}
	end,

	tick = function()
		if internalCounter%interpolateLeaps == 0 then
			--timeAdaptive()

	       	if internalCounter%interpolateSteps == 0 then
	       		-- prepare interpolate function
	       		interpolateFn = interpolate2(prevTint, finalTint, interpolateSteps)
	       	end

	       	-- call interpolation function
	       	if type(interpolateFn)=="function" then
	       		-- map step into <0, 1> interval
	       		local stepValue = (internalCounter%interpolateSteps)/(interpolateSteps-1)

	       		-- *************************************************************************************
	       		-- obtain interpolated pixel colors
	       		-- *************************************************************************************

	       		tint = interpolateFn(stepValue, globalEasingFn)
	       	end
	    end
       	internalCounter = internalCounter + 1
	end,
}


return M