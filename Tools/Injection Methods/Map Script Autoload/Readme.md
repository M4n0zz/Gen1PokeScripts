
## Map Script Autoload

**Description**

Setting up this hijack will create two ways to execute code permanently in the game.
1) Through OAM DMA routine: Custom payloads will be executed once in every frame, useful to program constant effects in the game.
2) Through Map Script: Custom payloads will be executed only when player is in overworld and not moving, useful for skipping some checks in the payloads.

---

**Logic**

Part 1
- OAM DMA routine executes Map Script pointer (MSP) manipulator, which checks if MSP is hijacked.
- If not, current room is checked. If HoF is detected, it waits for the active dialogs to close and replaces room id with an unused one.
- Afterwards, original MSP is copied to the end of this routine, and a custom one replaces it.
- OAM DMA payloads are execuded.
- Proper registers are set and OAM DMA routine continues its normal execution.

Part 2
- Starting up the game, custom MSP targets our custom MSP payload.
- MSP payload checks for active OAM hijack. If OAM is not hijacked, it sets it up.
- After setting up OAM hijack, currect active room is checked. If unused room $0b is detected, manual map reset after HoF is performed. 
- Custom MS payloads are executed
- Finally, a jump from the original backed up MSP happens and the game continues to its normal state.
