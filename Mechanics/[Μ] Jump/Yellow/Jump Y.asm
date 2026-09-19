/*
Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS
*/


include "pokeyellow.inc"

def  nicknameaddress = $d8b4

SECTION "ScriptName", ROM0

LOAD "NicknameWriterPayload", WRAMX[nicknameaddress]

start:                   ; constant execution that temporarily uses MapScript pointer
ld   hl, wCurMapScriptPtr
ld   [hl], low(jumpscript)
inc  hl
ld   [hl], high(jumpscript)
ret  

jumpscript:
ldh  a, [hJoyInput]
and  a, $02			; if B pressed			
ret  z				; jumps to ret if not
ld   hl, wMovementFlags
set  6, [hl]
ret  

.end
ENDL
