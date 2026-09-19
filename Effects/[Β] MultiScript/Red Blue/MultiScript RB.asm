/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokered.inc"


def  maxscriptsadr            = $c6e9
def  selectorpointer          = $c7c7
def  installaddress           = $c8c5
def  nicknameaddress          = $d8b5
def  hardcodedbankswitch1     = $1375
def  hardcodedbankswitch3     = $091a


SECTION "MultiScript", ROM0

LOAD "installer", WRAMX[nicknameaddress]
installer:
ld   bc, ((pend - pstart) / 2) * $100 + (pend - pstart)  ; b + c
ld   de, maxscriptsadr
ld   a, [de]                  ; load current total scripts
ld   l, a                     ; save for later
add  a, b                     ; increase total scripts
ld   [de], a                  ; save them in place

ld   de, selectorpointer      ; pointer destination initial address
ld   a, l                     ; restore initial script number
add  a, a                     ; double length
add  a, e                     ; add pointer start
ld   e, a                     ; update pointer
ld   hl, pstart               ; pointers origin
call CopyMapConnectionHeaderloop


; Copy payloads
ld   bc, end - start          ; script width
ld   de, installaddress       ; destination
jp   CopyData


; ----------- Payload pointers ------------
pstart:           ; it automatically calculates every script's starting point offsets
dw   itemgiver
dw   dexgiver
dw   letsgetwild
dw   hitrainer
dw   poketeacher
dw   duplicator
dw   makeitrain
dw   instant
dw   anypc
dw   flier
dw   healer
pend:

ENDL


LOAD "scripts", WRAM0[installaddress]

start:

; ----------- Common functions ------------
emptyscreen:
call ClearScreen
jp   UpdateSprites


selector:
ld   [wMaxItemQuantity], a
call DisplayChooseQuantityMenu
and  a, a                          ; if a is 0, z flag is set
ld   a, [wItemQuantity]            ;  read
ret


copyname:
ld   hl, $c409                     ; destination
ld   de, wNameBuffer               ; origin
jp   PlaceString


; ----------- Scripts ------------
itemgiver:
call emptyscreen
ld   a, $ff                        ; total item IDs
call selector
ret  nz                            ; if B pressed, then ret
push af
ld   [wPokedexNum], a
call GetItemName 
call copyname
ld   a, 99
call selector
pop  bc
jr   nz, itemgiver                 ; if B pressed go to the beginning
ld   c, a                          ; bc = id, quantity
call GiveItem
jr   itemgiver


; common pokemon function
pokecommon:
call emptyscreen
ld   a, 151                        ; total species IDs
call selector
jr   z, .continue                  ; if B pressed, then ret
ret
.continue
ld   de, wPokedexNum
ld   [de], a                       ; pokemon id is stored in wPokedexNum
ld   b, PokedexToIndex_Bank        ; select bank 16
ld   hl, PokedexToIndex
call Bankswitch
ld   a, [de]                       ; wPokedexNum
push af
call GetMonName
call copyname
ld   a, $64                        ; up to level 100
call selector
pop  bc
jr   nz, pokecommon                ; if B pressed go to the beginning
ret


dexgiver:
call pokecommon
ret  nz
ld   c, a                          ; bc = id, level
call GivePokemon
jr   dexgiver


letsgetwild:
call pokecommon
ret  nz

encounter:                         ; common function
ld   [wEnemyMonAttackMod], a       ; [wCurEnemyLevel]/[wTrainerNo]
ld   a, [wPokedexNum]              ; wPokedexNum - pokemon/trainer id
jp   InitBattleEnemyParameters+3


hitrainer:
call emptyscreen
ld   a, 47                         ; total encounter IDs
call selector
ret  nz                            ; if B pressed, then ret
ld   [wTrainerClass], a
push af
call GetTrainerName
call copyname
pop  af
add  a, $c8                        ; allign to correct trainer ID
ld   [wNamedObjectIndex], a
ld   a, $ff                        ; allow all rosters
call selector
jr   nz, hitrainer                 ; if B pressed go to the beginning
jr   encounter


poketeacher:
call emptyscreen
ld   a, 165                        ; total move IDs
call selector
ret  nz                            ; if B pressed, then ret
ld   [wMoveNum], a
ld   [wNamedObjectIndex], a
call GetMoveName
call copyname
ld   hl, wStringBuffer             ; destination
ld   e, low(wNameBuffer)           ; origin $6d
call CopyString
ld   a, [wPartyCount]	 
call selector
jr   nz, poketeacher               ; if B pressed go to the beginning
dec  a
ld   [wWhichPokemon], a
ld   hl, LearnMove
call hardcodedbankswitch1
jr   poketeacher


duplicator:
; transfer pokemon id
ld   hl, wPartySpecies             ; poke 1 id
ld   a, [hli]
ld   [hl], a                       ; hl = $d164
; transfer pokemon data
ld   bc, $002c                     ; poke data length
ld   de, wPartyMon2                ; poke 2 data
ld   l, low(wPartyMon1)            ; $6a - poke 1 data
call CopyData
; transfer pokemon nickname
ld   de, wPartyMon1Nick            ; poke 1 nickname
ld   hl, wPartyMon2Nick            ; poke 2 nickname
jp   CopyString


makeitrain:
ld   hl,wPlayerMoney
ld   a, $99
ld   [hli],a
ld   [hli],a
ld   [hl],a
ret

instant:
ld   hl,wOptions
ld   a, [hl]
and  a, $f0
ld   [hl], a
ret


anypc:
ld   b, ActivatePC_Bank
ld   hl, ActivatePC
jp   Bankswitch


flier:
; set all fly locations
ld   hl, wTownVisitedFlag+1
push hl
ld   a, [hld]
ld   b, a
ld   a, [hl]
ld   c, a
push bc
ld   a, $ff
ld   [hli], a
ld   [hl], a
call ChooseFlyDestination
pop  bc
pop  hl
ld   a, b
ld   [hld], a
ld   a, c
ld   [hl], a
ret 


healer:
ld   hl, HealParty
jp   hardcodedbankswitch3

end:
ENDL
