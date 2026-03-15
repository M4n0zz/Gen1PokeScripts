
include "charmap.inc"
include "pokered.inc"


def nickaddress     = $d8b5
def bankswitch3     = $091a
def spriteinrom     = $4780
def romtrucktiles   = $69d0
def truckids        = $6c20
def mewsprite       = $80c0
def script          = $52
def palette         = $10
def vramsprite      = $02
def spritestate     = wSprite01StateData1
def spritey         = wSprite01StateData2MapY
def spriteimage     = wSprite01StateData2ImageBaseOffset


SECTION "Main", ROM0
Main:

LOAD "Mew_Event", WRAMX[nickaddress]

;;;;;;;;;;;;;; Executed by Nickname Writer ;;;;;;;;;;;;;;;;;;
ld   hl, wCurMapScriptPtr
ld   a, script                     ; vermilion docks map script
cp   a, [hl]
ret  nz                            ; stop if not detected
ld   [hl], low(MSPhijack)          ; custom Map Script Pointer is set
inc  hl
ld   [hl], high(MSPhijack)
ret

;;;;;;;;;;;;;; Executed by MSP hijack ;;;;;;;;;;;;;;;;;;

MSPhijack:
ld   hl, .eventflag                ; check flag for script state
ld   a, [hl]
and  a
jr   z, .dontreloadtruck           ; flag is 0, no event took place yet
dec  a
jr   nz, .flagisnot1

; if event is triggered and pokemon is not there, it makes a cleanup and fixes truck
inc  [hl]                          ; eventflag = 2
ld   [wNumSprites], a              ; a = 0 from previously
ld   [spritestate], a
inc  a                             ; it forces dontFixMew

.flagisnot1
dec  a
jr   z, .dontFixMew                ; if flag was 1 or 2, go on and reload track if needed

; if mew is out, setup sprite - different for rb / y
ld   hl, mewsprite                 ; else check vram and replace graphics
ld   a, [hl]
dec  a
jr   z, .dontFixMew

; fix mew graphics
ld   de, spriteinrom               ; mew sprite origin from ROM bank 5
ld   bc, $050c
call CopyVideoData

; fix mew text pointer - different for rb / y
ld   hl, .textPointer              ; in yellow text pointers dont start from 1
call SetMapTextPointer

.dontFixMew:                       ; dont move truck if already there
ld   hl, $c731                     ; ow map address
ld   a, $0c
cp   a, [hl]
jr   z, .dontreloadtruck           ; instantly moves truck after battle reload

ld   [hl], a                       ; reloadtruck    
jr   .changetruck
 
; else if all below checks are fulfilled, the truck is pushed
.dontreloadtruck:
ld   a, [wXCoord]                  ; check X position
cp   a, $13
ret  nz

ld   a, [wStatusFlags1]            ; check if strength is used
rrca                               ; shifts bits right to check bit0
ret  nc

ld   a, [wTileInFrontOfPlayer]     ; check if tile infront of player is the left side of truck
cp   a, $58
ret  nz

ld   a, [wPlayerMovingDirection]   ; check if player is pushing to the right
dec  a
ret  nz

; pushing truck event
dec  [hl]                          ; eventflag = $ff

; copy truck graphics inside vram
ld   de, romtrucktiles
ld   hl, $8c00
ld   bc, $191e                     ; pull 30 tiles from bank 25
ld   a, b
call BankswitchBack+3              ; same as BankswitchCommon
call CopyVideoData

.SetupLoop
ld   bc, $0341
.waitForNonHBlank
ldh  a, [c]
and  a, b
jr   z, .waitForNonHBlank

.waitForHBlank
ldh  a, [c]
and  a, b
jr   nz, .waitForHBlank

inc  hl
ld   a, [hl-]
xor  a, $ff
xor  a, [hl]
ld   [hl+], a
inc  hl
ld   a, $8e
cp   a, h
jr   nz, .SetupLoop


; it renders truck tiles using correct colors
ld   a, %11100000                  ; $e0
ldh  [$ff49], a

ld   a, $0d
ld   [wSpriteStateData1+2], a      ; walking sprite

ld   a, $02
call StopMusic                     ; a = 2 frames to stop music
ld   hl, TryPushingBoulderdone+3
call bankswitch3


ld   a, $ff
ld   [wUpdateSpritesEnabled], a


; load truck tiles in OAM sprite buffer
ld   hl, wShadowOAMSprite14        ; every ShadowOAMSprite uses 4 bytes
push hl                            ; save address for later
ld   bc, $5058                     ; initial sprite X coord
ld   de, truckids                  ; truck tile ids location

.loadloop
ld   [hl], b
inc  hl
ld   [hl], c
inc  hl
ld   a, c
add  a, $08
ld   c, a
ld   a, [de]
add  a, $84
ld   [hl+], a
inc  de
ld   [hl], palette
inc  hl
cp   a, $d0
jr   z, .loadstop
cp   a, $cf
jr   nz, .loadloop
ld   bc, $5858
jr   .loadloop

.changetruck
ld   a, $03
ld   bc, $000b                     ; coords to right of truck

.changetiles:                      ; function to be used later
ld   [wNewTileBlockID], a
ld   a, $17                        ; ReplaceTileBlock
jp   Predef

.loadstop

; remove truck from original position
ld   a, $0c
ld   bc, $000a                     ; coords to truck original position
call .changetiles

; init addresses for graphics in OAMBuffer
ld   c, $20                        ; frames
ld   de, $0004
push de                            ; saved for later too

; move truck using OAM sprites
.movetruck
ld   hl, wShadowOAMSprite14XCoord  ; 4 * 4 + 1
ld   a, $08                        ; sprites

; moves truck 1 pixel to the right
.shiftTruck
inc  [hl]
add  hl, de                        ; wShadowOAMSprite15XCoord etc
dec  a                             ; loops until 8 sprites are moved
jr   nz, .shiftTruck

call DelayFrame
dec  c
jr   nz, .movetruck

call .changetruck                  ; put truck in new position

ld   a, $01
ld   [wUpdateSpritesEnabled], a
ld   [wNumSprites], a
ld   bc, $a010
pop  de                            ; $0004
pop  hl                            ; wShadowOAMSprite14

.hideSpritesLoop
ld   [hl], b
add  hl, de
dec  c
jr   nz, .hideSpritesLoop

; setups and shows Mew sprite on the map
ld   a, $01
ld   [wNumSprites], a
ld   [spritestate], a
ld   hl, spritey
ld   [hl], $04                     ; sprite Y position
inc  hl
ld   [hl], $19                     ; sprite X position
inc  hl
ld   [hl], $ff                     ; sprite not moving
ld   hl, spriteimage
ld   [hl], vramsprite              ; vram sprite position    
ret


; Text pointer message and code. It activates when speaking to Mew
.textPointer
dw   .pointer                      ; db   low(.pointer), high(.pointer) ; pointer to this text


.pointer
db   $00, "Mew!", $50 , $08

ld   a, $15                        ; Mew ID, lvl
ld   [wCurOpponent], a
ld   [wCurEnemyLevel], a
call PlayCry

ld   hl, .eventflag
ld   [hl], $01
ld   hl, wCurMapTileset            ; don't reload map script after battle
set  7, [hl]                       ; it resets when battle ends
jp   TextScriptEnd

.eventflag:
db   $00



.end
ENDL  

 