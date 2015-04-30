local config = require 'config'
local colors = require 'colors'
local pixelsProto = require 'pixels'
local pixelsProtoDummy = require 'pixels/dummy'
local effects = require 'effects'

return function(interface)
	local allPixels = interface.allPixels
	local gui = interface.gui

	local pixels = interface.addPixels(pixelsProto("192.168.13.68", 4))

	local timer = gui.addTimer(function()
		effects.interactive(pixels)
	end)

    return {title = 'Front', desc = 'Front panel',
   		menu = {
   			{title = 'On', desc = 'LEDs On', fn = function()
   		    	timer.stop()
   		    	pixels.on()
   			end},
   			{title = 'Off', desc = 'LEDs Off', fn = function()
   		    	timer.stop()
   		    	pixels.off()
   			end},
   			{title = 'White', desc = 'White color', fn = function()
   		    	timer.stop()
   		    	pixels.white()
   			end},
   			{title = 'Red', desc = 'Red color', fn = function()
   		    	timer.stop()
   		    	pixels.red()
   			end},
   			{title = 'Green', desc = 'Green color', fn = function()
   		    	timer.stop()
   		    	pixels.green()
   			end},
   			{title = 'Custom', desc = 'Custom color', fn = function()
       			local color = gui.pickColor()
       			if color then
	   		    	timer.stop()
   			    	pixels.custom(color.r, color.g, color.b)
               	end
   			end},
   			{title = 'Interactive', desc = 'Interactive LEDs', fn = function()
   		    	timer.start(1)
   			end},
   		},
   	}
end