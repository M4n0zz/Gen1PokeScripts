

include "pokeyellow.inc"
include "charmap.inc"              ; this one gives us all game's character to easily print text

def nicknameaddress = $d8b4

SECTION "CelebiSpritess",ROM0

LOAD "Installer", WRAMX[nicknameaddress]
;;;;;;;;;;;; Installer payload ;;;;;;;;;;;; 
installer:
xor  a                   ; SRAM bank 0
call OpenSRAM

ld   bc, frontsprite - backsprite
ld   de, $a498           ; unused sram space
ld   hl, backsprite
call CopyData

ld   bc, end - frontsprite
ld   de, $b858           ; unused sram space
jp   CopyData

;jp   CloseSRAM          ; not enough installation memory to close sram
	
backsprite:
db $44, $E9, $55, $39, $3A, $A0, $4B, $AA, $53, $74, $88, $24, $CE, $94, $CD, $30, $4D, $A4, $B6, $08, $C1, $37, $92, $24, $14, $54, $E5, $98, $3E, $14, $52, $23, $04, $53, $18, $9A, $14, $98, $29, $C1, $14, $C5, $72, $24, $24, $2A, $21, $18, $54, $BA, $2D, $42, $81, $34, $8D, $DE, $A0, $4C, $D0, $64, $CD, $08, $66, $49, $6A, $62, $24, $C9, $09, $43, $EB, $D5, $8E, $29, $42, $05, $8D, $A5, $63, $1A, $8F, $5A, $76, $A9, $3C, $2A, $A9, $C5, $69, $36, $A1, $48, $4A, $6F, $45, $B7, $B5, $B6, $99, $23, $18, $CD, $FB, $6D, $98, $41, $11, $18, $5B, $7B, $68, $65, $60, $C3, $19, $7A, $1D, $56, $FE, $28, $C3, $C6, $F0, $DF, $EF, $0C, $D1, $C9, $5F, $48, $44, $39, $CD, $8F, $D4, $0A, $75, $50, $D6, $71, $26, $68, $59, $DB, $7C, $7D, $08

frontsprite:
db $77, $3F, $82, $1A, $53, $D2, $50, $88, $4F, $42, $46, $CF, $11, $7F, $94, $C3, $87, $22, $39, $D7, $F5, $06, $5C, $59, $91, $7F, $2A, $8E, $75, $EF, $1A, $8C, $50, $68, $C6, $39, $D5, $61, $82, $30, $69, $82, $06, $30, $8E, $D6, $30, $5A, $52, $23, $14, $E6, $55, $21, $45, $29, $C1, $19, $09, $71, $63, $A1, $54, $9F, $0A, $18, $29, $81, $B4, $64, $23, $AA, $D1, $AB, $82, $22, $BE, $26, $91, $82, $3B, $6A, $50, $8C, $12, $EA, $53, $C3, $A4, $50, $5D, $04, $B8, $98, $EC, $AA, $08, $1F, $F7, $8D, $93, $B9, $46, $09, $B9, $04, $C6, $58, $EE, $A2, $50, $8F, $65, $1A, $3D, $48, $18, $F4, $A1, $63, $D4, $58, $FE, $00, $9F, $C1, $2A, $7B, $1E, $9E, $95, $A3, $E7, $88, $A0, $9A, $40, $D1, $E0, $32, $61, $25, $3F, $B9, $E0, $5A, $67, $20, $83, $FF, $F9, $E7, $20, $FF, $FF, $E7, $74, $63, $02, $85, $8C, $85, $5F, $1D, $12, $64, $93, $06, $39, $35, $A7, $64, $98, $56, $31, $0C, $16, $55, $9E, $2E, $5B, $A3, $20, $93, $9E, $0A, $5A, $28, $62, $C8, $60, $B9, $E1, $40, $84, $86, $08, $41, $0C, $C3, $D9, $DF, $92, $D4, $8E, $67, $27, $81, $15, $D3, $B1, $E9, $58, $7E, $7A, $9B, $C7, $AB, $F1, $EA, $F1, $FC, $70

end:

ENDL
