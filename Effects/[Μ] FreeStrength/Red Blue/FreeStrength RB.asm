/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


SECTION "FreeStrength", ROM0

start:
ld   b, PrintStrengthText_Bank
ld   hl, PrintStrengthText
jp   Bankswitch