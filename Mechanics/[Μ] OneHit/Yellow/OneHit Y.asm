/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"

SECTION "1hitko", ROM0

start:
ld   a, $ff		; max damage
ld   [wDamage+1], a
ret


