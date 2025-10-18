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


### Installation

1. **Insert code:**
Use [Nickname Converter](https://timovm.github.io/NicknameConverter/) to translate hex payloads to nickname codes, then [Nickname Writer](https://glitchcity.wiki/wiki/Guides:Nickname_Writer_Codes) to inject them, or alternatively, copy and paste the hex code directly into the appropriate memory address if using a compatible emulator:
- $D8B5 for Pokémon Red & Blue
- $D8B4 for Pokémon Yellow

2. **Run code:**
After you insert the last code (leave it empty in case of direct copy and paste) press Start in the nickname verification screen to run the code.

3. **Verify installation (installers only):**
Open the script selector and run the last script on the list. If everything was successful, the total number of available scripts should have increased by one, and the installed script should run without any issues.

Warning: Since script selector offers a limited amount of space, not every installable script can fit inside. Thus, every script will be saved on top of the previous one, unless you manually change its installation address. To avoid this issue and get access in every script at any point, BBMenus is about to be released soon. Stay tuned!
