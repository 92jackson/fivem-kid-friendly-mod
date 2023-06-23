---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------ver0.2---
-- KID FRIENDLY MOD for FiveM by Jackson92 --------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Github:	https://github.com/92jackson/fivem-kid-friendly-mod -----------------------------------
-- Discord: https://discord.gg/e3eXGTJbjx (join for support, feedback, fixes, updates etc) --------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- PLEASE THOROUGHLY TEST BEFORE ALLOWING YOUR CHILDREN TO PLAY.
-- THIS SCRIPT WILL UNLIKELY EVER REMOVE 100% OF ALL ADULT CONTENT (THERE'S JUST TOO MUCH OF IT!)
--   Join our ^Discord^ if you discover any bugs/have any issues, or have any requests/suggestions.
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
CONFIG = {
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
----START OF CONFIG--------------------------------------------------------------------------------
-----READ ME!--------------------------------------------------------------------------------------
--	Most config options are enabled with "true" and disabled with "false", others have numerical
--	values, in which case the comment beside each config will detail the valid numerical values.
--
--
----KEYBINDS/HOTKEYS:
--	This CONFIG also allows you to define keybinds for the custom functions available in this script.
--
--	Keyboard keybind configs:		".._keyboard_hotkey"
--	Controller keybind configs:		".._controller_hotkey"
--		For controller keybind configs with the suffix "_combo_1" and "_combo_2", these act as
--		2 individual hotkeys which must be held at the same time to run the function. If you only
--		require one hotkey, just leave the value for "_combo_2" empty.
--
--	Keybind configs act as the DEFAULT key values, meaning that regardless of what you set 
--	them as in this config, they can be changed by the user in their GTA settings afterwards.
--	If you wish to force a new default keybind, you MUST change the value of CONFIG.HOTKEY_VER
--	in order to push the updated keybind (simply changing the relevant hotkey config value
--	is not enough) - this however should be done sparingly to prevent annoyance to your users, as 
--	this will revert any customisations they have made to their keybinds!
--
--	Controller valid input parameters:
--		https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/pad_digitalbutton/
--
--	Keyboard valid input parameters:
--		https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
--
--
----N.B.
--	Configs which are indented (	) rely on the result of the previous config (owning function).
--	Keybinds only function if their owning function is enabled (there is no need to delete
--		individual keybindings in order to disable a function, just disable the owning function).
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
----CONTENTS:				LINE #		PURPOSE
--		PLAYERS				71			Local and online player related
--		NPC					111			NPCs and how they interact with the players
--		POLICE				145			Police NPCs and how they react to the players
--		WEAPONS				153			Weapon handelling
--		VEHICLES			180			Player and NPC vehicle related
--		WORLD				227			Time, weather, blood pools, ambient sounds and area access
--		NETWORK				283			Data handelling from online players
--		NETWORK_PROTECTION	258			Protection against players using models which they shouldn't
--		TRAINER				267			In-built simple trainer, with simple spawning and other tasks
--		PARENTAL			292			In-built game timer to restrict game-play time by parents
--		LOADING_SCREEN		300			In-built loading screen
--		DEBUG				307			Shows debug messages in the client/server console
--		HOTKEY_VER			308			Update if wanting to force changes to keybinds
--		
--		SPAWN_ITEMS			311			Vehicle and ped models available to TRAINER + NETWORK_PROTECTION
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--	Active players (local/online humans connected)
	PLAYERS = {
		invincible = true, -- Make players invincible. If PLAYERS.prevent_ragdoll_flags.disable_all is "false", invincibility is emulated by attempting to keep the peds health and armour at 100%
		clear_injuries = true, -- Attempts to keep player's ped clean of blood, injuries and marks
		cant_carjack = true, -- Stops players and NPCs from being able to carjack the player's car
		disable_close_combat = true, -- Disables punching and kicking, see CONFIG.WEAPONS for weapon handling/blocking. Has no effect if CONFIG.WEAPONS.prevent_all_aim_fire is set true
		disable_duck_and_cover = true, -- Prevents the player from being able to use the take cover button
		prevent_middle_finger = true, -- Disables the player from using the middle finger while in vehicle
		stick_to_vehicle = true, -- Prevents the player falling off bikes
		auto_parachute = true, -- Give the player a parachute if falling (works sometimes - v0.2)
		no_low_stamina = true, -- Run forever without getting tired
		random_spawn_ped = true, -- At first spawn, randomly assign player a ped from SPAWN_ITEMS.PEDS
		ped_quick_change = true, -- Quick change to a new ped model from the SPAWN_ITEMS.PEDS list with the press of a hotkey (while not in a vehicle)
			ped_quick_change_controller_hotkey_combo_1 = "LLEFT_INDEX", -- (D-PAD LEFT)
			ped_quick_change_controller_hotkey_combo_2 = "",
			ped_quick_change_keyboard_hotkey = "",
		disable_idle_cam = true, -- Disable automatic camera movement on idle
		prevent_ragdoll_flags = {
			disable_all = true, -- MOST ACCURATE. Any ragdoll animation looks violent, this will prevent all ragdoll animations. Settings below are only used if this is set false.
			
			-- The following flags work by trying to intercept the relevant event and bypassing ragdolling
			-- These may not work all the time (if at all) on player peds(?)
			_prevent_on_fire = true,
			_prevent_on_explosion = true,
			_prevent_run_down = true,
			_prevent_when_shot = true,
			
			-- The following flags prevent ragdoll by forcing the ped as invincible during the events
			_prevent_in_vehicle = true,
			
			-- The following flags prevent ragdoll by teleporting the ped immediately to the same position
			_prevent_when_falling = true,
			_prevent_when_leaving_moving_vehicle = true
		},
		allow_simple_emote = true, -- Plays one of a few select child friendly emotes while not in a vehicle
			simple_emote_controller_hotkey_combo_1 = "LRIGHT_INDEX", -- (D-PAD RIGHT)
			simple_emote_controller_hotkey_combo_2 = "",
			simple_emote_keyboard_hotkey = "NUMPAD0" -- (NUMPAD 0)
	},
	
--	Non-player characters
	NPC = {
		spawn_density_multiplier = 0.8, -- 0.0 to 1.0. Controls how many NPC peds spawn. 1.0 is GTA base game
		spawn_density_multiplier_scenario = 0.0, -- 0.0 to 1.0. Controls number of NPC scenarios
		invincible = true, -- Make NPCs invincible. If NPC.prevent_ragdoll_flags.disable_all is "false", invincibility is emulated by attempting to keep the peds health and armour at 100%
		clear_injuries = true, -- Attempts to keep ped clean of blood, injuries and marks
		ignore_players = 2, -- 0 = Off/default, 1 = NPCs sometimes act startled if driving on the path, 2 = NPCs will not get scared or agitated at all
		gangs_leave_alone = true, -- Gangs will not hassle the players
		stop_speaking = 2, -- 0 = Off/default, 1 = No NPC speech, 2 = No NPC speech and no pain sounds
		stick_to_vehicle = true, -- Prevents the NPC falling off bikes
		auto_parachute = true, -- Give the ped a parachute if falling
		cant_carjack = false, -- Stops players from being able to take any NPC occupied vehicle
		prevent_visual_carjack = 3, -- 0 = Off/default, 1 = Delete NPC to prevent drag-out animation, 2 = Delete the NPC and teleport into the seat (MOST RELIABLE), 3 = NPC leaves the vehicle on their own and player walks to seat (most visually pleasing, but will sometimes still drag-out), 4 = Like 3, but even more friendly (buggy v0.2)
			prevent_visual_carjack_passngers = true, -- Only effective if CONFIG.NPC.prevent_visual_carjack is true. Prevents drag-out animation if the player's target seat is the driver's seat, but they enter from the passenger side
		cant_target = false, -- Prevents the player from being able to target the NPC
		prevent_evasive_driving = true, -- Prevents NPCs from driving off at speed
		non_combat = true, -- Prevents NPCs from attacking/retaliating. NPCs will always run off unless PLAYERS.ignore_players is set to "2"
		del_disturbing_peds = true, -- Deletes any inappropriate NPC peds
		del_minimal_clothing_peds = true, -- Deletes any NPC peds which have little clothing (only wearing small bikinis/underwear)
		prevent_ragdoll_flags = {
			disable_all = true, -- MOST ACCURATE. Any ragdoll animation looks violent, this will prevent all ragdoll animations. Settings below are only used if this is set false.
			
			-- The following flags work by trying to intercept the relevant event and bypassing ragdolling 
			_prevent_on_fire = true,
			_prevent_on_explosion = false,
			_prevent_run_down = true,
			_prevent_when_shot = false,
			
			-- The following flags prevent ragdoll by forcing the ped as invincible during the events
			_prevent_in_vehicle = true,
			_prevent_when_falling = true
		},
		replace_peds = 1 -- 0 = Off, 1 = Replace all NPC, 2 = Replace disturbing and minimal clothing NPCs only. Replace NPC models with random models from the SPAWN_ITEMS.PEDS list
	},
	
--	Police NPCs
	POLICE = {
		max_wated_level = 0, -- 0 to 6. Sets the max wanted level for players
		spawn_police = false, -- Spawns random police, if POLICE.max_wanted_level is 0 the police will not react to the player
		ignore_players = true, -- If POLICE.max_wanted_level is more than 0 but this is "true", police will be dispatched to the area but will not attempt to arrest
		spawn_police_scenarios = false -- Spawns random police scenarios
	},
	
--	Weapons
	WEAPONS = {
		-- Handheld weapons
		prevent_all_aim_fire = true, -- Prevents aiming or firing any handheld weapon, or from using close combat (punching/kicking)
		remove_all_weapons = 2, -- 0 = NPCs and Players can have weapons, 1 = NPC weapons removed, 2 = NPC and Player weapons removed
		prevent_weapon_pickups = true, -- Disables players from collecting shotgun pickups from police cars
		make_weapons_ineffective = true, -- Weapons take no health points
		restrict_to_permitted_only = true, -- Only the weapons listed below will be allowed
			permitted_weapons = {
				-- Weapon list: https://vespura.com/fivem/weapons/stats/
				"weapon_snowball",
				"weapon_ball",
				"weapon_flashlight",
				"weapon_raypistol",
				"weapon_fireextinguisher",
				"weapon_flare"
			},
			auto_allocate_permitted = true, -- Give all permitted weapons to players
		
		-- Vehicle weapons
		disable_vehicle_weapons = 1, -- 0 = No vehicle weapons are disabled, 1 = Allow permitted vehicles only (listed below), 2 = Disable all vehicle weapons
		permitted_vehicle_weapons = {
			-- Vehicle list: https://docs.fivem.net/docs/game-references/vehicle-models/
			"firetruk", -- Fire Truck water cannon
		}
	},
	
--	Vehicles
	VEHICLES = {
		spawn_density_multiplier = 0.8, -- 0.0 to 1.0. Controls how many vehicles spawn, 1.0 is GTA base game
		spawn_density_multiplier_parked = 1.0, -- 0.0 to 1.0. Controls how many parked vehicles spawn
		spawn_density_multiplier_scenario = 1.0, -- 0.0 to 1.0. Controls number of vehicle scenarios (NPCs driving etc)
		spawn_boats = true, -- Allows random boats to spawn in water
		all_unlocked = true, -- All vehicles are unlocked to players
		no_hotwire = true, -- Parked vehicles dont require hotwiring by players
		invincible = 2, -- 0 = No vehicles are invincible, 1 = Player occupied vehicles are invincible, 2 = All vehicles are invincible
			invincible_keep_damage_physics = true, -- Only useful for keeping vehicle impact physics while the vehicle is invincible (to allow the vehicle to react to weapons such as the ray pistol)
		repair_damage = 1, -- 0 = No change, 1 = Player occupied vehicles repaired every 10sec, 2 = All vehicles repaired
		keep_clean = 1, -- 0 = No change, 1 = Cleans dirt (inc blood) on player occupied vehicles every 10sec, 2 = Dirt cleaned on all vehicles
		disable_radio = 2, -- 0 = Off/default, 1 = Disables player vehicle radios, 2 = Disables player and NPC vehicle radios
			radio_driver_only = false, -- The radio is only played for the driver of a player vehicle and disabled for all passenger players. This is usful in split-screen gaming to overcome mismatched radio stations. Ignored if VEHICLES.disable_radio is > 0
		muted_sirens = 2, -- 0 = Off/default, 1 = Player sirens are muted, 2 = Player and NPC sirens are muted, 3 = NPC sirens are muted
		max_spawned_per_player = 15, -- To prevent flooding the game, after the player has spawned/cloned this number, old spawned will be deleted at a rate of 1 per second. If the player managed to spawn in 5 over this number, extras will be deleted all at once
		show_vehicle_speed = " MPH", -- MPH or KPH, leave blank to disable. It will display however you write it, for example " M/ph" will display "26 M/ph", "MPH" will display as "26MPH"
		disable_cinematic_cam = true, -- Disables cinematic mode, automatic or by pressing B
		lock_player_vehicle_colour = false, -- Lock the player's vehicle colour to their favorite colour (set below)
			lock_primary_colour_to = "pink", -- Set the colour for the above: red, green, blue, black, white, yellow, pink, purple, orange, grey, light_pink, light_green, light_blue, light_grey
			also_lock_secondary_colour = true, -- Also match the vehicle's secondary colours when changing vehicle's primary colour
		taxi_npcs = true, -- Players pressing their horn (hotkey changeable below) will invite NPCs into free seats in their vehicle
			taxi_npcs_call_controller_hotkey = "L3_INDEX", -- (L3) -- Call NPCs to get in the vehicle as passengers
			taxi_npcs_call_keyboard_hotkey = "LSHIFT", -- (LEFT SHIFT) -- As above
			taxi_npcs_leave_controller_hotkey = "RLEFT_INDEX", -- (X) -- Pressing will force all passengers to leave the vehicle. If same key as CONFIG.VEHICLES.taxi_npcs_call_controller_hotkey, leave will be called when pressed after vehicle is full
			taxi_npcs_leave_keyboard_hotkey = "SUBTRACT", -- (NUMPAD MINUS) -- As above. If same key as CONFIG.VEHICLES.taxi_npcs_call_keyboard_hotkey, leave will be called when pressed after vehicle is full
			taxi_drop_off = true, -- Passenger NPCs will leave the player's vehicle when stopped at a rate of 1 NPC every 30 seconds with a 70% chance of leaving
		clone_vehicles = true, -- Creates a clone of the player's current vehicle with the hotkey set below, useful if a player wants a copy of a network player's vehicle
			clone_vehicle_controller_hotkey_combo_1 = "LDOWN_INDEX", -- (D-PAD DOWN)
			clone_vehicle_controller_hotkey_combo_2 = "",
			clone_vehicle_keyboard_hotkey = "C", -- (C)
			teleport_inside_spawned = true, -- Affects cloned vehicles and ones spawned via the trainer
			match_cloned_vehicle_speed = true, -- Spawn cloned vehicle moving at the same speed as the original
		teleport_to_last_vehicle = true, -- With the hotkey(s) set below, the player can teleport into their last vehicle while on foot
			teleport_to_last_vehicle_controller_hotkey_combo_1 = "RRIGHT_INDEX", -- (B)
			teleport_to_last_vehicle_controller_hotkey_combo_2 = "",
			teleport_to_last_vehicle_keyboard_hotkey = "L", -- (L)
		quick_spawn_new = true, -- Spawn a new vehicle from the SPAWN_ITEMS.VEHICLES list with the press of a hotkey (while not in a vehicle)
			quick_spawn_controller_hotkey_combo_1 = "R1_INDEX", -- (RB)
			quick_spawn_controller_hotkey_combo_2 = "",
			quick_spawn_keyboard_hotkey = "Q", -- (Q)
		enter_as_passenger = true, -- With the use of a hotkey set below, this allows you to enter the closest vehicle as a passenger. Only works for non-police cars and motorbikes while not already inside a vehicle
			enter_passenger_controller_hotkey_combo_1 = "L3_INDEX", -- (L3)
			enter_passenger_controller_hotkey_combo_2 = "",
			enter_passenger_keyboard_hotkey = "NUMPADENTER" -- (NUMPAD ENTER)
	},
	
--	Time, weather, blood pooling, ambient sounds and door locks
	WORLD = {
		lock_time_to_hour = -4, -- -4 = Off/default, -3 = Faster days, really fast nights (BUGGED!!! v0.2.2), -2 = Faster days and nights,  -1 = Match the player's time of day, 0 - 23 = Locked to set hour of day
		lock_weather = "", -- BLIZZARD, CLEAR, CLEARING, CLOUDS, EXTRASUNNY, FOGGY, HALLOWEEN, NEUTRAL, OVERCAST, RAIN, SMOG, SNOW, SNOWLIGHT, THUNDER, XMAS
		disable_ambient_speech = true, -- Disables non-ped speech (such as phone call audio) and other ambient world audio
		prevent_blood_pools = true, -- Blood pools are inevitable if ragdolling is enabled, this tries to remove them as they appear
		remove_adult_interiors = false, -- (NON-FUNCTIONING - v0.2) Removes adult interirors listed in WORLD.interiors_doors_to_restrict
		lock_adult_doors = true, -- Prevents doors from opening to interirors listed in WORLD.interiors_doors_to_restrict
			interiors_doors_to_restrict = {"stripclub", "ammunation", "liquor", "tattoo", "drugs", "misc"} -- Options: "stripclub", "ammunation", "liquor", "tattoo", "drugs", "misc"
	},
	
--	Markers, blips and teleports. These only apply to active network players
	NETWORK = {
		online_player_count = true, -- Show a count of active (non-ghosted) players near the mini-map
		players_are_friendly = true, -- Prevents players from shooting each other (if weapons are enabled)
		active_player_blips = true, -- Show all active players as blips on the map
			nearby_blips_only = false, -- Only show active players which are nearby on the mini-map
			outline_nearby_blips = true, -- Shows a blue circle around nearby player blips
		show_static_line_marker = true, -- Shows a straight red line beaming up from each player's ped to the sky
			nearby_line_markers_only = false, -- Only draw static line markers for nearby players
		show_animated_marker = true, -- Shows a particle effect above nearby active players/their vehicle
		show_gamertag_above_ped = true, -- Show player's gamertag above their ped's head
			gamertag_format = "[PLAYER] %GAMERTAG%", -- Used for blips and gamertags above player peds, "%GAMERTAG%" will be replaced with the player's gamertag/steam name, any other text will show as plain text, for example: "[PLAYER] %GAMERTAG% (:"  shows as "[PLAYER] Jacko92 (:"
		show_chevron_above_ped = true, -- Show an arrow above players head
		allow_teleport_to_player = true, -- Teleport to a random active player with the hotkey set below
			teleport_player_controller_hotkey_combo_1 = "LUP_INDEX", -- (D-PAD UP)
			teleport_player_controller_hotkey_combo_2 = "",
			teleport_player_keyboard_hotkey = "T", -- (T)
			teleport_match_vehicle_speed = true -- When teleporting with a vehicle to a player also in a vehicle, this will match their current speed
	},
	
--	Conditions handelled server-side to ensure players aren't spawning innopropiate peds/vehicles/objects
	NETWORK_PROTECTION = {
		auto_kick = true, -- Kick the player if they stop client side scripts (thus disabling the child friendly modifications)
		spawn_protection = true, -- Prevents players being able to spawn in vehicles/objects/peds via 3rd party trainers
		trusted_ped_models_only = true, -- Only allow the player to change to a ped model from SPAWN_ITEMS.PEDS. Requires PLAYERS.random_spawn_ped to be true to be fully effective against players spawning in with un-trusted models
		disable_known_inappropriate_ped_models = true -- Prevents players from trying to swap to base-game inappropriate ped models
	},
	
--	A simple trainer with the main intention of simple vehicle spawning and ped swapping
----	Add the vehicles and peds available in the trainer to the table SPAWN_ITEMS below
	TRAINER = {
		allow_trainer = true, -- Active/deactive the trainer
			trainer_toggle_controller_hotkey_combo_1 = "LRIGHT_INDEX", -- (D-PAD RIGHT)
			trainer_toggle_controller_hotkey_combo_2 = "RLEFT_INDEX", -- (X)
			trainer_toggle_keyboard_hotkey = "F7", -- (F7)
			show_vehicle_spawn = true, -- Show the vehicle spawner in the trainer, only vehicles listed in SPAWN_ITEMS.VEHICLES will be shown
				show_vehicle_colour_picker = true, -- Show a list of colours to change the player's current vehicle to
				show_teleport_inside_spawned_check = true, -- Show a checkbox which controls CONFIG.VEHICLES.teleport_inside_spawned
			show_ped_swap = true, -- Show the player ped swap option in the trainer, only peds listed in SPAWN_ITEMS.PEDS will be shown
			show_change_weather = true, -- Show a weather picker. Changes only affect the local player 
			show_change_time = true, -- Show a time picker. Changes only affect the local player 
			show_teleport_to_waypoint = true, -- Show a shortcut to teleport to your waypoint set in the map
			show_teleport_to_player = false, -- Show a shortcut to teleport to a random active player
			show_clone_vehicle = false, -- Show an option to clone your current(/sat inside) vehicle
			show_this_config = false, -- FOR TESTING PURPOSES ONLY!! Shows boolean configs only (true/fale) and CONFIG.TRAINER configs are excluded. Changes to the CONFIG via the trainer are temporary and per client. Not all configs are hot-swappable
			allow_ghost_to_others = true, -- Show an option allowing the player to make themselves invisible to other active players (ghost)
			allow_parental_controls = true, -- Show an option to set a game timer (more options below in CONFIG.PARENTAL)
				parental_access_controller_hotkey_combo_1 = "R2_INDEX", -- (RT) -- Hotkey must be held while using the controls in the parental menu. If this and the following 2 hotkeys are left blank, the user will be able to use all parental controls without any verification
				parental_access_controller_hotkey_combo_2 = "L2_INDEX", -- (LT)
				parental_access_keyboard_hotkey = "RSHIFT", -- (RIGHT SHIFT)
				parental_show_force_pause_option = true -- Show a force pause command in the trainer which will backout all active player screens and pause the set timer
	},
	
--	Parental controls, accessable via the trainer
----	To disable completely, see CONFIG.TRAINER.allow_parental_controls
	PARENTAL = {
		timer_server_wide = false, -- CAUTION, this should only be used on LOCAL servers!! This will make all set timer, pause timer, and cancel timer events sync with all connected players
		timer_allow_pause_break = true, -- Players pausing their game will pause the set timer (if the player starts navigating the pause menu - for example, starts checking the map, the timer will resume)
		timer_end_with_blackout = true, -- Blackout the screen when the timer runs out
		timer_interval_warnings = true -- Flash the remaining time in the middle of the screen at intervals when close to tine running out
	},

--	Loading screen	
	LOADING_SCREEN = {
		loading_screen_enabled = true, -- If false, also comment out "loadscreen 'loadscreen/load.html'" in the fxmanifest.lua
		-----------------------------------------------------------------
		-- FOR LOADING SCREEN CUSTOMISATION, CHECK: loadscreen/config.js
		-----------------------------------------------------------------
	},
	
	DEBUG = 3, -- 0 = Off (only messages printed are player join and leave), 1 = Prints all debug messages (server + client), 2 = Prints all server debug messages, 3 = Prints important server messages only (recommended for normal use)
	HOTKEY_VER = "_ver1" -- If you wish to force an update on your server's keybinds, you MUST change this value (keep in mind, if users have customised their keybinds in GTA's settings, this will also revert those back to your set defaults)
}

SPAWN_ITEMS = {
-----------------------------------------------------------------------
-- SPAWN ITEMS --------------------------------------------------------
-----------------------------------------------------------------------
-- The following tables contain Vehicle and Ped models used by the
-- Trainer spawners, this should work with both stock models and addons
-----------------------------------------------------------------------
-- Format:
--		model_name = "Display Name"
-----------------------------------------------------------------------
	
	-- https://docs.fivem.net/docs/game-references/vehicle-models/
	VEHICLES = {
		ambulance = "Ambulance",
		firetruk = "Fire engine",
		police = "Police car",
		bus = "Bus",
		zentorno = "Sports car",
		stretch = "Limo",
		scarab3 = "Caterpillar tracks",
		marshall = "Monster truck",
		bruiser3 = "Monster car",
		openwheel1 = "F1 car",
		veto2 = "Go cart",
		dune4 = "Ramp car",
		raptor = "3 wheeler",
		ruiner2 = "Spy car",
		thruster = "Jet pack",
		vigilante = "Batmobile",
		sanchez = "Dirt bike",
		hakuchou = "Sports bike",
		zombieb = "Chopper bike",
		oppressor  = "Jet bike",
		shotaro = "Tron bike",
		deluxo = "Flying car",
		blazer5 = "Water quad"
	},
	
	-- https://docs.fivem.net/docs/game-references/ped-models/
	PEDS = {
		a_f_y_runner_01 = "Athletic female",
		ig_fbisuit_01 = "Suited male",
		s_m_m_movspace_01 = "Spaceman",
		s_m_y_fireman_01 = "Fireman",
		s_m_y_marine_03 = "Marine",
		s_m_y_cop_01 = "Police man",
		s_m_m_paramedic_01 = "Paramedic",
		--spidey = "Spiderman",
		--elsa = "Elsa"
	}
}
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- END OF CONFIG ----------------------------------------------------------------------------------
--   Missing a feature you'd like? Join our Discord:  https://discord.gg/e3eXGTJbjx ---------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
