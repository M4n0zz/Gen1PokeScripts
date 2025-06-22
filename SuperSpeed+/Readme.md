
SuperSpeed+

When the script is active, all overworld activities have their speed doubled.

While button A is held, player is moving extremely fast.

Logic
This bug free activity is achieved because DMA payload is inspecting specific stack address, changes it and then the payload is executed whilebeing syncronised with overworld loop.
If the return address from a delay in overworld is detected, its return address is modified to execute a custom payload which consumed moving frames in the overworld loop and return to the normal execution skipping 1 more overworld delay.
