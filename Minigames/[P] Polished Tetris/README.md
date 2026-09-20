
# 🧱 Polished Tetris

A refined Tetris mini-game inspired by the original Game Boy version.


# ![preview](Tetris.png)

Based on offgao’s work, it is designed to integrate seamlessly with ACE, with the following additions:

* **Original control implementation** for smooth and responsive gameplay.
* **Enhanced graphics** — now it actually looks like a proper Tetris game.
* **Next block** — shows the upcomming block
* **Pause menu** — so you don't have to lose your game when your GF asks you something.
* **Speed mode** — the speed increases every 16 lines, making the game progressively more challenging.
* **Score counters** — show me your high scores!


---

### Installation

Due to its size and architecture, the game is designed exclusively for use with TimOS Script Selector.

Please follow the instructions on the [main page](https://github.com/M4n0zz/Gen1PokeScripts) of this repo.

---

### Note

The game will break if you try to move it in any address other than $c800.

The above address is tied to the fundamental logic of Tetris tetromino creation. If the address is changed, the tetromino shapes will be distorted!

---

**Red/Blue**

Part1
```
21 c1 d8 11 00 c9 01 f2 00 c3 b5 00 60 06 60 03 30 06 40 07  
20 07 10 07 22 22 22 22 60 06 31 02 32 01 30 22 20 23 20 32  
00 0f 00 0f 60 06 60 03 30 06 00 17 00 27 00 47 22 22 22 22  
60 06 31 02 32 01 20 62 20 26 60 22 00 0f 00 0f 3e d4 f5 3e  
79 ea 6d c9 f1 18 06 3e 7b ea 6d c9 af e5 d5 c5 06 c9 cd 61  
c9 03 cd 61 c9 a7 c3 25 24 f5 0a 5f f1 cd 68 c9 16 04 cb 1b  
dc 79 c9 23 15 20 f7 d5 1e 10 19 d1 c9 77 c9 a7 c0 7e fe 7f  
c0 af c9 51 81 e6 3f 4f cd 4b c9 28 02 4a c9 3e be c3 b1 23  
11 f1 ff d5 21 ea c3 01 03 41 cd 5f 3c e1 11 f1 c9 1a be 30  
02 7e 12 21 4e c4 c3 5f 3c 21 b2 c4 3e 7f cd 42 c9 cd 5c 3e  
e6 3e e0 f0 4f c3 40 c9 f0 b4 e6 80 28 05 78 e6 e0 47 c9 cb  
6a 28 07 2b cd 4b c9 28 01 23 cb 62 c8 23 cd 4b c9 c8 2b c9  
92 a2 ae b1 a4 81 a4 b2 b3 8d a4 b7 b3 00
```

Part2
```
21 e9 c6 7e 34 87 11 f2 c8 21 c7 c7 85 6f 73 23 72 21 cf d8  
01 64 01 c3 b5 00 01 05 04 11 b8 65 21 00 8d cd 48 18 cd d8  
20 cd 0f 19 cd 29 24 3e 1f ea ef c0 3e d9 cd b1 23 01 05 04  
11 c2 c3 21 e4 c8 cd 3a 12 48 11 26 c4 cd 3a 12 48 1e 8a cd  
3a 12 af e0 f1 3c e0 b6 e0 b7 e0 f2 cd 94 c8 21 08 c5 11 d0  
12 01 f7 ff 09 73 0e f5 09 73 15 20 f4 cd f6 20 cd b1 c8 f0  
f0 4f c5 cd b1 c8 c1 06 10 21 a4 c3 cd 4b c8 28 22 3e f1 cd  
42 c8 af cd 51 09 3e 97 cd b1 23 cd 48 37 f0 f8 3d 28 87 3d  
20 f8 c3 07 23 cd 40 c8 cd 3a 1b 3e 7f cd 42 c8 c5 cd 31 38  
c1 f0 b5 57 f0 b3 5f cb 57 28 14 e5 21 02 c0 cb c6 3e b5 cd  
b1 23 f0 f8 cb 5f 28 fa af 77 e1 cd c4 c8 7b e6 03 28 09 e6  
02 cb 37 c6 f0 cd 83 c8 f0 f2 05 3d 20 fc cb 78 28 b7 06 ff  
e5 c5 01 14 00 09 c1 cd 4b c8 20 05 06 10 f1 18 01 e1 78 3c  
c2 7d c9 3e ac cd b1 23 cd 40 c8 0e 1e cd 39 37 21 fe c4 54  
5d 41 0e 0a e5 3a fe 7f 28 0d 0d 20 f8 04 e1 d5 11 ec ff 19  
d1 18 10 e1 0e 0a 3a 12 1b 0d 20 fa 0e 0a 2b 1b 0d 20 fb 7d  
fe 96 20 d6 7b fe 96 28 0f 3e 7f 0e 0a 12 1b 0d 20 fb 3e f6  
83 5f 18 ed af 80 28 1f fe 04 f5 f0 f1 80 e0 f1 cb 37 e6 0f  
3c e0 f2 cd 94 c8 f1 3e a8 20 02 3e 91 cd b1 23 cd 48 37 c3  
4f c9
```


**Yellow**

Part1
```
21 c0 d8 11 00 c8 01 f2 00 c3 b1 00 60 06 60 03 30 06 40 07  
20 07 10 07 22 22 22 22 60 06 31 02 32 01 30 22 20 23 20 32  
00 0f 00 0f 60 06 60 03 30 06 00 17 00 27 00 47 22 22 22 22  
60 06 31 02 32 01 20 62 20 26 60 22 00 0f 00 0f 3e d4 f5 3e  
79 ea 6d c8 f1 18 06 3e 7b ea 6d c8 af e5 d5 c5 06 c8 cd 61  
c8 03 cd 61 c8 a7 c3 84 22 f5 0a 5f f1 cd 68 c8 16 04 cb 1b  
dc 79 c8 23 15 20 f7 d5 1e 10 19 d1 c9 77 c9 a7 c0 7e fe 7f  
c0 af c9 51 81 e6 3f 4f cd 4b c8 28 02 4a c9 3e be c3 38 22  
11 f1 ff d5 21 ea c3 01 03 41 cd 5b 3c e1 11 f1 c8 1a be 30  
02 7e 12 21 4e c4 c3 5b 3c 21 b2 c4 3e 7f cd 42 c8 cd 6d 3e  
e6 3e e0 f0 4f c3 40 c8 f0 b4 e6 80 28 05 78 e6 e0 47 c9 cb  
6a 28 07 2b cd 4b c8 28 01 23 cb 62 c8 23 cd 4b c8 c8 2b c9  
92 a2 ae b1 a4 81 a4 b2 b3 8d a4 b7 b3 00
```

Part2
```
21 e9 c6 7e 34 87 11 f2 c8 21 c0 c7 85 6f 73 23 72 21 ce d8  
01 64 01 c3 b1 00 01 05 04 11 48 51 21 00 8d cd fe 15 cd 96  
1e cd dd 16 cd 1c 23 3e 1f ea ef c0 3e d9 cd 38 22 01 05 04  
11 c2 c3 21 e4 c8 cd ac 0e 48 11 26 c4 cd ac 0e 48 1e 8a cd  
ac 0e af e0 f1 3c e0 b6 e0 b7 e0 f2 cd 94 c8 21 08 c5 11 d0  
12 01 f7 ff 09 73 0e f5 09 73 15 20 f4 cd bd 1e cd b1 c8 f0  
f0 4f c5 cd b1 c8 c1 06 10 21 a4 c3 cd 4b c8 28 22 3e f1 cd  
42 c8 af cd 85 07 3e 97 cd 38 22 cd 3e 37 f0 f5 3d 28 87 3d  
20 f8 c3 6b 21 cd 40 c8 cd 13 19 3e 7f cd 42 c8 c5 cd 1e 38  
c1 f0 b5 57 f0 b3 5f cb 57 28 14 e5 21 02 c0 cb c6 3e b5 cd  
38 22 f0 f5 cb 5f 28 fa af 77 e1 cd c4 c8 7b e6 03 28 09 e6  
02 cb 37 c6 f0 cd 83 c8 f0 f2 05 3d 20 fc cb 78 28 b7 06 ff  
e5 c5 01 14 00 09 c1 cd 4b c8 20 05 06 10 f1 18 01 e1 78 3c  
c2 7d c9 3e ac cd 38 22 cd 40 c8 0e 1e cd 2f 37 21 fe c4 54  
5d 41 0e 0a e5 3a fe 7f 28 0d 0d 20 f8 04 e1 d5 11 ec ff 19  
d1 18 10 e1 0e 0a 3a 12 1b 0d 20 fa 0e 0a 2b 1b 0d 20 fb 7d  
fe 96 20 d6 7b fe 96 28 0f 3e 7f 0e 0a 12 1b 0d 20 fb 3e f6  
83 5f 18 ed af 80 28 1f fe 04 f5 f0 f1 80 e0 f1 cb 37 e6 0f  
3c e0 f2 cd 94 c8 f1 3e a8 20 02 3e 91 cd 38 22 cd 3e 37 c3  
4f c9
```
