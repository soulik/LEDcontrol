local dfmt = "%s %s\n"
package.path = './?/init.lua'

local CONFIG = {
	paths = {
		lua = {
			'C:/utils/lua/{module}',
			'{root}/{module}',
			'{root}/lib/{module}',
			'{root}/lib/external/{module}',
			'{root}/lib/external/platform-specific/{platform}/{module}',
		},
		modules = {
			'?.{extension}',
			'?/init.{extension}',
			'?/core.{extension}',
			'{root}/lib/external/?.{extension}',
			'{root}/lib/external/?/core.{extension}',
		},
	},
}

local paths = CONFIG.paths.lua
local module_paths = CONFIG.paths.modules

local extensions = {
	Windows = 'dll',
	Linux = 'so',
}

local function getOS()
	local OS = (os.getenv('OSTYPE') or os.getenv('OS')):lower()
	if OS:find("windows") then
		return "Windows"
	elseif OS:find("linux") or OS:find("unix") then
		return "Linux"
	elseif OS:find("mac") or OS:find("darwin") then
		return "MacOS"
	else
		return "Unknown"
	end
end

local root_dir = '.'
local current_platform = getOS()
local cpaths, lpaths = {}, {}
local current_clib_extension = extensions[current_platform]
if current_clib_extension then
	for _, path in ipairs(paths) do
		local path = path:gsub("{(%w+)}", {
			root = root_dir,
			platform = current_platform,
		})
		if #path>0 then
			for _, _module_path in ipairs(module_paths) do
				local module_path = path:gsub("{(%w+)}", {
					module = _module_path
				})
				cpaths[#cpaths+1] = module_path:gsub("{(%w+)}", {
					extension = current_clib_extension
				})
				lpaths[#lpaths+1] = module_path:gsub("{(%w+)}", {
					extension = 'lua'
				})
				lpaths[#lpaths+1] = module_path:gsub("{(%w+)}", {
					extension = 'luac'
				})
			end
		end
	end
	package.path = table.concat(lpaths, ";")
	package.cpath = table.concat(cpaths, ";")
end

if type(jit) ~= 'table' then
	require 'bit'
end

function debug.print(fmt,...)
	if (fmt) then
		local dmsg = string.format(fmt,...)
		local f,errmsg = io.open('debug.log',"a")
		if (f) then
			_fmt = dfmt:format(os.date(),dmsg)
			f:write(_fmt:format())
			f:close()
			return true
		else
			return false,errmsg
		end
	else
		return false,"Empty string"
	end
end
