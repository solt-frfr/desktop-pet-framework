# Desktop Pet Framework
 Solt made a desktop pet!
 
# Hopes for this project
 ❌ - Not currently implemeneted 	✅ - Currently implemented
 
 Mod Support ✅
 
 Window Sitting ❌
 
 Taskbar Sitting ✅
 
 Dragging Animation ✅
 
 Idle Animations ✅
 
 Alarm / Timed Animation ✅
 
 Dance Animation ⏸ - Anim is in game, can't link
 
 Touch Reactions (Head / Sensitive Area) ✅
 
 Changeable Clothing ✅
 
 Toggleable Window Border ✅
 
 Flip Sprites ✅
 
 Particle Effects ✅
 
 Open Source ✅

# Installing Mods
 You can install additional characters by placing them in the mods folder.

> Windows: %APPDATA%\DesktopPetFramework

> macOS: ~/Library/Application Support/DesktopPetFramework

> Linux: ~/.local/share/DesktopPetFramework

 There is currently no download page for mods.

# Creating a Character

## Setup
 I did my best to try to make this as painless as possible, but it's still not the quickest, nor the most fun.

 You'll need to have Godot 4 installed. The version used to make this game was version 4.4.

 Clone the repository and load the project in Godot. You'll find the example character, Miles Edgeworth, already there.

 Inside the `pet_scenes` folder is a folder called `miles.solt11`. Rename it to whatever you like, but it's recommeneded to rename it to `{character}.{author}`. So if I were to make, say, a Hatsune Miku character, I'd likely name the folder `miku.solt11`. This naming convention helps characters to be created without worrying about overlaps.

 If you know how to code, the scripts can be changed as you want. This is how to add a character without knowing how to code, it though still applies for those editing.

## character.ini
 Next you should look at the `character.ini` file. I'll define what you should write in each part.

 `name=` should contain a string representing your character's name, which will show on the character select. In my case, "Miles Edgeworth".

 `idle_anims=` should contain an interger representing the number of basic idle animations.

 `sit_anims=` should contain an interger representing the number of sitting idle animations.

 `clothes_toggles=` should contain an interger representing how many additional costumes the character has.

 `toggle_style=` should contain an enum representing how additional clothes and costumes should be applied to your character.

> 0 means there are no additional clothes or costumes.
>
> 1 means for the sprite to be entirely swapped.
>
> 2 means for additional sprites to be pasted on top of the character.
>
> Any numbers higher than the styles available will act as the highest number shown. This may cause compatibility issues if more styles are introduced, so please stick with what is available.

 `sit_offset=` should contain an interger representing how far down the sprite it should snap to when sitting on your taskbar. The number should represent where it meets the top of the taskbar. This is not affected by scale, so bear in mind you may have to scale this number to match the window size.

 `drag_offset=` should contain a Vector2i representing the offset, from the center of the window, the cursor should be placed at when dragging your character. This is not affected by scale, so bear in mind you may have to scale this number to match the window size. Vector2i's can only contain intergers.

 `scale=` should contain an interger. The window the character takes up is always a 384x384 window. You can scale your character up as much as you want, with each one shrinking the effective amount of pixels you have.

> 1 allows up to 384x384 sprites
>
> 2 allows up to 192x192 sprites
>
> 3 allows up to 128x128 sprites
>
> You can pick any number, even a decimal. These are what I recommend though.

 `alarm_length=` should contain a number in seconds of how long you want your alarm to play for. The song I chose loops at 72 seconds, so I cut it off there.

If the Toggle Style is not `0`, for each costume or clothing, provide `clothes_nameX=`, where `X` is an interger and the value is a string containing the costume name, such as `clothes_name1="Default"`

## Scene Layout
```
Character:
 ┣ Chest
 ┣ Crotch
 ┣ Head
 ┣ Hitbox
 ┣ Sprite1
 ┣ Particles
 ┣ Timer
 ┣ AlarmPlayer
 ┗ Textures
```

 This is the current scene tree. You'll immediately need to change some things depending on what your Toggle Style is.
 
> If you set it to 0 or 2, you can call `Sprite1` whatever you want. For the purposes of this guide, I'll keep calling it `Sprite1`.
>
> If you set it to 1, it must be called `Sprite1`.

 In regards to additional costumes...

> If you set it to 1, additional costumes must be **siblings** to `Sprite1`, and must be called `Sprite2`, `Sprite3`, and so on.
>
> If you set it to 2, additional clothing must be **children** to `Sprite1`, and must be called `Costume1`, `Costume2`, `Costume3`, and so on.

 The `Textures` node is interesting. It's entirely optional, but I found by placing certain additional images like particles as `TextureRect`s, I stopped having problems loading them. Always test before release!

## Animations
 There are 10 required animations. They must be named as is.

> `alarm` plays when your alarm goes off.

> `drag` plays when dragging your character.

> `drop` plays when letting go of your character.

> `idle0` is the sprite's default standing pose.

> `music`, although currently unused, is designed to be played when the program detects music playing from certain other software.

> `react_chest`, `react_crotch`, and `react_head` each play when clicking on their respective areas.

> `sitidle0` is the sprites's default sitting pose.

> `sleep` is the sprite's sleeping pose.

> `startup` plays when either switching to your character or launching the program with your character as the most recently used.

> `tosleep` plays when your character is falling asleep.

 You can add the following additional animations.

> `idleX`, where `X` is an interger. Each one is an idle animation that will play randomly. Miles Edgeworth has 2, `idle1` and `idle2`.

> `sitidleX`, where `X` is an interger. Each one is an idle animation that will play randomly when sitting. Miles Edgeworth has 1, `sitidle1`.

 When deciding `idle_anims` and `sit_anims` values in the `character.ini`, `idle0` and `sitidle0` do not count.

### Particles
 When reacting to your click, the particles change depending on where. The image for each is `head.png`, `chest.png`, and `crotch.png`. Edit these in your program of choice, but they won't be recognized unless they are named as such.

### Hitboxes
 By far the most tedious part of the whole process. Under the `Chest`, `Crotch`, `Head`, and `Hitbox` nodes, you will find `Node2D`s, each named after an animation, and under each is one or more `ColissionShape2D`s. For each frame of each animation, you will need to tweak the hitboxes to match your sprite. I recommend using `RectangleShape2D`s as your shape for each hitbox. Other shapes may work, but it may have issues. 
 
 You may notice not all frames have a hitbox. You are free to add or remove hitboxes, but you must keep in mind the following restrictions.

> One (1) hitbox must be provided for each animation. This must be named `0`.
>
> If a hitbox for a specific frame is not found, it counts backwards until it finds one.
>
> If an animation's `Node2D` is missing, it will default to `idle0`'s first frame.

 For each one in `Hitbox`, create a bounding box around the whole sprite. This is used to define where the window can be clicked. Wherever there isn't a hitbox will not be detected and will pass to the program behind it.

 For each one in `Head`, create a bounding box around the head.

 For each one in `Chest`, create a bounding box around the chest and/or shoulders.

 For each one in `Crotch`, create a bounding box around the crotch.

 This process takes a while, as there isn't a great way to automate it.

## Misc. Assets
 Each character has an icon to show on the character select, being `icon.png`. Edit this in your program of choice, but it must be included and named properly.

 Each character also has an alarm sound. This can be a song or any other audio file you want. Make sure the audio is placed in your character folder, and drag it onto the `Stream` part of the `AlarmPlayer` in the `Inspector` tab.

## Exporting
 Once you're all done and can assure that it works, go to Project -> Export...

 Create a profile for your OS if you don't have one, then go to the Resources tab.

 Under "Resources to export", find your `character.tscn` and click on it. It should automatically select the necessary folders.

 Export it as a .pck and you're done. You can now place this inside the mods folder of any install of Desktop Pet Framework, and you will be able to load it.

# About
 I created this in Godot 4.4 to get myself used to the engine and to test myself. It was really fun! I encourage people to make their own coding projects for thing's they're passionate in.

## Credits
 Capcom, for creating Ace Attorney Investiagtions 1 and 2.
 
 The Spriters Resource, for ripping the sprites from both of those games.

 My dad, who wants me to add Superman.
