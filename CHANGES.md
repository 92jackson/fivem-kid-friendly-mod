# FiveM Kid Friendly Mod Change List

**v0.2.3**
* Fixed not teleporting inside of spawned vehicles when VEHICLES.teleport_inside_spawned is set true
* Short wait added when spawning new vehicles after purging a previous to help reduce collisions
* Implemented fixes to allow hot-restarts (restarting the script without restarting the server)
* Cloned vehicles no longer forced on to a road if called by quick spawn/spawned without the spawn inside setting
* Fixed locking time to particular hour
* Optimised handling for interior based door locking
* Improved player blip/FX handling
* Fixed mishandling of keyboard hotkeys
* Other bug fixes as per individual file changelogs

**v0.2.2**
* Fixed incorrect handling of dropped network players
* Hotkeys ignored if weapon wheel HUD currently active
* Fixed handling of the "enter vehicle as passenger" function if the driver is a player

**v0.2.1**
* **Supports OneSync** (if you previously used ```set onesync off``` in your server.cfg, change this to ```+set onesync on```)
* Added a fully configurable loading screen
* Added quick vehicle spawner (hotkey - press the set hotkey to cycle through vehicles)
* Enter an NPC's vehicle as a passenger (hotkey)
* Change the time of day and weather via the trainer
* Option to block certain doors from opening (i.e to prevent access to stripclub)
* Many function rewrites to optimise the script, including how hotkeys are handled
* Added protection against players spawning models which go against your server rules
* Failsafe to kick player if they stop this script from running
* Integrated NativeUI as part of the release (no longer a need for a separate resource)
* Fixed screen spinning when trainer opened
* Fixed trainer left and right scroll speed
* Modifiable levels of ped ragdoll prevention
* Better weapon handling, with the option to allow certain weapons
* "Parental hotkeys" fixed to protect the game timer functions
