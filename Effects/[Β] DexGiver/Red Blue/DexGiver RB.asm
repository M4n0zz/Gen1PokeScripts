/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


SECTION "DexGiver", ROM0

start:
call ClearScreen
call UpdateSprites            ; removes sprites from screen
ld   a, 151                   ; total species IDs
ld   [wMaxItemQuantity],a     ; wMaxItemQuantity write
call DisplayChooseQuantityMenu
and  a, a                     ; if a is 0, z flag is set
ret  nz                       ; if B pressed, then ret
ld   a, [wItemQuantity]       ; wItemQuantity read
ld   de, wPokedexNum
ld   [de], a                  ; pokemon id is stored in wd11e
ld   b, $10                   ; select bank 16
ld   hl, PokedexToIndex
call Bankswitch
ld   a, [de]
push af
call GetMonName
ld   hl, $c409                ; destination
ld   de, wNameBuffer          ; origin
call PlaceString
ld   a, $64                   ; level 100
ld   [wMaxItemQuantity], a    ; wMaxItemQuantity
call DisplayChooseQuantityMenu
pop  bc
and  a, a                     ; if a is 0, z flag is set
jr   nz, start	               ; if B pressed go to the beginning
ld   a, [wItemQuantity]       ; wItemQuantity
ld   c, a                     ; bc = id, level
call GivePokemon              ; GivePokemon
jr   start                    ; jp to start