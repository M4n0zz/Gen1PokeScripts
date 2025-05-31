/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

DEF nicknameaddress = $d8b4

SECTION "ItemGiver+", ROM0

LOAD "NicknameWriterPayload", WRAMX[nicknameaddress]

start:
ld  hl, wListPointer			; list header is stored
ld  de, list
ld  [hl], e
inc hl
ld  [hl], d

xor a
.loop1
inc a
inc de
ld  [de], a
cp  a, $73						    ; list is stopped before glitch names appear
jr  nz, .loop1

ld  a, $c4						    ; list continues from HMs 

.loop2
inc de
ld  [de], a
inc a
and a							        ; up to cancel item
jr  nz, .loop2

ld  [wCurrentMenuItem], a
ld  hl, wPrintItemPrices	
ld  [hl+], a					    ; wListMenuID
ld  [hl], $04
dec a							        ; $ff
ld  l, LOW(wMaxItemQuantity)
ld  [hl], a

reload:
call DisplayListMenuID
and a, a	
jr  nz, continue				  ; end if B is pressed

ldh a, [hJoyInput]
xor a, $02						    ; so when B is pressed, a == 00
jr  z, exit

ld  hl, wNumBagItems			; checks for non zero items
ld  a, [hl]
and a
jr  z, reload

dec a							        ; removes last item in full quantity
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
jr  nz, reload					  ; if B pressed reload menu
ld  hl, wItemQuantity
ld  c, [hl]						    ; b, c = id, quantity
ld  l, LOW(wCurItem)
ld  b, [hl]
call GiveItem
ld  a, $86         				; Load the sound identifier [86 == levelup sound]
playsound:
call PlaySound      			; Play the sound

jr  reload						    ; reload menu

list:
db $ae

.end
ENDL
