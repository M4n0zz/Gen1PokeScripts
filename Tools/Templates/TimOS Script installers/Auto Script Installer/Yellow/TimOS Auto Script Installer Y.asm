/*

Auto Script Installer - Compatible with EN Yellow ONLY


Description
It targets to the ease of installing one or more scripts into TimOS script selector.
It automatically finds unused memory and installs your new scripts.

Restrictions
This method is compatible ONLY WITH RELATIVE ADDRESS SCRIPTS! If the script uses "call" or "jp" instructions targeting in another part of the script,
then you shouyld use STATIC INSTALLER and compile the script yourself.

Static script's jumps or calls are not tolerated since the script can be installed in different addresses


Instructions
1) Put your script's assembly code under "CustomPayload" section.
2) Compile your script using (Quick)RGBDS.
3) Install the output over Nickname Writer.

The script will automatically calculate the offsets needed for:
- Script selector number
- Jump table address
- The script itself



Source is compiled with QuickRGBDS
https://github.com/M4n0zz/QuickRGBDS

*/

include "pokeyellow.inc"


def  scriptnumberaddress = $c6e9 
def  scriptpointers      = $c7c0
def  defaultinstall      = $c7ff
def  nicknameaddress     = $d8b4


SECTION "AutoScriptInstaller", ROM0

LOAD "Installer", WRAMX[nicknameaddress]
; ----------- Installer payload ------------ 
installer:               ; find free space in unused memory
ld   de, $cb49           ; last usable WRAM byte ($ff)

.loop
ld   a, [de]
dec  de
cp   a, $ff
jr   z, .loop
inc  de
inc  de
ld   a, d
cp   a, $c8
jr   nc, .skip           ; if no script exists
ld   de, defaultinstall  ; default installation address is set

.skip
ld   hl, $c6e9
ld   a, [hl]
inc  [hl]
add  a, a
ld   hl, scriptpointers  ; change nickname writer pointer inside timos
add  a, l
ld   l, a
ld   [hl], e
inc  hl
ld   [hl], d

; Copy payloads
ld   c, end - start
ld   hl, .end            ; origin
jp   CopyMapConnectionHeaderloop

.end

start:                   ; do not replace this

; place your code in here

end:                     ; do not replace this
ENDL
