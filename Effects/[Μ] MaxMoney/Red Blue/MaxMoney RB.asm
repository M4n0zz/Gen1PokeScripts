/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/



include "pokered.inc"


SECTION "MaxMoney", ROM0

maxman:
ld   hl, wPlayerMoney
ld   a, $99
ld  [hli], a
ld  [hli], a
ld  [hl], a
ret
