/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

def nicknameaddress = $d8b5
def installaddress  = $df15




SECTION "OAM_Hijack", ROM0


LOAD "Installer", WRAMX[nicknameaddress]
     
start:
ld   hl, endjack
ld   de, payload
ld   c, end - payload
call CopyMapConnectionHeaderloop

hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine       ; we stop all interrupts to avoid crashes
ld   [hl], $cd             ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(payload)    ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(payload)
inc  hl
ld   [hl], $e2             ; ldh [c], a command is put to allow hijack to return dma's original code 
reti                     ; dma code modification is done, interrupts are enabled again
endjack:
ENDL



LOAD "Payload", WRAMX[installaddress]

payload:                 ; input your payload here
ldh  a, [hJoyInput]
bit  1, a                ; B Button
ld   a, $00              ; we cannot use xor a, since it will reset z
jr   z, trespass         ; reset collision if not pressed
inc  a

trespass:
ld   [wSimulatedJoypadStatesIndex], a 	; Loads Walk Type

skip:                    ; after our custom payload returns, values are set up to continue to dma routine
ld c, $46
ld a, $c3
ret	

end:
ENDL
