/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

def  nicknameaddress     = $d8b5
def  maxscriptsadr       = $c6e9
def  selectorpointer     = $c7c7
def  installaddress      = $c900


SECTION "ItemGiver", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
;;;;;;;;;;;; Installer payload ;;;;;;;;;;;; 
installer:                         ; move script into TimOS
ld   hl, maxscriptsadr
ld   a, [hl]
inc  [hl]
add  a, a
ld   de, installaddress            ; destination
ld   hl, selectorpointer           ; change nickname writer pointer inside timos
add  a, l
ld   l, a
ld   [hl], e
inc  hl
ld   [hl], d

ld   c, finish - start
ld   hl, .end                      ; origin
jp   CopyMapConnectionHeaderloop
.end
ENDL



LOAD "script", WRAM0[installaddress]

start:
call ClearScreen
call UpdateSprites                 ; removes sprites from screen
ld   a, $ff                        ; all item IDs
ld   [wMaxItemQuantity],a
call DisplayChooseQuantityMenu     ; DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ret  nz                            ; if B pressed, then ret
ld   a, [wItemQuantity]
push af
ld   [wNamedObjectIndex], a
call GetItemName
ld   hl, $c409                     ; screen tile destination
ld   de, wNameBuffer
call PlaceString
ld   a, $ff                        ; all item quanities
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
pop  bc
and  a, a                          ; if a is 0, z flag is set
jr   nz, start                     ; if B pressed go to the beginning
ld   a, [wItemQuantity]            ; wItemQuantity
ld   c, a                          ; bc = id, quantity
call GiveItem
jr   start

finish:		                    ; do not replace this
ENDL
