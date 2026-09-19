/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

Do use the latest *.inc files from the repo, to avoid compilation errors

*/


include "pokeyellow.inc"

def listitems                 = 47
def nicknameaddress           = $d8b4
def stackaddress              = $dfdf
def returnaddress             = DisplayListMenuIDLoop+6


SECTION "HiTrainer+", ROM0

LOAD "NicknameWriterPayload", WRAMX[nicknameaddress]

createlist:
ld   hl, wListPointer	; list header is stored
ld   de, wmenulist       ; list of menu id is created by the end of the script
ld   [hl], e             ; wmenulist address us loaded into wListPointer
inc  hl
ld   [hl], d
ld   a, $56              ; 1F items id has a small name = quicker code execution without graphical glitches

ld   b, listitems        ; how many options will be loaded

buildloop:               ; builds item list
inc  de
ld   [de], a
dec  b
jr   nz, buildloop
inc  de
ld   a, $ff              ; adds cancel item at the end of the list
ld   [de], a             ; it is ff anyway, no need to make it

; predefs menu settings
ld   hl, wListScrollOffset
push hl
xor  a
ld   [hl], a             ; initialize list items position
ld   l, low(wCurrentMenuItem)
ld   [hl], a             ; initialize selector
ld   hl, wPrintItemPrices	
ld   [hl+], a			; wPrintItemPrices = 0
ld   [hl], $04           ; wListMenuID = 4

hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   [hl], $cd           ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(pcall)    ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(pcall)
inc  hl
ld   [hl], $e2           ; ldh [c], a command is put to allow hijack to return dma's original code 
ei                       ; dma code modification is done, interrupts are enabled again

call DisplayListMenuID   ; script's menu is fired

; unloads dma hijack
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   [hl], $3e           ; $ff80-$ff83 OAM DMA's original values are restored
inc  hl
ld   [hl], $c3
inc  hl
ld   [hl], $e0
inc  hl
ld   [hl], $46
ei                       ; returns and enables interrupts at the same time

pop  hl                  ; wListScrollOffset
ld   b, [hl]
ld   [hl], a             ; if it exits it means it is 0, otherwise we zero it out later

and  a, a	               ; reads list menu button
ret  z                   ; exits if B is pressed


presseda:
xor  a
ld   [hl], a             ; wListScrollOffset = 0 
inc  a
ld   [wEngagedTrainerSet], a  ; wEngagedTrainerSet = 1
ld   l, low(wCurrentMenuItem)
ld   a, [hl]
add  a, b                ; calculates selected item
add  a, $c9
jp   InitBattleEnemyParameters+3


pcall:                   ; now dma hijack always points to this address
call dmapayload          ; it calls our custom dma payload

.endoam                  ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
ret	

dmapayload:              ; we check specific addresses in stack to detect the address
ld   hl, stackaddress    ; HandleMenuInput is going to return to
ld   a, low(returnaddress) ; if detected, we set our custom address (hijackpayload)
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

hijackpayload:           ; when HandleMenuInput finishes execution it jumps to this script instead
; loop that calculates correct address for display names

ld   de, wNameBuffer     ; origin
ld   hl, $c3f6           ; destination tile - first letter of menu
ld   a, [wListScrollOffset]   ; it shows how many times the list has scrolled downwards
inc  a
ld   c, a                ; wListScrollOffset

; loop that overwrites list names
ld   b, $04              ; 4 lines to be replaced

.loopline  
push de                  ; saves wNameBuffer
push hl                  ; saves initial tile for later
ld   a, c                ; wListScrollOffset
ld   [wTrainerClass], a

cp   a, 48               ; if list ended, skip loading names
jr   nc, .endloop
cp   a, 25               ; replace name 25 with rival's
jr   z, .rival
and  a, %11111110        ; combines 42 and 43 by clearing bit 0
cp   a, 42               ; replace name 42 or 43 with rival's
jr   nz, .aftercheck

.rival
ld   de, wRivalName
jr   .loopletter
.aftercheck
push bc                  ; b: lines remaining, c: wListScrollOffset
call GetTrainerName      ; other registers are the same
pop  bc
pop  hl                  ; initial tile
pop  de                  ; wNameBuffer
push de
push hl                  ; saves initial tile for later

; fetches text replacement
.loopletter
ld   a, [de]
inc  de
cp   a, $50              ; if @
jr   z, .endloop         ; stops execution without writing char
ld   [hli], a            ; else write char and repeat
jr   .loopletter

.endloop
pop  hl                  ; restores first tile
ld   de, $0028           ; tiles to be added
add  hl, de              ; calculates next line
pop  de                  ; restores wNameBuffer address
inc  c                   ; wListScrollOffset + 1
dec  b                   ; subtracts 1 line from the counter
jr   nz, .loopline       ; are remaining lines 0?

endjp:
jp   DisplayListMenuIDLoop+6

wmenulist:
db listitems

.end
ENDL

