require 'core'

local config = require 'config'
local panels = {'front',}

local gui = require 'gui'

local pixels = {}

local function allPixels(fn)
	assert(type(fn)=='function')
    for _, _pixels in ipairs(pixels) do
    	fn(_pixels)
	end
end

local function addPixels(p)
	p.init()
	table.insert(pixels, p)
	return p
end

local function main()
	gui.init({
		quit = function()
		   	allPixels(function(pixels)
		   		--pixels.off()
				pixels.quit()
			end)
			config.sync()
			config.close()
			gui.quit()
		end,
		allPixels = allPixels,
		pixels = pixels,
		addPixels = addPixels,
	})

	for _, name in ipairs(panels) do
		local panel = require (('panels/%s'):format(name))
		gui.addPanel(panel)
	end

	gui.finishPanels()

	gui.run()
end

main()
