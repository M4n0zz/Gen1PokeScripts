/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

;include "pokered.inc"
;include "pokeyellow.inc"

SECTION "OAM_Hijack", ROM0

start:
LOAD "Payload", WRAMX[$d8b4]  ; address is not important because se don't have static jumps
     
hijack:
di                            ; because DMA routine triggers out of sync with our payload
ld   hl, $FF80                ; we stop all interrupts to avoid crashes
ld   [hl], $3E                ; $ff80-$ff83 OAM DMA's original values are restored
inc  hl
ld   [hl], $C3
inc  hl
ld   [hl], $E0
inc  hl
ld   [hl], $46
reti	                         ; returns and enables interrupts at the same time

.end
ENDL
