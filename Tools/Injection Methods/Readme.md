## Injection methods


This directory contains scripts that are not directly usable by the user. Instead, they provide the tools and techniques needed to achieve specific effects, such as **background code execution, game functionality customization, and other advanced game modifications**.

---

### ACE Logic

To run a script, two things are needed:

1. A way to write code into a specific memory location
2. A way to execute code from that memory location

**1. Writing Code to Memory**

Several methods have been developed over the years. The most common are:

* **RAM Writers:** Allow hex code to be written directly into any writable memory location. This method is relatively slow, but the code can be reviewed and modified in real time.
* **Nickname Writers:** Hex payloads are converted into Pokémon nicknames, usually with the help of an external tool. This significantly reduces the number of button presses required. A checksum may also be used.
* **D-Pad Writers:** Hex payloads are converted into sequences of D-Pad inputs, usually with the help of an external tool. Like Nickname Writers, this greatly reduces the number of inputs required. A checksum may also be used.

**2. Executing Code**

There are many ways to execute code, most of which rely on game glitches.

A common approach is to use glitch items such as **4F, 8F, ws_m (Yellow only)**, etc. These items execute code from specific memory addresses. By placing a jump instruction at the appropriate address, execution can be redirected to custom code.

---

### Constant Code Execution

Some scripts need to run continuously in the background. This can be used to create persistent effects, monitor memory, or modify the game's normal behavior.

Several methods can be used to repeatedly execute code:

* **OAM DMA:** Executes once per frame.
* **Serial Hijack:** Executes approximately once every 1200+ instructions.
* **Map Script Pointer:** During the overworld, the game repeatedly executes code from the address stored in this pointer. This happens every overworld frame (every 2 frames while in the overworld with no menus open).
* **Text Pointer:** A custom address can be placed in the text pointer table, causing an NPC's dialogue to load data from that address. A specific text command can then be used to escape the dialogue and execute custom code.

---

### Game Modification

There are several ways to modify the game's original behavior:

* **Directly modifying the game through Pret:** The original game code can be customized directly. This provides a lot of flexibility, but the resulting scripts can become very large depending on what is being changed.

* **Stack Hook:** The return address stored on the stack is replaced with a custom address. This requires carefully timing the hook so the stack can be modified at the right moment. It works well with larger game functions and becomes more practical when a DMA hijack is already available.

* **Copy ROM to WRAM and patch:** A section of ROM is copied into WRAM, where specific addresses can then be patched. This requires enough WRAM to hold the copied code, but the resulting script can remain relatively small unless many addresses need to be patched.
