/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "ItemGiver+", ROM0


LOAD "NicknameWriterPayload", WRAMX[$D8B4]

start:
ld 	hl, list					; list header is stored
ld 	a, l
ld 	[wListPointer], a
ld 	a, h
ld 	[wListPointer + 1], a

xor a
.loop1
inc a
inc hl
ld 	[hl], a
cp 	a, $73						; list is stopped before glitch names appear
jr 	nz, .loop1

ld 	a, $c4						; list continues from HMs 

.loop2
inc hl
ld	[hl], a
inc a
and a							    ; up to cancel item
jr 	nz, .loop2

ld 	[wPrintItemPrices], a
ld 	[wCurrentMenuItem], a
dec a
ld 	[wMaxItemQuantity], a 
ld 	a, $04
ld 	[wListMenuID], a

reload:
call DisplayListMenuID
and a, a	
jr 	nz, continue				  ; end if B is pressed
xor a
ld	[wListScrollOffset], a
ret

continue:
call DisplayChooseQuantityMenu
and a, a	
jr 	nz, reload					  ; if B pressed reload menu
ld 	a, [wItemQuantity]
ld 	c, a						      ; b, c = id, quantity
ld 	a, [wCurItem]
ld 	b, a
call GiveItem
ld 	a, $86         				; Load the sound identifier [86 == levelup sound]
call PlaySound      			; Play the sound

jr 	reload						    ; reload menu

list:
db $ae

.end
ENDL
