local M = {}
M.hsl2rgb = function(h, s, l)
	    local r, g, b
	    if s == 0 then
	        r,g,b = l,l,l -- achromatic
	    else
	    	local p, q
	        local function hue2rgb(t)
	            t = math.fmod(t, 1)
	            if t < 1/6 then
	            	return p + (q - p) * 6 * t
	            elseif t < 1/2 then
	            	return q
	            elseif t < 2/3 then
	            	return p + (q - p) * (2/3 - t) * 6
	            else
	            	return p
	            end
	        end
	        if l < 0.5 then
            	q = l * (1 + s)
           	else
           		q = l + s - l * s
           	end
	        p = 2 * l - q

	        r = hue2rgb(h + 1/3)
	        g = hue2rgb(h)
	        b = hue2rgb(h - 1/3)
	    end
	    return r, g, b
	end

M.rgb2hsl = function(r, g, b)
        local max = math.max(r, g, b)
        local min = math.min(r, g, b)
        local h, s, l = (max + min) / 2
        s, l = h, h
        if max == min then
            h,s = 0,0 -- achromatic
        else
            local d = max - min;
            if l > 0.5 then
            	s = d / (2 - max - min)
            else
            	s = d / (max + min)
            end
            if max == r then
            	if g < b then
            		h = (g - b) / d + 6
            	else
            		h = (g - b) / d + 0
            	end
            elseif max == g then
            	h = (b - r) / d + 2
            elseif max == b then
            	h = (r - g) / d + 4
            end
            h = h / 6
        end
        return h, s, l
	end

M.RGB888 = function(r, g, b)
	return math.floor(math.max(r,0)*255), math.floor(math.max(g,0)*255), math.floor(math.max(b,0)*255)
end

return M