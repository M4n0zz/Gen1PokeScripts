/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"

def  backup = $d6ee


SECTION "escape", ROM0

escape:
; preload values
ld   hl, wIsInBattle     ; 00 no, 01 wild, 02 trainer, ff lost
ld   de, backup
ld   bc, wMenuCursorLocation

; check for active battle
ld   a, [hl]
and  a			     ; check battle
jr   nz, .runcheck

; if no active battle, check backup and reset some values if not already
ld   a, [de]
and  a			     ; check backup
ret  z
xor  a
ld   [de], a		     ; reset backup
ld   [bc], a		     ; reset selector
ret

; if active battle, check for selected menu
.runcheck
ld   a, [bc]
cp   a, $ef		     ; is RUN selected?
jr   z, .backup

.itemcheck
cp   a, $e9		     ; is ITEM selected?
jr   z, .backup

.pkmncheck
cp   a, $c7		     ; is PKMN selected?
jr   z, .restore

.fightcheck
cp   a, $c1		     ; is FIGHT selected?
ret  nz			     ; fallthrough if z

; if no RUN selected, restore battle type and zero out backup address if not already
.restore
ld   a, [de]
and  a			     ; check backup
ret  z
ld   a, [de]
ld   [hl], a
xor  a
ld   [de], a
ret

; if RUN selected, backup battle type and set it to 01 if not already
.backup
ld   a, [de]
and  a			     ; check backup
ret  nz
ld   a, [hl]
ld   [de], a
ld   [hl], $01
ret

