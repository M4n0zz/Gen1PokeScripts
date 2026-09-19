/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "ScriptName", ROM0

start:
xor  a
ld   hl, wPlayTimeHours
ld   [hli], a
ld   [hli], a
ld   [hli], a
ld   [hl], a
ret
