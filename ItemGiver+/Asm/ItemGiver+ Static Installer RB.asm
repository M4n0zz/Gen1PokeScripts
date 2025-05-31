/*

ItemGiver+ Static Installer - Compatible with EN Red and Blue ONLY


Description
This script installs ItemGiver+ into TimOS environment.


Instructions
1) Change "InstallationAddress" to the address you want to install your payload at.
2) Compile your script using (Quick)RGBDS.
3) Install the output HEX code over NicknameWriter (https://timovm.github.io/NicknameConverter/).

The script will automatically calculate the offsets needed for:
- Script selector
- Jump table
- The script itself

Warning!
Make sure the memory space for your script is unused before installation!



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"

DEF nicknameaddress = $d8b5
DEF listaddress = $d8b5
DEF timospointers = $c7c2
DEF InstallationAddress = $c9ce

SECTION "ItemGiver+", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:
; increse no of scripts
ld  hl, $c6e9
ld  b, [hl]
ld  a, scriptnumber		; calculated in DEF
add a, [hl]
ld  [hl], a

; write pointers to the correct position
ld  de, timospointers		; start counting from script #1
.pointerloop
inc e
inc e
dec b
jr  nz, .pointerloop

; Copy pointers
ld  c, pointerwidth		; Calculated in DEF - b = 0 from previous operation
ld  hl, pointers		; $d8d4	- origin
call CopyData

; Copy payloads
ld  bc, payloadwidth		; Calculated in DEF
ld  de, InstallationAddress
jp  CopyData


; ----------- Payload pointers ------------
pointers:	       		; it automatically calculates every script's starting point offsets
db LOW(Begining), HIGH(Begining)
.end
ENDL


LOAD "ItemGiverScript", WRAM0[InstallationAddress]

start:				; do not replace this

CustomPayload:

Begining:
ld  hl, wListPointer		; list header is stored
ld  de, listaddress
ld  [hl], e
inc hl
ld  [hl], d

ld  a, $ae
ld  [de], a

xor a
.loop1
inc a
inc de
ld  [de], a
cp  a, $73			; list is stopped before glitch names appear
jr  nz, .loop1

ld  a, $c4			; list continues from HMs 

.loop2
inc de
ld  [de], a
inc a
and a				; up to cancel item
jr  nz, .loop2

ld  [wCurrentMenuItem], a
ld  hl, wPrintItemPrices	
ld  [hl+], a			; wListMenuID
ld  [hl], $04
dec a				; $ff
ld  l, LOW(wMaxItemQuantity)
ld  [hl], a

reload:
call DisplayListMenuID
and a, a	
jr  nz, continue		; end if B is pressed

ldh a, [hJoyInput]
xor a, $02			; so when B is pressed, a == 00
jr  z, exit

ld  hl, wNumBagItems		; checks for non zero items
ld  a, [hl]
and a
jr  z, reload

dec a				; removes last item in full quantity
ld  [hli], a
add a, a
add a, l
ld  l, a
ld  a, $ff
ld  [hl], a
call WaitForSoundToFinish
ld  a, $ab
jr  playsound

exit:
ld  [wListScrollOffset], a
ret

continue:
call DisplayChooseQuantityMenu
and a, a	
jr  nz, reload			; if B pressed reload menu
ld  hl, wItemQuantity
ld  c, [hl]			; b, c = id, quantity
ld  l, LOW(wCurItem)
ld  b, [hl]
call GiveItem
ld  a, $86         		; Load the sound identifier [86 == levelup sound]
playsound:
call PlaySound      		; Play the sound

jr  reload			; reload menu

end:				; do not replace this
ENDL

	
DEF scriptnumber = (pointers.end - pointers) / 2
DEF pointerwidth = pointers.end - pointers
DEF payloadwidth = end - start
