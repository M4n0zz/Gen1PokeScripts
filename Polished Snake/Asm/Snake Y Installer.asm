/*

Polished Snake Installer - Compatible with EN Yellow ONLY


Description
This script installs Polished Snake into TimOS environment.


Instructions
1) Change "InstallationAddress" to the address you want to install your payload at.
2) Compile your script using (Quick)RGBDS.
3) Install the output over NicknameWriter.

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
DEF foodTile 		= $d7
DEF bgTile  		= $7f
DEF tileAddress 	= $5188
DEF buffer  		= $d8b4
DEF nicknameaddress	= $d8b4
DEF atefood 		= $ffef
DEF length 	    	= $fff0
DEF score   		= $fff1
DEF level   		= $fff2
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
ld c, pointerwidth	; Calculated in DEF - b = 0 from previous operation
ld hl, pointers		; $d8d4	- origin
call CopyData

; Copy payloads
ld bc, payloadwidth	; Calculated in DEF
ld de, InstallationAddress
jp CopyData


; ----------- Payload pointers ------------
pointers:	       ; it automatically calculates every script's starting point offsets
db LOW(Begining), HIGH(Begining)
.end
ENDL


LOAD "Snake", WRAM0[InstallationAddress]

start:				; do not replace this

CustomPayload:

collided:			; Snake collided
ld a, $a6         		; Load the sound identifier [A6 == error sound]
pop hl
call PlaySound      	; Play the sound [external subroutine]
call WaitForSoundToFinish ; Wait for sound to be done playing [external subroutine]

Begining:
ld bc, $0409			; load 9 tiles from bank $04
ld de, tileAddress		; from address
ld hl, $8d00			; to vram address
call CopyVideoData

EnterPoint:			; Clear BG
call GBFadeOutToWhite	; fade out effect
call ClearScreen		; Fill screen with 7F bytes = white tiles
call UpdateSprites		; removes sprites from screen

ld a, $10			; default direction value set to right
ldh [lastkey], a 		; starting movement lastkey
ldh [lastmove], a 

; Draw top border
ld hl, wTileMap 		; 1st screen tile		
ld bc, $0014 			; screen width (20)
ld a, borderTile		; black tile (border)
call FillMemory

; Draw vertical borders
ld c, $12			; b is already 0, a is black
ld d, $0f 			; screen height 
;ld a, borderTile		; used only for rb
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
dec hl				; screen tile position
call PrintNumber		; print highscore
	
call GBFadeInFromWhite

; Place the three-tile snake in the screen and save its position and length	
ld a, $02
ldh [length], a	
ld b, a
ld de, buffer			; save the snake position in the buffer
ld hl, $c445 			; center of screen
call bufferloop
push hl				; saves next tile position
jr placeobject

; MAIN LOOP
tilecheck:			; Check if the snake moved on empty tile
push hl				; saves new tile position
ld a, [hl]
cp a, bgTile
jr z, movesnake

; Check if the snake ate the object
cp a, foodTile
jr nz, collided

didEat:
ld a, $a7           		; Load the sound identifier [A7 == eating sound]
call PlaySound        		; Play the sound

; Draw the object that can be eaten in a random position in the screen
placeobject:
call Random			; Since A can handle values up to 255, we divide by 2 and multiply by 2 afterwards.
cp a, $95 			; 298 empty tiles / 2  
jr nc, placeobject 		; don't place the object outside the screen
ld b, $00
ld c, a
ld hl, $c3b5			; 1st screen tile c3b5-c4de=398 tiles
add hl, bc
add hl, bc
call Random
and a, $01
jr z, noinc
inc hl
noinc:
ld a, bgTile 			; white tile
cp [hl]				; check random tile
jr nz, placeobject 		; don't place the object in a border or over a snake or obstacle tile
ld [hl], foodTile 		; place object

buffsnake:			; +1 length
ldh a, [length]
inc a
cp a, $c7
jr nc, movesnake
ldh [length], a 		; increase snake length
jr loadhead


movesnake:			; Move snake in the buffer
; Remove the snake's tail
ld de, buffer			; load last tile from buffer
push de
ld a, [de]			; into hl
ld h, a
inc de
ld a, [de]
ld l, a
inc de
ld [hl], bgTile 		; replace with white tile

ldh a, [length]
dec a				; subtracts head
add a				; doubles size to fit buffer addresses
ld c, a
	
; move every snake tile one space
movebody:
ld h, d
ld l, e
pop de
call CopyMapConnectionHeader+2


; add head tile
loadhead:
pop hl				; loads new head address to hl
ld b, $01
call bufferloop			; updates tile + buffer
dec hl				; it selects head tile again
push de				; buffer head +1
push hl				; tile head 
; fallthrough	


DrawScore:			; update stats
ld bc, $4103			; bit 6 of b set to align left, c = 3 digits
ld de, length
ld a, [de]
inc de				; lenght to score
sub a, c			; c = 3 snake tiles too
ld [de], a			; into score
ld hl, highscore
cp a, [hl]
jr c, nobest
ld [hl], a
nobest:
ld hl, $c4fb
call PrintNumber		; current score

ld bc, $141c			; calculate speed level
ld a, [de]			; load current length (PrintNumber actually decreses de)
cp a, b				; if current score more than 17
jr nc, samelevel		; use preset speed
ld b, a				; else use current score

samelevel:			; calculate delay frames
ld a, c				; example if skipping level (max speed)
sub a, b			; min 8
ld b, a				; delay frames

pop hl				; tile head
pop de				; buffer +1

loopdelay:
call DelayFrame

ldh a, [hJoyInput]
bit 1, a
ret nz				; end game if B is pressed
and $F0 			; %11110000, R/L/U/D bits
jr z, nobutton
ld c, a

ldh a, [lastmove]
and a, $30			; check last active bits 4,5
jr nz, next			; if not, we know last active bits are 6,7

ld a, c
and a, $C0			; if true we check new input
jr nz, nobutton 		; if new input ands with non zero, we have same or forbidden direction, end of loop

ld a, c				; if new input ands with zero, legal button is pressed, we update input
ldh [lastkey], a
jr nobutton


; lastmove and C0 is true for sure
next:
ld a, c
and a, $30			; if true we check new input
jr nz, nobutton 		; if new input ands with non zero, we have same or forbidden direction, end of loop

ld a, c				; if new input ands with zero, legal button is pressed, we update input
ldh [lastkey], a

nobutton:
dec b
jr nz, loopdelay


; Read user input
ReadUserInput:
ldh a, [lastkey] 		; load last key pressed out of R/L/U/D
ldh [lastmove], a
bit 6, a
ld bc, $ffec			; - $14 up
jr nz, MovePosition
bit 5, a
ld c, b 			; - $01 left
jr nz, MovePosition
bit 4, a
inc bc
inc bc 				; + $01 right
jr nz, MovePosition
MovePositionDown: 		; + $14 down
ld c, $14
; fallthrough

; Calculate the new snake head and save it in the buffer
MovePosition:
add hl, bc			; adds new offset to head'stile address
jp tilecheck

bufferloop:			; places b snake's tiles on screen and save their address int buffer
ld [hl], snakeTile
ld a, h
ld [de], a
inc de
ld a, l
ld [de], a
inc de
inc hl
dec b
ret z
jr bufferloop


text:				; " Score XXX Best XXX "
db $7F, $92, $A2, $AE, $B1, $A4, $7F, $F6, $7F, $7F, $7F, $81, $A4, $B2, $B3, $7F, $50
	
highscore:
db $00

end:		; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start
