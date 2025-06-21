/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "OAM_Hijack", ROM0

start:
LOAD "Payload", WRAMX[$d8b4]
hijack:
di					; we'll be messing with $FF80, so stop all interrupts
ld hl, $FF80
ld [hl], $3E
inc hl
ld [hl], $C3
inc hl
ld [hl], $E0
inc hl
ld [hl], $46
reti	

.end
ENDL