require 'libusb'
require 'bit'

local M = {}

local proxy = function(t, mt)
	assert(type(t) == 'table', 'Argument should be a table')

	local proxy = newproxy(true); t.__proxy = proxy

	if type(mt)=='table' then
		local p_mt = getmetatable(proxy)
		
		for k,fn in pairs(mt) do
			assert(type(fn) == 'function')

			if k == '__gc' then
				p_mt.__gc = function()
					fn()
				end
			else
				p_mt[k] = fn
			end
		end
	end
end

local function getDevice(_device)
	local o = {}
	local device = _device.device
	local descriptor = libusb.device_descriptor(device)
	local uDev = libusb.open(device)
	local config = libusb.device_config(device)
	local endpoints = {}
	local defaultTimeout = 10

	local function closeDevice()
		if uDev then
			libusb.close(uDev)
			uDev = nil
		end
	end

	local function getString(index)
		if index>0 then
			if uDev then
				local text, code = libusb.get_string_simple(uDev, index, 1024)
				if text then
					return text
				else
					return nil, ("%d"):format(bit.tobit(1-code))
				end
			else
				return ''
			end
		else
			return '', 'Unknown index'
		end
	end
	
	local getters = {
		bLength = descriptor.bLength,
		bDescriptorType = descriptor.bDescriptorType,
		bcdUSB = descriptor.bcdUSB,
		bDeviceClass = descriptor.bDeviceClass,
		bDeviceSubClass = descriptor.bDeviceSubClass,
		bDeviceProtocol = descriptor.bDeviceProtocol,
		bMaxPacketSize0 = descriptor.bMaxPacketSize0,
		bcdDevice = descriptor.bcdDevice,
		bNumConfigurations = descriptor.bNumConfigurations,

		idVendor = descriptor.idVendor,
		idProduct = descriptor.idProduct,
		manufacturer = assert(getString(descriptor.iManufacturer)),
		product = assert(getString(descriptor.iProduct)),
		serialNumber = assert(getString(descriptor.iSerialNumber)),

		currentConfiguration = function()
			return libusb.device_config(device)
		end,
		settings = (function()
			local settings = {}
			local interface = libusb.interface_alt_settings(config.interface)
			
			for k,v in pairs(interface) do
				local setting = {
					id = v.bAlternateSetting,
					iInterface = v.iInterface,
					bLength = v.bLength,
					bDescriptorType = v.bDescriptorType,
					bInterfaceNumber = v.bInterfaceNumber,
					bAlternateSetting = v.bAlternateSetting,
					bNumEndpoints = v.bNumEndpoints,
					bInterfaceClass = v.bInterfaceClass,
					bInterfaceSubClass = v.bInterfaceSubClass,
					bInterfaceProtocol = v.bInterfaceProtocol,
					extra = v.extra,
					endpoint = (function()
						local endpoint = libusb.endpoint_descriptor(v.endpoint)
						local ep = {
							bLength = endpoint.bLength,
							bDescriptorType = endpoint.bDescriptorType,
							bEndpointAddress = endpoint.bEndpointAddress,
							bmAttributes = endpoint.bmAttributes,
							wMaxPacketSize = endpoint.wMaxPacketSize,
							bInterval = endpoint.bInterval,
							bRefresh = endpoint.bRefresh,
							bSynchAddress = endpoint.bSynchAddress,
							extra = endpoint.extra,
						}
						endpoints[endpoint.bEndpointAddress] = ep
						return ep
					end)(),
				}
				
				table.insert(settings, setting)
			end
			
			return settings
		end)(),
		controlMsg = function(requesttype, request, value , index, bytes, timeout)
			if uDev then
				return libusb.control_msg(uDev, requesttype, request, value , index, bytes, timeout or defaultTimeout)
			end
		end,
		read = function(endpoint, size, timeout)
			if uDev and type(endpoint)=="number" then
				local _endpoint = endpoints[endpoint]
				if _endpoint then
					return libusb.bulk_read(uDev, endpoint, size or _endpoint.wMaxPacketSize, timeout or defaultTimeout)
				else
					return libusb.bulk_read(uDev, endpoint, size, timeout or defaultTimeout)
				end
	    	end
		end,
		write = function(endpoint, buffer, timeout)
			if uDev and type(endpoint)=="number" and type(buffer)=="string" then
				return libusb.bulk_write(uDev, endpoint, buffer, timeout or defaultTimeout)
	    	end
		end,
		intRead = function(endpoint, size, timeout)
			if uDev and type(endpoint)=="number" then
				local _endpoint = endpoints[endpoint]
				if _endpoint then
					return libusb.interrupt_read(uDev, endpoint, size or _endpoint.wMaxPacketSize, timeout or defaultTimeout)
				else
					return libusb.interrupt_read(uDev, endpoint, size, timeout or defaultTimeout)
				end
	    	end
		end,
		intWrite = function(endpoint, buffer, timeout)
			if uDev and type(endpoint)=="number" and type(buffer)=="string" then
				return libusb.interrupt_write(uDev, endpoint, buffer, timeout or defaultTimeout)
	    	end
		end,
		reset = function()
			if uDev then
				return libusb.reset(uDev)
			end
		end,
		clearHalt = function(endpoint)
			if uDev and type(endpoint)=="number" then
				return libusb.clear_halt(uDev, endpoint)
			end
		end,
	}
	
	local setters = {
		configuration = function(index)
			if uDev and index>=0 then
				libusb.set_configuration(uDev, index)
			end
		end,
		altInterface = function(index)
			if uDev and index>=0 then
				libusb.set_altinterface(uDev, index)
			end
		end,
		timeout = function(value)
			assert(type(value)=="number" and (value >= 0), "Timeout must be a positive number")
			defaultTimeout = value
		end,
	}
	
	local mt = {
		__index = function(t,k)
			local f = getters[k]
			return f
		end,
		__newindex = function(t,k,v)
			local f = setters[k]
			if type(f)=="function" then
				return f(v)
			end
		end,
	}
	local cleanup = proxy(o, {
		__gc = closeDevice,
	})
	setmetatable(o, mt)
	return o
end

local function getDevices()
	local out = {}
	local busses = libusb.get_busses()
	for busPath, bus in pairs(busses) do
		for devicePath, device in pairs(libusb.get_devices(bus)) do
			table.insert(out, {
				busPath = busPath,
				devicePath = devicePath,
				device = device,
			})
		end
	end
	return out
end

local function findDevice(idVendor, idProduct, devices)
	local out = {}
	for _, device in ipairs(devices or getDevices()) do
		local descriptor = libusb.device_descriptor(device.device)
		
		if idVendor and idProduct then
			if idVendor==tonumber(descriptor.idVendor) and idProduct==tonumber(descriptor.idProduct) then
				table.insert(out, getDevice(device))
			end
		else
			print(("%s/%s %X:%X"):format(device.busPath, device.devicePath, tonumber(descriptor.idVendor), tonumber(descriptor.idProduct)))
			--table.insert(out, getDevice(device))
		end
	end
	return out
end

M.getDevices = getDevices
M.findDevice = findDevice

return M
