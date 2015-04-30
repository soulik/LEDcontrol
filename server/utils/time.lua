local ffi = require 'ffi'

local M = {}

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

M.sleep = sleep

return M