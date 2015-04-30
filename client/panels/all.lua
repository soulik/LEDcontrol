local config = require 'config'
local colors = require 'colors'
local pixelsProto = require 'pixels'
local pixelsProtoDummy = require 'pixels/dummy'

return function(interface)
	local pixels = interface.pixels
	local allPixels = interface.allPixels
	local gui = interface.gui

    return {title = 'All', desc = 'All panels',
   		menu = {
   			{title = 'On', desc = 'LEDs On', fn = function()
   		    	gui.stopTimer()
   		    	allPixels(function(pixels)
   			    	pixels.on()
   		    	end)
   			end},
   			{title = 'Off', desc = 'LEDs Off', fn = function()
   		    	gui.stopTimer()
   		    	allPixels(function(pixels)
   			    	pixels.off()
   		    	end)
   			end},
   			{title = 'White', desc = 'White color', fn = function()
   		    	gui.stopTimer()
   		    	allPixels(function(pixels)
   			    	pixels.white()
   		    	end)
   			end},
   			{title = 'Red', desc = 'Red color', fn = function()
   		    	gui.stopTimer()
   		    	allPixels(function(pixels)
   			    	pixels.red()
   		    	end)
   			end},
   			{title = 'Green', desc = 'Green color', fn = function()
   		    	gui.stopTimer()
   		    	allPixels(function(pixels)
   			    	pixels.green()
   		    	end)
   			end},
   			{title = 'Custom', desc = 'Custom color', fn = function()
       			local color = M.pickColor()
       			if color then
   			    	gui.stopTimer()
   		    		allPixels(function(pixels)
   				    	pixels.custom(color.r, color.g, color.b)
   		    		end)
   		    	end
   			end},
   			{title = 'Interactive', desc = 'Interactive LEDs', fn = function()
   		    	gui.startTimer()
   			end},
   		},
   	}
end
