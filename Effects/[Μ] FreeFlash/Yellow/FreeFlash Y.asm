/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"


SECTION "FreeFlash", ROM0

start:
ldh  a, [hLoadedROMBank]
push af
ld   a, StartMenu_Pokemon_Bank
call BankswitchBack+3              ; simple bankswitch compatible for both versions
xor  a
ld   [wMapPalOffset], a
ld   hl, StartMenu_PokemonflashLightsAreaText
call PrintText
jp   Bankswitch+12                 ; restores previous bank