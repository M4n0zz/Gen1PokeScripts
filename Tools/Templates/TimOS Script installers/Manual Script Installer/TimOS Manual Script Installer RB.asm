/*

Manual Script Installer - Compatible with EN Red and Blue ONLY


Description
A template installer to easily put your scripts inside TimOS Script selector.


Instructions
1) Set your total "scriptnumber".
2) Change "installationaddress" to the address you want to install your payload to.
3) Put your script's code inside "CustomPayload" section.
3) Compile your script using QuickRGBDS.
4) Install the output using NicknameWriter as normal.

The template code will automatically calculate the address offsets needed for:
- Script selector
- Jump table
- The script itself

Warning!
Make sure the area for your script is unused before installation!



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"

def scriptnumber         = $03
def installationaddress  = $c8c3
def nicknameaddress      = $d8b5


SECTION "ScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; write no of script
ld   a, scriptnumber
ld   [$c6e9], a

; write pointer to the correct position based on script number
ld   hl, $c7c0	+ (2*scriptnumber)
ld   de, installationaddress
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   bc, end - start     ; Calculated in DEF
ld   hl, installerend
jp   CopyData

installerend:
ENDL


LOAD "CustomPayload", WRAM0[installationaddress]

start:                   ; do not replace this

; insert your code here
ret

end:                     ; do not replace this
ENDL


