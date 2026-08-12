# 🧱 Tetris

A simple Tetris mini-game with enhanced gameplay inspired by the original Game Boy Tetris.

It is a port of offgao's Tetris, designed to integrate seamlessly with ACE.
# ![preview](Tetris.png)

### Features

- Refined controls for natural and reliable gameplay
- Line counter, high score, increasing game speed, and next-piece preview TO BE ADDED!


----
### Installation

Due to its size, the payload is split into two parts and is designed exclusively for use with TimOS Script Selector.

Please follow the instruction in the [main page](https://github.com/M4n0zz/Gen1PokeScripts) of this repo.

----
### Note

In case you manually move the payloads within the memory region, make sure that Part 1 is always installed at an address with a low nibble of ``$00``. This is tied to the fundamental logic of Tetris tetromino creation, and if the address is changed, the tetromino shapes can be hilariously distorted!
