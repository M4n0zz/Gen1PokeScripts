
# Custom Scripts Menu

A template for building a **custom in-game script menu**.

### ✔ Features

* Keep multiple scripts organized in a single menu
* Assign custom titles and execution pointers to each script
* Navigate through the scripts, run them with **A** or exit with **B**
* Add your labels and addresses with minimal setup

The included `.asm` files demonstrate the complete setup process and show where to insert your custom payloads at the end of the routine.


---

## 🚀 How to Use

### If you use **TimoVM’s Nickname Writer**

1. Edit the `listitems` count.
2. Replace the script labels and addresses with your own in the `.asm` files.
3. Compile everything using **QuickRGBDS**.

### If you are using a **custom entry point**

You also need to adjust:

* `nicknameaddress` - to ensure compatibility to your custom entry point
* `stackaddress` - to correct any stack offset in label detection


---

## ⚠ Important Notes

* The Custom Menu uses a **DMA hijack** to dynamically overwrite its labels.
  You can still use a DMA hijack inside a selected script, but it will break any hijack already active.

* **Do NOT use this DMA hijack together with [BBMenu](https://github.com/M4n0zz/BBMenu).**
  BBMenu already relies on its own DMA hijack, and overwriting it will cause conflicts and break functionality.
