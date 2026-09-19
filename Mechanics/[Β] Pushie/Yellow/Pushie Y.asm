/*

Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"

def payloadaddress  = $d8b4
def bankswitch3     = $074b



SECTION "ScriptName", ROM0

start:
LOAD "NicknameWriterPayload", WRAMX[payloadaddress]
;;;;;;;;;;;; Payload ;;;;;;;;;;;; 
payload:
; constant execution, probably by setting wCurMapScriptPtr to $DC00
ld   hl, wCurMapScriptPtr
ld   a, LOW(pushscript)
ld   [hl+], a
ld   a, HIGH(pushscript)
ld   [hl], a
ret  

pushscript:
ldh  a, [hJoyPressed]
bit  1, a  ; B Button
ret  z
ld   hl, wStatusFlags1
set  0, [hl]
ld   hl, wMiscFlags
set  1, [hl]
ret  

.end
ENDL

