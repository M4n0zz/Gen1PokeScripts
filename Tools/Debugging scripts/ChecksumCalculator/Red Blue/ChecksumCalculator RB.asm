/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

SECTION "Main", ROM0

ld   a, CalcCheckSum_Bank
call BankswitchBack+3         ; simple bankswitch, but can be used by both versions
ld   hl, sGameData
ld   bc, sGameDataEnd - sGameData
call CalcCheckSum
ld   [sMainDataCheckSum], a
ret
