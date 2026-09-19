/*

TimOS Auto Script Installer - Compatible with EN Red and Blue ONLY


Description
This script targets to the ease of installing one or more scripts into TimOS environment.
It automatically finds and installs new scripts in unused memory.

Restrictions
This method is compatible ONLY WITH RELATIVE ADDRESS SCRIPTS!
Static script's jumps or calls are not tolerated since the script can be installed in different addresses


Instructions
1) Put your script's code under "CustomPayload" section.
2) Compile your script using (Quick)RGBDS.
3) Install the output over NicknameWriter.

The script will automatically calculate the offsets needed for:
- Script selector
- Jump table
- The script itself



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/
include "pokered.inc"

def InstallationAddress  = $cccc    ; to be changed by itself
def nicknameaddress      = $d8b5
def scriptnumberaddress  = $c6e9 
def defaultinstall       = $c7ff
def scriptpointers       = $c7c7

SECTION "AutoScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; find free space in timos
ld   hl, $cb49             ; last TimOS byte ($ff)
.loop
ld   a, [hld]
cp   a, $ff
jr   z, .loop
inc  hl
inc  hl
ld   a, h
cp   a, $c8
jr   nc, .skip             ; if no script exists
ld   hl, defaultinstall    ; default installation address is set
.skip
ld   [pointers+1], a
ld   a, l
ld   [pointers], a
push hl                  ; save pointers for later

; increse no of scripts
ld   hl, scriptnumberaddress
ld   b, [hl]
ld   a, scriptnumber       ; calculated at the end of the file
add  a, [hl]
ld   [hl], a

; write pointers to the correct position
ld   de, scriptpointers  ; start counting from script #1
.pointerloop
inc  e
inc  e
dec  b
jr   nz, .pointerloop

; Copy pointers
ld   c, pointerwidth     ; calculated at the end of the file
ld   hl, pointers        ; origin
call CopyMapConnectionHeaderloop

; Copy payloads
ld   c, payloadwidth     ; calculated at the end of the file
pop  de                  ; destination
jp   CopyMapConnectionHeaderloop


; ----------- Payload pointers ------------
pointers:           ; it automatically calculates every script's starting point offsets
dw start
.end
ENDL


LOAD "CustomPayload", WRAM0[InstallationAddress]

start:              ; do not replace this

CustomPayload:
; place your payload here




end:                ; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start

