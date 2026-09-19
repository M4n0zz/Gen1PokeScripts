/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

SECTION "ItemGiver", ROM0

start:
call ClearScreen
call UpdateSprites                 ; removes sprites from screen
ld   a, $ff                        ; all item IDs
ld   [wMaxItemQuantity],a
call DisplayChooseQuantityMenu     ; DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, then ret
ld   a, [wItemQuantity]
push af
ld   [wNamedObjectIndex], a
call GetItemName
ld   hl, $c409                     ; screen tile destination
ld   de, wNameBuffer
call PlaceString
ld   a, $ff                        ; all item quanities
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
pop  bc
and  a, a                          ; if a is 0, z flag is set
jr   nz, start                     ; if B pressed go to the beginning
ld   a, [wItemQuantity]            ; wItemQuantity
ld   c, a                          ; bc = id, quantity
call GiveItem
jr   start