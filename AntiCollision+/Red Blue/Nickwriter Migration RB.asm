/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/


include "pokered.inc"

def nickwriterptr   = $c7c9
def nickwriterdest  = $c800
def currentaddress  = $d66a
def nicknameaddress = $d8b5

SECTION "ScriptName", ROM0

start:
LOAD "NicknameWriterPayload", WRAMX[nicknameaddress]
;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:
ld   hl, nickwriterptr        ; change nickname writer pointer inside timos
ld   de, nickwriterdest       ; destination address
ld   [hl], e
inc  hl
ld   [hl], d

; move NicknameWriter into TimOS
ld   hl, currentaddress       ; origin address
ld   c, $41                   ; 65 bytes to copy
jp   CopyMapConnectionHeaderloop

.end
ENDL
