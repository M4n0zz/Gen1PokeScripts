/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"


def stackreturnaddress        = OverworldLoopLessDelay   
def returnaddress             = OverworldLoopLessDelay+3
def hardcodedbankswitch3f     = $1001
def nickwriteraddress         = $d8b4
def topstack                  = $df15
def stackcheckaddress         = $dffd


SECTION "OAM_Hijack", ROM0

LOAD "SuperSpeed", WRAMX[nickwriteraddress]

start:
ld   hl, endjack
ld   de, topstack
ld   c, finish - payload
call CopyMapConnectionHeaderloop

hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   [hl], $cd           ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(payload)  ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(payload)
inc  hl
ld   [hl], $e2           ; ldh [c], a command is put to allow hijack to return dma's original code 
reti                     ; dma code modification is done, interrupts are enabled again

endjack:
ENDL


LOAD "Payload", WRAMX[topstack]
;;;;;;;;;;;; Executed by OAM DMA hijack ;;;;;;;;;;;;;;;;

payload:                 ; This is called by DMA routine

; stack check and replace
ld   hl, stackcheckaddress
ld   a, [hli]
cp   a, low(stackreturnaddress)
jr   nz, .endoam
ld   a, [hl]
cp   a, high(stackreturnaddress)
jr   nz, .endoam
ld   a, high(speedon)
ld   [hld], a
ld   [hl], low(speedon)

.endoam                  ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
ret	

; script activates when delayFrame ends in overworld loop
speedon:
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

finish:
ENDL
