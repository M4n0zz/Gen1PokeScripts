
## Stack Manipulation


This method works based on an OAM DMA hijack as an execution point.

**Tutorial**
- Find a call in rom that requires 1 or more frames in order to be completed - if it has a FrameDelay its compatibility is guaranteed.
- Return address is +3 of this instruction, temporarily stored in the stack.
- In bgb make a Watch Setpoint for the above address.
- Run the game until the watchpoint fires.
- Look for the stack address and write it in the script.
- Write the payload you need to inject and use a jump to return back to original return address or somewhere closeby so the game does not go out of sync.
- Optional: Using this methodology you can also return to a different address than the original one, effectively skipping or terminating part of the ROM code!