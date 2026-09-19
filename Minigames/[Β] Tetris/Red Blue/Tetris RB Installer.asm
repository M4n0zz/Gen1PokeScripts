
/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


def  blocktile           = $8e
def  instaladdress       = $c929
def  nickwriterpointer   = $c7c7
def  nickwriteraddress   = $d8b5
def  temp                = $fff0


SECTION "PokeTetris", ROM0

LOAD "Installer", WRAMX[nickwriteraddress]

installer:
ld   hl, $c6e9
ld   a, [hl]
inc  [hl]                     ; increse no of scripts
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
ld   de, $247c                ; d: counter to run the loop for 18 layers, e: border tile
.borderLoop:
ld   bc, $fff6                ; - 10
add  hl, bc                   ; actually a substruction happens
ld   [hl], e                  ; writes border tile
dec  d                        ; decreases counter
jr   nz, .borderLoop          ; de exits $007c from here


; === Game loop ===
newblock:
ld   b, $10                   ; the height the piece starts falling from
ld   hl, $c3a4                ; initial drop position
call Random                   ; generate a number
and  a, $3e                   ; %00111110 to randomly select any piece in any orientation
ld   c, a                     ; save it in c
call collisioncheck           ; decode current block and return a
jr   z, blockcontrol          ; if a is not zero, collision detected and game is over

; === Game Over Sequence ===
xor  a                        ; is needed to stop music instantly
call StopMusic

.waitaction
ldh  a, [hJoyInput]
dec  a
jr   z, start                 ; restart game
dec  a
jr   nz, .waitaction
jp   PlayDefaultMusic         ; go backif b pressed

notlanded:
call drawblocktiles           ; put it in new position
call DelayFrame

blockcontrol:
ld   a, $7f                   ; white tiles
call drawblock                ; remove old block position first

; === Process user input ===
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
jr   z, checkright            ; if collision is found
inc  hl                       ; restore previous block position

checkright:
bit  4, d
jr   z, checkab                ; if right is pressed
inc  hl                       ; changes block position to the right
call collisioncheck           ; then check collisions
jr   z, checkab                ; if collision is found
dec  hl                       ; restore previous block position

checkab:
ld   a, d
and  a, %00000011
jr   z, checkdown             ; if a is pressed
and  a, %00000010
swap a                        ; $02 -> $20
add  a, $f0                   ; if A, a = $f0, if B, a = $10
call checkandrotate           ; rotate block right

checkdown:
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
jr   nz, notlanded            ; else underflow continues op to df

landed:
ld   a, $ac
call PlaySound                ; play landing sound
call drawblocktiles           ; put block permanently in new position
call WaitForSoundToFinish     ; retains hl, bc, de, returns a=0

; === Line cleanup routine ===
ld   hl, $c4f5                ; set hl to first placeable tile in last line

cleanuploop:
ld   a, l                     ; check if current top line
cp   a, $a1                   ; top line address low nibble
jp   z, newblock
ld   c, $09                   ; counter for total number of block tiles per line
push hl                       ; saves first tile address of current line

.tilecheck
ld   a, [hl+]                 ; check current tile and inrease
rla
jr   c, .tilenext             ; carry set = block found
pop  hl                       ; if white, go on with upper line
ld   bc, $ffec                ; -20 tiles = -1 line
add  hl, bc                   ; change to upper line
jr   cleanuploop

.tilenext
dec  c                        ; else decrease counter
jr   nz, .tilecheck           ; repeat for all tiles in this line
pop  hl                       ; restores upper line to origin
push hl

.clearline                    ; if no white tile is found, line is full
ld   d, h                     ; backup to de
ld   e, l
ld   bc, $ffec                ; -20 tiles = -1 line
add  hl, bc                   ; change to upper line
ld   a, l                     ; check if current top line
cp   a, $8d                   ; top line address low nibble
jr   nz, .copyline            ; if not out of screen range, go on
pop  hl
jr   cleanuploop              ; run again

.copyline
push hl                       ; store again
ld   c, $09                   ; set counter to 20 tiles
call CopyMapConnectionHeaderloop   ; pass tiles from upper to lower row
pop  hl                       ; since upper line is copied to lower, we keep checking the same line
jr   .clearline


; Encoded blocks - each block consists of 2 bytes and each bit represents 1 tile in a 4x4 grid
; the position of each line represents the rotation of the block in the same column
blocks:
db $60, $06, $60, $03, $30, $06, $40, $07, $20, $07, $10, $07, $22, $22, $22, $22 
db $60, $06, $31, $02, $32, $01, $30, $22, $20, $23, $20, $32, $00, $0f, $00, $0f 
db $60, $06, $60, $03, $30, $06, $00, $17, $00, $27, $00, $47, $22, $22, $22, $22
db $60, $06, $31, $02, $32, $01, $20, $62, $20, $26, $60, $22, $00, $0f, $00, $0f 


drawblocktiles:
ld   a, blocktile             ; load block tile

drawblock:
push af
ld   a, low(loadtile)        ; loads tile loading function low byte address
ld   [changable+1], a        ; puts it in changeable function pointer
pop  af
jr   blockhandler


collisioncheck:
ld   a, low(checktile)        ; loads empty check function low byte address
ld   [changable+1], a         ; puts it in changeable function pointer

xor  a

blockhandler:
push hl                       ; saves draw tile position
push de                       ; saves 
push bc                       ; saves game height and block id
ld   b, high(blocks)          ; blocks high byte in b, so [bc] is the generated block id
call bytedecoder              ; decodes 1st block byte and places or checks tiles in block lines 1 and 2
inc  bc                       ; selects generated block address 2nd byte
call bytedecoder              ; decodes 2nd block byte and places or checks tiles in block lines 3 and 4
and  a                        ; check placement status - output for caller function
jp   PlaySounddone            ; pops everything and returns     

; === Draw piece shifted 4 pixels wide ===
bytedecoder:
push af
ld   a, [bc]                  ; loads current block id
ld   e, a                     ; in e
pop  af
call next                     ; calls next address in order to run it twice

next:
ld   d, $04                   ; 4 bits to be used

blockbitloop:
rr   e                        ; checks each bit of the loaded block id and checks or draws a tile if true

changable:                    ; call address is self modified by the game
call c, loadtile              ; can be loadtile or checktile, BOTH ADDRESSES NEED TO HAVE THE SAME HIGH BYTE

inc  hl                       ; increases draw tile address
dec  d
jr   nz, blockbitloop         ; repeat 4 times

push de                       ; saves current state of e
ld   e, $10                   ; d is already 0
add  hl, de                   ; next line
pop  de                       ; restores current state of e
ret

loadtile:
ld   [hl], a                  ; loads tile id into current tile position
ret  

; === Check for empty tile ($7F) ===
checktile:
and  a
ret  nz                       ; if a is not 0
ld   a, [hl]
cp   a, $7f                   ; or if selected tile is empty
ret  nz
xor  a                        ; returns a = 0
ret

; === Placement Check Around ===
checkandrotate:
ld   d, c                     ; save height and previous block byte origin
add  a, c                     ; adds block address offset - +16 or -16
and  a, $3f                   ; fix overflow or underflow - loops in data table
ld   c, a                     ; update new block byte origin
call collisioncheck
jr   z, .success              ; if a not z, collision detected
ld   c, d                     ; restore height and previous block address
ret

.success
ld   a, $be                   ; rotation sound
jp   PlaySound

end:
ENDL

