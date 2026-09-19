; To be compiled with RGBDS


include "pokered.inc"


SECTION "HiTrainer", ROM0

start:
call ClearScreen
call UpdateSprites                 ; removes sprites from screen
ld   a, 47                         ; total encounter IDs
ld   [wMaxItemQuantity],a
call DisplayChooseQuantityMenu     ; DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, then ret
ld   a, [wItemQuantity]
ld   [wTrainerClass], a
push af                            ; saves trainer id
call GetTrainerName
ld   hl, $c409	                    ; destination tile
ld   de, wNameBuffer
call PlaceString
pop  af                            ; restores trainer id
add  a, $c8                        ; increases it to proper encounter id
ld   [wNamedObjectIndex], a
ld   a, $ff
ld   [wMaxItemQuantity], a 
call DisplayChooseQuantityMenu
and  a, a	                         ; if a is 0, z flag is set
jr   nz, start	                    ; if B pressed go to the beginning, ln0
ld   a, [wItemQuantity]
ld   [wEngagedTrainerSet], a       ; [wCurEnemyLevel]/[wTrainerNo]
ld   a, [wMoveType]	               ; pokemon/trainer id
jp   InitBattleEnemyParameters+3

