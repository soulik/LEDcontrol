local ffi = require 'ffi'
local bit = require 'bit'
local M = {}

ffi.cdef[[
typedef unsigned long HDC;
typedef unsigned long HWND;
typedef unsigned long HBITMAP;
typedef unsigned long HGDIOBJ;
typedef unsigned long DWORD;
typedef unsigned long COLORREF;
typedef unsigned long LRESULT;
typedef unsigned short WPARAM;
typedef unsigned long LPARAM;
typedef unsigned int UINT;
typedef long LONG;

typedef struct _RECT {
  LONG left;
  LONG top;
  LONG right;
  LONG bottom;
} RECT, *PRECT;
typedef RECT * LPRECT;
typedef bool BOOL;

HDC GetDC(HWND);
HDC CreateCompatibleDC(HDC);
int ReleaseDC(HWND, HDC);
BOOL DeleteDC(HDC hdc);
HWND WindowFromDC(HDC hDC);

BOOL DeleteObject(HGDIOBJ hObject);

int GetSystemMetrics(int);
HBITMAP CreateCompatibleBitmap(HDC, int, int);
void SelectObject(HDC, HGDIOBJ);
BOOL BitBlt(HDC hdcDest, int nXDest, int nYDest, int nWidth, int nHeight, HDC hdcSrc, int nXSrc, int nYSrc, DWORD dwRop);
BOOL StretchBlt(HDC hdcDest, int nXOriginDest, int nYOriginDest, int nWidthDest, int nHeightDest, HDC hdcSrc, int nXOriginSrc, int nYOriginSrc, int nWidthSrc, int nHeightSrc, DWORD dwRop);
COLORREF GetPixel(HDC hdc, int nXPos, int nYPos);
int SetStretchBltMode(HDC hdc, int iStretchMode);

BOOL GetClientRect(HWND hWnd, LPRECT lpRect);
LRESULT SendMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
BOOL FreeConsole(void);
HWND GetConsoleWindow(void);

]]
local user32 = ffi.load('User32.dll')
local gdi32 = ffi.load('Gdi32.dll')
local kernel32 = ffi.load('Kernel32.dll')

M.SM_XVIRTUALSCREEN = 76
M.SM_YVIRTUALSCREEN = 77
M.SM_CXVIRTUALSCREEN = 78
M.SM_CYVIRTUALSCREEN = 79

M.SRCCOPY = 0x00CC0020 -- dest = source
M.SRCPAINT = 0x00EE0086 -- dest = source OR dest
M.SRCAND = 0x008800C6 -- dest = source AND dest
M.SRCINVERT = 0x00660046 -- dest = source XOR dest
M.SRCERASE = 0x00440328 -- dest = source AND (NOT dest )
M.NOTSRCCOPY = 0x00330008 -- dest = (NOT source)
M.NOTSRCERASE = 0x001100A6 -- dest = (NOT src) AND (NOT dest)
M.MERGECOPY = 0x00C000CA -- dest = (source AND pattern)
M.MERGEPAINT = 0x00BB0226 -- dest = (NOT source) OR dest
M.PATCOPY = 0x00F00021 -- dest = pattern
M.PATPAINT = 0x00FB0A09 -- dest = DPSnoo
M.PATINVERT = 0x005A0049 -- dest = pattern XOR dest
M.DSTINVERT = 0x00550009 -- dest = (NOT dest)
M.BLACKNESS = 0x00000042 -- dest = BLACK
M.WHITENESS = 0x00FF0062 -- dest = WHITE

M.BLACKONWHITE = 1
M.WHITEONBLACK = 2
M.COLORONCOLOR = 3
M.HALFTONE = 4
M.MAXSTRETCHBLTMODE = 4

M.WM_SETFOCUS                     = 0x0007
M.WM_KILLFOCUS                    = 0x0008
M.WM_ENABLE                       = 0x000A
M.WM_SETREDRAW                    = 0x000B
M.WM_SETTEXT                      = 0x000C
M.WM_GETTEXT                      = 0x000D
M.WM_GETTEXTLENGTH                = 0x000E
M.WM_PAINT                        = 0x000F
M.WM_CLOSE                        = 0x0010
M.WM_QUIT                         = 0x0012
M.WM_ERASEBKGND                   = 0x0014
M.WM_SYSCOLORCHANGE               = 0x0015
M.WM_SHOWWINDOW                   = 0x0018
M.WM_WININICHANGE                 = 0x001A
M.WM_PAINTICON                    = 0x0026
M.WM_ICONERASEBKGND               = 0x0027
M.WM_NEXTDLGCTL                   = 0x0028
M.WM_SPOOLERSTATUS                = 0x002A
M.WM_DRAWITEM                     = 0x002B
M.WM_MEASUREITEM                  = 0x002C
M.WM_DELETEITEM                   = 0x002D
M.WM_VKEYTOITEM                   = 0x002E
M.WM_CHARTOITEM                   = 0x002F
M.WM_SETFONT                      = 0x0030
M.WM_GETFONT                      = 0x0031
M.WM_SETHOTKEY                    = 0x0032
M.WM_GETHOTKEY                    = 0x0033
M.WM_QUERYDRAGICON                = 0x0037
M.WM_COMPAREITEM                  = 0x0039
M.WM_KEYFIRST                     = 0x0100
M.WM_KEYDOWN                      = 0x0100
M.WM_KEYUP                        = 0x0101
M.WM_CHAR                         = 0x0102
M.WM_DEADCHAR                     = 0x0103
M.WM_SYSKEYDOWN                   = 0x0104
M.WM_SYSKEYUP                     = 0x0105
M.WM_SYSCHAR                      = 0x0106
M.WM_SYSDEADCHAR                  = 0x0107
M.WM_INITDIALOG                   = 0x0110
M.WM_COMMAND                      = 0x0111
M.WM_SYSCOMMAND                   = 0x0112
M.WM_TIMER                        = 0x0113
M.WM_HSCROLL                      = 0x0114
M.WM_VSCROLL                      = 0x0115
M.WM_INITMENU                     = 0x0116
M.WM_INITMENUPOPUP                = 0x0117
M.WM_MENURBUTTONUP                = 0x0122
M.WM_MENUDRAG                     = 0x0123
M.WM_MENUGETOBJECT                = 0x0124
M.WM_UNINITMENUPOPUP              = 0x0125
M.WM_MENUCOMMAND                  = 0x0126
M.WM_MOUSEFIRST                   = 0x0200
M.WM_MOUSEMOVE                    = 0x0200
M.WM_LBUTTONDOWN                  = 0x0201
M.WM_LBUTTONUP                    = 0x0202
M.WM_LBUTTONDBLCLK                = 0x0203
M.WM_RBUTTONDOWN                  = 0x0204
M.WM_RBUTTONUP                    = 0x0205
M.WM_RBUTTONDBLCLK                = 0x0206
M.WM_MBUTTONDOWN                  = 0x0207
M.WM_MBUTTONUP                    = 0x0208
M.WM_MBUTTONDBLCLK                = 0x0209
M.WM_MOUSEHWHEEL                  = 0x020E
M.WM_CUT                          = 0x0300
M.WM_COPY                         = 0x0301
M.WM_PASTE                        = 0x0302
M.WM_CLEAR                        = 0x0303
M.WM_UNDO                         = 0x0304
M.WM_RENDERFORMAT                 = 0x0305
M.WM_RENDERALLFORMATS             = 0x0306
M.WM_DESTROYCLIPBOARD             = 0x0307
M.WM_DRAWCLIPBOARD                = 0x0308
M.WM_PAINTCLIPBOARD               = 0x0309
M.WM_VSCROLLCLIPBOARD             = 0x030A
M.WM_SIZECLIPBOARD                = 0x030B
M.WM_ASKCBFORMATNAME              = 0x030C
M.WM_CHANGECBCHAIN                = 0x030D
M.WM_HSCROLLCLIPBOARD             = 0x030E
M.WM_QUERYNEWPALETTE              = 0x030F
M.WM_PALETTEISCHANGING            = 0x0310
M.WM_PALETTECHANGED               = 0x0311
M.WM_HOTKEY                       = 0x0312

local function gc(t, gc)
	assert(type(t)=="table" and type(gc)=="function")
	local proxy = newproxy(true); t.__proxy = proxy
	local p_mt = getmetatable(proxy)
	p_mt.__gc = gc
end

local function BITMAP(bitmap)
	local obj = {}
	obj.raw = bitmap

	obj.SelectObject = function(hdc)
		gdi32.SelectObject(hdc, bitmap)	
	end

	gc(obj, function()
		gdi32.DeleteObject(bitmap)
	end)
	return obj
end

local function HWND(hwnd)
	local obj = {}
	obj.raw = hwnd
	
	obj.GetClientRect = function()
		local lprect = ffi.new("RECT[1]")
		local result = user32.GetClientRect(hwnd, lprect)
		return lprect
	end

	obj.SendMessage = function(msg, wparam, lparam)
		return user32.SendMessage(hwnd, msg, wparam or 0, lparam or 0)
	end

	gc(obj, function()
	end)
	return obj
end

local function DC(hdc)
	local obj = {}
	obj.raw = hdc
	obj.CreateCompatibleBitmap = function(width, height)
		local bitmap = gdi32.CreateCompatibleBitmap(hdc, width, height)
		return BITMAP(bitmap)
	end
	obj.SelectObject = function(bitmap)
		gdi32.SelectObject(hdc, bitmap)	
	end
	obj.GetPixel = function(x,y)
		return gdi32.GetPixel(hdc, x, y)
	end
	obj.SetStretchBltMode = function(mode)
		return gdi32.SetStretchBltMode(hdc, mode)
	end
	obj.WindowFromDC = function()
		local hwnd = user32.WindowFromDC(hdc)
		return (hwnd>0) and HWND(hwnd)
	end
	return obj
end

M.GetDC = function(window)
	local window = window or 0
	local hdc = user32.GetDC(window)
	local obj = DC(hdc)

	obj.CreateCompatibleDC = function()
		local hdc2 = gdi32.CreateCompatibleDC(hdc)
		local obj = DC(hdc2)
		gc(obj, function()
			gdi32.DeleteDC(hdc2)
		end)
		return obj
	end

	gc(obj, function()
		user32.ReleaseDC(window, hdc)
	end)
	return obj
end

M.GetSystemMetrics = function(code)
	return user32.GetSystemMetrics(code)
end

M.BitBlt = function(hdc, xdest, ydest, width, height, hdcSrc, xsrc, ysrc, rwop)
	return gdi32.BitBlt(hdc, xdest, ydest, width, height, hdcSrc, xsrc, ysrc, rwop)
end

M.StretchBlt = function(hdc, xdest, ydest, wdest, hdest, hdcSrc, xsrc, ysrc, wsrc, hsrc, rwop)
	return gdi32.StretchBlt(hdc, xdest, ydest, wdest, hdest, hdcSrc, xsrc, ysrc, wsrc, hsrc, rwop)
end

M.FreeConsole = function()
	return kernel32.FreeConsole()
end

M.GetConsoleWindow = function()
	local hwnd = kernel32.GetConsoleWindow()
	return (hwnd>0) and HWND(hwnd)
end

return M
