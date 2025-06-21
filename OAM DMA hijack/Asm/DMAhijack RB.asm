/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

SECTION "OAM_Hijack", ROM0

start:
LOAD "Payload", WRAMX[$d8b5]
     
hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld hl, $FF80             ; we stop all interrupts to avoid crashes
ld [hl], $CD             ; $ff80 is replaced with command "call", to jump to our custom address
inc hl
ld [hl], LOW(pcall)      ; $ff81 and $ff82 hold hijack's custom address
inc hl
ld [hl], HIGH(pcall)
inc hl
ld [hl], $E2             ; ldh [c], a command is put to allow hijack to return dma's original code 
ei                       ; dma code modification is done, interrupts are enabled again

pcall:                   ; now dma hijack always points to this address
call payload             ; it calls our custom payload at the end of the script

.endoam                  ; after our custom payload returns, values are set up to continue to dma routine
ld c, $46
ld a, $c3
ret	

;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:                 ; input your payload here

ret

.end
ENDL
