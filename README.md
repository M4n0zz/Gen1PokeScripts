# ACE Scripts for English Pokémon Red, Blue and Yellow

This repository contains my collection of [Arbitrary Code Execution](https://glitchcity.wiki/wiki/Arbitrary_code_execution) scripts for Pokémon Generation 1 games.
They are designed to either run using TimoVM’s Nickname Writer or to be installed with it inside TimOS script selector for persistency.

----
### Features

- Ready-to-install HEX payloads, compatible with original cartridges, VC and emulators
- Assembly RGBDS source code for learning and customization purposes


### Requirements
- A Gameboy console or an accurate emulator (BGB recommended)
- A Gen 1 English Pokémon authentic cartridge or an original ROM
- [TimoVM's ACE](https://glitchcity.wiki/wiki/Guides:TimoVM%27s_gen_1_ACE_setups) setup
- [TimOS](https://glitchcity.wiki/wiki/Guides:Nickname_Writer_Codes) latest version (for permanent script installation)
- [QuickRGBDS](https://github.com/M4n0zz/QuickRGBDS) (in case you want to adjust the scripts and recompile them)


### How to run the payloads

1. **Insert code:**
Use [Nickname Converter](https://timovm.github.io/NicknameConverter/) to translate the hex payload into nickname codes, then [Nickname Writer](https://glitchcity.wiki/wiki/Guides:Nickname_Writer_Codes) to inject them. Alternatively, if using a compatible emulator, just open Nickname Writer and paste the hex code directly into the appropriate memory address:
- $D8B5 for Pokémon Red & Blue
- $D8B4 for Pokémon Yellow

2. **Run code:**
After you insert the last nickname code (or just press start in case of direct hex paste) press Start again in the nickname verification screen to run it. If everything was correct the script will run without any issues. In case of an installer, the installation will be done and you will get back to items menu.

3. **Verify (installers only):**
Open the script selector and run the last script on the list. If everything was successful, the total number of available scripts should have increased by one, and the installed script should run without any issues.


###  ⚠ Warning
Since the script selector has **limited space**, not all installable scripts can fit at the same time. This means that installing a new script usually overwrites the previous one, unless you manually change the installation address in the .asm file and recompile it. To solve this and get access to every script at any moment in the game, [BBMenu](https://github.com/M4n0zz/BBMenu) is now available.
