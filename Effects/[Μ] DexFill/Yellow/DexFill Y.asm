/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

SECTION "ResetPokedex", ROM0

start:
ld   hl, wPokedexOwned
ld   e, $02              ; repeat 2 times, one for seen, one for own

.loop
ld   bc, $0012
xor  a
dec  a
call FillMemory  ;; Set BC bytes of A starting from address HL
ld   a, $7f
ld   [hli], a
dec  e
jr   nz, .loop
ret

