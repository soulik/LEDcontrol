#!/usr/bin/luajit
local usb = require 'usb'
local bin = require 'bit'
local ffi = require 'ffi'
local zmq = require 'zmq'

ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]

local sleep

if ffi.os == "Windows" then
	function sleep(s)
    	ffi.C.Sleep(s)
	end
else
	function sleep(s)
    	ffi.C.poll(nil, 0, s)
	end
end

local trinket = function()
	local settings = {
		vendor = 0x1781,
		product = 0x1111,
		endpoint = 0x81,
	}
	local devices = usb.findDevice(settings.vendor, settings.product)
	assert(#devices>0, "Couldn't find device specified")
	local device = devices[1]
	local setting = device.settings[1]
--[[
	print(device.manufacturer, device.product, device.serialNumber)
	print('Settings', #device.settings)

	for k,v in pairs(setting.endpoint) do
		print(k,v)
	end
]]--

	local interface = {
		send = function(data)
			return device.controlMsg(0x43, 0x01, 0x00, 0x00, data)
		end,
		reset = function()
			return device.controlMsg(0x43, 0x02, 0x00, 0x00, string.char(0x00))
		end,
		recv = function()
			return device.read(settings.endpoint)
		end,
	}

	local function sendByte(b)
		local r,c = interface.send(string.char(b))
		sleep(2)
		return r,c
	end

	local function sendBytes(...)
		local r,c = interface.send(string.char(...))
		sleep(2)
		return r,c
	end

	local function readByte()
		local data, code = interface.recv()
		while (type(data) ~= 'string') do
			data, code = interface.recv()
		end
		return string.byte(data)
	end
	
	local function byte(v)
		local v0 = tonumber(v)
		if v0>=0 and v0<=255 then
			return v0
		else
			return v0 % 256
		end
	end

	interface.color = function(index, R, G, B)
		interface.reset()
		sendBytes(byte(index), byte(R), byte(G), byte(B))
		return true --(readByte()==0x01)
	end

	return interface
end

--usb.findDevice()
local t1 = trinket()

local context = assert(zmq.context())
local socket = assert(context.socket(zmq.ZMQ_REP))
assert(socket.bind("tcp://*:6042"))

local poll = zmq.poll()

poll.add(socket, zmq.ZMQ_POLLIN, function(socket)
	local result = assert(socket.recvMultipart())
	local index, r, g, b = unpack(result)
	print(index, r, g , b)
	index,r,g,b = tonumber(index), tonumber(r), tonumber(g), tonumber(b)
	--print(index, r, g , b)
	assert(t1.color(index, r, g, b))
	socket.sendMultipart({'1'})
end)

while true do
	poll.start()
end
socket.close()
