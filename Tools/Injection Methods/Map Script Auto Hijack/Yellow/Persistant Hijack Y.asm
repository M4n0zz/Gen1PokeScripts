/* To be compiled with RGBDS 

Persistence - Permanent OAM+MSP hijack

Description

Setting up this hijack will create two ways to execute code permanently in the game.
1) Through OAM DMA routine: Custom payloads will be executed once in every frame, useful to program constant effects in the game.
2) Through Map Script: Custom payloads will be executed only when player is in overworld and not moving, useful for skipping some checks in the payloads.



*********** Logic **********

Part 1
- OAM DMA routine executes Map Script pointer (MSP) manipulator, which checks if MSP is hijacked.
- If not, current room is checked. If HoF is detected, it waits for the active dialogs to close and replaces room id with an unused one.
- Afterwards, original MSP is copied to the end of this routine, and a custom one replaces it.
- OAM DMA payloads are execuded.
- Proper registers are set and OAM DMA routine continues its normal execution.

Part 2
- Starting up the game, custom MSP targets our custom MSP payload.
- MSP payload checks for active OAM hijack. If OAM is not hijacked, it sets it up.
- After setting up OAM hijack, currect active room is checked. If unused room $0b is detected, manual map reset after HoF is performed. 
- Custom MS payloads are executed
- Finally, a jump from the original backed up MSP happens and the game continues to its normal state.

*/

include "pokeyellow.inc"

DEF nicknameaddress      = $d8b4
DEF HardcodedBankswitch1 = $1135
DEF MMpressedA           = $5c83
DEF MSPayloads           = $0000   ; set your desired execution address for map script payloads


SECTION "PermaHijack", ROM0

LOAD "Hijack_Destination", WRAMX[nicknameaddress]

;;;;;;;;;;;;;; Executed by MSP hijack ;;;;;;;;;;;;;;;;;;
MSPhijack:
; it checks if DMA hijack is on
ld   hl, hDMARoutine
ld   a, $cd                   ; if there is a call there, it means it is hijacked
cp   a, [hl]
jr   z, mspayloads

; if unset, it sets the hijack
di	
ld   [hl+], a
ld   a, low(DMAhijack)
ld   [hl+], a
ld   a, high(DMAhijack)
ld   [hl+], a
ld   [hl], $e2

; checks and initialises map if unused room is detected in place of HoF
ld   hl, wCurMap              ; 00=Pallet town, 76=HoF room, 0b=unused
ld   a, [hl]
cp   a, $0b                   ; if unused room is detected
jr   nz, endcp 	
ld   [hl], $76                ; set room back to HoF
ld   sp, $e003                ; underflows SP to fix stack imbalance
ld   hl, MMpressedA           ; run MainMenu.pressedA, as it is intended by the game
jp   HardcodedBankswitch1     ; Bankswitch with preset bank 1

endcp:
ei

mspayloads:
; call MSPayloads		     ; optional payloads execute by MSP	

originalmsp:
jp   payloads                 ; original map script pointer is backed up here

     
;;;;;;;;;;;; Executed by OAM DMA hijack ;;;;;;;;;;;;;;;;

; It checks and sets Map Script Pointer after backing up the original one
DMAhijack: 
     
; Preload addresses
ld   hl, wCurMapScriptPtr+1
ld   de, originalmsp+2

; checks if MSP is hijacked
ld   a, d                     ; Custom wCurMapScriptPtr high byte check
cp   a, [hl]                  ; Compares current to custom pointer
jr   z, dmapayloads

; room checking to bypass HoF reset
ld   bc, wCurMap              ; 00=Pallet town, 76=HoF room, 0b=unused
ld   a, [bc]
cp   a, $76                   ; if wCurMap = HoF
jr   nz, backup
ld   a, [wLetterPrintingDelayFlags]		; 
and  a                        ; check if text is active
jr   nz, dmapayloads          ; if 0 do following
ld   a, $0b                   ; set wCurMap to unused id
ld   [bc], a

; moves original MSP and sets the custom one
backup:
ld   a, [hl-]
ld   [de], a
dec  de
ld   a, [hl]
ld   [de], a
ld   a, low(MSPhijack)
ld   [hl+], a
ld   [hl], high(MSPhijack)

; runs custom payloads
dmapayloads:
call payloads

; setting return values for OAM DMA routine
endoam:
ld   c, $46
ld   a, $c3
ret	

; custom payloads go here
payloads:
ret




