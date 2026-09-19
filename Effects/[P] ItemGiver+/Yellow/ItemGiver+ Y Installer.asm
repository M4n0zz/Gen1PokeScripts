/*

ItemGiver+ Static Installer - Compatible with EN Yellow ONLY


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

include "pokeyellow.inc"

def scriptnumaddr             = $c6e9
def timospointers             = $c7c0
def installaddress            = $c9ce
def nicknameaddress           = $d8b4
def listaddress               = $d8b4


SECTION "ItemGiver+", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
Installer:

ld   hl, scriptnumaddr
ld   a, [hl]
inc  [hl]                     ; increse no of scripts
add  a, a                     ; doubles number since pointers use 2 bytes
ld   hl, timospointers        ; start counting from script #1
ld   de, installaddress
add  a, l
ld   l, a
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   bc, end - start
ld   hl, installerend
jp   CopyData

installerend:
ENDL


LOAD "ItemGiverScript", WRAM0[installaddress]

start:                        ; do not replace this

CustomPayload:

Begining:
ld   hl, wListPointer         ; list header is stored
ld   de, listaddress
ld   [hl], e
inc  hl
ld   [hl], d

ld   a, $ae
ld   [de], a

xor  a
.loop1
inc  a
inc  de
ld   [de], a
cp   a, $73                   ; list is stopped before glitch names appear
jr   nz, .loop1

ld   a, $c4                   ; list continues from HMs 

.loop2
inc  de
ld   [de], a
inc  a
and  a                        ; up to cancel item
jr   nz, .loop2

ld   [wCurrentMenuItem], a
ld   hl, wPrintItemPrices	
ld   [hl+], a                 ; wListMenuID
ld   [hl], $04
dec  a                        ; $ff
ld   l, LOW(wMaxItemQuantity)
ld   [hl], a

reload:
call DisplayListMenuID
and  a, a	
jr   nz, continue             ; end if B is pressed

ldh  a, [hJoyInput]
xor  a, $02                   ; so when B is pressed, a == 00
jr   z, exit

ld   hl, wNumBagItems         ; checks for non zero items
ld   a, [hl]
and  a
jr   z, reload

dec  a                        ; removes last item in full quantity
ld   [hli], a
add  a, a
add  a, l
ld   l, a
ld   a, $ff
ld   [hl], a
call WaitForSoundToFinish
ld   a, $ab
jr   playsound

exit:
ld   [wListScrollOffset], a
ret

continue:
call DisplayChooseQuantityMenu
and  a, a	
jr   nz, reload               ; if B pressed reload menu
ld   hl, wItemQuantity
ld   c, [hl]                  ; b, c = id, quantity
ld   l, LOW(wCurItem)
ld   b, [hl]
call GiveItem
ld   a, $86                   ; Load the sound identifier [86 == levelup sound]

playsound:
call PlaySound                ; Play the sound
jr   reload                   ; reload menu

end:                          ; do not replace this
ENDL
