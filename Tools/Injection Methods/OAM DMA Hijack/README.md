
# OAM DMA Hijack – Background Payload Execution

This technique allows you to run a custom payload continuously in the background during gameplay.
It's especially useful when you want to:

- Constantly check or modify memory addresses while being in the Overworld
- Change screen tiles or text on the fly
- "Freeze" specific memory values (like a GameShark code does)

The included .asm files demonstrate how the OAM DMA hijack works, allowing you to insert your own payload at the end of the routine.

----
### How to Use

- If you're using TimoVM's Nickname Writer to execute code, you can simply paste the provided hex codes followed by your own payload instead of the last hex digit (c9) — no compiling required.
- If you use a custom entry point, you need to modify script's address and then compile with (Quick)RGBDS
- If you want to stop the hijack from running, a hijack unloader is also included. Use it to cleanly disable the loop (otherwise, the effect stops only when the game is reset).


### ⚠ Important Notes:

- Do not overwrite the DMA payload while the hijack is active — doing so is risky and will most likely cause the game to crash.
- Do not use the DMA hijack along with [BBMenu](https://github.com/M4n0zz/BBMenu) — it already uses the same hijack internally. Overwriting it may cause conflicts and break functionality.

-----

**Red/Blue**
```
f3 21 80 ff 36 cd 23 36 c5 23  
36 d8 23 36 e2 fb cd cd d8 0e  
46 3e c3 c9 c9
```

**Yellow**
```
f3 21 80 ff 36 cd 23 36 c4 23  
36 d8 23 36 e2 fb cd cc d8 0e  
46 3e c3 c9 c9
```

**DMA Unloader**
```
f3 21 80 ff 36 3e 23 36 c3 23  
36 e0 23 36 46 d9
```