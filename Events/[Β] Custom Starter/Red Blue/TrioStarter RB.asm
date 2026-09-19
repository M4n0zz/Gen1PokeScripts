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
ld   hl, $ff80           ; we stop all interrupts to avoid crashes
ld   [hl], $cd           ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(pcall)    ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(pcall)
inc  hl
ld   [hl], $e2           ; ldh [c], a command is put to allow hijack to return dma's original code 
ei                       ; dma code modification is done, interrupts are enabled again

pcall:                   ; now dma hijack always points to this address
call payload             ; it calls our custom payload at the end of the script

.endoam                  ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
ret	

;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:                 ; input your payload here
ld   hl, wPokedexNum
ld   b, $49              ; load custom pokemon id - moltres
ld   a, $b0              ; starters check value
cp   a, [hl]
jr   z, moltress
inc  a
cp   a, [hl]
jr   z, articuno
ld   a, $99
cp   a, [hl]
jr   nz, skip
zapdos:
inc  b
articuno:
inc  b
moltress:
ld   [hl], b
skip:
ld   a, [wPartyCount]    ; if party pokemon > 0, starter is received and the script stops
and  a                   ; and
ret  z                   ; the script stops

di                       ; because DMA routine triggers out of sync with our payload
ld   hl, $ff80           ; we stop all interrupts to avoid crashes
ld   [hl], $3e           ; $ff80-$ff83 OAM DMA's original values are restored
inc  hl
ld   [hl], $c3
inc  hl
ld   [hl], $e0
inc  hl
ld   [hl], $46
reti	                    ; returns and enables interrupts at the same time

.end
ENDL
