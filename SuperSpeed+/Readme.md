# 🏃 SuperSpeed+

This script doubles the speed of all Overworld activity while it’s active.

Additionally, holding the A button makes the player move at extremely high speed — similar to the fast-forward feature in emulators.

The effect is achieved using an OAM DMA hijack, which keeps the payload running constantly in the background.

###  ⚠ Warnings
  <ul>
    <li>If you are already using an <strong>OAM DMA hijack</strong> for another purpose, installing this payload will overwrite it and break any existing functionality.</li>
    <li>Due to its nature, this script is <strong>temporary</strong> and cannot be permanently installed; it will stop working when the game is reset.</li>
    <li>Temporary scripts use the <strong>battle data area</strong>, so the game will <strong>crash if you encounter a trainer</strong> while it is active.</li>
  </ul>
  <p><strong>Use with caution!</strong></p>

-----
### Logic Behind the Hack

This bug-free hack works by monitoring a specific stack address during the OAM DMA hijack.

Here's how it works:

- The DMA payload constantly checks the stack for a specific return address used by the DelayFrame function (a routine commonly called during Overworld activity).

- When this return address is detected, it is replaced to target a custom payload instead.

- This payload executes in sync with the Overworld loop, allowing for smooth integration.

- Once the payload runs, it then returns to the main game loop — but skips one additional Overworld delay, effectively increasing the overall speed.

This technique allows the payload to run at exactly the right time, seamlessly blending with the game's natural flow and making frame-based manipulations like speeding up movement possible without crashing or interfering with unrelated logic.



