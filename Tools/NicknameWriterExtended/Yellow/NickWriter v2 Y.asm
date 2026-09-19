/*

https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"


def  nicknameaddress     = $d8b4
def  nickwriterpointer   = $c7c2
def  nickwriterdest      = $c800
def  AskName_Hijack      = AskName + $38     ; jump 0x39 (RB) / 0x38 (Y) bytes into AskName
def  bankswitch1         = $1135
def  counterlow          = $8c60
def  counterhigh         = $8fa0
def  pokeid              = $c5               ; glitch pokemon with 2 graphics tiles in its name

SECTION "ScriptName", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
;;;;;;;;;;;; Installer payload ;;;;;;;;;;;; 
installer:                    ; move NicknameWriter into TimOS
ld   de, nickwriterdest       ; destination
ld   hl, nickwriterpointer    ; change nickname writer pointer inside timos
ld   [hl], e
inc  hl
ld   [hl], d
ld   hl, .end                 ; origin

ld   c, finish - start
jp   CopyMapConnectionHeaderloop
.end
ENDL


LOAD "NicknameWriterPayload", WRAM0[nickwriterdest]
start:

ScreenFix:
xor  a, a
ldh  [hWY], a                 ; Ensure menu isn't offscreen
ld   b, a                     ; nickname counter = 0
ld   hl, wCurPartySpecies
ld   [hl], pokeid


NickWriter:
ld   de, nicknameaddress      ; payload write location
push de                       ; store initial payload address

.nextnickname
ld   c, $01                   ; c = 1 tile to be copied later on
ld   a, c                     ; a = 1
add  a, b                     ; counter increased into a
daa                           ; change it back to decimal if it overflows to hex
ld   b, a                     ; increases nickname counter decimal value

.samenickname
push bc                       ; stores current counter and checksum
push de                       ; stores current payload location

ld   hl, counterlow           ; low tile always go first since in Y, high tile is always changed
call copytile                 ; bc is preserved

swap b                        ; low byte goes to high
ld   hl, counterhigh
call copytile

ld   hl, AskName_Hijack
call bankswitch1
ld   c, $80                   ; ensures consistency for the checksum
ld   hl, wStringBuffer
pop  de                       ; restore current byte location
push de                       ; stores current byte location again

.nextPair
ld   a, [hli]                 ; character in stringbuffer (nickname entered)
add  a, a                     ; doubles its value
jr   nc, .continue            ; end loop if nc
add  a, [hl]                  ; adds next char
ld   [de], a                  ; convert and store value in payload area
inc  de                       ; increase payload byte
inc  hl                       ; increase string buffer read area
add  a, c                     ; adds $80 to last char
ld   [de], a                  ; calculate and store checksum in next byte
ld   c, a                     ; saves checksum to c
jr   .nextPair                ; repeat for next byte

.continue
push de                       ; latest payload location is stored
ld   hl, wTileMap+$60
ld   c, 1
call PrintBCDNumber+$12       ; write checksum to screen, increment hl twice

.modifyChecksum
dec  l
set  7, [hl]                  ; makes sure that screen tiles for A through F become readable
jr   nz, .modifyChecksum

.inputLoop
call JoypadLowSensitivity
ldh  a, [hJoy5]
and  a, $0F                   ; discard dpad state, set z flag is no button pressed
jr   z, .inputLoop

pop  de                       ; at least one button pressed, so retrieve de
pop  hl                       ; old de location is restored in hl
pop  bc                       ; latest checksum is restored
rra                           ; set c flag if A pressed
jr   c, .nextnickname         ; A pressed
ld   d, h
ld   e, l
rra                           ; set c flag if B pressed
jr   c, .samenickname
rra                           ; set c flag if START pressed
pop  hl                       ; restore initial de to hl
ret  c
jp   hl                       ; we can only be here if SELECT was pressed


copytile:
ld   de, $8f60                ; vram origin at number row first tile
ld   a, b                     ; load counter
and  a, $0f                   ; high byte is zeroed
swap a                        ; low becomes high
add  a, e                     ; value added to de
ld   e, a                     ; effectively adds current dec digit to initial tile number
jp   CopyVideoData            ; updates vram

finish:
ENDL
