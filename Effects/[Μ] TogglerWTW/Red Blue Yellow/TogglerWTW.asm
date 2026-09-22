/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/



include "pokeyellow.inc"


SECTION "wtw", ROM0

start:
ld   hl, wSimulatedJoypadStatesIndex
ld   a, $01
xor  a, [hl]
ld   [hl], a
ret
