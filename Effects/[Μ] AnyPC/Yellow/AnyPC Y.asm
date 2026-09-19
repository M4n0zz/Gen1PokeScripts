/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"


def  bankswitch5 = $3dbd

SECTION "anypc", ROM0

start:
ld   hl, ActivatePC
jp   bankswitch5


