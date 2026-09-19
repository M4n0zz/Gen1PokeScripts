/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/



include "pokeyellow.inc"


SECTION "MaxCoins", ROM0

start:
ld   hl, wPlayerCoins
ld   a, $99
ld   [hli], a
ld   [hl], a
ret
