/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

Do use the latest *.inc files from the repo, to avoid compilation errors

*/

include "pokered.inc"

def scriptnumaddr             = $c6e9
def timospointers             = $c7c7
def installaddress            = $c9ce
def nicknameaddress           = $d8b5
def stackaddress              = $dfdd
def returnaddress             = DisplayListMenuIDLoopnotOldManBattle+6
def hardcodedbankswitch1      = $1375
def hbackup                   = $ffef


SECTION "PokeTeacher+", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:

ld   hl, scriptnumaddr
ld   a, [hl]
inc  [hl]                     ; increse no of scripts
add  a, a                     ; doubles number since pointers use 2 bytes
ld   hl, timospointers        ; start counting from script #1
ld   de, installaddress
add  a, l
ld   l, a
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   bc, end - start
ld   hl, installerend
jp   CopyData

installerend:
ENDL



LOAD "PokeTeacherScript", WRAM0[installaddress]
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
xor  a
ld   [wUpdateSpritesEnabled], a         ; enable moving sprites
ld   [wPartyMenuTypeOrMessageID], a     ; text id 0
call DisplayPartyMenu
ld   a, [wWhichPokemon]
ldh  [hbackup], a
jr 	nc, createlist

call ClearScreen                        ; Fill screen with 7F bytes = white tiles
call RestoreScreenTilesAndReloadTilePatterns
ld   [wListScrollOffset], a             ; a is z anyway

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
reti                          ; returns and enables interrupts at the same time

createlist:
ld   hl, list                 ; list header is stored for later
ld   a, l
ld   [wListPointer], a
ld   a, h
ld   [wListPointer + 1], a

xor  a
ld   [wPrintItemPrices], a
ld   [wCurrentMenuItem], a
inc  a                        ; we start from move with id 1
ld   [wListMenuID], a         ; we need to set it to 0 with oam dma, when not scrolling      
inc  hl

.loop1
inc  a
ld   [hl+], a
cp   a, $a6                   ; list is stopped before glitch names appear
jr   nz, .loop1

xor  a
ld   c, a
dec  a
ld   [hl], a

ld   hl, list                 ; list header is stored
call DisplayListMenuID
and  a
jr   z, beginning             ; end if B is pressed

continue:
ldh  a, [hbackup]
ld   [wWhichPokemon], a
ld   hl, LearnMove
call hardcodedbankswitch1

jr   beginning                ; reload menu

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
ld   a, high(returnaddress)
cp   a, [hl]
ret  nz
ld   a, high(hijackpayload)
ld   [hld], a
ld   a, low(hijackpayload)
ld   [hl], a
ret

hijackpayload:                ; when HandleMenuInput finishes execution it jumps to this script instead
bit  0, a                     ; if we detect A button pressed
jp   z, returnaddress         ; we jumpback to the original return point if A is not pressed

ld   a, [wCurrentMenuItem]
ld   b, a
ld   a, [wListScrollOffset]
add  a, b                     ; calculates selected item
inc  a
inc  a
ld   [wMoveNum], a
ld   [wNamedObjectIndex], a
call GetMoveName
jp   DisplayListMenuIDLoopstoreChosenEntry

list:
db $a3

end:                          ; do not replace this
ENDL

