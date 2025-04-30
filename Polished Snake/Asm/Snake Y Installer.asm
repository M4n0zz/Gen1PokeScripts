/*

Polished Snake Script Installer - Compatible with EN Yellow ONLY


Description
This script installs Polished Pong script into TimOS environment.


Instructions
1) Change "InstallationAddress" to the address you want to install your payload at.
2) Put your script's code under "CustomPayload" section.
3) Compile your script using (Quick)RGBDS.
4) Install the output over NicknameWriter.

The script will automatically calculate the offsets needed for:
- Script selector
- Jump table
- The script itself

Warning!
Make sure the area for your script is unused before installation!



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"

DEF borderTile 		= $d0
DEF snakeTile 		= $d1
DEF foodTile 		= $d7;ae
DEF bgTile 			= $7f;c0
DEF tileAddress 	= $5188
DEF buffer 			= $d8b4;c700
DEF nicknameaddress = $d8b4
DEF atefood 		= $ffef
DEF length 			= $fff0
DEF score 			= $fff1
DEF level 			= $fff2
DEF lastkey 		= $fff6
DEF lastmove 		= $fff7
DEF InstallationAddress = $c9ce

SECTION "ScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; increse no of scripts
ld hl, $c6e9
ld b, [hl]
ld a, scriptnumber	; calculated in DEF
add a, [hl]
ld [hl], a

; write pointers to the correct position
ld de, $c7bb		; start counting from script #1
.pointerloop
inc e
inc e
dec b
jr nz, .pointerloop

; Copy pointers
ld c, pointerwidth  ; Calculated in DEF - b = 0 from previous operation
ld hl, pointers		; $d8d4	- origin
call CopyData

; Copy payloads
ld bc, payloadwidth	; Calculated in DEF
ld de, InstallationAddress
jp CopyData


; ----------- Payload pointers ------------
pointers:           ; it automatically calculates every script's starting point offsets
db LOW(start),      HIGH(start)
.end
ENDL


LOAD "Snake", WRAM0[InstallationAddress]

start:		; do not replace this

CustomPayload:

Begining:
ld bc, $0409			; load 9 tiles from bank $04
ld de, tileAddress		; from address
ld hl, $8d00			; to vram address
call CopyVideoData

EnterPoint:
; Clear BG
call GBFadeOutToWhite	; fade out effect
call ClearScreen		; Fill screen with 7F bytes = white tiles
call UpdateSprites		; removes sprites from screen

ld a, $10				; default direction value set to right
ldh [lastkey], a 		; starting movement lastkey
ldh [atefood], a		; set non zero to draw food

; Draw top border
ld hl, wTileMap 		; 1st screen tile		
ld bc, $0014 			; screen width (20)
ld a, borderTile		; black tile (border)
call FillMemory

; Draw vertical borders
ld c, $12				; b is already 0, a is black
ld d, $0f 				; screen height 
.loop
ld [hli], a 			; right border tile
add hl, bc
ld [hli], a 			; left border tile
dec d
jr nz, .loop 
	
; Draw bottom border
ld c, $14
call FillMemory 		; bottom row

; Draw stats
ld de, text
call CopyString			; copies game's stats text
ld bc, $4103			; bit 6 of b set to align left, c = 3 digits
ld de, highscore
ld hl, $c504			; screen tile position
call PrintNumber		; print highscore
	
call GBFadeInFromWhite

; Place the three-tile snake in the screen and save its position and length	
ld b, $03
ld a, b
ldh [length], a	
ld a, snakeTile
ld hl, buffer			; save the snake position in the buffer	
ld de, $c448 			; center of screen
bufferloop:
ld [de], a 				; place snake tile
ld [hl], d
inc hl
ld [hl], e
inc hl
dec b
inc de
jr nz, bufferloop


; MAIN LOOP

; Draw the object that can be eaten in a random position in the screen
DrawObject:
ld de, buffer			; contains snake tail
ldh a, [atefood] 		; restore whether snake ate or not
and a
jr nz, placeobject

movesnake:				; Move snake in the buffer
; snake head is at buffer + 2 * snake_length - 2
ldh a, [length]
dec a
add a
ld b, a

; Remove the snake's tail
ld a, [de]
ld h, a
inc de
ld a, [de]
ld l, a
dec de
ld a, bgTile 			; white tile
ld [hl], a
	
; move every snake tile one space
movebody:
inc de
inc de
ld a, [de]
dec de
dec de
ld [de], a
inc de
dec b
jr nz, movebody
dec de
dec de 					; de now points to previous snake head
jr loadhead

placeobject:
call Random				; Since A can handle values up to 255, we divide by 2 and multiply by 2 afterwards.
cp a, $95 				; 298 empty tiles / 2  
jr nc, placeobject 		; don't place the object outside the screen
ld c, a
ld b, $00
ld hl, $c3b5			; 1st screen tile c3b5-c4de=398 tiles
add hl, bc				; giati olo auto kai oxi aplh topothetish?
add hl, bc
call Random
and a, $01
jr z, noinc
inc hl
noinc:
ld a, bgTile 			; white tile
cp [hl]					; check random tile
jr nz, placeobject 		; don't place the object in a border or over a snake or obstacle tile
ld [hl], foodTile 		; place object

; If we ate the object in the last move, the snake only increases its length
buffsnake:
ldh a, [length]
inc a
ldh [length], a 		; increase snake length
dec a
dec a
	
movepointer:
inc de
inc de
dec a
jr nz, movepointer
ldh [atefood], a		; a = 0 from above sequence
; fallthrough	


; de points to snake head tile, load its content (tile occupied) to hl
loadhead:
ld a, [de]
ld h, a
inc de
ld a, [de]
ld l, a
inc de 
; fallthrough	

	
; Read user input
ReadUserInput:
ldh a, [lastkey] 		; load last key pressed out of R/L/U/D
ldh [lastmove], a
bit 6, a
ld bc, $ffec			; - $14 up
jr nz, MovePosition
bit 5, a
ld c, b 				; - $01 left
jr nz, MovePosition
bit 4, a
ld bc, $0001 			; + $01 right
jr nz, MovePosition
MovePositionDown: 		; + $14 down
ld c, $14
; fallthrough

; Calculate the new snake head and save it in the buffer
MovePosition:
add hl, bc

; Check if the snake ate the object
ld a, foodTile
cp [hl]
jr nz, checkCollision

didEat:
ldh [atefood], a
ld 	a, 167           	; Load the sound identifier [A6 == error sound]
call PlaySound        	; Play the sound [external subroutine]

	
; Save the new snake head tile in the buffer and draw the new head
moveSnake:
ld a, snakeTile
ld [hl], a 				; draw head
ld a, h
ld [de], a
inc de
ld a, l
ld [de], a


DrawScore:				; update stats
ld c, $04				; calculate and print score
ld de, length
ld a, [de]
inc de					; lenght to score
sub a, c
ld [de], a				; into score
ld bc, $4103			; bit 6 of b set to align left, c = 3 digits
ld hl, $c4fb
call PrintNumber		; current score

ld c, $06				; calculate and print level
ld a, [de]
cp a, $15				; if current score more than 18
jr nc, samelevel		; keep same level
ld bc, $0300

levelup:				; subtracts 3 tiles from main body
inc c
sub a, b
cp a, b
jr nc, levelup

samelevel:				; calculate delay frames
ld a, $08				; example if skipping level (max speed)
sub a, c				; 8-6=2
add a					; 2+2=4
add a					; 4+4=8
ld c, a					; 8 delay frames

loopdelay:
call DelayFrame

ldh a, [hJoyInput]
bit 1, a
ret nz						; end game if B is pressed
and $F0 				; %11110000, R/L/U/D bits
jr z, nobutton
ld b, a

ldh a, [lastmove]
and a, $30				; check last active bits 4,5
jr nz, next				; if not, we know last active bits are 6,7

ld a, b
and a, $C0				; if true we check new input
jr nz, nobutton 		; if new input ands with non zero, we have same or forbidden direction, end of loop

ld a, b					; if new input ands with zero, legal button is pressed, we update input
ldh [lastkey], a
jr nobutton


; lastmove and C0 is true for sure
next:
ld a, b
and a, $30				; if true we check new input
jr nz, nobutton 		; if new input ands with non zero, we have same or forbidden direction, end of loop

ld a, b					; if new input ands with zero, legal button is pressed, we update input
ldh [lastkey], a

nobutton:
dec c
jr nz, loopdelay

jp DrawObject 			; make sure to place a new object to replace the one just eaten

; Check if the snake collided so the player lost
checkCollision:
ld a, bgTile
cp [hl]
jp z, moveSnake
ld 	a, $a6         		; Load the sound identifier [A6 == error sound]
call PlaySound      	; Play the sound [external subroutine]
call WaitForSoundToFinish ; Wait for sound to be done playing [external subroutine]
ldh a, [score]
ld hl, highscore
cp a, [hl]
jr c, skip
ld [hl], a
skip:
jp EnterPoint

text:					; " Score XXX Best XXX "
db $7F, $92, $A2, $AE, $B1, $A4, $7F, $F6, $7F, $7F, $7F, $81, $A4, $B2, $B3, $7F, $50
	
highscore:
db $00

end:		; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start
