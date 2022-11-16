---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- KID FRIENDLY MOD for FiveM by Jackson92 --------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- PLEASE THOROUGHLY TEST BEFORE ALLOWING YOUR CHILDREN TO PLAY.
-- THIS SCRIPT WILL LIKELY NEVER REMOVE 100% OF ALL ADULT CONTENT (THERE'S JUST TOO MUCH OF IT!)
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
CONFIG = {
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- START OF CONFIG --------------------------------------------------------------------------------
-----READ ME!--------------------------------------------------------------------------------------
-- Most config options are turned ON with "true" and OFF with "false",
--	 others have numerical values, in which case the comment beside
--	 each config will detail the valid numerical values.
--
--	 For configs named "_hotkey_1", valid keys can be found here:
--	 https://docs.fivem.net/docs/game-references/controls/#controls
--	 	"_hotkey_2" configs can be set either as a valid key
--		or as -1 to disable the need of pressing a 2nd key.
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

	-- Active players (local/online humans connected)
	PLAYERS = {
		invincible = 2, -- 0 = Off/default, 1 = Can die from falls and explosions, 2 = Invincible
		clear_injuries = true, -- Attempts to keep player's ped clean of blood, injuries and marks
		clear_weapons = true, -- Strip player of all weapons
		prevent_ragdoll = true, -- Prevents the player's ped from ragdolling
		cant_carjack = true, -- Stops players and NPCs from being able to carjack the player's car
		prevent_firing = true, -- Attemps to prevent all keyboard and controller firing/attack commands
		prevent_middle_finger = true, -- Disables the player from using the middle finger while in vehicle
		prevent_weapon_pickup = true, -- Disables shotgun pickups from police cars
		stick_to_vehicle = true, -- Prevents the player falling off bikes
		auto_parachute = true, -- NON-FUNCTIONING? Give the player a parachute if falling
		no_low_stamina = true, -- Run forever without getting tired
		resurrect_if_dead = true, -- Will bring the player's ped back to life if it dies
		random_spawn_ped = false, -- At first spawn, randomly assign player a ped from SPAWN_ITEMS.PEDS
		simple_emote_hotkey = 52, -- (D-pad left) Plays one of a few select emotes. Set hotkey to -1 to disable
		disable_idle_cam = true -- Disable automatic camera movement on idle
	},
	
	-- Non-player characters
	NPC = {
		spawn_density_multiplier = 1.0, -- 0.0 to 1.0. Controls how many NPC peds spawn. 1.0 is GTA base game
		spawn_density_multiplier_scenario = 0.0, -- 0.0 to 1.0. Controls number of NPC scenarios
		invincible = true, -- Make NPCs invincible
		clear_weapons = true, -- Strip NPC of all weapons
		clear_injuries = true, -- Attempts to keep ped clean of blood, injuries and marks
		prevent_ragdoll = true, -- Prevents the NPC from ragdolling
		ignore_players = 2, -- 0 = Off/default, 1 = NPCs sometimes act startled if driving on the path, 2 = NPCs will not get scared or annoyed at all
		gangs_leave_alone = true, -- Gangs will not hassle the players
		stop_speaking = 2, -- 0 = Off/default, 1 = No NPC speech, 2 = No NPC speech and no pain sounds
		stick_to_vehicle = true, -- Prevents the NPC falling off bikes
		cant_carjack = false, -- Stops players from being able to take any NPC occupied vehicle
		prevent_visual_carjack = 3, -- 0 = Off/default, 1 = Delete NPC to prevent drag-out animation, 2 = Delete the NPC and teleport into the seat (MOST RELIABLE), 3 = NPC leaves the vehicle on their own and player walks to seat (most visually pleasing, but will sometimes still drag-out)
		prevent_visual_carjack_passngers = true, -- Only effective if CONFIG.NPC.prevent_visual_carjack on. Prevents drag-out animation if the player's target seat is the driver's seat, but they enter from the passenger side
		cant_target = true, -- Prevents the player from being able to target the NPC
		prevent_evasive_driving = true, -- Prevents NPCs from driving off at speed
		non_combat = true, -- Prevents NPCs from attacking/retaliating. NPCs will always run off unless PLAYERS.ignore_players is set to "2"
		del_disturbing_peds = true, -- Deletes any inappropriate NPC peds
		del_minimal_clothing_peds = true -- Deletes any NPC peds which have little clothing (only wearing small bikinis/underwear)
	},
	
	-- Police NPCs
	POLICE = {
		max_wated_level = 0, -- 0 to 6. Sets the max wanted level for players
		spawn_police = false, -- Spawns random police, if POLICE.max_wanted_level is 0 the police will not react to the player
		ignore_players = true, -- If POLICE.max_wanted_level is more than 0 but this is "true", police will be dispatched to the area but will not attempt to arrest
		spawn_police_scenarios = false -- Spawns random police chases
	},
	
	-- Vehicles
	VEHICLES = {
		spawn_density_multiplier = 0.8, -- 0.0 to 1.0. Controls how many vehicles spawn, 1.0 is GTA base game
		spawn_density_multiplier_parked = 1.0, -- 0.0 to 1.0. Controls how many parked vehicles spawn
		spawn_density_multiplier_scenario = 1.0, -- 0.0 to 1.0. Controls number of vehicle scenarios (NPCs driving etc)
		spawn_boats = true, -- Allows random boats to spawn in water
		spawn_garbage_trucks = true, -- Allows random garbage trucks to spawn in traffic
		all_unlocked = true, -- All vehicles are unlocked to players to prevent window smash animation
		no_hotwire = true, -- Parked vehicles dont require hotwiring
		invincible = 2, -- 0 = No vehicles are invincible, 1 = Player occupied vehicles are invincible, 2 = All vehicles are invincible
		prevent_damage = 1, -- 0 = No change, 1 = Player occupied vehicles repaired every 10sec, 2 = All vehicles repaired
		keep_clean = 1, -- 0 = No change, 1 = Cleans dirt (inc blood) on player occupied vehicles every 10sec, 2 = Dirt cleaned on all vehicles
		disable_radio = true, -- Disables the player's vehicle radio
		radio_driver_only = false, -- The radio is only played for the driver of the vehicle and disabled for all passenger players. This is usful in split-screen gaming to overcome mismatched radio stations. Ignored if VEHICLES.disable_radio is "true"
		taxi_npcs = true, -- Players pressing their horn (hotkey changeable below) will invite NPCs into free seats in their vehicle
		taxi_drop_off = true, -- Passenger NPCs will leave the player's vehicle when stopped at a rate of 1 NPC every 30 seconds with a 70% chance of leaving
		taxi_npcs_call_hotkey = 86, -- (L3) Call NPCs to get in the vehicle as passengers
		taxi_npcs_leave_hotkey = 99, -- (X) Pressing will force all passengers to leave the vehicle. If same key as CONFIG.VEHICLES.taxi_npcs_call_hotkey, leave will be called when pressed after vehicle is full
		clone_vehicles = true, -- Creates a clone of the player's current vehicle with the hotkey set below, useful if a player wants a copy of a network player's vehicle
		clone_vehicle_hotkey_1 = 20, -- (D-pad down)
		clone_vehicle_hotkey_2 = -1,
		teleport_inside_spawned = true, -- Affects cloned vehicles and ones spawned via the trainer
		match_cloned_vehicle_speed = true, -- Spawn cloned vehicle moving at the same speed as the original
		max_spawned_per_player = 15, -- To prevent flooding the game, after the player has spawned/cloned this number, old spawned will be deleted at a rate of 1 per second. If the player managed to spawn in 5 over this number, extras will be deleted all at once
		show_vehicle_speed = " MPH", -- MPH or KPH, leave blank to disable. It will display however you write it, for example " M/ph" will display "26 M/ph", "MPH" will display as "26MPH"
		disable_cinematic_cam = true, -- Disables cinematic mode, automatic or by pressing B
		lock_player_vehicle_colour = false, -- Lock the player's vehicle colour to their favorite colour (set below)
		lock_primary_colour_to = "", -- Set the colour for the above option
		also_lock_secondary_colour = false, -- Also match the vehicle's secondary colours when changing vehicle's primary colour
		teleport_to_last_vehicle = true, -- With the hotkey(s) set below, the player can teleport into their last vehicle while on foot
		teleport_to_last_vehicle_hotkey_1 = 45, -- (B)
		teleport_to_last_vehicle_hotkey_2 = -1
	},
	
	-- Time and weather
	WORLD = {
		lock_time_to_hour = -2, -- -2 = Off/default, -1 = Match the player's time of day, 0 - 23 = Locked to set hour of day
		lock_weather = "" -- BLIZZARD, CLEAR, CLEARING, CLOUDS, EXTRASUNNY, FOGGY, HALLOWEEN, NEUTRAL, OVERCAST, RAIN, SMOG, SNOW, SNOWLIGHT, THUNDER, XMAS
	},
	
	-- Markers, blips and teleports. These only apply to active network players
	---- "onesync_enabled 0" required in your server.config to work correctly
	---- will fix to work with onesync in future update
	NETWORK = {
		online_player_count = true, -- Show a count of active (non-ghosted) players near the mini-map
		active_player_blips = true, -- Show all active players as blips on the map
		nearby_blips_only = false, -- Only show active players which are nearby on the map
		show_static_line_marker = true, -- Shows a straight red line beaming up from each player's head
		show_animated_marker = true, -- Shows a particle effect above active players/their vehicle
		show_names_above_ped = false, -- Show player names floating above player's head
		show_custom_text_above_ped = false, -- Show some custom text (set below) floating above player's head
		custom_text_above_ped = "Hi", -- The short custom text used if NETWORK.show_custom_text_above_ped is "true"
		show_small_marker_above_ped = true, -- Show an arrow floating above player's head
		allow_teleport_to_player = true, -- Teleport to a random active player with the hotkey set below
		teleport_hotkey_1 = 27, -- (D-pad up)
		teleport_hotkey_2 = -1,
		teleport_match_vehicle_speed = true -- When teleporting with a vehicle and the player being teleported to is also in a vehicle, this will match their current speed
	},
	
	-- A simple trainer with the main intention of simple vehicle spawning and ped swapping
	---- Add the vehicles and peds available in the trainer to the table SPAWN_ITEMS below
	TRAINER = {
		allow_trainer = true, -- Active/deactive the trainer
		trainer_hotkey_1 = 51, -- (D-pad right)
		trainer_hotkey_2 = 22, -- (X)
		show_vehicle_spawn = true, -- Show the vehicle spawner in the trainer, only vehicles listed in SPAWN_ITEMS.VEHICLES will be shown
		show_vehicle_colour_picker = true, -- Show a list of colours to change the player's current vehicle to
		show_teleport_inside_spawned_check = true, -- Show a checkbox which controls CONFIG.VEHICLES.teleport_inside_spawned
		show_ped_swap = true, -- Show the player ped swap option in the trainer, only peds listed in SPAWN_ITEMS.PEDS will be shown
		show_change_weather = true, -- Show a weather picker. Changes only effect the local player 
		show_teleport_to_waypoint = true, -- Show a shortcut to teleport to your waypoint set in the map
		show_teleport_to_player = false, -- Show a shortcut to teleport to a random active player
		show_clone_vehicle = false, -- Show an option to clone your current(/sat inside) vehicle
		show_this_config = false, -- FOR TESTING PURPOSES ONLY! Shows boolean configs only (true/fale) and CONFIG.TRAINER configs are excluded. Changes to the CONFIG via the trainer are temporary and per client (active player)
		allow_ghost_to_others = true, -- NON-FUNCTIONING. Show an option allowing the player to make themselves invisible to other active players (ghost)
		allow_parental_controls = true -- Show an option to set a game timer (more options below in CONFIG.PARENTAL)
	},
	
	-- Parental controls, accessable via the trainer
	---- To disable completely, see CONFIG.TRAINER.allow_parental_controls
	PARENTAL = {
		timer_server_wide = true, -- CAUTION, this should only be used on local servers! This will make all set timer, pause timer, and cancel timer events sync with all connected players
		timer_allow_pause_break = true, -- Player pausing the game will pause the set timer
		timer_end_with_blackout = true, -- Blackout the screen when the timer runs out
		timer_interval_warnings = true, -- Flash the remaining time in the middle of the screen at intervals when close to tine running out
		timer_show_force_pause = true, -- Show a force pause command in the trainer which will backout all active player screens and pause the set timer
		secret_access_hotkey_1 = 24, -- (24RT) NON-FUNCTIONING Hotkey must be held while selecting any of the Parental options in the trainer. -1 disables this function
		secret_access_hotkey_2 = -1 -- (25LT) NON-FUNCTIONING
	},
	
	DEBUG = false -- Prints debug messages to the console (F8)
}

SPAWN_ITEMS = {
-----------------------------------------------------------------------
-- SPAWN ITEMS --------------------------------------------------------
-----------------------------------------------------------------------
-- The following tables contain Vehicle and Ped models used by the
-- Trainer spawners, this should work with both stock models and addons
-----------------------------------------------------------------------
-- Format:
--		model_name = "A display name that the trainer will show"
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
		shotaro = "Tron bike"
	},
	
	-- https://docs.fivem.net/docs/game-references/ped-models/
	PEDS = {
		a_f_y_runner_01 = "Athletic female",
		ig_fbisuit_01 = "Suited male",
		s_m_m_movspace_01 = "Spaceman",
		s_m_y_fireman_01 = "Fireman",
		s_m_y_marine_03 = "Marine",
		s_m_y_cop_01 = "Police man",
		s_m_m_paramedic_01 = "Paramedic"
	}
}
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- END OF CONFIG ----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------