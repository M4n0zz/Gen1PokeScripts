/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


SECTION "AllBadges", ROM0

start:
ld   a, $ff
ld   [wObtainedBadges], a
ret
