# 🧱 AntiCollision+

This script activates the ability to walk through walls safely, without crashing the game if you try to go beyond map borders!

Usage
- Hold B Button to disable collision.
- Release B Button to enable collision.

###  ⚠ Warnings:
If you’re already using an OAM DMA hijack for something else, this payload will override it and break existing functionality.
Also keep in mind that due to its nature, the script is not installable, meaning that it will stop working upon game reset. Furthermore, since temporary scripts reside in battle data area, the game will crash upon encountering a trainer.
Use with caution!

-----
### Logic Behind the Hack

The effect is achieved using an OAM DMA and a Map Script Pointer hijack, which keeps the payload running constantly in the background.

<p>OAM DMA Hijack</p>
It constantly monitors for changes to the Map Script Pointer and re-applies the hijack whenever needed.
<p></p>
<p>Map Script Hijack</p>
It always checks the current tile based on the map’s width and height. If an edge tile is detected, it then checks the player’s button presses. If the player is attempting to move outside the area, collisions are re-enabled, except in cases where there is a map connection, which is generally a crash-free scenario.


