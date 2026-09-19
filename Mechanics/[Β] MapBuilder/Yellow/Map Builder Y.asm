/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokeyellow.inc"

def nicknameaddress = $d8b4
def installaddress  = $df15




SECTION "OAM_Hijack", ROM0


LOAD "Installer", WRAMX[nicknameaddress]
     
start:
ld   hl, wCurMapScriptPtr
ld   a, low(payload)
ld   [hli], a
ld   [hl], high(payload)
ret

payload:                 ; input your payload here
ldh  a, [hJoyPressed]
bit  1, a                ; B Button
jr   z, noplace          ; reset collision if not pressed

ld   hl, ReplaceTreeTileBlock ; get address of tile in front of player -  on bank 3\
call $074b
ldh  a, [$ffa8]
ld   [hl], a             ; replace block
ld   hl, RedrawMapView   ; on bank 3
jp   $074b

noplace:
bit  2, a                ; Select Button
ret  z

change:
ld   hl, $ffa8
inc  [hl]
ret	

end:
ENDL
