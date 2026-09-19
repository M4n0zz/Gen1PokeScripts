/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/



include "pokeyellow.inc"


SECTION "PartyHeal", ROM0

start:
ld   a, [wPartyCount]              ; aborts if no pokemon to avoid crash
and  a
ret  z
ld   a, $07                        ; Predef id
jp   Predef                        ; calls HealParty


