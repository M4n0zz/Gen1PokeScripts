/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"


def  nicknameaddress     = $d8b5
def  installaddress      = $df15



SECTION "OAM_Hijack", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
     
start:
ld   hl, wCurMapScriptPtr
ld   [hl], low(builder)
inc  hl
ld   [hl], high(builder)

builder:
ldh  a, [hJoyPressed]
bit  1, a                     ; B Button
jr   z, noplace               ; reset collision if not pressed

ld   hl, ReplaceTreeTileBlock ; get address of tile in front of player
call ExtraWarpCheckdoBankswitch
ldh  a, [$ffa8]
ld   [hl], a                  ; replace block
ld   hl, RedrawMapView
jp   ExtraWarpCheckdoBankswitch

noplace:
bit  2, a                     ; Select Button
ret  z

change:
ld   hl, $ffa8
inc  [hl]
ret	

end:
ENDL
