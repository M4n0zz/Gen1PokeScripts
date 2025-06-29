/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

Do use the latest *.inc files from the repo, to avoid compilation errors

*/


include "pokered.inc"

DEF timospointers             = $c7c2
DEF nicknameaddress           = $d8b5
DEF InstallationAddress       = $c9ce
DEF stackaddress              = $dfd1
DEF returnaddress             = ShowPokedexMenuexitPokedex-2


SECTION "DexGiver+", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; increse no of scripts
ld   hl, $c6e9
ld   b, [hl]
ld   a, scriptnumber          ; calculated in DEF
add  a, [hl]
ld   [hl], a

; write pointers to the correct position
ld   de, timospointers        ; start counting from script #1
.pointerloop
inc  e
inc  e
dec  b
jr   nz, .pointerloop

; Copy pointers
ld   c, pointerwidth          ; Calculated in DEF - b = 0 from previous operation
ld   hl, pointers             ; origin
call CopyData

; Copy payloads
ld   bc, payloadwidth         ; Calculated in DEF
ld   de, InstallationAddress
jp   CopyData


; ----------- Payload pointers ------------
pointers:                     ; it automatically calculates every script's starting point offsets
db LOW(hijack), HIGH(hijack)
.end
ENDL


LOAD "DexGiverScript", WRAM0[InstallationAddress]
start:                        ; do not replace this

hijack:
di                            ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine          ; we stop all interrupts to avoid crashes
ld   [hl], $cd                ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(pcall)         ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(pcall)
inc  hl
ld   [hl], $e2                ; ldh [c], a command is put to allow hijack to return dma's original code 
ei                            ; dma code modification is done, interrupts are enabled again

beginning:
; pokedex flags backup
ld   hl, wPokedexSeen
ld   de, backup
ld   bc, $0013
push de
push bc
push hl

push bc
push hl
call CopyData

pop  hl
pop  bc
dec  bc                       ; we ff 1 byte less
xor  a
dec  a                        ; $ff, all bits set
call FillMemory               ; Set BC bytes of A starting from address HL
ld   [hl], $7f                ; last byte is set manually so 151 pokemon appear instead of 152

xor  a                        ; preset zero to return if nothing is selected
ld   [wCurPartySpecies], a

ld   b, $10                   ; ROM bank $10
ld   hl, ShowPokedexMenu      ; route address
call Bankswitch

; unloads dma hijack
di                            ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine          ; we stop all interrupts to avoid crashes
ld   [hl], $3e                ; $ff80-$ff83 OAM DMA's original values are restored
inc  hl
ld   [hl], $c3
inc  hl
ld   [hl], $e0
inc  hl
ld   [hl], $46
ei

; restores seen flags
pop  de
pop  bc
pop  hl                       ; backup
push bc                       ; bytes
push de                       ; seens start
call CopyData

; merges seen with own
pop  hl                       ; hl = own end, de = seen end
pop  bc
.loop
dec  de
dec  hl
ld   a, [de]
or   a, [hl]
ld   [de], a
dec  c
jr   nz, .loop

call LoadScreenTilesFromBuffer2 ; restore saved screen
call Delay3
call LoadGBPal
jp   UpdateSprites


pcall:                        ; now dma hijack always points to this address
call dmapayload               ; it calls our custom dma payload

.endoam                       ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
ret	

dmapayload:                   ; we check specific addresses in stack to detect the address
ld   hl, stackaddress         ; HandleMenuInput is going to return to
ld   a, low(returnaddress)    ; if detected, we set our custom address (hijackpayload)
cp   a, [hl]
ret  nz

inc  hl
;ld   a, high(returnaddress)  ; it is the same, $4040
cp   a, [hl]
ret  nz

ld   a, high(hijackpayload)
ld   [hld], a
ld   a, low(hijackpayload)
ld   [hl], a
ret

hijackpayload:                ; when  HandlePokedexListMenu finishes execution it jumps to this script instead
jp	nc, returnaddress+2

continue:
ld   a, $64
ld   [wMaxItemQuantity], a 
call DisplayChooseQuantityMenu
and  a, a	
jr   nz, reload               ; if B pressed reload menu

ld   a, [wCurrentMenuItem]
ld   b, a
ld   a, [wListScrollOffset]
add  a, b                     ; calculates selected item position
inc 	a
ld   [wPokedexNum], a
ld 	b, $10
ld 	hl, PokedexToIndex       ; changes pokedex id to pokemon id
call Bankswitch
ld   a, [wPokedexNum]
ld   b, a
ld   a, [wItemQuantity]
ld   c, a                     ; b = id, c = level
call GivePokemon

reload:
call ClearScreen
jp   ShowPokedexMenusetUpGraphics

backup:

end:
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start

