
/*
Address and function names replaced from pokegreen v1.1

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"
include "charmap.inc"


def  whitetile           = $7f
def  blocktile           = $d4
def  nicknameaddress     = $d8b4
def  instaladdress       = $c800
def  tilenext            = $fff0
def  score               = $fff1


SECTION "PokeTetris", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
;;;;;;;;;;;; Installer payload ;;;;;;;;;;;; 
installer:
; Copy payloads
ld   hl, .end                 ; origin
ld   de, instaladdress        ; destination
ld   bc, end - blocks
jp   CopyData
.end
ENDL


LOAD "Payload", WRAM0[instaladdress]

; Encoded blocks - each block consists of 2 bytes and each bit represents 1 tile in a 4x4 grid
; the position of each line represents the rotation of the block in the same column
blocks:
db $60, $06, $60, $03, $30, $06, $40, $07, $20, $07, $10, $07, $22, $22, $22, $22 
db $60, $06, $31, $02, $32, $01, $30, $22, $20, $23, $20, $32, $00, $0f, $00, $0f 
db $60, $06, $60, $03, $30, $06, $00, $17, $00, $27, $00, $47, $22, $22, $22, $22
db $60, $06, $31, $02, $32, $01, $20, $62, $20, $26, $60, $22, $00, $0f, $00, $0f 


drawblocktile:
ld   a, blocktile             ; load block tile

drawblock:
push af                       ; save tile id
ld   a, low(loadtile)         ; loads tile loading function low byte address
ld   [changable+1], a         ; puts it in changeable function pointer
pop  af                       ; restore tile id
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
push af                       ; save tile id
ld   a, [bc]                  ; loads current block id
ld   e, a                     ; in e
pop  af                       ; restore tile id
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


; === Updates highscore and transfer all scores to the screen ===
setcounters:
ld   de, score
push de                       ; save current score
ld   hl, $c3ea                ; current score tile position
ld   bc, $4103                ; bit 6 of b set to align left, c = 3 digits
call PrintNumber              ; current score
pop  hl                       ; restore current score
ld   de, highscore
ld   a, [de]
cp   a, [hl]                  ; compare cuurent with highscore
jr   nc, .printhighscore      ; update best if current is higher
ld   a, [hl]
ld   [de], a

.printhighscore:
ld   hl, $c44e                ; best score tile position
jp   PrintNumber              ; print highscore


; === Generates next block and show it in the indicator ===
placeblock:
ld   hl, $c4b2                ; next block indicator tile
ld   a, whitetile
call drawblock                ; remove previous tile
call Random                   ; generate a random number
and  a, %00111110             ; strip it to usable position in encoded block data matrix
ldh  [tilenext], a            ; save it to HRAM
ld   c, a
jp   drawblocktile            ; draw new tile in the indicator



dpadhandler:
ldh  a, [hJoyHeld]
and  a, $80
jr   z, .checkleft            ; if down is pressed
ld   a, b                     ; block height
and  a, $e0                   ; reduce drop delay
ld   b, a
ret

.checkleft
bit  5, d
jr   z, .checkright           ; if left is pressed
dec  hl                       ; changes block position to the left
call collisioncheck           ; then check collisions
jr   z, .checkright           ; if collision is found
inc  hl                       ; restore previous block position

.checkright
bit  4, d
ret  z                        ; if right is pressed
inc  hl                       ; changes block position to the right
call collisioncheck           ; then check collisions
ret  z                        ; if collision is found
dec  hl                       ; restore previous block position
ret

; === Labels to be print on screen ===
labels:
db   "Score"
db   "Best"
db   "Next"

highscore:
db   $00

end:

ENDL

