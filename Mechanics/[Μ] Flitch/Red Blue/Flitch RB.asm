/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


SECTION "flitch", ROM0


flitch:
ld   a, $08	                         ; &00001000    bit3 = flitch
ld   [wEnemyBattleStatus1], a
ret


