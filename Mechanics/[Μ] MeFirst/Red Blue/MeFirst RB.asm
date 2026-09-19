/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


SECTION "mefirst", ROM0


start:
ld   a, $ff		          ; max speed
ld   [wBattleMonSpeed], a
ret


