/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"
; include "pokeyellow.inc"
include "charmap.inc"              ; this one gives us all game's character to easily print text

def  nicknameaddress = $d8b5   ; RB
; def  nicknameaddress = $d8b4   ; Y

SECTION "ScriptName", ROM0

LOAD "NicknameScript", WRAMX[nicknameaddress]

start:
; Your script goes here

ret

end:
ENDL
