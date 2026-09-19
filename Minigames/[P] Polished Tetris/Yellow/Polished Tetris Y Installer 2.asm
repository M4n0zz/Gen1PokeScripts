
/*
Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS
*/

include "pokeyellow.inc"
include "charmap.inc"

 
; part1 installation address
def  payloadaddress      = $c800


def  whitetile           = $7f
def  blocktile           = $d4
def  failtile            = $f1
def  tileAddress         = $5148
def  nickwriterpointer   = $c7c0
def  nicknameaddress     = $d8b4
def  tilenext            = $fff0
def  score               = $fff1
def  speed               = $fff2

; part1 references
def  drawblocktile       = payloadaddress + $40   
def  drawblock           = payloadaddress + $42
def  collisioncheck      = payloadaddress + $4b
def  checktile           = payloadaddress + $7b
def  checkandrotate      = payloadaddress + $83
def  setcounters         = payloadaddress + $94
def  placeblock          = payloadaddress + $b1
def  dpadhandler         = payloadaddress + $c4
def  labels              = payloadaddress + $e4
def  instaladdress       = payloadaddress + $f2


SECTION "PokeTetris", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
;;;;;;;;;;;; Installer payload ;;;;;;;;;;;; 
installer:
; increse no of scripts
ld   hl, $c6e9
ld   a, [hl]
inc  [hl]
add  a, a

ld   de, instaladdress        ; destination
ld   hl, nickwriterpointer    ; change nickname writer pointer inside timos
add  a, l
ld   l, a
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   hl, .end                 ; origin
ld   bc, end - start          ; Calculated in DEF
jp   CopyData
.end
ENDL


LOAD "NicknameWriterPayload", WRAM0[instaladdress]
;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
start:
ld   bc, $0405                ; load 5 tiles from bank $04
ld   de, tileAddress          ; from address
ld   hl, $8d00                ; to unused vram address
call CopyVideoData


; === Clear BG ===
entrypoint:
call GBFadeOutToWhite         ; fade out effect
call ClearScreen              ; fill screen with 7F bytes = white tiles
call UpdateSprites            ; removes sprites from screen

; === Init Sequence ===
ld   a, $1f                   ; sound bank
ld   [wAudioROMBank], a       ; set sound bank
ld   a, $d9
call PlaySound                ; change music

; === Copy Labels ===
ld   bc, $0405
ld   de, $c3c2                ; "score" lablel tile position
ld   hl, labels
call CopyMapConnectionHeaderloop
ld   c, b
ld   de, $c426                ; "best" lablel tile position
call CopyMapConnectionHeaderloop
ld   c, b
ld   e, $8a                   ; "next" lablel tile position
call CopyMapConnectionHeaderloop

; === Init values ===
xor  a
ldh  [score], a               ; initial score = 0
inc  a
ldh  [hJoy6], a               ; JoypadLowSensitivity flag1 = 1
ldh  [hJoy7], a               ; JoypadLowSensitivity flag2 = 1
ldh  [speed], a               ; initial delay frames for game speed
call setcounters

; === Set grid borders with tile $7C every 0x10 offset ===
ld   hl, $c508                ; we start from bottom to the top of the screen tiles
ld   de, $12d0                ; d: counter to run the loop for 18 layers, e: border tile

.borderloop
ld   bc, $fff7                ; - 9
add  hl, bc                   ; actually a substruction happens
ld   [hl], e                  ; writes border tile
ld   c, $f5                   ; - 11
add  hl, bc                   ; actually a substruction happens
ld   [hl], e                  ; writes border tile
dec  d                        ; decreases counter
jr   nz, .borderloop
call GBFadeInFromWhite
call placeblock               ; generate next block and show it in the indicator


; === Game loop ===
newblock:
ldh  a, [tilenext]            ; load previous block from hram
ld   c, a                     ; save it into c
push bc
call placeblock               ; generate next block and show it in the indicator
pop  bc
ld   b, $10                   ; the height the piece starts falling from
ld   hl, $c3a4                ; initial drop position
call collisioncheck           ; decode current block and return a
jr   z, blockcontrol          ; if a is not zero, collision detected and game is over

; === Game Over Sequence ===
ld   a, failtile              ; draw new block with Xes
call drawblock
xor  a
call StopMusic
ld   a, $97                   ; load failure sound
call PlaySound
call WaitForSoundToFinish

.waitaction
ldh  a, [hJoyInput]
dec  a
jr   z, entrypoint            ; restart game
dec  a
jr   nz, .waitaction
jp   PlayDefaultMusic         ; exit game

notlanded:
call drawblocktile            ; put it in new position
call ProtectedDelay3          ; saves bc and delays 3 frames

blockcontrol:
ld   a, whitetile             ; white tiles
call drawblock                ; remove old block position first

; === Process user input ===
push bc
call JoypadLowSensitivity     ; Read joypad
pop  bc

ldh  a, [hJoy5]               ; used for left and right extended press
ld   d, a
ldh  a, [hJoyPressed]         ; use for block rotation
ld   e, a


bit  2, a
jr   z, .checkdown
push hl
ld   hl, wMuteAudioAndPauseMusic
set  0, [hl]
ld   a, $b5                   ; pause sound
call PlaySound                ; change music

.loopuntilstart
ldh  a, [hJoyInput]           ; use for block rotation
bit  3, a
jr   z, .loopuntilstart
xor  a
ld   [hl], a
pop  hl

.checkdown
call dpadhandler

.checkab:
ld   a, e
and  a, %00000011
jr   z, .checkheight          ; if a is pressed
and  a, %00000010
swap a
add  a, $f0
call checkandrotate           ; rotate block right

.checkheight
ldh  a, [speed]

.dropspeed
dec  b                        ; reduce byte by 1
dec  a
jr   nz, .dropspeed
bit  7, b                     ; if b underflows, block is landed
jr   z, notlanded
ld   b, $ff
push hl                       ; save tile position
push bc                       ; save height and block byte
ld   bc, $0014
add  hl, bc
pop  bc                       ; restore height and block byte
call collisioncheck
jr   nz, .restoreposition     ; collision is found and movement is restored

; if last row
ld   b, $10                   ; the height the piece starts falling from
pop  af                       ; it pops af to destroy last hl in stack
jr   .checklanded

.restoreposition
pop  hl                       ; restore tile position

.checklanded
ld   a, b                     ; load height to a
inc  a                        ; to check z flag
jp   nz, notlanded            ; else underflow continues op to df

.landed
ld   a, $ac
call PlaySound                ; play landing sound
call drawblocktile            ; put block permanently in new position
;call WaitForSoundToFinish    ; it bugs out
ld   c, $1e
call DelayFrames              ; 30 frames to generate new block and sync with sound

; === Line cleanup routine ===
ld   hl, $c4fe                ; set hl to last placeable tile
ld   d, h                     ; copy address to de
ld   e, l
ld   b, c                     ; b = c = 0 already - since piece is landed, b now measures full lines

cleanuploop:
ld   c, $0a                   ; counter for total number of block tiles per line
push hl                       ; saves last tile address of current line

.tilecheck
ld   a, [hl-]                 ; check current tile and decrease
cp   a, $7f                   ; if tile is empty
jr   z, .copyline             ; break loop
dec  c                        ; else decrease counter
jr   nz, .tilecheck           ; repeat for all tiles in this line
inc  b                        ; increase line counter
pop  hl                       ; restores last tile address of current line
push de                       ; save current line destination address
ld   de, $ffec                ; -20 tiles = -1 line
add  hl, de                   ; change line origin to upper line
pop  de                       ; restore line destination address
jr   .toplinecheck

.copyline                     ; it copies previous line
pop  hl                       ; restores last tile address of current line
ld   c, $0a                   ; set counter to 10 tiles

.copyloop
ld   a, [hl-]                 ; pass tiles from upper to lower row
ld   [de], a
dec  de
dec  c                        ; decrease counter
jr   nz, .copyloop            ; if counter is zero, line copy is finished
ld   c, $0a                   ; set counter to 10 tiles

.skiploop
dec  hl                       ; decrease 10 more tiles
dec  de                       ; to reach upper line
dec  c                        ; since each line has 20 tiles in total
jr   nz, .skiploop

.toplinecheck
ld   a, l                     ; check hl low byte
cp   a, $96                   ; top line address low nibble
jr   nz, cleanuploop          ; repeat until top line is detected

; Fill above lines with empty if needed
ld   a, e

.topfillcheck
cp   a, $96                   ; check if destination line byte is also at the top
jr   z, .topline              ; skip if top line is reached
ld   a, $7f                   ; empty tile
ld   c, $0a                   ; 10 tiles

.linefill
ld   [de], a                  ; if de is not on top line, fill the line with empty tiles
dec  de
dec  c
jr   nz, .linefill
ld   a, $f6
add  a, e
ld   e, a                     ; reduce de by 10
jr   .topfillcheck            ; and repeat

.topline
xor  a                        ; a is 0
add  a, b                     ; a is b and flags are set, same as ld a,b  and a, but nice
jr   z, prenewblock           ; if b is 0, it goes to next block
cp   a, $04                   ; 4 lines check
push af
ldh  a, [score]
add  a, b
ldh  [score], a

swap a
and  a, $0f
inc  a

ldh  [speed], a

.tetrischeck
call setcounters
pop  af
ld   a, $a8                   ; simple line clear sound
jr   nz, .notetris            ; if less than 4 lines cleared - to remove this in simple version
ld   a, $91                   ; 4-line clear sound

.notetris
call PlaySound
call WaitForSoundToFinish


prenewblock:
jp   newblock                 ; try to move it close to the top to change it to jr

end:
ENDL
