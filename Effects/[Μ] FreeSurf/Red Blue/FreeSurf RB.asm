/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


def  bankswitch3         = $091a


SECTION "FreeSurf", ROM0

start:
ld   hl, ItemUseSurfboard
jp   bankswitch3