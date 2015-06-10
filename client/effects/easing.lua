--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
-- actually adapted from particle lib proton.js
--
-- @value should be float in range from 0.0 to 1.0

local easing = {
  _VERSION     = 'easing 0.9',
  _DESCRIPTION = 'easing for lua',
  _URL         = 'https://github.com/baranok/easing.lua',
  _LICENSE     = [[
    MIT LICENSE
    Copyright (c) 2014 Enrique García Cota, Yuichi Tateno, Emmanuel Oga, Enrique García

    ROB CO CHCES LICENSE
    Copyright (c) 2015 BARANIS
    Vsetky zamky su zatvorene, kluce splachnute, kazda violacia suboru
    tychto pravidiel sa bude povazovat za uspech a genialitu skrizenu
    so sialenstvom. Niektore myslienky a napady som si vypozical cez 
    lokalnu kniznicu a zavazujem si snurky, ze som netahal z referatov.
  ]]
}

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- normalize * (better func name maybe?)
-- @value can be any float, returns clamped float in range 0.0 - 1.0, in looping manner
local function easeNormalize(value)
  value = value % 1
  if value < 0 then return value + 1 end
  return value
end

-- linear *
local function easeLinear(value)
	return value
end

-- smoothstep *
-- R = t*t * (3 - 2*t)
local function easeSmoothstep(value)
	return pow(value, 2) * (3 - 2 * value) 
end

-- smootherstep *
-- R = t*t*t * (t * (6*t - 15) + 10)
local function easeSmootherstep(value)
	return pow(value, 3) * (value * (6 * value - 15) + 10) 
end

-- quad *
local function easeInQuad(value)
	return pow(value, 2)
end
local function easeOutQuad(value)
	value = value - 1
	return -(pow(value, 2) - 1)
end
local function easeInOutQuad(value)
	value = value / 0.5
	if value < 1 then return 0.5 * pow(value, 2) end
	value = value - 2
	return -0.5 * (value * value - 2)
end

-- cubic *
local function easeInCubic(value)
	return pow(value, 3)
end
local function easeOutCubic(value)
	value = value - 1
	return pow(value, 3) + 1
end
local function easeInOutCubic(value)
	value = value / 0.5
	if value < 1 then return 0.5 * pow(value, 3) end
	value = value - 2
	return 0.5 * (pow(value, 3) + 2)
end

-- quart *
local function easeInQuart(value)
	return pow(value, 4)
end
local function easeOutQuart(value)
	return -(pow(value - 1, 4) - 1)
end
local function easeInOutQuart(value)
	value = value / 0.5
	if value < 1 then return 0.5 * pow(value, 4) end
	value = value - 2
	return -0.5 * (value * pow(value, 3) - 2)
end

-- sine *
local function easeInSine(value)
	return -cos(value * (pi / 2)) + 1
end
local function easeOutSine(value)
	return sin(value * (pi / 2))
end
local function easeInOutSine(value)
	return -0.5 * (cos(pi * value) - 1)
end

-- expo *
local function easeInExpo(value)
	if value == 0 then return 0 end
	return pow(2, 10 * (value - 1))
end
local function easeOutExpo(value)
	if value == 1 then return 1 end
	return -pow(2, -10 * value) + 1
end
local function easeInOutExpo(value)
	if value == 0 then return 0 end
	if value == 1 then return 1 end
	value = value / 0.5
	if value < 1 then return 0.5 * pow(2, 10 * (value - 1)) end
	return 0.5 * (-pow(2, -10 * value) + 2)		
end

-- circ *
local function easeInCirc(value)
	return -(sqrt(1 - (value * value)) - 1)
end
local function easeOutCirc(value)
	return sqrt(1 - pow((value - 1), 2))
end
local function easeInOutCirc(value)
  value = value / 0.5
	if value < 1 then return -0.5 * (sqrt(1 - value * value) - 1) end
  value = value - 2
  return 0.5 * (sqrt(1 - value * value) + 1)
end

-- back *
local function easeInBack(value)
	local s = 1.70158
	return value * value * ((s + 1) * value - s)
end
local function easeOutBack(value)
	local s = 1.70158
  value = value - 1
	return value * value * ((s + 1) * value + s) + 1
end
local function easeInOutBack(value)
	local s = 1.70158
  s = s * 1.525
  value = value / 0.5
	if value < 1 then return 0.5 * (value * value * ((s + 1) * value - s)) end
  value = value - 2
	return 0.5 * (value * value * ((s + 1) * value + s) + 2)
end

-- elastic *
local function easeElastic(value)
	if (value == 0 or value == 1) then return value end
	return pow(2, -10 * value) * sin((value - 0.075) * (2 * PI) / 0.3) + 1
end

-- not converted yet

--[[
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end

local function inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

local function outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

local function inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end

local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return outElastic(t * 2, b, c / 2, d, a, p) end
  return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- bounce
local function easeBounce(value)
	local s = 7.5625,
          p = 2.75,
          l
    if (n < (1 / p))
        l = s * n * n;
    else
        if (n < (2 / p))
            n -= (1.5 / p);
            l = s * n * n + .75;
        else
            if (n < (2.5 / p))
                n -= (2.25 / p);
                l = s * n * n + .9375;
            else
                n -= (2.625 / p);
                l = s * n * n + .984375;
            end
        end
    end
    return l;
end

local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
local function inBounce(t, b, c, d) return c - outBounce(d - t, 0, c, d) + b end

local function inOutBounce(t, b, c, d)
  if t < d / 2 then return inBounce(t * 2, 0, c, d) * 0.5 + b end
  return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end

local function outInBounce(t, b, c, d)
  if t < d / 2 then return outBounce(t * 2, b, c / 2, d) end
  return inBounce((t * 2) - d, b + c / 2, c / 2, d)
end
--]]

--cubic bezier(1,2,3,4)
--[[

"linear":"0,0,1,1"
"ease":".25,.1,.25,1"
"ease-in":".42,0,1,1"
"ease-out":"0,0,.58,1"
"ease-in-out":".42,0,.58,1"
"Goofybad":".85,-0.1,.27,.25" -- horsie
"Goofy":".85,-0.1,.25,.25" -- pekne round

{"ease":".25,.1,.25,1","linear":"0,0,1,1","ease-in":".42,0,1,1","ease-out":"0,0,.58,1","ease-in-out":".42,0,.58,1","Goofy":".85,-0.1,.27,.25"}

--]]

--[[
tween.easing = {
  linear    = linear,
  inQuad    = inQuad,    outQuad    = outQuad,    inOutQuad    = inOutQuad,    outInQuad    = outInQuad,
  inCubic   = inCubic,   outCubic   = outCubic,   inOutCubic   = inOutCubic,   outInCubic   = outInCubic,
  inQuart   = inQuart,   outQuart   = outQuart,   inOutQuart   = inOutQuart,   outInQuart   = outInQuart,
  inQuint   = inQuint,   outQuint   = outQuint,   inOutQuint   = inOutQuint,   outInQuint   = outInQuint,
  inSine    = inSine,    outSine    = outSine,    inOutSine    = inOutSine,    outInSine    = outInSine,
  inExpo    = inExpo,    outExpo    = outExpo,    inOutExpo    = inOutExpo,    outInExpo    = outInExpo,
  inCirc    = inCirc,    outCirc    = outCirc,    inOutCirc    = inOutCirc,    outInCirc    = outInCirc,
  inElastic = inElastic, outElastic = outElastic, inOutElastic = inOutElastic, outInElastic = outInElastic,
  inBack    = inBack,    outBack    = outBack,    inOutBack    = inOutBack,    outInBack    = outInBack,
  inBounce  = inBounce,  outBounce  = outBounce,  inOutBounce  = inOutBounce,  outInBounce  = outInBounce
}
--]]

--[[
elastic: function (n) {
    if (n == !!n) {
        return n;
    }
    return pow(2, -10 * n) * math.sin((n - .075) * (2 * PI) / .3) + 1;
},

bounce: function (n) {
    var s = 7.5625,
        p = 2.75,
        l;
    if (n < (1 / p)) {
        l = s * n * n;
    } else {
        if (n < (2 / p)) {
            n -= (1.5 / p);
            l = s * n * n + .75;
        } else {
            if (n < (2.5 / p)) {
                n -= (2.25 / p);
                l = s * n * n + .9375;
            } else {
                n -= (2.625 / p);
                l = s * n * n + .984375;
            }
        }
    }
    return l;
}
]]--



--[[

easeLinear : function(value) {
			return value;
		},

		easeInQuad : function(value) {
			return Math.pow(value, 2);
		},

		easeOutQuad : function(value) {
			return -(Math.pow((value - 1), 2) - 1);
		},

		easeInOutQuad : function(value) {
			if ((value /= 0.5) < 1)
				return 0.5 * Math.pow(value, 2);
			return -0.5 * ((value -= 2) * value - 2);
		},

		easeInCubic : function(value) {
			return Math.pow(value, 3);
		},

		easeOutCubic : function(value) {
			return (Math.pow((value - 1), 3) + 1);
		},

		easeInOutCubic : function(value) {
			if ((value /= 0.5) < 1)
				return 0.5 * Math.pow(value, 3);
			return 0.5 * (Math.pow((value - 2), 3) + 2);
		},

		easeInQuart : function(value) {
			return Math.pow(value, 4);
		},

		easeOutQuart : function(value) {
			return -(Math.pow((value - 1), 4) - 1);
		},

		easeInOutQuart : function(value) {
			if ((value /= 0.5) < 1)
				return 0.5 * Math.pow(value, 4);
			return -0.5 * ((value -= 2) * Math.pow(value, 3) - 2);
		},
	
		easeInSine : function(value) {
			return -Math.cos(value * (Math.pi / 2)) + 1;
		},

		easeOutSine : function(value) {
			return Math.sin(value * (Math.pi / 2));
		},

		easeInOutSine : function(value) {
			return (-0.5 * (Math.cos(Math.pi * value) - 1));
		},

		easeInExpo : function(value) {
			return (value === 0) ? 0 : Math.pow(2, 10 * (value - 1));
		},

		easeOutExpo : function(value) {
			return (value === 1) ? 1 : -Math.pow(2, -10 * value) + 1;
		},

		easeInOutExpo : function(value) {
			if (value === 0)
				return 0;
			if (value === 1)
				return 1;
			if ((value /= 0.5) < 1)
				return 0.5 * Math.pow(2, 10 * (value - 1));
			return 0.5 * (-Math.pow(2, -10 * --value) + 2);
		},

		easeInCirc : function(value) {
			return -(Math.sqrt(1 - (value * value)) - 1);
		},

		easeOutCirc : function(value) {
			return Math.sqrt(1 - Math.pow((value - 1), 2));
		},

		easeInOutCirc : function(value) {
			if ((value /= 0.5) < 1)
				return -0.5 * (Math.sqrt(1 - value * value) - 1);
			return 0.5 * (Math.sqrt(1 - (value -= 2) * value) + 1);
		},
		
		easeInBack : function(value) {
			var s = 1.70158;
			return (value) * value * ((s + 1) * value - s);
		},

		easeOutBack : function(value) {
			var s = 1.70158;
			return ( value = value - 1) * value * ((s + 1) * value + s) + 1;
		},

		easeInOutBack : function(value) {
			var s = 1.70158;
			if ((value /= 0.5) < 1)
				return 0.5 * (value * value * (((s *= (1.525)) + 1) * value - s));
			return 0.5 * ((value -= 2) * value * (((s *= (1.525)) + 1) * value + s) + 2);
		},

return {
  linear = linear,
  inQuad = inQuad,
  outQuad = outQuad,
  inOutQuad = inOutQuad,
  outInQuad = outInQuad,
  inCubic  = inCubic ,
  outCubic = outCubic,
  inOutCubic = inOutCubic,
  outInCubic = outInCubic,
  inQuart = inQuart,
  outQuart = outQuart,
  inOutQuart = inOutQuart,
  outInQuart = outInQuart,
  inQuint = inQuint,
  outQuint = outQuint,
  inOutQuint = inOutQuint,
  outInQuint = outInQuint,
  inSine = inSine,
  outSine = outSine,
  inOutSine = inOutSine,
  outInSine = outInSine,
  inExpo = inExpo,
  outExpo = outExpo,
  inOutExpo = inOutExpo,
  outInExpo = outInExpo,
  inCirc = inCirc,
  outCirc = outCirc,
  inOutCirc = inOutCirc,
  outInCirc = outInCirc,
  inElastic = inElastic,
  outElastic = outElastic,
  inOutElastic = inOutElastic,
  outInElastic = outInElastic,
  inBack = inBack,
  outBack = outBack,
  inOutBack = inOutBack,
  outInBack = outInBack,
  inBounce = inBounce,
  outBounce = outBounce,
  inOutBounce = inOutBounce,
  outInBounce = outInBounce,
}
--]]