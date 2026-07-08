# Note Splashes Offsets For SE 0.6.X & PE 0.6.3 : 

# V1:

**What did i do?**
I created a small Lua script that acts as a "bridge", forcing PE 0.6.3 to read a `noteSplashes.txt` file and apply the offsets to the note splashes in real-time during gameplay, which the engine doesn't do natively in this version.

**How does it work?**
- **Reading:** When the song starts, the code opens the `.txt` file and stores the X and Y coordinates in its memory.

- **Smart Detection:** The code ignores common modding mistakes (like leaving the texture name as "noteSplashTexture" or "noteSplashData.texture") and auto-detects the splash name. It also recognizes that 0.6.3 uses animation names like `note0-1` instead of `blue 1`.

- **The Secret Timing:** I used a hidden function called `onUpdatePost` (*YAAY*). This function runs *after* the engine finishes updating the splash's animation, but *before* it draws it to the screen. This precise timing is what prevented the engine from overriding our custom offsets.

- **Brute Force Looping:** The code checks all active splashes on screen 60 times a second and forcefully applies the `.txt` offsets to them without using any counters. This completely bypassed the engine's "sprite recycling" bug, which was causing the code to stop working after the first note.

example: *Note Splashes Vanilla*
```txt
note splash
-26 -20
-26 -20
-26 -20
-26 -20
-14 -16
-14 -16
-14 -16
-14 -16
```
**NO ANIM FPS DELETE THAT SHIT**

# Enable (noteSplashes) in UE 0.5.5 + RGB + Pixel SUPPORT :

# V5:

- We made it recognize **Pixel Stage** more effectively.

- We prevented the pixel from working in all **stages**.

- It now uses:

```lua
noteSplashes-pixel

noteSplashes-nRGB-pixel

```
only within **Pixel Stage**.

- We set `antialiasing = false` within **Pixel Stage**.

- We **fixed** RGB so it copies the notes from the string and doesn't break.

**In short**:

Not Splash = Pixel image + RGB adjusted + Works only in Pixel Stage.

# Better Hold Cover FOR SOLAR ENGINE + RGB + Pixel SUPPORT:

# V6:

- We implemented the same robust **Pixel Stage** detection.

- We added a list of **pixel stage** names as a backup.

- Within **Pixel Stage**, it now forcibly turns off smoothing:

```lua
antialiasing = false
bitmap.smoothing = false

```
- We **fixed** RGB in the same way as **Note Splash**.

- `holdCoverPixelRGB` only works in **Pixel Stage** and with **RGB**.

**In short:**

Hold Cover = Pixel Stage detection adjusted + Fixed pixelation + RGB adjusted.
