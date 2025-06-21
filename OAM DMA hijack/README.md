
# OAM DMA Hijack – Background Payload Execution

This technique allows you to run a custom payload continuously in the background during gameplay.
It's especially useful  when you want to:

- Constantly check or modify memory while being in the Overworld
- Change screen tiles or text on the fly
- "Freeze" specific memory values (like a GameShark code)

The included .asm files demonstrate how the OAM DMA hijack works, allowing you to insert your own payload at the end of the routine.

----
### How to Use

- If you're using TimoVM's Nickname Writer to execute code, you can simply paste the provided hex codes followed by your own payload — no compiling required.
- If you use your custom entr point, you need to modify script's address and then compile with (Quick)RGBDS
- If you want to stop the hijack from running, a hijack unloader is also included. Use it to cleanly disable the loop (otherwise, the effect stops only when the game is reset).
