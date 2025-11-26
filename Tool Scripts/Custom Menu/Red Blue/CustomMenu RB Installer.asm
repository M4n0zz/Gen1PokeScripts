/*

Custom Menu Installer - Compatible with EN Red and Blue ONLY


Description
This script installs Custom Menu into TimOS environment.


Instructions
1) Change "InstallationAddress" to the address you want to install your payload at.
2) Compile your script using (Quick)RGBDS.
3) Install the output HEX code over NicknameWriter (https://timovm.github.io/NicknameConverter/).

The script will automatically calculate the offsets needed for:
- Script selector
- Jump table
- The script itself

Warning!
Make sure the memory space for your script is unused before installation!



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"
include "charmap.inc"

def listitems            = 4
def nicknameaddress      = $d8b5
def tablelist            = $da00
def stackaddress         = $dfd9
def returnaddress        = DisplayListMenuIDLoop+6
def listaddress          = $d8b4
def timospointers        = $c7c7
def InstallationAddress  = $c9ce

SECTION "CustomMenu", ROM0

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
db   low(menustart), high(menustart)
.end
ENDL


LOAD "CustomMenuScript", WRAM0[InstallationAddress]

start:                        ; do not replace this

; Declares the number of list items and creates a list of them at the end of the script
menustart:
ld   hl, wListPointer	     ; list header is stored
ld   de, tablelist
ld   [hl], e
inc  hl
ld   [hl], d
ld   a, listitems
ld   b, a
ld   [de], a
ld   a, $56                   ; items id is the least noticable one

buildloop:                    ; builds item list at the end of the script
inc  de
ld   [de], a
dec  b
jr   nz, buildloop
inc  de
ld   a, $ff                   ; adds cancel item
ld   [de], a                  ; it is ff anyway, no need to make it


; Presets necessary menu options
openmenu:
ld   hl, wListScrollOffset
ld   b, [hl]
push hl
xor  a
ld   [hl], a                  ; initialize list items position
ld   l, low(wCurrentMenuItem)
ld   c, [hl]
push bc                       ; saves original menu pointer
ld   [hl], a                  ; initialize selector
ld   hl, wPrintItemPrices	
ld   [hl+], a			     ; wPrintItemPrices = 0
ld   [hl], $04                ; wListMenuID = 4


; Starts an OAM DMA hijack
hijack:
di                            ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine          ; we stop all interrupts to avoid crashes
ld   [hl], $cd                ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(menucode)      ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(menucode)
inc  hl
ld   [hl], $e2                ; ldh [c], a command is put to allow hijack to return dma's original code 
ei                            ; dma code modification is done, interrupts are enabled again


; Starts hardcoded menu function
call DisplayListMenuID


; Unloads DMA hijack when menu closes
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


; Stores menu selection flags and exits if B was pressed
pop  de
pop  hl                       ; wListScrollOffset
and  a, a	                    ; reads list menu button for later


; Calls the function of the selected list item in the address table
ld   b, [hl]
ld   [hl], d
ld   l, low(wCurrentMenuItem)
ld   a, [hl]
ld   [hl], e
ret  z                        ; exits if B was pressed earlier
add  a, b
ld   hl, functions
call CallFunctionInTable


; Reloads menu
jr   menustart		          ; reload menu



;;;;;;;;;;;; DMA Routine ;;;;;;;;;;;;

; When DMA hijack is active, it always hijacks DisplayListMenuIDLoop
menucode:                     ; we check specific addresses in stack to detect the address
ld   hl, stackaddress         ; HandleMenuInput is going to return to
ld   a, low(returnaddress)    ; if detected, we set our custom address (hijackpayload)
cp   a, [hl]
jr   nz, .endoam
inc  hl
ld   a, high(returnaddress)
cp   a, [hl]
jr   nz, .endoam
ld   a, high(hijackpayload)
ld   [hld], a
ld   a, low(hijackpayload)
ld   [hl], a

.endoam                       ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
saferet:
ret	


; It runs right after PrintListMenuEntries completes its execution
hijackpayload:                ; it overwrites list menu names
ld   de, menulabels           ; origin
ld   hl, $c3f6		          ; destination tile - first letter of menu
ld   a, [wListScrollOffset]   ; it shows how many times the list has scrolled downwards
inc  a                        ; +1
ld   b, a                     ; stored in b counter
ld   c, a                     ; stored in c counter

.loop                         ; breaks when correct label is found for line 1
dec  b
jr   z, next

.findstop                     ; next label is after @ char
ld   a, [de]
inc  de
cp   a, $50
jr   nz, .findstop
jr   .loop

; loop that overwrites list names
next:
ld   b, $04                   ; 4 lines to be replaced
push hl                       ; saves initial tile for later

.loop                         ; fetches text replacement
ld   a, [de]
inc  de
cp   a, $50                   ; if @
jr   z, .endloop              ; stops execution without writing char
ld   [hli], a                 ; else write char and repeat
jr   .loop

.endloop
pop  hl                       ; restores first tile

.nextline
push de                       ; saves current text origin
ld   de, $0028                ; tiles to be added to draw next line
add  hl, de                   ; calculates next line
pop  de                       ; restores dear address
push hl                       ; saves new line's first digit
dec  b                        ; subtracts 1 line from the counter
jr   nz, .loop                ; are remaining lines 0?

pop  hl                       ; restores saved line to keep balance of stack

endjp:
jp   DisplayListMenuIDLoop+6  ; jumps to original execution path


menulabels:
menu1:
db   "Script1@"
menu2:
db   "Script2@"
menu3:
db   "Script3@"
menu4:
db   "Script4@"
menu5:
db   "Cancel@"
menu6:
db   "@"


functions:
db   low(saferet), high(saferet)
db   low(saferet), high(saferet)
db   low(saferet), high(saferet)
db   low(saferet), high(saferet)


menuend:

end:                          ; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start

