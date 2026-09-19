/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "DexReset", ROM0

start:
ld   hl, wPokedexOwned
ld   bc, $0026
xor  a
jp   FillMemory               ; Sets BC bytes of A=0 starting from address HL
