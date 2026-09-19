/*

TimOS Static Script Installer - Compatible with EN Yellow ONLY


Description
This script targets to the ease of installing one or more scripts into TimOS environment.


Instructions
1) Change "InstallationAddress" to the address you want to install your payload at.
2) Put your script's code under "CustomPayload" section.
3) Compile your script using (Quick)RGBDS.
4) Install the output over NicknameWriter.

The script will automatically calculate the offsets needed for:
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

CustomPayload:
; insert your payload here





ret



end:                     ; do not replace this
ENDL


