/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"


def  bankswitch3         = $074b


SECTION "FreeSurf", ROM0

start:
ld   hl, ItemUseSurfboard
jp   bankswitch3