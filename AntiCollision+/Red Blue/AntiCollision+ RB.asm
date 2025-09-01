/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

def nicknameaddress      = $d8b5
def safejump             = $00b4


SECTION "PermaHijack", ROM0

LOAD "Hijack_Destination", WRAMX[nicknameaddress]

; it runs once
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
     
;;;;;;;;;;;; Executed by OAM DMA hijack ;;;;;;;;;;;;;;;;

; It checks and sets Map Script Pointer after backing up the original one
DMAhijack: 
     
; Preload addresses
ld   hl, wCurMapScriptPtr+1   ; original msp address
ld   de, mspbackup+2          ; msp backup address

; checks if MSP is hijacked
ld   a, d                     ; Custom wCurMapScriptPtr high byte check
cp   a, [hl]                  ; Compares current to custom pointer
jr   z, endoam                ; Skips msp moddification if already done

; moves original MSP to backup location and sets the custom one
backup:
ld   a, [hl-]
ld   [de], a
dec  de
ld   a, [hl]
ld   [de], a
ld   a, low(MSPhijack)
ld   [hl+], a
ld   [hl], high(MSPhijack)

; setting return values for OAM DMA routine
endoam:
ld   c, $46
ld   a, $c3
ret	

;;;;;;;;;;;;;; Executed by MSP hijack ;;;;;;;;;;;;;;;;;;
MSPhijack:               ; is executed by map script
call mspayload

mspbackup:
jp   safejump            ; safe jump just in case, it is replaces later by the script


;;;;;;;;;;;;;;;;;;;; MSP Payload ;;;;;;;;;;;;;;;;;;;;;;;;
mspayload:
ld   a, [wStatusFlags5]  ; spin check
and  a                   ; to avoid bugs
ret  nz

ld   hl, hJoyInput
ld   c, [hl]
bit  1, [hl] 			; B Button
jr   z, .skip            ; reset collision if not pressed

call check               ; if B pressed call checks
xor  a                   ; a = 0 is needed for later
dec  b                   ; check flag b
jr   nz, .skip           ; if b was 0, forbid movement
inc  a                   ; else walk through walls
.skip
ld   [wSimulatedJoypadStatesIndex], a ; Changes collision: 0 = ON, 1 = OFF
ret

check:
ld   b, a                ; a = 0, b flag = 0 for later
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
ld   a, [wCurMap]
and  a                   ; checks for Pallet town
jr   z, .lmap
cp   a, $10              ; route 5
ld   a, [hl]
jr   nz, .nolmap
.lmap
ld   a, [hl]
dec  a                   ; it narrows borders 1 tile
.nolmap
and  a
jr   nz, checkright      ; next check if not on map left
ld   a, [de]             ; else check map connections
bit  1, a                ; check left connection
jr   nz, checkright      ; if it exists go to next check
bit  5, c                ; else check key left
ret  nz                  ; ret if pressed

checkright:
ld   a, [wCurMap]
and  a                   ; checks for Pallet town
jr   z, .rmap
cp   a, $10              ; route 5
ld   a, [wCurrentMapWidth2]
jr   nz, .normap
.rmap
ld   a, [wCurrentMapWidth2]
dec  a                   ; it narrows borders 1 tile more
.normap
dec  a
cp   a, [hl]
jr   nz, last            ; finish if not on map right
ld   a, [de]             ; else check map connections
bit  0, a                ; check right connection
jr   nz, last            ; if it exists go to finish
bit  4, c                ; else check key right
ret  nz                  ; ret if pressed
 
last:
inc  b                   ; b flag = 1
ret

.end
ENDL
