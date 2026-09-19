/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


SECTION "PokeDuplicator", ROM0

start:
; transfer pokemon id
ld   hl, wPartySpecies
ld   a, [hli]                   ; poke 1 id
ld   [hl], a                    ; poke 2 id

; transfer pokemon data
ld   l, low(wPartyMon1)            ; poke 1 data - $6a
ld   de, wPartyMon2             ; poke 2 data
ld   c, wPartyMon2 - wPartyMon1 ; poke data length
call CopyMapConnectionHeaderloop   ; transfer pokemon data

; transfer pokemon nickname
ld   de, wPartyMon1Nick
ld   hl, wPartyMon2Nick
jp   CopyString