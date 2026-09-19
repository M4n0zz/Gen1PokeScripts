/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"

def  bankswitch1 = $3917


SECTION "PokeTeacher", ROM0

start:
call ClearScreen
call UpdateSprites
ld   a, 165                        ; total move IDs
ld   [wMaxItemQuantity], a         ; wMaxItemQuantity write
call DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, then ret
ld   a, [wItemQuantity]
ld   [wMoveNum], a
ld   [wMoveType], a
call GetMoveName
ld   hl, wStringBuffer             ; destination
ld   de, wNameBuffer               ; origin
call CopyString                    ; ensure dialogs use the correct name
ld   hl, $c409                     ; destination
ld   e, low(wNameBuffer)           ; origin
call PlaceString                   ; shows move name on screen
ld   a, [wPartyCount]              ; wPartyCount
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
jr   nz, start                     ; if B pressed go to the beginning, ln0
ld   a, [wItemQuantity]            ; party pokemon read
dec  a
ld   [wWhichPokemon], a
ld   hl, LearnMove
call bankswitch1
jr   start



