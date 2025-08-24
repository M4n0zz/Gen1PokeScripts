/*

Polished Pong Script Installer - Compatible with EN Red/Blue ONLY


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
include "pokered.inc"


DEF backroundTile        = $c0
DEF ballTile             = $d0
DEF padTile              = $d9
DEF tileAddress          = $697e
DEF nicknameaddress      = $d8b5
DEF InstallationAddress  = $c9e1

SECTION "ScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; increse no of scripts
ld   hl, $c6e9
ld   b, [hl]
ld   a, scriptnumber          ; calculated in DEF
add  a, [hl]
ld   [hl], a

; write pointers to the correct position
ld   de, $c7c7                ; start counting from script #1
.pointerloop
inc  e
inc  e
dec  b
jr   nz, .pointerloop

; Copy pointers
ld   c, pointerwidth          ; Calculated in DEF - b = 0 from previous operation
ld   hl, pointers             ; origin
call CopyData

; Copy payloads
ld   bc, payloadwidth         ; Calculated in DEF
ld   de, InstallationAddress
jp   CopyData


; ----------- Payload pointers ------------
pointers:                     ; it automatically calculates every script's starting point offsets
db LOW(start),      HIGH(start)
.end
ENDL


LOAD "CustomPayload", WRAM0[InstallationAddress]

start:                        ; do not replace this

CustomPayload:

Begining:
call ClearScreen
call UpdateSprites

ld   bc, $0e10                ; load 10 tiles from bank $0e
ld   de, tileAddress          ; from address
ld   hl, $8d00                ; to vram address
call CopyVideoData


EntryPoint:
ld   a, $06
ld   hl, $ffef
ld   [hli], a
ld   [hli], a                 ; holds current speed (frames to delay)
xor  a
ld   [hli], a
ld   [hli], a
ld   d, $0e                   ; Set the pad's initial position to 15 [0x0E]
ld   hl, $ffa2                ; Loads FFA2 [ball X location] address to HL
ld   [hl], d                  ; Sets the ball initial X location to 15 [0x0E]
inc  l                        ; HL=FFA3 [ball Y location]
ld   [hl], d                  ; Sets the ball initial Y location to 15 [0x0E]
ld   a, $ff                   ; Load the sound identifier [FF == mute music]
call PlaySound                ; Play the sound [here: mute the music]
dec  d                        ; Set the pad's position to 14 [0x0D]

; Does all the drawing and game calculations
DoGameTick:               
ld   bc, $0168                ; Argument #1: Write 168 bytes...
ld   hl, $c3a0                ; Argument #2: to location $C3A0 [screen I/O]...
ld   a, backroundTile         ; Argument #3: of value $10 [black tile]
push hl                       ; Saves HL for later use
call FillMemory               ; Set BC bytes of A starting from address HL [external subroutine] - clears the screen
pop  hl                       ; Restores HL for a while to clean up the stack
push de                       ; Saves DE [pad X location] for later use
push hl                       ; Saves HL [screen IO address] for later use
ld   hl, $c4e0                ; Loads C4E0 to HL [screen IO 17th line]
ld   a, l                       
add  d                         
ld   l, a                     ; Adds pad X position to the lower byte of HL to calculate the pad's drawing location
ld   a, padTile               ; Set A to 0 [white tile]
ldi  [hl], a
ldi  [hl], a
ldi  [hl], a
ldi  [hl], a
ldi  [hl], a                  ; Draw a 5-block-wide pad
push de
ld   de, text
ld   hl, $c4f4
call CopyString               ; copies game's stats text
ld   de, $fff0
ld   a, [de]
ld   c, a
ld   a, $07
sub  a, c
inc  de
ld   [de], a
ld   hl, $c4f6
ld   c, $c1
call PrintBCDDigit
ld   de, $fff2
ld   hl, $c4fc
ld   bc, $4103                ; bit 6 of b set to align left, c = 3 digits
call PrintNumber              ; current score
ld   de, highscore
ld   hl, $c505                ; screen tile position
;ld bc, $4103                 ; bit 6 of b set to align left, c = 3 digits
call PrintNumber              ; print highscore
pop  de

; Handles the collision detection with the walls and the pad
ld   hl, $ffa0                ; Loads the ball direction byte address
ld   c, $0f                   ; Loads the invert byte 0F [bounce off X axis]
ldh  a, [$ffA2]               ; Loads the ball X coordinate
and  a
call z, BallBounce            ; If X=0, do the bounce off the X axis
cp   a, $13
call z, BallBounce            ; If X=$13 [DEC 19], do the bounce off the X axis
ld   c, $f0                   ; Loads the invert byte 0F [bounce off Y axis]
ldh  a, [$ffa3]               ; Loads the ball Y coordinate
and  a
call z, BallBounce            ; If Y=0, do the bounce off the Y axis
cp   a, $11
jr   nz, nogameover           ; If Y=$11 [DEC 17], the lower part of the screen, it's game over

ld   a, $a6                   ; Load the sound identifier [A6 == error sound]
call PlaySound                ; Play the sound [external subroutine]
call WaitForSoundToFinish     ; Wait for sound to be done playing [external subroutine]
ldh  a, [$fff2]
ld   hl, highscore
cp   a, [hl]
jr   c, skip
ld   [hl], a
skip:
pop  hl
pop  hl
jp   EntryPoint

nogameover:
cp   a, $0f                   ; Check if Y=$0F [DEC 15] - the vertical position of the pad
jr   nz, UpdateBallPosition   ; If it isn't there's no need to check for collision with the pad

ldh  a, [$ffef]
inc  a
ldh  [$ffef], a
cp   a, $0a                   ; Check to speed up game
jr   nz, samehardness

ldh  a, [$fff0]
dec  a
ldh  [$ffef], a
cp   a, $01
jr   z, samehardness
ldh  [$fff0], a

samehardness:
ld   e, d
dec  e
ld   b, $08
ldh  a, [$ffa2]               ; Load the ball X location to register A

Loop1:
cp   e                        ; Check if the ball touches the pad
jr   nz, nobounce
; update counter
push af
ldh  a, [$fff2]
inc  a
ldh  [$fff2], a
pop  af
continue:
call BallBounce               ; Bounce if it does
nobounce:
inc  e
dec  b
jr   nz, Loop1                ; Check it for all 4 spots on the pad

; Moves the ball on diagonals based on the direction byte
UpdateBallPosition:
ld   a, [hl]                  ; Load the ball direction byte to register A
inc  l
inc  l                        ; HL=FFA2 [address of ball's X position]
ld   b, a                     ; Store a copy of the direction byte for later comparisons
and  a, $0f                   ; Check if the lower nibble of the direction byte is 0xF
jr   nz, dontincx             ; If it is, increment X position
inc  [hl]                      
xor  a  

dontincx:                     ; Since every a XOR a equals 0, this instruction will set the zero flag
jr   z, dontdecx              ; If it isn't, decrement X position
dec  [hl]
xor  a       

dontdecx:
inc  l                        ; HL=FFA3 [address of ball's Y position]
ld   a, b
and  a, $f0                   ; Check if the upper nibble of the direction byte is 0xF
jr   nz, dontincy             ; If it is, increment Y position
inc  [hl]                      
xor  a 

dontincy:
jr   z, dontdecy              ; If it isn't, decrement Y position
dec  [hl]
xor  a 
	
dontdecy:                     ; Calculates the drawing location [screen IO address] for the ball
pop  hl                       ; Restore HL from all the way before [HL is now screen IO address]
ldh  a, [$ffa2]               ; Loads the ball X position
add  l                         
ld   l, a                     ; Adds it to HL to calculate the ball's X drawing location
ldh  a, [$ffa3]               ; Loads the ball Y position
ld   bc, $0014                ; BC=0014: screen's width: adding it to HL will advance the drawing location 1 block downwards
and  a                        ; Check if A is equal to 0
jr   z, DrawBall              ; If it is, skip the loop, as the ball drawing position is already calculated

DrawBallLoop:                 ; Part of the ball's drawing location calculation
add  hl, bc                   ; Increase the Y drawing location by 1 block
dec  a                        ; Decrement the Y coordinate
jr   nz, DrawBallLoop         ; Jump back if it is not equal to 0

DrawBall:                     ; Draws the ball on the screen
ld   a, ballTile
ld   [hl], a                  ; Yeah, that was very hard...

; Checks for key input, moves the pad accordingly   
pop  de                       ; Restore DE from all the way before [D contains now pad's X coordinate]
ld   a, d                       
cp   a, $0f                   ; Check if the pad is on the screen's rightmost edge
jr   z, SkipRightKey          ; If it is, skip this check so the pad does not go outside the screen bounds
ldh  a, [hJoyInput]           ; Load key input address
and  a, $10                   ; Check for bit 4
jr   z, SkipRightKey          ; Increment the pad X location if it is set
inc  d                        ; Increments the D register. Used in conditional jumps.

; Part of key input checking
SkipRightKey:             
ld   a, d
and  a                        ; Check if the pad is on the screen's leftmost edge
jr   z, DelayFrames2          ; If it is, skip this check so the pad does not go outside the screen bounds
ldh  a, [hJoyInput]           ; Load key input address
bit  1, a                     ; Check for bit 1
ret  nz
and  a, $20                   ; Check for bit 5
jr   z, DelayFrames2          ; Decrement the pad Y location if it is set
dec  d

; Renders the screen, delays 5 frames and returns back to the game tick procedure
DelayFrames2:
ldh  a, [$fff0]
ld   c, a
call DelayFrames
jp   DoGameTick               ; Long jump back to the game tick beginning

BallBounce:
ld   b, a                     ; Loads the A register to B, to restore it later
ld   a, c                     ; Loads the direction byte to A
xor  [hl]                     ; XORs the direction byte with the ball's current direction address
ld   [hl], a                  ; Loads the operation result to the ball's current direction byte
ld   a, $af                   ; Load the sound identifier [AF == short beep]
call PlaySound                ; Play the sound [external subroutine]
ld   a, b                     ; Restore the A register back from B
ret  

text:
db $8B, $B5, $7F, $7F, $87, $AE, $AF, $7F, $7F, $7F, $7F, $7F, $81, $A4, $B2, $B3, $7F, $50
	
highscore:
db $00


end:                          ; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start

