LED control
======

LED controlling application for AdaFruit NeoPixels and AdaFruit Trinket.

Usage
=====

- Download and unpack latest release package with binaries into empty directory.
- Before doing anything serious, you'll have to burn trinket_serial.ino firmware into AdaFruit Trinket 5V microcontroller. It must be the one with 5V voltage for 16MHz processing speed which is required for USB port serial communication.
- The next step consists of Win32 libusb driver installation. However, this step is not necessary for UNIX-based systems.
- After these steps you can finally start the server and client side scripts

== Client side
```
luajit.exe main.lua
```
or a version without console window
```
client.exe
```

== Server side
```
luajit.exe main.lua
```
or a version without console window
```
server.exe
```

== Adafruit Trinket microcontroller
This USB device can be identified with following IDs:
- vendor ID: 0x1781
- product ID: 0x1111
- endpoint ID: 0x81

Authors
=======
* Mário Kašuba <soulik42@gmail.com>

Copying
=======
Copyright 2014, 2015 Mário Kašuba
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
