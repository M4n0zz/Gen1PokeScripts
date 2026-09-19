/*
Code is executed in every frame replacing encounter values when needed.
Sprite loading address replacement only work during battle loading or in stats page to avoid crashes.
CELEBI name replacement routine needs to stay on, so to be displayed correctly during battle dialogs or stats screen.
In case we encounter directly Pokemon E5, the game initiates a trainer battle instead.
If we catch E5, we fall under Rhydon trap, and pokedex registration messes up the game.
As a workaround, we encounter pikachu and change its species value to E5 and any other stats after caching it.

Logic
- Initially encounter caterprie to get its color pallette and cry
- Then change it to pikatchu, so it does not register a new pokemon in pokedex after catching it.
- After renaming it (or not), pokemon id changes to E5 and celebi stats are modified.
- To do so search for id 52 [pikachu], move2 [Agility] and lvl 100.
- E5 name also includes some invalid characters, so searching for its first letter is a way to avoid false positives while auto remaining to CELEBI

*/

include "pokered.inc"
include "charmap.inc"              ; this one gives us all game's character to easily print text


def pokeID          = $54
def wildlevel       = $64
def wildspecies     = $7b

def frontsprite     = $b858
def backsprite      = $a498
def scriptnumaddr   = $c6e9
def timospointers   = $c7c7
def installaddress  = $c9ce
def nicknameaddress = $d8b5
def topstack        = $db31


SECTION "CustomSprite", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
installer:
; increse no of scripts
ld   hl, scriptnumaddr
ld   b, [hl]
ld   a, scriptnumber          ; calculated in DEF
add  a, [hl]
ld   [hl], a

; write pointers to the correct position
ld   de, timospointers        ; start counting from script #1
.pointerloop
inc  e
inc  e
dec  b
jr   nz, .pointerloop

; Copy pointers
ld   c, pointerend - pointerstart ; Calculated in DEF - b = 0 from previous operation
ld   hl, pointerstart         ; origin
call CopyMapConnectionHeaderloop

; Copy payloads
ld   bc, payloadlength         ; Calculated in DEF
ld   de, installaddress
jp   CopyData

;ld bc, $e564
;jp GivePokemon

; ----------- Payload pointers ------------
pointerstart:                 ; it automatically calculates every script's starting point offsets
db low(start), high(start)
pointerend:
ENDL


LOAD "payload", WRAM0[installaddress]
start:		          ; do not replace this

;;;;;;;;;;;;;; One time payload ;;;;;;;;;;;;;;
copy:
ld   bc, (end - pcall)
ld   de, topstack
ld   hl, endsingle
call CopyData

hijack:
di                       ; because DMA routine triggers out of sync with our payload
ld   hl, hDMARoutine     ; we stop all interrupts to avoid crashes
ld   [hl], $cd           ; $ff80 is replaced with command "call", to jump to our custom address
inc  hl
ld   [hl], low(pcall)    ; $ff81 and $ff82 hold hijack's custom address
inc  hl
ld   [hl], high(pcall)
inc  hl
ld   [hl], $e2           ; ldh [c], a command is put to allow hijack to return dma's original code
;reti

ld   a, wildlevel
ld   [wEngagedTrainerSet], a
ldh  [$ffa8], a
ld   a, wildspecies
jp   InitBattleEnemyParameters+3


endsingle:
ENDL

LOAD "stack", WRAMX[topstack]
;; to transfer this to topstack

pcall:                   ; now dma hijack always points to this address
call payload             ; it calls our custom payload at the end of the script

.endoam                  ; after our custom payload returns, values are set up to continue to dma routine
ld   c, $46
ld   a, $c3
ret	


;;;;;;;;;;;;;; Constant effect payloads ;;;;;;;;;;;;;;

; check back sprite
payload:
ld   a, [wBattleMonSpecies2]
cp   a, $E5 		          ; CELEBI ID
jr   nz, .checkfront 
ld   hl, wMonHBackSprite
ld   a, low(backsprite)
ld   [hl+], a
ld   [hl], high(backsprite)

; check front sprite
.checkfront
ld   a, [wCurPartySpecies]	; stats active pokemon
cp   a, $E5 		          ; CELEBI ID
jr   nz, .iscelebibattle
ld   hl, wMonHSpriteDim
ld   a, $77		          ; sprite tile dimensions
ld   [hl+], a                 ; wMonHFrontSprite
ld   a, LOW(frontsprite)
ld   [hl+], a
ld   [hl], HIGH(frontsprite)

; stats screen
.loadex                       ; checks dex id
ld   hl, $c42f	               ; dex 1st digit tile
ld   a, [hl]
cp   a, $f6 		          ; E5 ID
jr   nz, .ldspname
ld   a, $f8
ld   [hl+], a
inc  hl
ld   [hl], $f7

.ldspname
ld   hl, $c3bd                ; check species name
ld   a, [hl]
cp   a, $20 		          ; E5 SPIECES NAME
jr   nz, .iscelebibattle

.pokename		               ; replace species to celebi
ld   de, pokename	          ; custom address name bytes are placed
call CopyString
ld   a, $7f
dec  hl	 
ld   [hl+], a		
ld   [hl+], a		
ld   [hl+], a		
ld   [hl+], a		


; check for active celebi encounter
.iscelebibattle
ldh  a, [$ffa8] 	          ; custom flag address
and  a, a 		          ; no battle = 00
ret  z

; check for active naming screen with E5 name starter
ld   hl, $c3b8 	          ; name writer pokemon tile
ld   a, [hl] 
cp   a, $20 		          ; E5  name starter
jr   nz, .battlesprites
ld   a, $54 	               ; NICKNAME POKEMON
ld   [wCurPartySpecies], a
jr   .pokename

; Checks and loads sprites in battle
.battlesprites
ld   a, [wTopMenuItemX] 	     ; battle selector state
cp   a, $0B 		          ; if sprite is loaded
jr   nz, .addr 	          ; Skips sprite load address

ld   hl, wMonHSpriteDim	     ; SPRITE LOAD ADR
ld   a, $77		          ; SPRITE LOAD
ld   [hl+], a                 ; wMonHFrontSprite
ld   a, LOW(frontsprite)
ld   [hl+], a
ld   [hl], HIGH(frontsprite)
ld   hl, wEnemyMonMoves       ; SPRITE MOVE 1 ADR
ld   a, $5d                   ; SET MOVE 1 CONFUSION
ld   [hl+], a
ld   a, $69                   ; SET MOVE 2 RECOVER
ld   [hl+], a
ld   a, $5f                   ; SET MOVE 3 HYPNOSIS
ld   [hl+], a
ld   [hl], $5e	               ; SET MOVE 4 PSYCHIC

; Preload addresses of interest
.addr
ld   bc, wPartyMon1Moves+1    ; move2
ld   de, wPartyMon1Nick       ; nickname
ld   hl, wPartyCount          ; no of pokemon
ld   a, $01                   ; pokemon count


; Check current party pokemon
.loopstart
cp   a, [hl] 		; checks if pokemon counter equals a
jr   z, .pokecheck

inc  a 			; to check next pokemon
push af			; store poke count to stack
push hl             ; stores pokemon counter in stack
ld   hl, $002c 	; next move2 address to a
add  hl, bc 
ld   b, h
ld   c, l
ld   a, e 		; transfers nickname address to a
ld   e, $0b 		; loads e with 11
add  a, e 
ld   e, a 		; transfers new nickname address to e
pop  hl
pop  af
jr   .loopstart

.pokecheck		; if pikachu + move2 agility + lvl 100
add  a, l           ; adds pokemon counter address to a
ld   l, a           ; hl becomes pokemon spieces
ld   a, [hl]        ; loads pokemon spieces to a
cp   a, $54         ; compare to pika id
jr   nz, .rename    ; skips next checks if pika not found
push hl             ; stores pokemon spieces in stack
ld   h, b           ; transfers move2 address to hl
ld   l, c
pop  bc             ; loads pokemon spieces from stack to bc
ld   a, [hl]
cp   a, $61         ; agility id
jr   nz, .rename	; skips next checks if move not found
push bc             ; pokemon species to stack again
ld   bc, $0018      ; +24 bytes to bc
add  hl, bc         ; pokemon level address
ld   a, [hl]        ; load level to a
ld   b, h           ; transfer level address to bc
ld   c, l
pop  hl             ; restores spieces to hl from stack
cp   a, $64         ; celebi level 100;
jr   nz, .rename    ; skips pokemon modification if level not found

; executes if new pikachu is found, CopyString is used
.isnewpika
ld   [hl], $e5 	; set pokemon id to e5
ld   h, b			; destination
ld   l, c
ld   de, stats1	; origin
ld   bc, $ffdf 	; FF-32
add  hl, bc 
call CopyString
dec  hl
ld   [hl], $5e
ld   de, stats2	; origin
ld   bc, $0010
add  hl, bc		; HL +17
call CopyString
dec  hl
ld   [hl], $4b
ld   h, d			; loads nickname address
ld   l, e	
ld   a, [de]
cp   a, $20		; E5 name starter
jr   z, .celebi

.rename
ld   hl, wEnemyMonNick	     ; naming address, keeps renaming pokemon everytime

; "CELEBI@"
.celebi
ld   de, pokename	; custom address name bytes are placed
call CopyString

; RENAME NEWLY CAUGHT TEXT TO CELEBI
.newname
ld   hl, wNameBuffer          ; newly caught name
ld   a, [hl]
cp   a, $8f                   ; PIKACHU P name digit
jr   z, .celebi
cp   a, $20                   ; _ E5 default name digit
jr   z, .celebi

; CHECK NEWLY CAUGHT TEXT FOR CELEBI
.isnewpoke
ld   a, [$c4e4]               ; newly caught name		
cp   a, $82                   ; CELEBI name C digit
jr   nz, .alwayson

; THEN CHECK YESNO SELECTOR
.isyesno
ld   a, [$c44f]               ; YES/NO SELECTOR
cp   a, $ed                   ; YES SELECTOR
jr   nz, .alwayson

; THEN CHECK A BUTTON PRESS
.isApressed
ld   a, [hJoyHeld]            ; inspect buttons
cp   a, $01                   ; A BUTTON PRESSED
jr   nz, .alwayson
ld   hl, wCurPartySpecies	; NICKNAME POKEMON
ld   [hl], $e5

; ALWAYS SET ENCOUNTER TO PIKACHU
.alwayson
ld   hl, wEnemyMon            ; Change encounter to pikachu
ld   [hl], $54

ld   a, [wCurOpponent]        ; battle state pointer
and  a, a                     ; if battle is not over
ret  nz                       ; stop

; Else stops CATCHING MODE
xor  a, a                     ; it always sets a to 0
ldh  [$ffa8], a	

.ret
ret

stats1:             ; Stats part 1 - $dddd
db $7b, $00, $e6, $00, $00, $18, $16, $be, $5d, $69, $5F, $50
stats2:             ; Stats part 2 - $dddd + 17
db $ff, $ff, $19, $14, $14, $0a, $64, $00, $e6, $00, $5f, $00, $69, $00, $7d, $00, $50
pokename:           ; CELEBI - $ddfa
db "CELEBI@"

end:                     ; do not replace this
ENDL

	
def scriptnumber = (pointerend - pointerstart) / 2
def payloadlength = end - pcall + endsingle - start


