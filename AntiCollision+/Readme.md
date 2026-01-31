# 🧱 AntiCollision+

This script activates the ability to walk through walls safely, without crashing the game if you try to go beyond map borders!

# ![preview](AntiCollision+.jpg)

###  Usage
- Hold B Button to disable collision.
- Release B Button to enable collision.



###  ⚠ Warnings
  <ul>
    <li>The effect is achieved using an OAM DMA hijack, which keeps the payload running constantly in the background. If you are already using the hijack, installing this payload will overwrite it and break any existing functionality.</li>
    <li>Due to its nature, this script cannot survive a game reset. You will need to activate it again.</li>
    <li>Although the script blocks movement beyond the map borders, switching maps can still result in invalid coordinates. This may cause graphical issues or even crash the game if the character ends up too far outside the map. <strong>Use with caution!</strong></li>
  </ul>

-----
### Logic Behind the Hack

  <p>The effect is achieved using both an <strong>OAM DMA hijack</strong> and a <strong>Map Script Pointer hijack</strong>, which keep the payload running constantly in the background.</p>

  <h3>OAM DMA Hijack</h3>
  <ul>
    <li>Continuously monitors for changes to the <strong>Map Script Pointer</strong>.</li>
    <li>Re-applies the hijack whenever necessary to maintain functionality.</li>
  </ul>

  <h3>Map Script Hijack</h3>
  <ul>
    <li>Checks the <strong>current player's tile</strong> based on the map’s width and height.</li>
    <li>If a <strong> map edge tile</strong> is detected, the script looks for d-pad button presses.</li>
    <li>If the player attempts to move outside the map, <strong>collisions are re-enabled</strong>, except in case there is a <strong>map connection</strong>.</li>
  </ul>




