/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


SECTION "FreeFly", ROM0

start:
ld   hl, wTownVisitedFlag+1        ; set all fly locations
push hl
ld   b, [hl]
dec  hl
ld   c, [hl]
push bc
ld   a, $ff
ld   [hli], a
ld   [hl], a
call ChooseFlyDestination
pop  bc
pop  hl
ld   [hl], b
dec  hl
ld   [hl], c
jp   LoadFontTilePatterns