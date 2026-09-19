/*

TimOS Auto Script Installer - Compatible with EN Yellow ONLY


Description
This script targets to the ease of installing one or more scripts into TimOS script selector.
It automatically finds unused memory and installs your new scripts.

Restrictions
This method is compatible ONLY WITH RELATIVE ADDRESS SCRIPTS! If the script uses "call" or "jp" instructions targeting in another part of the script,
then you shouyld use STATIC INSTALLER and compile the script yourself.

Static script's jumps or calls are not tolerated since the script can be installed in different addresses


Instructions
1) Put your script's assembly code under "CustomPayload" section.
2) Compile your script using (Quick)RGBDS.
3) Install the output over Nickname Writer.

The script will automatically calculate the offsets needed for:
- Script selector number
- Jump table address
- The script itself



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/
include "pokeyellow.inc"

def InstallationAddress  = $cccc    ; to be replaced by itself
def nicknameaddress      = $d8b4
def scriptnumberaddress  = $c6e9 
def defaultinstall       = $c7ff
def scriptpointers       = $c7c0

SECTION "AutoScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; find free space in timos
ld   hl, $cb49           ; last TimOS byte ($ff)
.loop
ld   a, [hld]
cp   a, $ff
jr   z, .loop
inc  hl
inc  hl
ld   a, h
cp   a, $c8
jr   nc, .skip           ; if no script exists
ld   hl, defaultinstall  ; default installation address is set
.skip
ld   [pointers+1], a
ld   a, l
ld   [pointers], a
push hl                  ; save pointers for later

; increse no of scripts
ld   hl, scriptnumberaddress
ld   b, [hl]
ld   a, scriptnumber     ; calculated at the end of the file
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
pointers:                ; it automatically calculates every script's starting point offsets
dw start
.end
ENDL


LOAD "CustomPayload", WRAM0[InstallationAddress]

start:                   ; do not replace this

CustomPayload:
; place your payload here




end:                     ; do not replace this
ENDL

	
def scriptnumber = (pointers.end - pointers) / 2
def pointerwidth = pointers.end - pointers
def payloadwidth = end - start

