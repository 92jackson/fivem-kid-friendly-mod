# FiveM Kid Friendly Mod

Inspired by [R3QQ's Family Friendly Free Roaming (FFFR)](https://sites.google.com/view/r3qq/family-friendly-free-roaming/fffr-3-0) mod for GTA 5 Single Player, this mod gives server owners the ability to limit/supress/remove game mechanics not suitable for their target audience, as well as providing features which make the game easier to play for that audience.

This mod was originally developed to provide a child-friendly experience for both of my sons.


## Features

All features can be turned on or off in the config, many have different options to tweak the feature to your liking.

Main features:

* Players and NPCs can be set invincible, with gore and blood removed
* Ability to disable Players and NPCs from being run-down
* Ability to disable Players and NPCs from ragdolling (fall over)
* Can remove of all weapons, make them ineffective, or limit to permitted weapons only
* NPCs can be set to ignore Players (including cops)
* Friendly carjacking - NPCs willingly leave their vehicle to the Player
* Ability to block NPC from carjacking
* All inappropriate ped models can be removed
* All NPC speech can be muted

Extra features:

* Loading screen
* Parental timer - a parent can set a max time the game can be played for. A timer will appear on the screen, on expiry the game will end
* Simple trainer - with options to spawn vehicles, swap the player ped, change the weather, and more
* Teleport to other active players (hotkey or trainer)
* Active player blips and visual markers
* Teleport to waypoint (hotkey or trainer)
* Teleport to your last vehicle (hotkey)
* Clone vehicle (hotkey or trainer)
* Simple emote (hotkey) - plays one of several select emotes on each press
* Simple taxi - when the player presses their horn (/ defined hotkey), NPCs will enter their vehicle and after a while will pay for their ride and leave
* Enter an NPC's vehicle as a passenger
* Change time and weather
* Quick spawn vehicles (hotkey)



## Support
### Discord

For updates, support and suggestions, join the [Discord](https://discord.gg/e3eXGTJbjx).


## Installation

* Download the [latest release](https://github.com/92jackson/fivem-kid-friendly-mod/releases)
* Copy ``` FiveM-Kid-Friendly ``` to your ``` resource ``` folder
* Add the following to your server.cfg:

```bash
  start FiveM-Kid-Friendly
```

* **The mod requires a game build version of 2189 or higher (this is NOT  the same as your FX Server version), if you haven't already, also set the following in your server.cfg:**
```
set sv_enforceGameBuild 2189
```

## FAQ

#### **Q1:** Can I run this mod locally without running a server?

**A1:** While it is possible to run scripts in FiveM without a server environment, it's not recommended. Check out the following guides to get a local server set up on your PC (accessible by computers on your local network):

* Local server with split-screen/dual screen support:
    - [YouTube - video guide](https://youtu.be/BvIIO0J50Zk)
    - [Reddit - written guide](https://www.reddit.com/r/nucleuscoop/comments/t18dfa/comment/hyee5nd/?utm_source=share&utm_medium=web2x&context=3)
* Local server only: [YouTube - video guide](https://youtu.be/YmW9K6GjY9w)

#### **Q2:** I run a FiveM server, can I use this script online?

**A2:** Yes, ~~it will work. But be warned, this script was intended for local host use and therefore does not employ any anti-cheat/hack preventions, given that this script is intended to provide a safe gaming experience for children, I highly recommend that you look into adding safety nets via a third party script(s).~~

As of version 0.2.1, there are anti-cheat/hack preventions, see ```NETWORK_PROTECTION``` in the ```config.lua``` to prevent players spawning in inappropriate vehicles/peds/objects, and to ensure they're not tampering with the client script.
