/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "unlimitedPP", ROM0

start:
ld hl, wBattleMonPP
ld a, $ff
ld [hli], a
ld [hli], a
ld [hli], a
ld [hl], a
ret


