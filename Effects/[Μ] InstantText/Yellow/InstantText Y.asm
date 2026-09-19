/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"


SECTION "InstaText", ROM0

start:
ld   hl, wOptions
ld   a, [hl]
and  a, $f0
ld   [hl], a
ret
