/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "ScriptName", ROM0

start:
LOAD "NicknameWriterPayload", WRAMX[$D8B4]
;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:
ld   b, SurfingPikachuMinigame_Bank
ld   hl, SurfingPikachuMinigame
call Bankswitch
ld   hl, $dfff
ld   sp, hl
jp   EnterMap

.end
ENDL
