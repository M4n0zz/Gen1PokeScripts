# 🏃 SuperSpeed+

This script doubles the speed of all Overworld activity while it’s active.

Additionally, holding the A button makes the player move at extremely high speed — similar to the fast-forward feature in emulators.

The effect is achieved using an OAM DMA hijack, which keeps the payload running constantly in the background.

###  ⚠ Warnings:
If you’re already using an OAM DMA hijack for something else, this payload will override it and break existing functionality.
Also keep in mind that due to its nature, the script is not installable, meaning that it will stop working upon game reset. Furthermore, since temporary scripts reside in battle data area, the game will crash upon encountering a trainer.
 Use with caution!

-----
### Logic Behind the Hack

This bug-free hack works by monitoring a specific stack address during the OAM DMA hijack.

Here's how it works:

- The DMA payload constantly checks the stack for a specific return address used by the DelayFrame function (a routine commonly called during Overworld activity).

- When this return address is detected, it is replaced to target a custom payload instead.

- This payload executes in sync with the Overworld loop, allowing for smooth integration.

- Once the payload runs, it then returns to the main game loop — but skips one additional Overworld delay, effectively increasing the overall speed.

This technique allows the payload to run at exactly the right time, seamlessly blending with the game's natural flow and making frame-based manipulations like speeding up movement possible without crashing or interfering with unrelated logic.


