/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"

SECTION "anypc", ROM0

start:
ld   b, ActivatePC_Bank
ld   hl, ActivatePC
jp   Bankswitch

