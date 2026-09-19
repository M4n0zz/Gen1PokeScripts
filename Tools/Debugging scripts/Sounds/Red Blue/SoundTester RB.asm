/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

; Sound banks: $02, $04, $08, $1f

include "pokered.inc"

def runaddress = $d8b5

SECTION "Sounds", ROM0

LOAD "NicknameWriterPayload", WRAMX[runaddress]

start:
call ClearScreen 
;call StopMusic

ld   a, $04                        ; 4 sound banks
ld   c, a
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, quit script
ld   hl, wItemQuantity
bit  2, [hl]
ld   a, $1f
jr   nz, .setbank
ld   a, $01

.loop
rla
dec  [hl]
jr   nz, .loop

.setbank
ldh  [$fff0], a


repeat:
xor  a                             ; total sound IDs
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, quit script
call StopAllSounds
ldh  a, [$fff0]
ld   [wAudioROMBank], a            ; set sound bank
ld   a, [wItemQuantity]
ld   b, a
ld   de, tempaddress
ld   a, [de]
add  a, b
ld   [de], a
call PlaySound                     ; Play the sound
ld   bc, $c103                     ; How many digits and bytes printed as numbers?
ld   hl, $c400                     ; Corresponds to screen tile
call PrintNumber
jr   repeat                        ; jp to start

tempaddress:
nop

.end
ENDL