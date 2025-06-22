/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

DEF nickwriteraddress         = $d8b4
DEF stackcheckaddress         = $dffd
DEF stackreturnaddress        = $0245   
DEF returnaddress             = $0248
DEF hardcodedbankswitch3f     = $1001

SECTION "OAM_Hijack", ROM0

start:
LOAD "SuperSpeed", WRAMX[nickwriteraddress]
     
hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   [hl], $cd           ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], LOW(pcall)    ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], HIGH(pcall)
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
payload:                 ; This is called by DMA routine

; stack check and replace
ld   hl, stackcheckaddress
ld   a, [hli]
cp   a, LOW(stackreturnaddress)
ret  nz
ld   a, [hl]
cp   a, HIGH(stackreturnaddress)
ret  nz
ld   a, HIGH(.speedon)
ld   [hld], a
ld   [hl], LOW(.speedon)
ret

; script activates when delayFrame ends in overworld loop
.speedon
ldh  a, [hJoyHeld]
bit  0, a                     ; check if button A is pressed
jp   z, returnaddress

.loop
ld   b, $02
ld   a, [wWalkBikeSurfState]
inc  a
cp   a, b
jr   nz, .nobike
inc  b
.nobike
ld   a, [wWalkCounter]
cp   a, b
jp   c, returnaddress
ld   hl, SpawnPikachu_
call hardcodedbankswitch3f
call AdvancePlayerSprite
jr   .loop

.end
ENDL