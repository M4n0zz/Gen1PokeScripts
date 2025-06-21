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
ld [hl], $CD
inc hl
ld [hl], LOW(pcall)
inc hl
ld [hl], HIGH(pcall)
inc hl
ld [hl], $E2
ei		

pcall:
call payload

.endoam
ld c, $46
ld a, $c3
ret	

;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:
; payload
ret

.end
ENDL