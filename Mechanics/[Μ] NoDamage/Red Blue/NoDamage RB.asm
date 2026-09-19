/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


SECTION "nodamage", ROM0

start:
xor  a
ld   [wEnemyMovePower], a
ret


