/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/



include "pokeyellow.inc"


SECTION "MaxMoney", ROM0

maxman:
ld   hl, wPlayerMoney
ld   a, $99
ld  [hli], a
ld  [hli], a
ld  [hl], a
ret
