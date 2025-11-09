# ACE Scripts for English Pokémon Red, Blue and Yellow

This repository contains my collection of Arbitrary Code Execution scripts for Pokémon Generation 1 games (Red, Blue, Yellow).
They are designed to either run using TimoVM’s Nickname Writer or to be installed with it inside TimOS environment.

----
### Features

- Ready-to-install HEX payloads
- Compatible with original cartridges, VC and emulators
- Assembly source code for learning and customization purposes


### Requirements
- A Gameboy emulator (BGB recommended) or an actual console
- A Gen 1 English Pokémon ROM or original cartridge
- [TimoVM's ACE](https://glitchcity.wiki/wiki/Guides:TimoVM%27s_gen_1_ACE_setups) setup
- [TimOS](https://glitchcity.wiki/wiki/Guides:Nickname_Writer_Codes) latest version (for permanent script installation)
- [QuickRGBDS](https://github.com/M4n0zz/QuickRGBDS) (optional)


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
Since the script selector has **limited space**, not all installable scripts can fit at the same time. This means that installing a new script usually overwrites the previous one, unless you manually change the installation address in the .asm file and recompile it. To solve this and allow access to every script at any moment, [BBMenu](https://github.com/M4n0zz/BBMenu) is now available.
