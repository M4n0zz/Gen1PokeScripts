; Address and function names replaced from pokegreen v1.1


/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


def  nicknameaddress     = $d8b5
def  instaladdress       = $c900


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
pop  bc                       ; restores game height and block id
pop  de                       ; restores 
pop  hl                       ; restores draw tile position
ret

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
rotateandcheck:
add  a, c                     ; adds block address offset
and  a, $3f                   ; fix overflow or underflow
push af                       ; save new tile address
push bc                       ; save height and previous block address
ld   c, a                     ; update tile address in a
call collisioncheck
and  a
pop  bc                       ; restore height and previous block address
jr   z, success

pop  af                       ; restore new tile address
ret

success:
pop  af                       ; restore new tile address
ld   c, a                     ; updates old tile address with new one
ld   a, $be                   ; rotation sound
jp   PlaySound

end:
ENDL

