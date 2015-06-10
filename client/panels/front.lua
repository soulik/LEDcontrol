local config = require 'config'
local colors = require 'colors'
local pixelsProto = require 'pixels'
local pixelsProtoDummy = require 'pixels/dummy'
local effects = require 'effects'

return function(interface)
	local allPixels = interface.allPixels
	local gui = interface.gui

	--local pixels = interface.addPixels(pixelsProto("192.168.13.68", 4))
	local pixels = interface.addPixels(pixelsProto("127.0.0.1", 4))

	local timer = gui.addTimer(function()
         if type(currentEffect)=='function' then
            currentEffect()
         end
   end)

   return {title = 'Front', desc = 'Front panel',
   		menu = {
            -- *************************************************************************************
            -- Static
            -- *************************************************************************************
            {title = 'Default (fluorescent)', desc = 'Light blue color', fn = function()
               timer.stop()
               pixels.on()
               gui.setIconOn()
            end},
   			{title = 'White', desc = 'White color', fn = function()
   		    	timer.stop()
   		    	pixels.white()
               gui.setIconOn()
   			end},
   			{title = 'Red', desc = 'Red color', fn = function()
   		    	timer.stop()
   		    	pixels.red()
               gui.setIconOn()
   			end},
   			{title = 'Green', desc = 'Green color', fn = function()
   		    	timer.stop()
   		    	pixels.green()
               gui.setIconOn()
   			end},
   			{title = 'Blue', desc = 'Blue color', fn = function()
   		    	timer.stop()
   		    	pixels.blue()
               gui.setIconOn()
   			end},
   			{title = 'Custom', desc = 'Custom color', fn = function()
       			local color = gui.pickColor()
       			if color then
	   		    	timer.stop()
   			    	pixels.custom(color.r, color.g, color.b)
                  gui.setIconOn()
               end
   			end},
            -- *************************************************************************************
            -- Interactive
            -- *************************************************************************************
   			{title = 'Interactive', desc = 'Interactive LEDs', fn = function()
               currentEffect = effects.interactive(pixels)
   		    	timer.start(1)
               gui.setIconAnimated()
   			end},
            {title = 'Interactive inverted', desc = 'Interactive LEDs', fn = function()
               currentEffect = effects.interactiveInv(pixels)
               timer.start(1)
               gui.setIconAnimated()
            end},
            {title = 'Interactive + Time adaptive (old)', desc = 'Interactive LEDs', fn = function()
               currentEffect = effects.interactiveTimeAdaptiveOld(pixels)
               timer.start(1)
               gui.setIconAnimated()
            end},
            {title = 'Interactive + Time adaptive (for night)', desc = 'Interactive LEDs', fn = function()
               currentEffect = effects.interactiveTimeAdaptive(pixels)
               timer.start(1)
               gui.setIconAnimated()
            end},
            -- *************************************************************************************
            -- Animated
            -- *************************************************************************************
   			{title = 'Disco', desc = 'Disco!', fn = function()
   				currentEffect = effects.disco(pixels, 0.5)
   		    	timer.start()
               gui.setIconAnimated()
   			end},
   			{title = 'Fire', desc = 'Fire simulation', fn = function()
   				currentEffect = effects.fire(pixels, 0.1)
   		    	timer.start()
               gui.setIconAnimated()
   			end},
   			{title = 'Strobo', desc = 'Stroboscope', fn = function()
   				currentEffect = effects.strobo(pixels, 0.01)
   		    	timer.start()
               gui.setIconAnimated()
   			end},
            {title = 'Police', desc = 'Police beacon', fn = function()
               pixels.off()
               currentEffect = effects.police(pixels, 0.1)
               timer.start()
               gui.setIconAnimated()
            end},
            -- *************************************************************************************
            -- Turned off
            -- *************************************************************************************
            {title = 'Off', desc = 'LEDs Off', fn = function()
               timer.stop()
               pixels.off()
               gui.setIconOff()
            end},
   		},
   	}
end