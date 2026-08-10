; Tetris Minigame Z80 ASM (Reconstructed for Japanese Pokémon Green)
; Decompiled and annotated by ChatGPT
; Address and function names replaced from pokegreen v1.1


/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


def  nicknameaddress     = $d8b5
def  instaladdress       = $c997
def  nickwriterpointer   = $c7c7

def  drawblock           = $c940
def  collisioncheck      = $c949
def  rotateandcheck      = $c981



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
; === Clear game area ($C3A0 - $C508 = 0x168 bytes) ===
call ClearScreen              ; fill screen with 7F bytes = white tiles
call UpdateSprites            ; removes sprites from screen

; === Init Sequence ===
ld   a, $1f                   ; sound bank
ld   [wAudioROMBank], a       ; set sound bank
ld   a, $d9
call PlaySound                ; change music

; === Set grid borders with tile $7C every 0x10 offset ===
ld   hl, $c508                ; we start from bottom to the top of the screen tiles
ld   de, $127c                ; d: counter to run the loop for 18 layers, e: border tile
.borderLoop:
ld   bc, $fff7                ; - 9
add  hl, bc                   ; actually a substruction happens
ld   [hl], e                  ; writes border tile
ld   c, $f5                   ; - 11
add  hl, bc                   ; actually a substruction happens
ld   [hl], e                  ; writes border tile
dec  d                        ; decreases counter
jr   nz, .borderLoop


; === Game loop ===
newblock:
ld   b, $10                   ; the height the piece starts falling from
ld   hl, $c3a4                ; initial drop position
call Random                   ; generate a number
and  a, $3e                   ; %00111110 to randomly select any piece in any orientation
ld   c, a                     ; save it in c
call collisioncheck           ; decode current block and return a
and  a
jr   z, blockcontrol          ; if a is not zero, collision detected and game is over

; === Game Over Sequence ===
ld   a, $f1                   ; draw new block with Xes
call drawblock
ld   a, $a6                   ; load failure sound
call PlaySound
call WaitForSoundToFinish


waitaction:
ldh  a, [hJoyInput]
dec  a
jr   z, start                 ; restart game
dec  a
;ret  z
jp   z, PlayDefaultMusic
jr   waitaction


blockcontrol:
ld   a, $7f                   ; white tiles
call drawblock                ; remove old block position first

; === Process user input ===
push de                       ; only used for lines??
push bc
call Joypad                   ; Read joypad - remove it later and read hJoyInput directly
pop  bc

ldh  a, [hJoyPressed]
ld   d, a

checkleft:
bit  5, d
jr   z, checkright            ; if left is pressed
dec  hl                       ; changes block position to the left
call collisioncheck           ; then check collisions
and  a
jr   z, checkright            ; if collision is found
inc  hl                       ; restore previous block position

checkright:
bit  4, d
jr   z, checkb                ; if right is pressed
inc  hl                       ; changes block position to the right
call collisioncheck           ; then check collisions
and  a
jr   z, checkb                ; if collision is found
dec  hl                       ; restore previous block position

checkb:
bit  1, d
jr   z, checka                ; if b is pressed
ld   a, $10                   ; block offset is set
call rotateandcheck           ; rotate block left

checka:
bit  0, d
jr   z, checkdown             ; if a is pressed
ld   a, $f0                   ; block offset is set
call rotateandcheck           ; rotate block right

checkdown:
pop  de
ldh  a, [hJoyHeld]
and  a, $80
jr   z, checkheight           ; if down is pressed
ld   a, b
and  a, $e0                   ; reduce drop delay
ld   b, a

checkheight:
dec  b                        ; reduce byte by 1
bit  7, b                     ; if b underflows, block is landed
jr   z, notlanded

push hl                       ; save tile position
push bc                       ; save height and block byte
ld   bc, $0014
add  hl, bc
pop  bc                       ; restore height and block byte
call collisioncheck
and  a
jr   nz, restoreposition      ; collision is found and movement is restored

; if last row
ld   b, $10                   ; the height the piece starts falling from
pop  af                       ; it pops af to destroy last hl in stack
jr   checklanded

restoreposition:
pop  hl                       ; restore tile position

checklanded:
ld   a, b                     ; load height to a
inc  a                        ; to check z flag
jr   z, landed                ; else underflow continues op to df

notlanded:
ld   a, $8e                   ; load block tile
call drawblock                ; put it in new position
push bc
ld   c, 2
call DelayFrames
pop  bc
jr   blockcontrol             ; repeat control loop

landed:
ld   a, $ac
call PlaySound                ; play landing sound
ld   a, $8e
call drawblock                ; put block permanently in new position
ld   c, $12
call DelayFrames              ; delay 18 frames to sync with sound

; === Line cleanup routine ===
checklines:
ld   b, c                     ; c = 0 already - since piece is landed, b can be reused
ld   hl, $c4fe                ; set hl to last placeable tile
ld   d, h
ld   e, l

.lineLoop:
ld   c, $0a                   ; counter for total number of block tiles per line
push hl                       ; saves last tile address of current line

.checkRow:
ld   a, [hl-]                 ; check current tile and decrease
cp   a, $7f                   ; if tile is empty
jr   z, .rowIncomplete        ; break loop
dec  c                        ; else decrease counter
jr   nz, .checkRow            ; repeat

.rowIncomplete:
pop  hl                       ; restores last tile address of current line
and  a, c                     ; if c is 0 (a = $7f = b01111111), 1 byte is saved here
jr   nz, .copyRow

inc  b                        ; increase line number
push de                       ; save current line destination address
ld   de, $ffec                ; -20 tiles = -1 line
add  hl, de                   ; change to upper line
pop  de                       ; restore line destination address
jr   .nextLine

.copyRow:
ld   c, $0a                   ; set counter to 10 tiles
.copyLoop:
ld   a, [hl-]                 ; pass tiles from upper to lower row
ld   [de], a
dec  de
dec  c                        ; decrease counter
jr   nz, .copyLoop            ; if counter is zero, line copy is finished

ld   c, $0a                   ; set counter to 10 tiles
.skipBack:
dec  hl                       ; decrease 10 more tiles
dec  de                       ; to reach upper line
dec  c                        ; since screen has 20 tiles in total
jr   nz, .skipBack

.nextLine:
ld   a, l                     ; check hl low byte
cp   a, $96
jr   nz, .lineLoop            ; repeat until top line is detected

; Fill above lines with empty if needed
ld   a, e
.topFill:
cp   a, $96                   ; check if destination line byte is also at the top
jr   z, .linesChecked         ; skip if it is

ld   a, $7f                   ; empty tile
ld   c, $0a                   ; 10 tiles
.fillRow:
ld   [de], a                  ; if de is not on top line, fill the line with empty tiles
dec  de
dec  c
jr   nz, .fillRow

ld   a, $f6
add  a, e
ld   e, a                     ; reduce de by 10
jr   .topFill                 ; and repeat

.linesChecked:
xor  a                        ; a is 0
add  a, b                     ; a is b and flags are set, same as ld a,b  and a, but nice
jr   z, prenewblock           ; if b is 0, it goes to next block

cp   a, $04                   ; 4 lines check
ld   a, $a8                   ; simple line clear sound
ld   c, $30                   ; 0.5 sec delay no tetris
jr   nz, notetris             ; if less than 4 lines cleared - to remove this in simple version

ld   a, $94                   ; 4-line clear sound
ld   c, $60                   ; 1 sec delay for tetris
notetris:

call PlaySound
call DelayFrames              ; drop piece delay to finish sound

prenewblock:
jp   newblock                 ; try to move it close to the top to change it to jr

end:
ENDL

