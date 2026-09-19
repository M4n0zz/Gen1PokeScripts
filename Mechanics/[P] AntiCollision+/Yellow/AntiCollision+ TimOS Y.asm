/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

def returnaddress        = OverworldLoopLessDelay+3
def timospointers        = $c7c0
def timosinstalladr      = $c841
def installaddress       = $d66a
def nicknameaddress      = $d8b4
def topstack             = $df15
def stackaddress         = $dffd


SECTION "PermaHijack", ROM0

LOAD "Installer", WRAMX[nicknameaddress]

installer:               ; it runs once upon installation
; change scripts number
ld   hl, $c6e9           ; number of scripts address
ld   b, [hl]             ; counter for later
inc  [hl]                ; increase script number by 1

; write pointers to the correct position
ld  hl, timospointers    ; start counting from script #1
.pointerloop
inc  hl
inc  hl
dec  b                   ; if counter = 0, current pointer is the one to change
jr   nz, .pointerloop    ; else loop until b = 0

; Copy script address to the calculated pointer
ld   de, start          ; origin
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   hl, installend
ld   bc, end-hijackpayload + finish-DMAhijack + endjack-start
jp   CopyData

installend:
ENDL


LOAD "TimOS_payload", WRAM0[timosinstalladr]

start:                   ; it runs once upon activation
ld   hl, endjack
ld   de, topstack
ld   c, finish - DMAhijack
call CopyMapConnectionHeaderloop

ld   de, installaddress
ld   c, end - hijackpayload
call CopyMapConnectionHeaderloop

di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   a, $cd              ; $ff80 is replaced with command "call", to jump to our custom address
ld   [hl+], a
ld   a, low(DMAhijack)   ; $ff81 and $ff82 hold hijack's custom address
ld   [hl+], a
ld   a, high(DMAhijack)
ld   [hl+], a
ld   [hl], $e2           ; ldh [c], a command is put to allow hijack to return dma's original code 
reti                     ; dma code modification is done, interrupts are enabled again

endjack:
ENDL


LOAD "StackPayload", WRAMX[topstack]
;;;;;;;;;;;; Executed by OAM DMA hijack ;;;;;;;;;;;;;;;;

DMAhijack:     ; 23 bytes

; stack check and replace
ld   hl, stackaddress            ; stack return pointer for PrintListMenuEntries
ld   a, [hli]
cp   a, low(returnaddress)
jr   nz, endoam
ld   a, [hl]
cp   a, high(returnaddress)
jr   nz, endoam
ld   a, high(hijackpayload)
ld   [hld], a
ld   [hl], low(hijackpayload)
     
; setting return values for OAM DMA routine
endoam:
ld   c, $46
ld   a, $c3
ret

backupad:
finish:
ENDL


LOAD "Script", WRAMX[installaddress]    ; 73 bytes

;;;;;;;;;;;;;; Executed by stack hijack ;;;;;;;;;;;;;;;;;;
hijackpayload: ; 53 bytes
ld   a, [wStatusFlags5]  ; automove/spin check
and  a
jr   nz, payloadend      ; don't run if auto moving/spinning

ldh  a, [hJoyInput]
ld   c, a                ; holds value for later

call check               ; if pressed call checks
ld   hl, wTilesetCollisionPtr+1
ld   de, backupad
jr   nz, .forbid         ; if zero not set, put collision everywhere

ld   a, [hld]            ; else restore original collisions
and  a
jr   nz, .checkb         ; no need to restore if already 0 

; restore wTilesetCollisionPtr
call WriteOAMBlockwriteOneEntry+4

.checkb
xor  a                   ; needed for later
bit  1, c 			; B Button check
jr   z, .clip            ; reset collision if not pressed
inc  a
jr   .clip               ; else walk through walls

.forbid
ld   a, [hld]           ; check to forbid movement
and  a
jr   z, .clip            ; no need to restore if already 0  

ld   a, [hli]            ; backup original address first
ld   [de], a
inc  de
ld   a, [hl]
ld   [de], a
xor  a                   ; also used to reset collision
ld   [hld], a            ; zedro out wTilesetCollisionPtr to block movement
ld   [hl], a

.clip
ld   [wSimulatedJoypadStatesIndex], a ; Loads Walk Type

payloadend:
jp   returnaddress

check:
ld   b, %11000000        ; to skip check if up or down is pressed along with direction keys
ld   de, wCurMapConnections
ld   hl, wYCoord         ; current Y position
ld   a, [hl]
and  a
jr   nz, checkbot        ; next check if not on map top
ld   a, [de]             ; else check map connections
bit  3, a                ; check top connection
jr   nz, checkbot        ; if it exists go to next check
bit  6, c                ; else check key up
ret  nz                  ; ret if pressed

checkbot:
ld   a, [wCurrentMapHeight2]
dec  a
cp   a, [hl]
jr   nz, checkleft       ; next check if not on map bot
ld   a, [de]             ; else check map connections
bit  2, a                ; check bot connection
jr   nz, checkleft       ; if it exists go to next check
bit  7, c                ; else check key down
ret  nz                  ; ret if pressed

checkleft:
inc  hl                  ; wXCoord
ld   a, [hl]
and  a
jr   nz, checkright      ; next check if not on map left
ld   a, [de]             ; else check map connections
bit  1, a                ; check left connection
jr   nz, checkright      ; if it exists go to next check
ld   a, c
and  a, b
jr   nz, checkright      ; if it exists go to next check
bit  5, c                ; else check key left
ret  nz                  ; ret if pressed

checkright:
ld   a, [wCurrentMapWidth2]
dec  a
cp   a, [hl]
jr   nz, last            ; finish if not on map right
ld   a, [de]             ; else check map connections
bit  0, a                ; check right connection
jr   nz, last            ; if it exists go to finish
ld   a, c
and  a, b
jr   nz, last            ; if it exists go to next check
bit  4, c                ; else check key right
ret  nz                  ; ret if pressed
 
last:
xor  a                   ; set z
ret                      ; z = 1

end:
ENDL

