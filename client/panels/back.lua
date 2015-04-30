local config = require 'config'
local colors = require 'colors'
local pixelsProto = require 'pixels'
local pixelsProtoDummy = require 'pixels/dummy'
local effects = require 'effects'

return function(interface)
	local allPixels = interface.allPixels
	local gui = interface.gui

	local pixels = interface.addPixels(pixelsProto("192.168.13.72", 5))

	local currentEffect

	local timer = gui.addTimer(function()
   		if type(currentEffect)=='function' then
   			currentEffect()
   		end
	end)

    return {title = 'Back', desc = 'Back panel',
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
   			{title = 'Disco', desc = 'Disco!', fn = function()
   				currentEffect = effects.disco(pixels, 0.5)
   		    	timer.start()
   			end},
   			{title = 'Fire', desc = 'Fire simulation', fn = function()
   				currentEffect = effects.fire(pixels, 0.1)
   		    	timer.start()
   			end},
   			{title = 'Strobo', desc = 'Stroboscope', fn = function()
   				currentEffect = effects.strobo(pixels, 0.01)
   		    	timer.start()
   			end},
   		},
   	}
end