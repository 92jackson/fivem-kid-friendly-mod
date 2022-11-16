---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- KID FRIENDLY MOD for FiveM by Jackson92 --------------------------------------------------------
-----FOR NORMAL USE, YOU SHOULD NOT NEED TO EDIT PAST THIS POINT!----------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local CONSTANT = {
	DISTURBING_PEDS = {
		GetHashKey("a_m_m_acult_01"),
		GetHashKey("a_f_m_fatcult_01"),
		GetHashKey("mp_m_cocaine_01"),
		GetHashKey("mp_f_cocaine_01"),
		GetHashKey("csb_stripper_01"),
		GetHashKey("csb_stripper_02"),
		GetHashKey("mp_f_stripperlite"),
		GetHashKey("s_f_y_stripper_01"),
		GetHashKey("s_f_y_stripper_02"),
		GetHashKey("s_f_y_stripperlite"),
		GetHashKey("cs_bradcadaver"),
		GetHashKey("u_f_m_corpse_01"),
		GetHashKey("u_f_y_corpse_01"),
		GetHashKey("u_f_y_corpse_02"),
		GetHashKey("u_m_y_corpse_01"),
		GetHashKey("u_m_y_justin"),
		GetHashKey("u_m_y_staggrm_01"),
		GetHashKey("u_m_y_zombie_01")
	},
	
	MIN_CLOTHING_PEDS = {
		GetHashKey("a_f_m_beach_01"),
		GetHashKey("a_f_m_bodybuild_01"),
		GetHashKey("a_f_y_beach_01"),
		GetHashKey("a_f_y_juggalo_01"),
		GetHashKey("a_f_y_topless_01"),
		GetHashKey("a_m_m_beach_02"),
		GetHashKey("a_m_m_tranvest_01"),
		GetHashKey("a_m_y_acult_02"),
		GetHashKey("a_m_y_musclbeac_01"),
		GetHashKey("s_f_y_baywatch_01"),
		GetHashKey("ig_tracydisanto"),
		GetHashKey("u_f_y_danceburl_01"),
		GetHashKey("u_f_y_dancelthr_01"),
		GetHashKey("u_f_y_dancerave_01")
	},
	
	WEATHER = {
		"BLIZZARD",
		"CLEAR",
		"CLEARING",
		"CLOUDS",
		"EXTRASUNNY",
		"FOGGY",
		"HALLOWEEN",
		"NEUTRAL",
		"OVERCAST",
		"RAIN",
		"SMOG",
		"SNOW",
		"SNOWLIGHT",
		"THUNDER",
		"XMAS"
	},
	
	EMOTES = {
		{name = "wave_a", dict = "friends@frj@ig_1"},
		{name = "wave_b", dict = "friends@frj@ig_1"},
		{name = "wave_c", dict = "friends@frj@ig_1"},
		{name = "wave_d", dict = "friends@frj@ig_1"},
		{name = "wave_e", dict = "friends@frj@ig_1"},
		{name = "wave_a", dict = "missmic4premiere"},
		{name = "wave_b", dict = "missmic4premiere"},
		{name = "wave_c", dict = "missmic4premiere"},
		{name = "wave_d", dict = "missmic4premiere"},
		{name = "groovy_thumbs_up", dict = "timetable@mime@ig_2"},
		{name = "thumbs_up", dict = "anim@mp_player_intcelebrationmale@thumbs_up"},
		{name = "slow_clap", dict = "anim@mp_player_intcelebrationmale@slow_clap"},
		{name = "fidget_short_dance", dict = "move_clown@p_m_two_idles@"},
		{name = "fidget_short_dance", dict = "move_clown@p_m_zero_idles@"},
		{name = "mnt_dnc_buttwag", dict = "special_ped@mountain_dancer@monologue_3@monologue_3a"},
		{name = "air_guitar", dict = "anim@mp_player_intcelebrationfemale@air_guitar"},
		{name = "air_synth", dict = "anim@mp_player_intcelebrationfemale@air_synth"},
		{name = "blow_kiss", dict = "anim@mp_player_intcelebrationfemale@blow_kiss"},
		{name = "bring_it_on", dict = "misscommon@response"},
		{name = "jazz_hands", dict = "anim@mp_player_intcelebrationfemale@jazz_hands"},
		{name = "idle_a", dict = "anim@mp_player_intincarsalutestd@ds@"},
		{name = "mp_player_int_peace_sign", dict = "mp_player_int_upperpeace_sign"},
	},
	
	PARTICLES = {
		flare = {name = "exp_grd_flare", dict = "core"},
		clown = {name = "scr_clown_appears", dict = "scr_rcbarry2"},
		firework = {name = "scr_indep_firework_shotburst", dict = "scr_indep_fireworks"},
	},
	
	COLOURS = {
		red = {r = 255, g = 0, b = 0},
		green = {r = 0, g = 255, b = 0},
		blue = {r = 0, g = 0, b = 255},
		black = {r = 0, g = 0, b = 0},
		white = {r = 255, g = 255, b = 255},
		yellow = {r = 255, g = 240, b = 0},
		pink = {r = 255, g = 42, b = 239},
		purple = {r = 143, g = 0, b = 255},
		orange = {r = 255, g = 178, b = 0},
		grey = {r = 142, g = 142, b = 142},
		light_blue = {r = 0, g = 216, b = 255},
		light_pink = {r = 255, g = 160, b = 255},
		light_grey = {r = 220, g = 220, b = 220},
		light_green = {r = 122, g = 255, b = 122},
	},
	
	ParachuteHash = GetHashKey("gadget_parachute")
}

local ClientClock = 0
local TimeRemaining = -1
local TotalTimeAllowed = -1
local TimerIsPaused = false
local PauseMenuActive = false
local PauseMenuIndex = nil
local GameIsForcePaused = false
local TimeIsExpired = false
local TimeExpiredClockRemaining = 60000
local PlayerID = PlayerId()
local PlayerPed = 0
local PlayerVehicle = {is_entering = false, is_inside = false, vehicle = 0, seat = -2}
local LastPlayerVehicle = {vehicle = 0, seat = -2}
local PlayerVehicleChangedThisTick = false
local IsEnteringVehicle = false
local IsTeleporting = false
local VehicleTaxi = 0
local VehicleTaxiFull = false
local VehicleTaxiDropOffClock = 0
local VehicleTaxiDropOffAtNextStop = false
local NetworkPlayerIsEnteringVehicle = {}
local VehiclesSpawned = {}
local PedChangedAtSpawn = false
local DisplayMoney = 0
local FreezePlayer = false
local FullscreenBlackout = false
local Notifications = {}
local InvisibleToNetwork = false
local PedIsInvisible = false
local VehicleIsInvisible = false
local ActivePlayerBlips = {}
local ActivePlayersWithFxAttached = {}
local VehiclesWithFxAttached = {}
local VehicleColourForced = ""
local LastAnim = nil


if CONFIG.PLAYERS.invincible > 0 then SetPlayerInvincible(PlayerID, true) end
SetMaxWantedLevel(CONFIG.POLICE.max_wated_level)
SetPoliceIgnorePlayer(PlayerID, CONFIG.POLICE.ignore_players)
if CONFIG.NPC.ignore_players > 0 then
	SetEveryoneIgnorePlayer(PlayerID, true)
	SetIgnoreLowPriorityShockingEvents(PlayerID, true)
end
SetPlayerCanBeHassledByGangs(PlayerID, not CONFIG.NPC.gangs_leave_alone)
SetDisableAmbientMeleeMove(PlayerID, CONFIG.PLAYERS.prevent_firing)
SetPlayerCanDoDriveBy(PlayerID, not CONFIG.PLAYERS.prevent_middle_finger)


------------------------------
------------------------------
------ CUSTOM NATIVES --------
------------------------------
------------------------------
function RunEveryX(S, ForceFirstRun)
	if ClientClock % S == 0 then return true
	elseif ForceFirstRun and ClientClock == 1 then return true
	else return false end
end

function GetPedVehicleSeat(Ped)
	local vehicle = GetVehiclePedIsIn(Ped, false)
	for i=-2, GetVehicleMaxNumberOfPassengers(vehicle) do
		if(GetPedInVehicleSeat(vehicle, i) == Ped) then return i end
	end
	return -2
end

function IsAnyPlayerInVehicle(Vehicle, IgnoreSelf)
	for i=-1, GetVehicleMaxNumberOfPassengers(Vehicle) do
		local PedInSeat = GetPedInVehicleSeat(Vehicle, i)
		if IsPedAPlayer(PedInSeat) and (not IgnoreSelf or (IgnoreSelf and PedInSeat ~= PlayerPed)) then return true end
	end
	return false
end

function GetVehicleFirstFreeSeat(Vehicle)
	local FirstNpcInSeat = -2
	local MaxPassengers = GetVehicleMaxNumberOfPassengers(Vehicle)
	
	if MaxPassengers > 0 then
		for i=-1, MaxPassengers do
			if IsVehicleSeatFree(Vehicle, i) then
				return i
			elseif not IsPedAPlayer(GetPedInVehicleSeat(Vehicle, i)) and FirstNpcInSeat == -2 then
				FirstNpcInSeat = i
			end
		end
	end
	
	if FirstNpcInSeat ~= -2 then
		DeletePed(GetPedInVehicleSeat(Vehicle, FirstNpcInSeat))
		return FirstNpcInSeat
	end
	
	return -2
end

function GetVehicleAllFreePassengerSeats(Vehicle)
	local FreeSeats = {}
	
	for i=0, GetVehicleMaxNumberOfPassengers(Vehicle) do
		if IsVehicleSeatFree(Vehicle, i) then
			table.insert(FreeSeats, i)
		end
	end
	
	return FreeSeats
end

function GetVehicleAllNpcsInside(Vehicle, ExcludeDriver)
	local NpcSeats = {}
	local StartSeat = -1
	if ExcludeDriver then StartSeat = 0 end
	
	for i = StartSeat, GetVehicleMaxNumberOfPassengers(Vehicle) do
		if not IsVehicleSeatFree(Vehicle, i) and IsPedNpc(GetPedInVehicleSeat(Vehicle, i)) then
			table.insert(NpcSeats, GetPedInVehicleSeat(Vehicle, i))
		end
	end
	
	return NpcSeats
end

function IsVehicleMiniGameAi(Vehicle)
	return false
end

function IsPedMiniGameAi(Ped)
	return false
end

function IsPedNpc(Ped)
	if DoesEntityExist(Ped)
		and not IsEntityDead(Ped)
		and IsEntityAPed(Ped)
		and IsPedHuman(Ped)
		and not IsPedAPlayer(Ped) then return true
	else return false end
end

function GetNearbyPeds(X, Y, Z, Radius, MaxNum)
	local NearbyPeds = {}
	local LoopNum = 0
	
	for key,Ped in pairs(GetGamePool("CPed")) do
		if LoopNum >= MaxNum then break end
		
		if IsPedNpc(Ped) and not IsPedInAnyVehicle(Ped, true) then
		--and not IsEntityPositionFrozen(Ped) then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
				LoopNum = LoopNum +1
			end
		end
	end
	
	return NearbyPeds
end

function CollectNpcPassengers(Vehicle, ForceLeave)
	if GetVehicleMaxNumberOfPassengers(Vehicle) > 0 then
		if VehicleTaxi ~= Vehicle and not ForceLeave then
			VehicleTaxi = Vehicle
			VehicleTaxiFull = false
			d_print("New taxi " .. VehicleTaxi)
			ShowNotification("~g~Taxi in service", false, "taxiservice")
		end
		
		if GetEntitySpeed(Vehicle) < 20 and not VehicleTaxiFull and not ForceLeave then
			local FreeSeats = GetVehicleAllFreePassengerSeats(Vehicle)
			local VehiclePosition = GetEntityCoords(Vehicle, false)
			
			if next(FreeSeats) ~= nil then
				local NearPeds = GetNearbyPeds(VehiclePosition.x, VehiclePosition.y, VehiclePosition.z, 25, math.random(#FreeSeats))
				
				if next(NearPeds) ~= nil then
					local str = " people"
					if #NearPeds == 1 then str = " person" end
					ShowNotification("Taxi called by ~g~" .. #NearPeds .. str)
					
					for i=1, #FreeSeats do
						if NearPeds[i] ~= nil then
							TaskEnterVehicle(NearPeds[i], Vehicle, 10000, FreeSeats[i], 2.0, 1, 0)
							d_print("Taxi seat " .. FreeSeats[i] .. " now occupied.")
						end
					end
				else
					ShowNotification("~r~Taxi not needed here", false, "taxiservice")
				end
			elseif next(FreeSeats) == nil then
				VehicleTaxiFull = true
				d_print("Taxi full!")
				ShowNotification("~y~Taxi is full", false, "taxiservice")
			end
		elseif ForceLeave
			or (CONFIG.VEHICLES.taxi_npcs_call_hotkey == CONFIG.VEHICLES.taxi_npcs_leave_hotkey and VehicleTaxiFull) then
			if VehicleTaxi == Vehicle then ShowNotification("~g~Taxi out of service", false, "taxiservice") end
			
			local FoundNpcs = ForceAllNpcToLeaveVehicle(Vehicle, false)
			if FoundNpcs > 0 then
				ShowNotification("All passengers are leaving")
				
				local RideCost = math.random(30, 150) * FoundNpcs
				DisplayMoney = DisplayMoney + RideCost
				StatSetInt("MP0_WALLET_BALANCE", DisplayMoney, true)
				SetMultiplayerWalletCash()
				
				ShowNotification("You charged them  ~g~$" .. RideCost)
			end
			VehicleTaxi = 0
			VehicleTaxiFull = false
		end
	end
end

function ForceAllNpcToLeaveVehicle(Vehicle, Immediate, ExcludeDriver)
	local NpcsInside = GetVehicleAllNpcsInside(Vehicle, ExcludeDriver)
	
	if next(NpcsInside) ~= nil then
		d_print(#NpcsInside .. " NPCs leaving vehicle  " .. Vehicle)
		
		for key,Ped in pairs(NpcsInside) do
			if Immediate then DeletePed(Ped)
			else
				TaskLeaveVehicle(Ped, Vehicle, 0)
				TaskWanderStandard(Ped, 10.0, 10)
			end
		end
		return #NpcsInside
	end
	return 0
end

function DropNpcPassengerOff(Vehicle)
	if VehicleTaxi == Vehicle then
		local NpcsInside = GetVehicleAllNpcsInside(Vehicle)
		d_print(dump(NpcsInside))
		if next(NpcsInside) ~= nil then
			local Ped = NpcsInside[math.random(#NpcsInside)]
			TaskLeaveVehicle(Ped, Vehicle, 0)
			TaskWanderStandard(Ped, 10.0, 10)
			VehicleTaxiFull = false
			
			local RideCost = math.random(30, 150)
			DisplayMoney = DisplayMoney + RideCost
			StatSetInt("MP0_WALLET_BALANCE", DisplayMoney, true)
			SetMultiplayerWalletCash()
			
			ShowNotification("A passenger is leaving, you charged them  ~g~$" .. RideCost)
		end
	end
end

function EjectAllNpcIfNoPlayer(Vehicle)
	if DoesEntityExist(Vehicle) and not DoesEntityExist(GetPedInVehicleSeat(Vehicle, -1)) then
		ForceAllNpcToLeaveVehicle(Vehicle, false)
	end
end

function FriendlyCarjack(Vehicle, Seat, NpcPedInSeat, NetworkPlayer)
	Citizen.CreateThread(function()
		if CONFIG.NPC.prevent_visual_carjack > 0 then
			if CONFIG.NPC.prevent_visual_carjack ~= 3 then
				if CONFIG.NPC.prevent_visual_carjack_passngers then ForceAllNpcToLeaveVehicle(Vehicle, true)
				else DeletePed(NpcPedInSeat) end
			end -- Delete ped in seat
			if CONFIG.NPC.prevent_visual_carjack == 2 and not NetworkPlayer then TaskEnterVehicle(PlayerPed, Vehicle, 5, Seat, 2.0, 16, 0) end -- Teleport to seat
			if CONFIG.NPC.prevent_visual_carjack == 3 then
				if not IsVehicleStopped(Vehicle) and Seat == -1 then TaskVehicleTempAction(NpcPedInSeat, Vehicle, 6, 2) end
				
				if CONFIG.NPC.prevent_visual_carjack_passngers then ForceAllNpcToLeaveVehicle(Vehicle, false, true) end
				
				if Seat == -1 then
					-- 0 = normal exit and closes door, 1 = normal exit and closes door, 16 = teleports outside, door kept closed, 64 = normal exit and closes door, maybe a bit slower animation than 0, 256 = normal exit but does not close the door, 4160 = ped is throwing himself out, even when the vehicle is still, 262144 = ped moves to passenger seat first, then exits normally  
					TaskLeaveVehicle(NpcPedInSeat, Vehicle, 256)
					
					if not NetworkPlayer then
						while GetVehiclePedIsIn(NpcPedInSeat, false) == Vehicle do
							Citizen.Wait(5) -- Wait for the NPC to get out
						end
						ClearPedTasksImmediately(NpcPedInSeat)
						TaskWanderStandard(NpcPedInSeat, 10.0, 10) -- Prevents npc reclaiming vehicle
						d_print("Forcing NPC previous driver to wander.")
						
						local Timeout = 0
						while GetPedVehicleSeat(PlayerPed) ~= Seat and Timeout < 2000 do
							Citizen.Wait(5)
							Timeout = Timeout + 5
							--d_print(Timeout)
							
							if GetVehiclePedIsEntering(PlayerPed) ~= Vehicle
								and GetVehiclePedIsTryingToEnter(PlayerPed) ~= Vehicle
								and GetVehiclePedIsIn(PlayerPed, false) ~= Vehicle then
									d_print("Task enter vehicle timed out, resending command")
									ClearPedTasksImmediately(PlayerPed)
									TaskEnterVehicle(PlayerPed, Vehicle, 1000, -1, 2.0, 1, 0)
							end
						end
						-- Overcome issue with player ped getting back out once inside jacked vehicle, as well as other issues with getting in vehicle normally
						ClearPedTasksImmediately(PlayerPed)
						TaskWarpPedIntoVehicle(PlayerPed, Vehicle, -1)
						SetVehicleDoorsShut(Vehicle, false)
					end
				end
			end
		end
		PlayerVehicle.is_inside = true
		PlayerVehicle.is_entering = false
		PlayerVehicle.vehicle = Vehicle
		PlayerVehicle.seat = Seat
	end)
end

function IsPlayerAGhost(ActivePlayerPed)
	if CONFIG.TRAINER.allow_ghost_to_others and not IsEntityVisible(ActivePlayerPed) then return true end
	return false
end

function AddPlayerBlip(ActivePlayer)
	if not IsPlayerAGhost(ActivePlayer.ped)
		and not DoesSetContain(ActivePlayerBlips, ActivePlayer.ped) then
		
		local Blip = AddBlipForEntity(ActivePlayer.ped)
		SetBlipSprite(Blip, 480) -- blip ids at -> https://docs.fivem.net/docs/game-references/blips/
		SetBlipDisplay(Blip, 2) -- both: 2 - map only: 3 and 4 - minimap only: 5
		SetBlipScale(Blip, 1.0) -- scale of the blip
		SetBlipColour(Blip, 2) -- colors at -> https://docs.fivem.net/docs/game-references/blips/#BlipColors
		SetBlipAsShortRange(Blip, CONFIG.NETWORK.nearby_blips_only) -- Sets whether or not the specified blip should only be displayed when nearby, or on the minimap
		ShowOutlineIndicatorOnBlip(Blip, true)
		
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName("[PLAYER] " .. GetPlayerName(ActivePlayer.id))
		EndTextCommandSetBlipName(Blip)
		
		AddToSet(ActivePlayerBlips, ActivePlayer.ped, Blip)
	end
end

function AddPlayerVisualIdentifier(ActivePlayer, OnlyDrawLineThisFrame)
	local ActivePlayerVehicle = 0
	
	if not IsPlayerAGhost(ActivePlayer.ped) then
		if OnlyDrawLineThisFrame and CONFIG.NETWORK.show_static_line_marker then
			local coords = GetEntityCoords(ActivePlayer.ped, true)
			DrawLine(coords.x, coords.y, coords.z + 0.0, coords.x, coords.y, coords.z + 100, 255, 0, 0, 200)
		elseif not OnlyDrawLineThisFrame then
			if CONFIG.NETWORK.show_animated_marker then
				if IsPedInAnyVehicle(ActivePlayer.ped, false) then
					ActivePlayerVehicle = GetVehiclePedIsIn(ActivePlayer.ped, false)
				end
				
				local MakeNewFx = false
				if ActivePlayerVehicle > 0 then
					if DoesSetContain(VehiclesWithFxAttached, ActivePlayerVehicle) then
						MakeNewFx = not DoesParticleFxLoopedExist(VehiclesWithFxAttached[ActivePlayerVehicle])
						if MakeNewFx then RemoveFromSet(VehiclesWithFxAttached, ActivePlayerVehicle) end
					else
						MakeNewFx = true
					end
					
					if DoesSetContain(ActivePlayersWithFxAttached, ActivePlayer.ped) then
						if DoesParticleFxLoopedExist(ActivePlayersWithFxAttached[ActivePlayer.ped]) then
							RemoveParticleFx(ActivePlayersWithFxAttached[ActivePlayer.ped], false)
						end
						RemoveFromSet(ActivePlayersWithFxAttached, ActivePlayer.ped)
					end
				else
					if DoesSetContain(ActivePlayersWithFxAttached, ActivePlayer.ped) then
						MakeNewFx = not DoesParticleFxLoopedExist(ActivePlayersWithFxAttached[ActivePlayer.ped])
						if MakeNewFx then RemoveFromSet(ActivePlayersWithFxAttached, ActivePlayer.ped) end
					else
						MakeNewFx = true
					end
				end
				
				if MakeNewFx then
					LoadFxDict(CONSTANT.PARTICLES.flare.dict)
					
					local Entity = ActivePlayer.ped
					if ActivePlayerVehicle > 0 then Entity = ActivePlayerVehicle end
					local Fx = StartParticleFxLoopedOnEntity(CONSTANT.PARTICLES.flare.name, Entity, 0, 0, 3.0, 0, 0, 0, 1.0, false, false, false)
					if ActivePlayerVehicle > 0 then AddToSet(VehiclesWithFxAttached, ActivePlayerVehicle, Fx)
					else AddToSet(ActivePlayersWithFxAttached, ActivePlayer.ped, Fx) end
				end
			end
			
			if CONFIG.NETWORK.show_names_above_ped or CONFIG.NETWORK.show_custom_text_above_ped or CONFIG.NETWORK.show_small_marker_above_ped then
				if not IsMpGamerTagActive(ActivePlayer.id) then
					-- Create gamer tag
					CreateMpGamerTagWithCrewColor(ActivePlayer.id, GetPlayerName(ActivePlayer.id), false, false, CONFIG.NETWORK.custom_text_above_ped, 0, 0, 0, 0)
					SetMpGamerTagVisibility(ActivePlayer.id, 0, CONFIG.NETWORK.show_names_above_ped)
					SetMpGamerTagVisibility(ActivePlayer.id, 21, CONFIG.NETWORK.show_small_marker_above_ped)
					SetMpGamerTagVisibility(ActivePlayer.id, 1, CONFIG.NETWORK.show_custom_text_above_ped)
				end
			end
		end
	else
		if IsMpGamerTagActive(ActivePlayer.id) then RemoveMpGamerTag(ActivePlayer.id) end
	end
end

function PurgePlayerBlips()
	if next(ActivePlayerBlips) ~= nil then
		for ActivePlayerPed, Blip in pairs(ActivePlayerBlips) do
			if IsPlayerAGhost(ActivePlayerPed) or not DoesEntityExist(ActivePlayerPed) then
				if DoesBlipExist(Blip) then RemoveBlip(Blip) end
				ActivePlayerBlips[ActivePlayerPed] = nil
			end
		end
	end
end

function PurgePlayerFx()
	if next(ActivePlayersWithFxAttached) ~= nil then
		for ActivePlayerPed, Fx in pairs(ActivePlayersWithFxAttached) do
			if IsPlayerAGhost(ActivePlayerPed) or not DoesEntityExist(ActivePlayerPed) or not IsPedAPlayer(ActivePlayerPed) then
				if DoesParticleFxLoopedExist(Fx) then RemoveParticleFx(Fx, false) end
				ActivePlayersWithFxAttached[ActivePlayerPed] = nil
			end
		end
	end
	
	if next(VehiclesWithFxAttached) ~= nil then
		for Vehicle, Fx in pairs(VehiclesWithFxAttached) do
			if not IsAnyPlayerInVehicle(Vehicle, true) or not DoesEntityExist(Vehicle) then
				if DoesParticleFxLoopedExist(Fx) then RemoveParticleFx(Fx, false) end
				VehiclesWithFxAttached[Vehicle] = nil
			end
		end
	end
end

function GetNetworkPlayers(MakeRand, ExcludeGhosts)
	local NetworkPlayers = {}
	local ActivePlayers = GetActivePlayers()
	
	if next(ActivePlayers) ~= nil and #ActivePlayers > 1 then
		for key,ActivePlayerId in pairs(ActivePlayers) do
			local ActivePlayerPed = GetPlayerPed(ActivePlayerId)
			if ActivePlayerId ~= PlayerID and (not ExcludeGhosts or (ExcludeGhosts and not IsPlayerAGhost(ActivePlayerPed))) then
				table.insert(NetworkPlayers, {id = ActivePlayerId, ped = ActivePlayerPed})
			end
		end
	end
	
	if next(NetworkPlayers) ~= nil and MakeRand then return Shuffle(NetworkPlayers)
	else return NetworkPlayers end
end

function GetTailPlayerCoords(Ped, ForceOutdoor, TailingEntity)
	local Entity = Ped
	if IsPedInAnyVehicle(Ped, false) then Entity = GetVehiclePedIsIn(Ped, false) end
	TailingEntity = TailingEntity or Entity
	
	local Heading = GetEntityHeading(Entity)
	
	local MinPos, MaxPos = GetModelDimensions(GetEntityModel(Entity))
	local EntityLength = MaxPos.y - MinPos.y
	local MinPosTail, MaxPosTail = GetModelDimensions(GetEntityModel(TailingEntity))
	local TailingEntityLength = MaxPosTail.y - MinPosTail.y
	
	local Offset = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -(TailingEntityLength + (EntityLength/2)+ 2), 3)
	
	if ForceOutdoor and GetInteriorAtCoords(Offset.x, Offset.y, Offset.z) ~= 0 then
		local Retval, OutPosition, OutHeading = GetClosestVehicleNodeWithHeading(Offset.x, Offset.y, Offset.z, 1, 3.0, 0)
		Offset = OutPosition
		Heading = OutHeading
	end
	
	return Offset, Heading
end

function CloneVehicle(ForceModelByName)
	if ForceModelByName ~= nil or IsPedInAnyVehicle(PlayerPed, false) then
		local ModelHash = nil
		if ForceModelByName ~= nil then ModelHash = GetHashKey(ForceModelByName)
		else ModelHash = GetEntityModel(GetVehiclePedIsIn(PlayerPed, false)) end
		
		if IsModelInCdimage(ModelHash) and IsModelValid(ModelHash) then
			RequestModel(ModelHash)
			while not HasModelLoaded(ModelHash) do
				Citizen.Wait(0)
			end
			
			local coords, heading = GetTailPlayerCoords(PlayerPed, true)
			ClearAreaOfVehicles(coords.x, coords.y, coords.z, 10, false, false, false, false, false)
			local SpawnVeh = CreateVehicle(ModelHash, coords.x, coords.y, coords.z, heading, true, false)
			
			if ForceModelByName == nil then
				ShowNotification("Vehicle cloned:   ~g~" .. GetLabelText(GetDisplayNameFromVehicleModel(ModelHash)))
				
				if CONFIG.VEHICLES.match_cloned_vehicle_speed then
					SetVehicleEngineOn(SpawnVeh, true, true, false)
					SetVehicleForwardSpeed(SpawnVeh, GetEntitySpeed(PlayerPed))
				end
			end
			
			if CONFIG.VEHICLES.teleport_inside_spawned then
				EjectAllNpcIfNoPlayer(PlayerVehicle.vehicle)
				ForceVehicleColour(PlayerVehicle.vehicle)
				
				TaskWarpPedIntoVehicle(PlayerPed, SpawnVeh, -1)
				PlayerVehicle.vehicle = SpawnVeh
			end
			
			SetModelAsNoLongerNeeded(ModelHash)
			table.insert(VehiclesSpawned, SpawnVeh)
			
			return true
		end
	end
	
	return false
end

function SetPlayerPed(Model)
	local KeepVehicle = PlayerVehicle.vehicle
	local Seat = PlayerVehicle.seat
	local ModelHash = GetHashKey(Model)
	
	if IsModelInCdimage(ModelHash) and IsModelValid(ModelHash) then
		d_print("Ped model hash found:  " .. ModelHash)
		RequestModel(ModelHash)
		while not HasModelLoaded(ModelHash) do
			Citizen.Wait(0)
		end
		
		SetPlayerModel(PlayerID, ModelHash)
		SetModelAsNoLongerNeeded(ModelHash)
		
		PlayerPed = PlayerPedId()
		if KeepVehicle ~= 0 then TaskEnterVehicle(PlayerPed, KeepVehicle, 5, Seat, 2.0, 16, 0) end
		
		PedIsInvisible = false
		return true
	end
	
	return false
end

function TeleportPlayer(X, Y, Z, Heading, VehicleEntity, IntoVehicleSeat, ConfirmEntityGround)
	X = X or 0
	Y = Y or 0
	Z = Z or 0 
	Heading = Heading or 0
	VehicleEntity = VehicleEntity or 0
	IntoVehicleSeat = IntoVehicleSeat or -2
	ConfirmEntityGround = ConfirmEntityGround or 0
	local WithVehicle = false
	if VehicleEntity > 0 then WithVehicle = true end
	
	BusyspinnerIsOn()
	--DoScreenFadeOut(500)
	--Citizen.Wait(500)
	
	if IntoVehicleSeat > -2 then
		TaskWarpPedIntoVehicle(PlayerPed, VehicleEntity, IntoVehicleSeat)
	else
		StartPlayerTeleport(PlayerID, X, Y, Z, Heading, WithVehicle, true, true)
		while IsPlayerTeleportActive() do
			Citizen.Wait(0)
		end
	end
	
	if DoesEntityExist(ConfirmEntityGround) then
		Citizen.Wait(200)
		local Check = GetEntityCoords(ConfirmEntityGround)
		
		local retval, GroundZ = GetGroundZFor_3dCoord(X, Y, 150.0, false)
		if Check.z < GroundZ then
			SetEntityCoordsNoOffset(ConfirmEntityGround, X, Y, GroundZ, true, false, false)
			d_print("Falling through ground, applying detected Z  " .. GroundZ)
		end
	end
	
	--DoScreenFadeIn(500)
	BusyspinnerOff()
end

function ForcePedInVehicleNow(Ped, Vehicle, Seat)
	Seat = Seat or -1
	
	local PedInSeat = GetPedInVehicleSeat(Vehicle, Seat)
	if IsPedNpc(PedInSeat) then ForceAllNpcToLeaveVehicle(Vehicle, true)
	elseif IsPedAPlayer(PedInSeat) then Seat = GetVehicleFirstFreeSeat(Vehicle) end
	
	if Seat > -2 then TaskWarpPedIntoVehicle(Ped, Vehicle, Seat) end
	Citizen.Wait(500) -- Wait to confirm ped is in vehicle
end

function TeleportToWaypoint()
	local Waypoint = GetFirstBlipInfoId(8)
	
	if Waypoint ~= 0 then
		local Coords = GetBlipCoords(Waypoint)
		local Heading = 0
		local WithVehicle = nil
		local CheckEntity = PlayerPed
		
		if PlayerVehicle.vehicle > 0 and PlayerVehicle.seat == -1 then
			if PlayerVehicle.is_entering then
				ForcePedInVehicleNow(PlayerPed, PlayerVehicle.vehicle)
				d_print("Forcing into vehicle then teleporting")
			end
			
			WithVehicle = PlayerVehicle.vehicle
			CheckEntity = PlayerVehicle.vehicle
			
			if GetInteriorAtCoords(Coords.x, Coords.y, Coords.z) ~= 0 then
				local Retval, OutPosition, OutHeading = GetClosestVehicleNodeWithHeading(Coords.x, Coords.y, Coords.z, 1, 3.0, 0)
				Coords = OutPosition
				Heading = OutHeading
				
				d_print("Interior at Waypoint detected, moving position to nearest road/path")
			end
		end
		
		ShowNotification("~g~Teleporting to waypoint", false, "teleportwaypoint")
		TeleportPlayer(Coords.x, Coords.y, Coords.z, Heading, WithVehicle, -2, CheckEntity)
		
		return true
	end
	ShowNotification("~r~No waypoint set", true, "teleportwaypoint")
	return false
end

function IsPlayerNearby(ActivePlayerPed)
	if IsPedInAnyVehicle(ActivePlayerPed, false) and (GetVehiclePedIsIn(ActivePlayerPed, false) == PlayerVehicle.vehicle) then return true
	elseif IsPedInAnyVehicle(ActivePlayerPed, false) and not PlayerVehicle.is_inside then return false end
	
	local PlayerPos = GetEntityCoords(PlayerPed, false)
	local ActivePlayerPos = GetEntityCoords(ActivePlayerPed, false)
	
	if Vdist(PlayerPos.x, PlayerPos.y, PlayerPos.z, ActivePlayerPos.x, ActivePlayerPos.y, ActivePlayerPos.z) <= 5 then return true end
	
	return false
end

function GetVehiclePedIsInOrEntering(Ped)
	local PedVehicle = {is_entering = false, is_inside = false, vehicle = 0, seat = -2}
	
	if IsPedInAnyVehicle(Ped, false) then
		PedVehicle.is_inside = true
		PedVehicle.vehicle = GetVehiclePedIsIn(Ped, false)
		PedVehicle.seat = GetPedVehicleSeat(Ped)
		
		if PlayerPed == Ped then
			LastPlayerVehicle.vehicle = 0
			LastPlayerVehicle.seat = -2
		end
	elseif DoesEntityExist(GetVehiclePedIsTryingToEnter(Ped)) then
		PedVehicle.is_entering = true
		PedVehicle.vehicle = GetVehiclePedIsTryingToEnter(Ped)
		PedVehicle.seat = GetSeatPedIsTryingToEnter(Ped)
	end
	
	if PlayerPed == Ped and (PlayerVehicle.is_entering or PlayerVehicle.is_inside) then
		if PlayerVehicle.is_inside and PlayerVehicle.vehicle ~= 0 and PlayerVehicle.vehicle ~= PedVehicle.vehicle then
			LastPlayerVehicle.vehicle = PlayerVehicle.vehicle
			LastPlayerVehicle.seat = PlayerVehicle.seat
			PlayerVehicleChangedThisTick = true
			
			d_print("New vehicle recorded: " .. dump(PedVehicle))
			d_print("Last vehicle recorded: " .. dump(LastPlayerVehicle))
		end
	end
	
	return PedVehicle
end

function TeleportToPlayer()
	if not IsTeleporting then
		IsTeleporting = true
		
		local hasTeleported = false
		local alreadyWithActivePlayer = false
		local NetworkPlayers = GetNetworkPlayers(true, true)
		
		d_print("Looking for active network players to teleport to.")
		d_print(dump(NetworkPlayers))
		
		if next(NetworkPlayers) ~= nil then
			for key,RandPlayer in pairs(NetworkPlayers) do
				if not IsPlayerNearby(RandPlayer.ped) then
					if PlayerVehicle.vehicle > 0 and PlayerVehicle.seat == -1 then
						d_print("Teleporting with vehicle to active player's location.")
						
						if PlayerVehicle.is_entering then ForcePedInVehicleNow(PlayerPed, PlayerVehicle.vehicle) end
						
						local coords, heading = GetTailPlayerCoords(RandPlayer.ped, true, PlayerVehicle.vehicle)
						TeleportPlayer(coords.x, coords.y, coords.z, heading, PlayerVehicle.vehicle)
						
						if CONFIG.NETWORK.teleport_match_vehicle_speed and IsPedInAnyVehicle(RandPlayer.ped, false) then
							SetVehicleEngineOn(PlayerVehicle.vehicle, true, true, false)
							SetVehicleForwardSpeed(PlayerVehicle.vehicle, GetEntitySpeed(RandPlayer.ped))
						end
						
						hasTeleported = true
					end
					if IsPedInAnyVehicle(RandPlayer.ped, false) and not hasTeleported then
						local vehIn = GetVehiclePedIsIn(RandPlayer.ped, false)
						local firstFreeSeat = GetVehicleFirstFreeSeat(vehIn)
						
						if firstFreeSeat > -2 then
							d_print("Teleporting to active player's vehicle.")
							TeleportPlayer(nil, nil, nil, nil, vehIn, firstFreeSeat)
							hasTeleported = true
						end
					end
					if not hasTeleported then
						d_print("Teleporting to active player's location.")
						
						local coords, heading = GetTailPlayerCoords(RandPlayer.ped, false, PlayerPed)
						TeleportPlayer(coords.x, coords.y, coords.z, heading)
						hasTeleported = true
					end
					
					if hasTeleported then
						ShowNotification("Teleported to:   ~g~" .. GetPlayerName(RandPlayer.id), false, "teleportplayer")
						break
					end
				else
					alreadyWithActivePlayer = true
				end
			end
			
			if not hasTeleported and alreadyWithActivePlayer then
				ShowNotification("~r~You're already close to the only available active player(s)", true, "teleportplayer")
			end
		else
			d_print("No active network players found to teleport to.")
			ShowNotification("~r~No players found to teleport to", true, "teleportplayer")
		end
		
		IsTeleporting = false
	end
end

function VehicleLimitDamage(Vehicle, OccupiedPedType)
	-- OccupiedPedType: 1 = Player, 2 = Player + NPC
	
	if CONFIG.VEHICLES.invincible == OccupiedPedType then
		SetEntityInvincible(Vehicle, true)
		SetDisableVehicleEngineFires(Vehicle, true)
		SetDisableVehiclePetrolTankDamage(Vehicle, true)
	end
	
	if CONFIG.VEHICLES.prevent_damage == OccupiedPedType then
		SetVehicleCanBeVisiblyDamaged(Vehicle, false)
		SetDisableVehicleWindowCollisions(Vehicle, true)
	end
end

function IsVehicleVisibilyDamaged(Vehicle)
	if IsVehicleDamaged(Vehicle) then return true end
	if not AreAllVehicleWindowsIntact(Vehicle) then return true end
	return false
end

function VehicleRepairDamage(Vehicle, OccupiedPedType)
	-- OccupiedPedType: 1 = Player, 2 = Player + NPC
		
	if CONFIG.VEHICLES.prevent_damage == OccupiedPedType then
		if IsVehicleVisibilyDamaged(Vehicle) then
			SetVehicleFixed(Vehicle)
		end
	end
	
	if CONFIG.VEHICLES.keep_clean == OccupiedPedType and GetVehicleDirtLevel(Vehicle) > 0.0 then
		WashDecalsFromVehicle(Vehicle, 1.0)
		SetVehicleDirtLevel(Vehicle, 0.0)
	end
end

function IsComboControlKeysSet(KeyOne, KeyTwo)
	if KeyOne ~= -1 or KeyTwo ~= -1 then return true end
	return false
end

function IsComboControlJustPressed(KeyOne, KeyTwo)
	if not IsComboControlKeysSet(KeyOne, KeyTwo) then return false end
	if IsControlJustPressed(1, KeyOne) and (KeyTwo == -1 or IsControlPressed(1, KeyTwo)) then return true end
	if IsControlJustPressed(1, KeyTwo) and (KeyOne == -1 or IsControlPressed(1, KeyOne)) then return true end
	return false
end

function IsComboControlPressed(KeyOne, KeyTwo)
	if IsComboControlKeysSet(KeyOne, KeyTwo) then return false end
	if IsControlPressed(1, KeyOne) and (KeyTwo == -1 or IsControlPressed(1, KeyTwo)) then return true end
	if IsControlPressed(1, KeyTwo) and (KeyOne == -1 or IsControlPressed(1, KeyOne)) then return true end
	return false
end

function ShowNotification(Text, Important, Set)
	Important = Important or false
	
	if Set and DoesSetContain(Notifications, Set) then
		if Notifications[Set] > 0 then ThefeedRemoveItem(Notifications[Set]) end
		RemoveFromSet(Notifications, Set)
	end
	
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Text)
	
	local NotificationId = EndTextCommandThefeedPostTicker(Important, Important)
	if Set then AddToSet(Notifications, Set, NotificationId) end
end

function SendParentalEvent(Event, Value)
	if CONFIG.PARENTAL.timer_server_wide then
		TriggerServerEvent(Event, Value)
		return true
	end
	return false
end

function UpdatePlayerTimer(TimeTable)
	local Reason = TimeTable["reason"]
	local Time = TimeTable["time_remaining"]
	local OldTime = TimeTable["old_time"]
	TimerIsPaused = TimeTable["is_paused"]
	GameIsForcePaused = TimeTable["force_pause"]
	
	if Reason == "newtimer" then
		ShowNotification("New game timer set for ~g~" .. MilisecondsToMin(Time) .. " minutes", true, "timer")
		TotalTimeAllowed = -1
		TimeIsExpired = false
		TimeExpiredClockRemaining = 60000
	elseif Reason == "timerextended" then
		ShowNotification("Game timer extended to ~g~" .. MilisecondsToMin(Time) .. " minutes", true, "timer")
		TimeIsExpired = false
		TimeExpiredClockRemaining = 60000
	elseif Reason == "canceltimer" then
		ShowNotification("~y~Game timer has been cancelled", true, "timer")
		TotalTimeAllowed = -1
		TimeIsExpired = false
		TimeExpiredClockRemaining = 60000
	elseif Reason == "pausestate" then
		if TimerIsPaused then ShowNotification("~y~The timer has been paused", true, "timer")
		else ShowNotification("Timer resuming with ~g~" .. MilisecondsToMin(Time) .. " minutes ~s~remaining", true, "timer") end
	elseif Reason == "forcepause" then
		if GameIsForcePaused then ShowNotification("~r~The game and timer has been force paused", true, "timer")
		else ShowNotification("Timer resuming with ~g~" .. MilisecondsToMin(Time) .. " minutes ~s~remaining", true, "timer") end
	elseif Reason == "timeexpiried" then
		TimeIsExpired = true
	else
		-- Server side refresh only
	end
	
	TimeRemaining = Time
	if TimeRemaining > TotalTimeAllowed then TotalTimeAllowed = TimeRemaining end
end

RegisterNetEvent("SyncTimer")
AddEventHandler("SyncTimer", function(Time)
	d_print("Timer set by the server  " .. dump(Time))
	
	UpdatePlayerTimer(Time)
end)

function DisplayProgressBar(CurrentVal, MaxVal, PosX, PosY, Width, Height, Justification, ColourFg, ColourBg, Alpha)
	MaxVal = MaxVal or 100
	PosX = PosX or 0.5
	PosY = PosY or 0.0
	Width = Width or 1.0
	Height = Height or 0.05
	Justification = Justification or 0 -- 0 = Center, 1 = Left, 2 = Right
	ColourBg = ColourBg or CONSTANT.COLOURS.black
	Alpha = Alpha or 200
	
	local PercentRemaining = (CurrentVal / MaxVal) * 100
	local GreenHighToLow = 255
	local RedLowToHigh = 0
	if ColourFg == nil then
		if PercentRemaining <= 50 then
			local PercentageRed = ((PercentRemaining - 25) / 50) * 100
			RedLowToHigh = math.floor(255 - ((255 / 50) * PercentageRed))
			if RedLowToHigh > 255 then RedLowToHigh = 255 end
		end
		if PercentRemaining <= 25 then
			local PercentageGreen = ((PercentRemaining / 25) * 100)
			GreenHighToLow = math.floor((255 / 100) * PercentageGreen)
			if GreenHighToLow < 0 then GreenHighToLow = 0 end
		end
	end
	
	ColourFg = ColourFg or {r = RedLowToHigh, g = GreenHighToLow, b = 0}
	--d_print(dump(ColourFg))
	
	if Justification == 2 then PosX = PosX - (Width / 2)
	elseif Justification == 1 then PosX = PosX + (Width / 2) end
	
	local Progress = (Width / MaxVal) * CurrentVal
	local ProgressXOffset = PosX - ((Width - Progress) / 2)
	
	DrawRect(PosX, PosY, Width, Height, ColourBg.r, ColourBg.g, ColourBg.b, Alpha)
	DrawRect(ProgressXOffset, PosY, Progress, Height, ColourFg.r, ColourFg.g, ColourFg.b, Alpha)
end

function IsTimerWithinWindow(Times)
	for key, Time in pairs(Times) do
		local TimeToMili = MinToMiliseconds(Time)
		
		if TimeRemaining < TimeToMili + 2000
			and TimeRemaining > TimeToMili - 2000 then
			return true, Time
		end
	end
	return false, MilisecondsToMin(TimeRemaining)
end

function DisplayGamePlayTimer()
	local Flash = false
	local Prompt = false
	local WithinWindow, Mins = IsTimerWithinWindow({30, 15, 5, 1})
	local SetBannerColour = nil
	
	if Mins ~= MilisecondsToMin(TotalTimeAllowed) then
		if WithinWindow then
			Flash = true
			Prompt = true
			
			if Mins == 15 then SetBannerColour = CONSTANT.COLOURS.yellow
			elseif Mins == 5 then SetBannerColour = CONSTANT.COLOURS.orange
			elseif Mins == 1 then SetBannerColour = CONSTANT.COLOURS.red end
		end
		
		if Mins <= 2 then Flash = true end
	end
	
	if TimeRemaining > 0 and not GameIsForcePaused then
		local TimerColour = CONSTANT.COLOURS.white
		local BarColour = nil
		
		if Flash and RunEveryX(2) then
			TimerColour = CONSTANT.COLOURS.red
			BarColour = CONSTANT.COLOURS.red
		end
		
		DisplayScreenText(MiliToTimeString(TimeRemaining), 0.95, 0.78, 0.45, 2, 0, TimerColour, 255, 0, true)
		DisplayProgressBar(TimeRemaining, TotalTimeAllowed, 0.95, 0.9, 0.2, 0.04, 2, BarColour)
		
		if Prompt and CONFIG.PARENTAL.timer_interval_warnings then
			local TimeWarnTitle, TimeWarnString = "Attention:", "~r~" .. Mins .. " minutes ~l~remaining."
			if Mins == 1 then TimeWarnTitle, TimeWarnString = "~r~Warning:", "~r~" .. math.floor(TimeRemaining / 1000) .. " seconds ~l~remaining." end
			DisplayFullScreenAlert(nil, TimeWarnTitle, TimeWarnString, false, SetBannerColour)
		end
	elseif TimeRemaining == 0 and TimeExpiredClockRemaining > 0 then
		TimeIsExpired = true
		local HeaderString, SubheaderString, BodyString = nil, "Game over", "Your timer has expired."
		if CONFIG.PARENTAL.timer_end_with_blackout then HeaderString, SubheaderString, BodyString = "Game over", "Your timer has expired", "The game will shutdown in  ~r~" .. math.floor(TimeExpiredClockRemaining / 1000) .. " seconds~l~." end
		DisplayFullScreenAlert(HeaderString, SubheaderString, BodyString, CONFIG.PARENTAL.timer_end_with_blackout, CONSTANT.COLOURS.red)
	end
	
	if CONFIG.PARENTAL.timer_end_with_blackout and TimeExpiredClockRemaining == 0 then
		DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 255)
		FullscreenBlackout = true
	end
	
	if GameIsForcePaused then
		DisplayFullScreenAlert("Game paused", "It's time to take a break.", "Your remaining timer has been paused at  ~g~" .. Mins .. " minutes~l~.", true)
	end
	
	if FullscreenBlackout then
		SetFreezePlayer(true)
	elseif not FullscreenBlackout and FreezePlayer then
		SetFreezePlayer(false)
	end
end

function DisplayScreenText(Text, X, Y, Scale, Justification, Font, Colour, Alpha, Shaddow, Outline)
	X = X or 0.0
	Y = Y or 0.0
	Scale = Scale or 1.0
	Justification = Justification or 1 -- 0 = Center, 1 = Left, 2 = Right
	Font = Font or 0 -- 0 = Default, 1 = Script, 7 = GTA
	Colour = Colour or CONSTANT.COLOURS.white
	Alpha = Alpha or 255
	Shaddow = Shaddow or 0
	Outline = Outline or false
	
	if Justification == 2 then
		SetTextWrap(0.0, X)
		X = 0.0
	end
	
	SetTextScale(Scale, Scale)
	SetTextJustification(Justification)
	SetTextFont(Font)
	SetTextColour(Colour.r, Colour.g, Colour.b, Alpha)
	SetTextDropshadow(Shaddow, 0, 0, 0, Alpha)
	if Outline then SetTextOutline() end
	
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(Text)
	EndTextCommandDisplayText(X, Y)
end

function DisplayFullScreenAlert(Title, Subtitle, Body, Blackout, BannerBorder)
	if Blackout then DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 255) end
	
	local Opacity = 180
	if Blackout then Opacity = 255 end
	
	if BannerBorder ~= nil then
		DrawRect(0.5, 0.52, 1.0, 0.14, BannerBorder.r, BannerBorder.g, BannerBorder.b, Opacity)
	end
	DrawRect(0.5, 0.52, 1.0, 0.12, CONSTANT.COLOURS.light_grey.r, CONSTANT.COLOURS.light_grey.g, CONSTANT.COLOURS.light_grey.b, Opacity)
	
	if Title ~= nil then DisplayScreenText(Title, 0.5, 0.35, 1.5, 0, 7, CONSTANT.COLOURS.white, 255, 0, true) end
	if Subtitle ~= nil then DisplayScreenText(Subtitle, 0.5, 0.475, 1.0, 0, 1, CONSTANT.COLOURS.black) end
	if Body ~= nil then DisplayScreenText(Body, 0.5, 0.525, 0.45, 0, 0, CONSTANT.COLOURS.black) end
	
	if Blackout then FullscreenBlackout = true end
end

function SetFreezePlayer(Freeze)
	FreezeEntityPosition(PlayerPed, Freeze)
	if PlayerVehicle.is_inside and PlayerVehicle.seat == -1 then FreezeEntityPosition(PlayerVehicle.vehicle, Freeze) end
	FreezePlayer = Freeze
end

function DisplaySpeedo()
	if CONFIG.VEHICLES.show_vehicle_speed ~= "" and not FullscreenBlackout then
		local Speed = math.floor(GetEntitySpeed(PlayerVehicle.vehicle) * 2.236936) -- MPH
		if string.lower(CONFIG.VEHICLES.show_vehicle_speed):gsub("%W", "") == "kph" then Speed = math.floor(Speed * 1.609344) end -- KPH
		
		DisplayScreenText("~h~" .. Speed .. "~h~" .. CONFIG.VEHICLES.show_vehicle_speed, 0.18, 0.855, 1.2, nil, 1, nil, nil, true)
	end
end

function DisplayOnlineCount()
	if CONFIG.NETWORK.online_player_count and not FullscreenBlackout then
		DisplayScreenText(TableLength(ActivePlayerBlips) +1 .. " online", 0.18, 0.94, 0.2)
	end
end

function DisplayCoords()
	if not FullscreenBlackout then
		local PedPosition = GetEntityCoords(PlayerPed, false)
		local CurrentVehicleName = ""
		if PlayerVehicle.is_inside then CurrentVehicleName = ", Vehicle: " .. GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(PlayerVehicle.vehicle))) end
		DisplayScreenText("X: " .. string.format("%.3f", PedPosition.x) .. " Y: " .. string.format("%.3f", PedPosition.y) .. " Z: " .. string.format("%.3f", PedPosition.z) .. CurrentVehicleName, 0.18, 0.96, 0.2)
	end
end

function LoadFxDict(Dict)
	while not HasNamedPtfxAssetLoaded(Dict) do
		RequestNamedPtfxAsset(Dict)
		Citizen.Wait(5)
	end
	UseParticleFxAssetNextCall(Dict)
end

function LoadAnimDict(Dict)
	while not HasAnimDictLoaded(Dict) do
		RequestAnimDict(Dict)
		Citizen.Wait(5)
	end
end

function AnimatePed(Ped, Emote)
	if Emote == nil then
		if LastAnim ~= nil then
			if IsEntityPlayingAnim(Ped, LastAnim.dict, LastAnim.name, 3) then
				--ClearPedTasks()
				d_print("Stopping emote:  " .. dump(LastAnim))
				StopAnimTask(Ped, LastAnim.dict, LastAnim.name, 1.0)
			end
			LastAnim = nil
		end
	else
		AnimatePed(Ped, nil)
		d_print("Emote called:  " .. dump(Emote))
		
		LoadAnimDict(Emote.dict)
		TaskPlayAnim(Ped, Emote.dict, Emote.name, 1.0, -1.0, 5000, 120, 1, false, false, false)
		LastAnim = Emote
	end
end

function ForceVehicleColour(Vehicle, Colour, IncludeSecondary)
	if Colour then
		SetVehicleCustomPrimaryColour(Vehicle, Colour.r, Colour.g, Colour.b)
		if IncludeSecondary then SetVehicleCustomSecondaryColour(Vehicle, Colour.r, Colour.g, Colour.b) end
	else
		if VehicleColourForced ~= "" then
			ClearVehicleCustomPrimaryColour(Vehicle)
			ClearVehicleCustomSecondaryColour(Vehicle)
			VehicleColourForced = ""
		end
	end
end
------------------------------
------------------------------
---- CUSTOM NATIVES END ------
------------------------------
------------------------------

------------------------------
------------------------------
---- BASIC LUA FUNCTIONS -----
------------------------------
------------------------------
function MinToMiliseconds(Min)
	return (Min * 60) * 1000
end

function MilisecondsToMin(Mili)
	return math.ceil((Mili / 1000) / 60)
end

function MiliToTimeString(Miliseconds)
	local MiliToSeconds = Miliseconds/1000
	local Hours = math.floor(math.fmod(MiliToSeconds, 86400)/3600)
	local Minutes = math.floor(math.fmod(MiliToSeconds,3600)/60)
	local Seconds = math.floor(math.fmod(MiliToSeconds,60))
	
	return ("~h~%d~h~ hours~n~~h~%d~h~ minutes~n~~h~%d~h~ seconds"):format(Hours, Minutes, Seconds)
end

function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

function AddToSet(set, key, value)
	if value == nil then set[key] = true
	else set[key] = value end
end

function RemoveFromSet(set, key)
	set[key] = nil
end

function DoesSetContain(set, key)
	return set[key] ~= nil
end

function Shuffle(T)
	for i = #T, 2, -1 do
		local j = math.random(i)
		T[i], T[j] = T[j], T[i]
	end
	return T
end

function TableLength(T)
	local Count = 0
	for _ in pairs(T) do Count = Count +1 end
	return Count
end

function d_print(S)
	if CONFIG.DEBUG then print(S) end
end
------------------------------
------------------------------
-- BASIC LUA FUNCTIONS END ---
------------------------------
------------------------------


------------------------------
------------------------------
-- NATIVEUI FUNCTIONS START --
------------------------------
------------------------------
local NativeUIMenuItems = {}
function AddMenuItem(Menu, ItemName, Type, Data, Description, Disabled, RightLabel)
	ItemName = ItemName or "------------------------"
	Type = Type or 0
	Data = Data or {id = nil, value = nil}
	Description = Description or ""
	Disabled = Disabled or false
	
	if type(Data) == "string" then Data = {id = Data, value = nil} end
	
	local MenuItem = nil
	if Type == 1 then MenuItem = NativeUI.CreateListItem(ItemName, Data.value, 1)
	elseif Type == 2 then MenuItem = NativeUI.CreateCheckboxItem(ItemName, Data.value, Description)
	else
		MenuItem = NativeUI.CreateItem(ItemName, Description)
		if RightLabel then MenuItem:RightLabel(RightLabel) end
	end
	
	if Disabled then MenuItem:Enabled(false)
	else AddToSet(NativeUIMenuItems, MenuItem, Data) end
	
	Menu:AddItem(MenuItem)
	return MenuItem
end

function AddMenuVehicles(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Vehicles")
	
	if CONFIG.TRAINER.show_vehicle_colour_picker then
		local Colours = {}
		for Colour, RGB in pairs(CONSTANT.COLOURS) do
			local ColourName = Colour:gsub("%W", " ")
			table.insert(Colours, ColourName)
		end
		AddMenuItem(submenu, "Change colour of your vehicle", 1, {id = "vehiclecolourselect", value = Colours})
		
		submenu.OnListChange = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "vehiclecolourselect" then
					colourIndex = (item:IndexToItem(index)):gsub("%W", "_")
					if CONFIG.VEHICLES.lock_player_vehicle_colour then CONFIG.VEHICLES.lock_primary_colour_to = colourIndex
					else VehicleColourForced = colourIndex end
					
					ShowNotification("Your vehicle colour will be changed to:  ~g~" .. colourIndex, false, "vehiclecolour")
				end
			end
		end
		
		AddMenuItem(submenu, "Lock colour to all Player Vehicles?", 2, {id = "lockcolour", value = CONFIG.VEHICLES.lock_player_vehicle_colour}, "Apply the colour set above to all cars the player enters.")
		AddMenuItem(submenu, "Use colour as the Vehicle's Secondary Colour?", 2, {id = "locksecondary", value = CONFIG.VEHICLES.also_lock_secondary_colour}, "Apply the colour set abovee to the vehicle's secondary coloured parts.")
	end
	
	if CONFIG.TRAINER.show_teleport_inside_spawned_check then
		local checkitem = AddMenuItem(submenu, "Teleport inside Spawned Vehicles?", 2, {id = "teleportinside", value = CONFIG.VEHICLES.teleport_inside_spawned}, "Teleport inside of newly spawned vehicles? Also affects cloned vehicles!")
	end
	
	submenu.OnCheckboxChange = function(sender, item, checked_)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id == "lockcolour" then
				CONFIG.VEHICLES.lock_player_vehicle_colour = checked_
				ShowNotification("Lock Vehicle Colour?   ~y~" .. tostring(checked_))
			elseif GetItem.id == "locksecondary" then
				CONFIG.VEHICLES.also_lock_secondary_colour = checked_
				ShowNotification("Secondary Colour matched?   ~y~" .. tostring(checked_))
			elseif GetItem.id == "teleportinside" then
				CONFIG.VEHICLES.teleport_inside_spawned = checked_
				ShowNotification("Teleport inside Spawned Vehicles?   ~y~" .. tostring(checked_))
			end
		end
	end
	
	AddMenuItem(submenu, "------- Spawn a Vehicle -------", 0, nil, nil, true)
	
	if next(SPAWN_ITEMS.VEHICLES) ~= nil then
		for model,name in pairs(SPAWN_ITEMS.VEHICLES) do
			AddMenuItem(submenu, name, 0, {id = "spawnvehicle", value = model}, "Spawn vehicle: " .. model)
		end
		
		submenu.OnItemSelect = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "spawnvehicle" then
					local spawned = CloneVehicle(GetItem.value)
					if spawned then ShowNotification("Spawned:  ~g~" .. SPAWN_ITEMS.VEHICLES[GetItem.value]) end
				end
			end
		end
	else
		AddMenuItem(submenu, "NO VEHICLES ADDED IN SPAWN_ITEMS!", 0, nil, "Edit the SPAWN_ITEMS table in this script's config.lua to add vehicles.", true)
	end
end

function AddMenuPlayerModel(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Character Models")
	AddMenuItem(submenu, "------- Change your Character -------", 0, nil, nil, true)
	
	if next(SPAWN_ITEMS.PEDS) ~= nil then
		for model,name in pairs(SPAWN_ITEMS.PEDS) do
			AddMenuItem(submenu, name, 0, {id = "playerped", value = model}, "Change player model to: " .. model)
		end
		
		submenu.OnItemSelect = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "playerped" then
					local pedSet = SetPlayerPed(GetItem.value)
					if pedSet then ShowNotification("Player model changed to:  ~g~" .. SPAWN_ITEMS.PEDS[GetItem.value], false, "playerped") end
				end
			end
		end
	else
		AddMenuItem(submenu, "NO PEDS ADDED IN SPAWN_ITEMS!", 0, nil, "Edit the SPAWN_ITEMS table in this script's config.lua to add peds.", true)
	end
end

function AddMenuGameTimer(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Parental Controls")
	
	AddMenuItem(submenu, "Set/append game timer", 0, "starttimer", "Start/append the timer by 15 minutes each time clicked.", false, "+15 mins")
	AddMenuItem(submenu, "Cancel current game timer", 0, "canceltimer", "Cancel the set timer.")
	AddMenuItem(submenu, "Force toggle pause player(s)", 0, "forcepausetoggle", "Blackout the screen and pause the running timer.")
	
	submenu.OnItemSelect = function(sender, item, index)
		--if not IsComboControlKeysSet(CONFIG.PARENTAL.secret_access_hotkey_1, CONFIG.PARENTAL.secret_access_hotkey_2)
		--	or IsComboControlPressed(CONFIG.PARENTAL.secret_access_hotkey_1, CONFIG.PARENTAL.secret_access_hotkey_2) then
			local GetItem = NativeUIMenuItems[item]
		
			if GetItem ~= nil then
				if GetItem.id == "starttimer" then
					if not SendParentalEvent("SetTimer", MinToMiliseconds(1)) then
						local Reason = "newtimer"
						local Time = MinToMiliseconds(15)
						if TimeRemaining > 0 then
							Reason = "timerextended"
							Time = Time + TimeRemaining
						end
						
						UpdatePlayerTimer({
							reason = Reason,
							time_remaining = Time,
							old_time = TimeRemaining,
							is_paused = TimerIsPaused,
							force_pause = GameIsForcePaused
						})
					end
				elseif TimeRemaining > 0 then
					if GetItem.id == "canceltimer" then
						if not SendParentalEvent("SetTimer", -1) then
							UpdatePlayerTimer({
								reason = "canceltimer",
								time_remaining = -1,
								old_time = TimeRemaining,
								is_paused = TimerIsPaused,
								force_pause = GameIsForcePaused
							})
						end
					elseif GetItem.id == "forcepausetoggle" then
						if not SendParentalEvent("ForcePausePlayers", not GameIsForcePaused) then
							UpdatePlayerTimer({
								reason = "forcepause",
								time_remaining = TimeRemaining,
								old_time = TimeRemaining,
								is_paused = TimerIsPaused,
								force_pause = not GameIsForcePaused
							})
						end
					end
				else
					ShowNotification("~r~No game timer is set!", true, "timer")
				end
			end
		--else
		--	ShowNotification("~r~~h~Access denied!", true, "timer")
		--end
	end
end

function AddMenuConfig(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Modify Config")
	
	local ConfigListItems = {}
	local ConfigListSets = {}
	for setName,configs in pairs(CONFIG) do
		if type(configs) == "table" and setName ~= "TRAINER" then			
			AddMenuItem(submenu, "------- " .. setName .. " -------", 0, nil, nil, true)
			
			for config,val in pairs(configs) do
				if tostring(val) == "true" or tostring(val) == "false" then
					local newsubitem = NativeUI.CreateCheckboxItem(config, val, "")
					submenu:AddItem(newsubitem)
					AddToSet(ConfigListSets, newsubitem, setName)
					AddToSet(ConfigListItems, newsubitem, config)
				end
			end
			
			submenu.OnCheckboxChange = function(sender, item, checked_)
				local GetConfigSet = ConfigListSets[item]
				local GetConfig = ConfigListItems[item]
				d_print(item)
				d_print(GetConfig)
				d_print(GetConfigSet)
				
				if GetConfigSet ~= nil and GetConfig ~= nil then
					CONFIG[GetConfigSet][GetConfig] = checked_
					ShowNotification("~y~" .. GetConfigSet .. " : " .. GetConfig .. " ~s~changed to:   ~y~" .. tostring(checked_))
				end
			end
		end
	end
end

if CONFIG.TRAINER.allow_trainer then
	_menuPool = NativeUI.CreatePool()
	mainMenu = NativeUI.CreateMenu("FiveM Kid Friendly", "~b~Trainer")
	_menuPool:Add(mainMenu)
	
	if CONFIG.TRAINER.show_vehicle_spawn then AddMenuVehicles(mainMenu) end
	if CONFIG.TRAINER.show_ped_swap then AddMenuPlayerModel(mainMenu) end
	
	AddMenuItem(mainMenu, nil, 0, nil, nil, true)
	
	if CONFIG.TRAINER.show_change_weather then AddMenuItem(mainMenu, "Change local weather", 1, {id = "changeweather", value = CONSTANT.WEATHER}) end
	if CONFIG.TRAINER.show_teleport_to_waypoint then AddMenuItem(mainMenu, "Teleport to Waypoint", 0, "teleportwaypoint", "Teleport to your waypoint (set waypoint first).") end
	if CONFIG.TRAINER.show_teleport_to_player then AddMenuItem(mainMenu, "Teleport to an Active Player", 0, "teleportplayer", "Teleport to a random player currently in the server.") end
	if CONFIG.TRAINER.show_clone_vehicle then AddMenuItem(mainMenu, "Clone your Current Vehicle", 0, "clonevehicle", "Clone the vehicle that you're currently inside.") end
	if CONFIG.TRAINER.allow_ghost_to_others then AddMenuItem(mainMenu, "Become a Ghost", 0, "ghostmode", "You will be invisible to active players and will not show up on the map.") end
	
	AddMenuItem(mainMenu, nil, 0, nil, nil, true)
	
	if CONFIG.TRAINER.allow_parental_controls then AddMenuGameTimer(mainMenu) end
	if CONFIG.TRAINER.show_this_config then AddMenuConfig(mainMenu) end
	
	_menuPool:ResetCursorOnOpen(true)
	_menuPool:RefreshIndex()
	
	mainMenu.OnItemSelect = function(sender, item, index)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id == "teleportwaypoint" then TeleportToWaypoint()
			elseif GetItem.id == "teleportplayer" then TeleportToPlayer()
			elseif GetItem.id == "clonevehicle" then CloneVehicle()
			elseif GetItem.id == "ghostmode" then
				InvisibleToNetwork = not InvisibleToNetwork
				ShowNotification("Invisible to active players?  ~y~" .. tostring(InvisibleToNetwork), true, "ghostmode")
			end
		end
	end
	
	mainMenu.OnListChange = function(sender, item, index)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id  == "changeweather" then
				weatherIndex = item:IndexToItem(index)
				
				SetWeatherOwnedByNetwork(false)
				SetWeatherTypeNowPersist(weatherIndex)
				CONFIG.WORLD.lock_weather = weatherIndex
				ShowNotification("Weather changed to:  ~g~" .. weatherIndex, false, "weatherselect")
			end
		end
	end
end
------------------------------
------------------------------
--- NATIVEUI FUNCTIONS END ---
------------------------------
------------------------------


------------------------------
------------------------------
------ LOOPING THREADS -------
------------------------------
------------------------------
Citizen.CreateThread(function()
	print("FiveM-Kid-Friendly initalised.")
	ShowNotification("Welcome to ~n~FiveM ~g~K~y~i~r~d ~o~F~p~r~q~i~b~e~c~n~r~d~y~l~g~y ~s~(:")
	
	while true do
		Citizen.Wait(0) -- Prevent crashing, repeat every tick
		PlayerPed = PlayerPedId()
		PlayerVehicle = GetVehiclePedIsInOrEntering(PlayerPed)
		
		if CONFIG.TRAINER.allow_trainer then
			_menuPool:ProcessMenus()
			--_menuPool:ControlDisablingEnabled(false)
			
			if IsComboControlJustPressed(CONFIG.TRAINER.trainer_hotkey_1, CONFIG.TRAINER.trainer_hotkey_2) then
				mainMenu:Visible(not mainMenu:Visible())
			end
		end
		
		FullscreenBlackout = false
		DisplayGamePlayTimer()
		DisplayOnlineCount()
		DisplayCoords()
		
		if CONFIG.PLAYERS.invincible == 2 then SetEntityInvincible(PlayerPed, true) end
		if CONFIG.PLAYERS.clear_injuries then
			ResetPedVisibleDamage(PlayerPed)
			ClearPedBloodDamage(PlayerPed, true)
		end
		
		if (CONFIG.PLAYERS.resurrect_if_dead or CONFIG.PLAYERS.invincible == 2) and IsPedDeadOrDying(PlayerPed, 1) then
			ResurrectPed(PlayerPed)
		end
		
		SetPedCanRagdoll(PlayerPed, not CONFIG.PLAYERS.prevent_ragdoll)
		SetPedRagdollOnCollision(PlayerPed, not CONFIG.PLAYERS.prevent_ragdoll)
		SetPedCanBeKnockedOffVehicle(PlayerPed, not CONFIG.PLAYERS.stick_to_vehicle)
		SetPedCanBeDraggedOut(PlayerPed, not CONFIG.PLAYERS.cant_carjack)
		if CONFIG.PLAYERS.prevent_weapon_pickup then DisablePlayerVehicleRewards(PlayerID) end
		
		--if not CONFIG.TRAINER.allow_trainer 
		--	or (CONFIG.TRAINER.allow_trainer and mainMenu ~= nil and not mainMenu:Visible()) then
			if CONFIG.NETWORK.allow_teleport_to_player and IsComboControlJustPressed(CONFIG.NETWORK.teleport_hotkey_1, CONFIG.NETWORK.teleport_hotkey_2) then
				if TableLength(ActivePlayerBlips) == 0 then TeleportToWaypoint() 
				else TeleportToPlayer() end
			end
			
			if CONFIG.VEHICLES.clone_vehicles and IsComboControlJustPressed(CONFIG.VEHICLES.clone_vehicle_hotkey_1, CONFIG.VEHICLES.clone_vehicle_hotkey_2) then
				CloneVehicle()
			end
		--end
		
		if CONFIG.PLAYERS.prevent_firing then
			DisablePlayerFiring(PlayerID, true)
			HudWeaponWheelIgnoreControlInput(true)
			
			-- Disable key inputs					EVENT NAME					KB		CONTROLLER
			--[[DisableControlAction(0, 140, true) 	-- INPUT_MELEE_ATTACK_LIGHT		R		B
			DisableControlAction(0, 141, true) 	-- INPUT_MELEE_ATTACK_HEAVY		Q		A
			DisableControlAction(0, 142, true) 	-- INPUT_MELEE_ATTACK_ALTERNATE	LMB		RT
			DisableControlAction(0, 263, true) 	-- INPUT_MELEE_ATTACK1			R		B
			DisableControlAction(0, 264, true) 	-- INPUT_MELEE_ATTACK2			Q		A
			DisableControlAction(0, 68, true) 	-- INPUT_VEH_AIM				RMB		LB
			DisableControlAction(0, 69, true) 	-- INPUT_VEH_ATTACK				LMB		RB
			DisableControlAction(0, 70, true) 	-- INPUT_VEH_ATTACK2			RMB		A
			DisableControlAction(0, 345, true) 	-- INPUT_VEH_MELEE_HOLD			X		A
			DisableControlAction(0, 346, true) 	-- INPUT_VEH_MELEE_LEFT			LMB		LB
			DisableControlAction(0, 347, true) 	-- INPUT_VEH_MELEE_RIGHT		RMB		RB
			]]--
		end
		
		if IsPedFalling(PlayerPed) and CONFIG.PLAYERS.auto_parachute then
			if not HasPedGotWeapon(PlayerPed, CONSTANT.ParachuteHash, false) then
				d_print("Giving you a parachute.")
				d_print("Distance above ground:  " .. GetEntityHeightAboveGround(PlayerPed))
				---- BROKEN
				--
				--
				GiveWeaponToPed(PlayerPed, CONSTANT.ParachuteHash, 1, false, false)
			end
			
			if IsPedInParachuteFreeFall(PlayerPed) then ForcePedToOpenParachute(PlayerPed) end
		elseif CONFIG.PLAYERS.clear_weapons and IsPedArmed(PlayerPed, 7) then
			d_print("Removing all of your weapons.")
			RemoveAllPedWeapons(PlayerPed, true)
		end
		
		-- Detects when player is trying to enter a vehicle
		if PlayerVehicle.is_entering and not IsEnteringVehicle then
			IsEnteringVehicle = true
			d_print("Attempting to get in a vehicle.")
			
			AnimatePed(PlayerPed, nil)
			
			local pedInSeat = GetPedInVehicleSeat(PlayerVehicle.vehicle, -1) -- References any ped sat in the driver's seat		
			
			if CONFIG.VEHICLES.all_unlocked then SetVehicleDoorsLocked(PlayerVehicle.vehicle, 1) end -- Unlocks car's doors (to bypass window break when parked)
			if CONFIG.VEHICLES.no_hotwire then SetVehicleNeedsToBeHotwired(PlayerVehicle.vehicle, false) end
			
			if CONFIG.NPC.prevent_visual_carjack > 0 then
				-- If ped is found in the driver's seat
				if DoesEntityExist(pedInSeat) then
					-- If ped in seat IS NOT a player
					if not IsPedAPlayer(pedInSeat) then
						d_print("NPC in driving seat, forcing ped to leave to skip jacking animations.")
						
						FriendlyCarjack(PlayerVehicle.vehicle, -1, pedInSeat, false)
						
					-- If ped IS a player
					elseif IsPedAPlayer(pedInSeat) then
						d_print("Player in driving seat!")
						
						local pedWithHuman = GetPedInVehicleSeat(PlayerVehicle.vehicle, PlayerVehicle.seat) -- Defines any ped currently sat in seat
						
						-- If ped is found and it IS NOT a player
						if DoesEntityExist(pedWithHuman) and not IsPedAPlayer(pedWithHuman) then
							d_print("NPC sat in seat, forcing ped to leave to skip jacking animations.")
							
							FriendlyCarjack(PlayerVehicle.vehicle, PlayerVehicle.seat, pedWithHuman, false)
						end
					end
				end
			end
		elseif not PlayerVehicle.is_entering and IsEnteringVehicle then
			IsEnteringVehicle = false
		elseif PlayerVehicle.is_inside then
			VehicleLimitDamage(PlayerVehicle.vehicle, 1)
			
			DisplaySpeedo()
			
			if CONFIG.VEHICLES.disable_cinematic_cam then
				SetCinematicButtonActive(false)
				SetCinematicModeActive(false)
			end
			
			if CONFIG.VEHICLES.disable_radio or (CONFIG.VEHICLES.radio_driver_only and PlayerVehicle.seat ~= -1) then
				SetVehicleRadioEnabled(PlayerVehicle.vehicle, false)
				SetUserRadioControlEnabled(false)
				if GetPlayerRadioStationName() ~= nil then
					SetVehRadioStation(PlayerVehicle.vehicle, "OFF")
				end
			end
			
			if CONFIG.PLAYERS.prevent_firing and DoesVehicleHaveWeapons(PlayerVehicle.vehicle) then
				if not IsVehicleModel(PlayerVehicle.vehicle, GetHashKey("firetruk")) then
					d_print("Vehicle has weapons, attempting to disable.")
					
					SetVehicleWeaponsDisabled(PlayerVehicle.vehicle, -1)
					SetVehicleWeaponsDisabled(PlayerVehicle.vehicle, 0)
					SetVehicleWeaponsDisabled(PlayerVehicle.vehicle, 1)
					SetVehicleWeaponsDisabled(PlayerVehicle.vehicle, 2)
					
					DisableControlAction(0, 68, true) 	-- INPUT_VEH_AIM				RMB		LB
					DisableControlAction(0, 69, true) 	-- INPUT_VEH_ATTACK				LMB		RB
					DisableControlAction(0, 70, true) 	-- INPUT_VEH_ATTACK2			RMB		A
					DisableControlAction(0, 345, true) 	-- INPUT_VEH_MELEE_HOLD			X		A
					DisableControlAction(0, 346, true) 	-- INPUT_VEH_MELEE_LEFT			LMB		LB
					DisableControlAction(0, 347, true) 	-- INPUT_VEH_MELEE_RIGHT		RMB		RB
				end
			end
			
			if CONFIG.VEHICLES.taxi_npcs then
				if IsControlJustPressed(1, CONFIG.VEHICLES.taxi_npcs_call_hotkey) then
					CollectNpcPassengers(PlayerVehicle.vehicle, false)
				elseif IsControlJustPressed(1, CONFIG.VEHICLES.taxi_npcs_leave_hotkey)
					and CONFIG.VEHICLES.taxi_npcs_call_hotkey ~= CONFIG.VEHICLES.taxi_npcs_leave_hotkey then
						CollectNpcPassengers(PlayerVehicle.vehicle, true)
				end
				
				if IsVehicleStopped(PlayerVehicle.vehicle) and VehicleTaxiDropOffAtNextStop then
					VehicleTaxiDropOffAtNextStop = false
					DropNpcPassengerOff(PlayerVehicle.vehicle)
				end
			end
		else
			if PlayerVehicleChangedThisTick then
				EjectAllNpcIfNoPlayer(LastPlayerVehicle.vehicle)
				
				if VehicleIsInvisible then
					SetEntityAlpha(LastPlayerVehicle.vehicle, 255, false)
					SetEntityAlpha(PlayerPed, 200, false)
					VehicleIsInvisible = false
				end
				
				ForceVehicleColour(LastPlayerVehicle.vehicle)
				
				PlayerVehicleChangedThisTick = false
			end
			
			if CONFIG.PLAYERS.no_low_stamina then ResetPlayerStamina(PlayerID) end
			
			if IsControlJustPressed(1, CONFIG.PLAYERS.simple_emote_hotkey) then
				AnimatePed(PlayerPed, CONSTANT.EMOTES[math.random(#CONSTANT.EMOTES)])
			end
			
			if IsComboControlJustPressed(CONFIG.VEHICLES.teleport_to_last_vehicle_hotkey_1, CONFIG.VEHICLES.teleport_to_last_vehicle_hotkey_2)
				and CONFIG.VEHICLES.teleport_to_last_vehicle
				and DoesEntityExist(LastPlayerVehicle.vehicle) then
					ForcePedInVehicleNow(PlayerPed, LastPlayerVehicle.vehicle, LastPlayerVehicle.seat)
					PlayerVehicle.vehicle = LastPlayerVehicle.vehicle
					PlayerVehicle.seat = LastPlayerVehicle.seat
			end
		end
		
		NetworkSetEntityInvisibleToNetwork(PlayerPed, InvisibleToNetwork)
		if PlayerVehicle.is_inside then  NetworkSetEntityInvisibleToNetwork(PlayerVehicle.vehicle, InvisibleToNetwork) end
		if InvisibleToNetwork then
			if not PedIsInvisible then
				SetEntityAlpha(PlayerPed, 200, false)
				PedIsInvisible = true
			end
			if PlayerVehicle.is_inside and not VehicleIsInvisible then
				SetEntityAlpha(PlayerVehicle.vehicle, 200, false)
				VehicleIsInvisible = true
			end
		else
			if PedIsInvisible then
				SetEntityAlpha(PlayerPed, 255, false)
				PedIsInvisible = false
			end
			if PlayerVehicle.is_inside and VehicleIsInvisible then
				SetEntityAlpha(PlayerVehicle.vehicle, 255, false)
				VehicleIsInvisible = false
			end
		end
		
		for key,ActivePlayer in pairs(GetNetworkPlayers(false)) do
			AddPlayerVisualIdentifier(ActivePlayer, true)
			
			if CONFIG.PLAYERS.invincible == 2 then SetEntityInvincible(ActivePlayer.ped, true) end
			if CONFIG.PLAYERS.clear_injuries then
				ResetPedVisibleDamage(ActivePlayer.ped)
				ClearPedBloodDamage(ActivePlayer.ped, true)
			end
			
			SetPedCanRagdoll(ActivePlayer.ped, not CONFIG.PLAYERS.prevent_ragdoll)
			SetPedRagdollOnCollision(ActivePlayer.ped, not CONFIG.PLAYERS.prevent_ragdoll)
			SetPedCanBeKnockedOffVehicle(ActivePlayer.ped, not CONFIG.PLAYERS.stick_to_vehicle)
			SetPedCanBeDraggedOut(ActivePlayer.ped, not CONFIG.PLAYERS.cant_carjack)
			
			local ActivePlayerVehicle = GetVehiclePedIsInOrEntering(ActivePlayer.ped)
			if ActivePlayerVehicle.is_entering then
				if not DoesSetContain(NetworkPlayerIsEnteringVehicle, ActivePlayer.ped) then
					AddToSet(NetworkPlayerIsEnteringVehicle, ActivePlayer.ped)
					
					local pedInSeatPlayerEnt = GetPedInVehicleSeat(ActivePlayerVehicle.vehicle, ActivePlayerVehicle.seat) -- References any ped sat in the driver's seat
					
					if CONFIG.VEHICLES.all_unlocked then SetVehicleDoorsLocked(ActivePlayerVehicle.vehicle, 1) end -- Unlocks car's doors (to bypass window break when parked)
					if CONFIG.VEHICLES.no_hotwire then SetVehicleNeedsToBeHotwired(ActivePlayerVehicle.vehicle, false) end
					
					if CONFIG.NPC.prevent_visual_carjack > 0 and DoesEntityExist(pedInSeatPlayerEnt) and not IsPedAPlayer(pedInSeatPlayerEnt) then
						d_print("NPC sat in vehicle seat active player is entering, forcing ped to leave to skip jacking animations.")
						FriendlyCarjack(ActivePlayerVehicle.vehicle, ActivePlayerVehicle.seat, pedInSeatPlayerEnt, true)
					end
				end
			elseif DoesSetContain(NetworkPlayerIsEnteringVehicle, ActivePlayer.ped) then
				RemoveFromSet(NetworkPlayerIsEnteringVehicle, ActivePlayer.ped)
			elseif ActivePlayerVehicle.is_inside then
				VehicleLimitDamage(ActivePlayerVehicle.vehicle, 1)
			end
		end
		
		SetPedDensityMultiplierThisFrame(CONFIG.NPC.spawn_density_multiplier) -- set npc/ai peds density, default 1.0
		SetScenarioPedDensityMultiplierThisFrame(CONFIG.NPC.spawn_density_multiplier_scenario, CONFIG.NPC.spawn_density_multiplier_scenario) -- set random npc/ai peds or scenario peds
		
		SetCreateRandomCops(CONFIG.POLICE.spawn_police) -- random cops walking/driving around
		SetCreateRandomCopsNotOnScenarios(CONFIG.POLICE.spawn_police) -- random cops (not in a scenario) spawning
		SetCreateRandomCopsOnScenarios(CONFIG.POLICE.spawn_police_scenarios) -- random cops (in a scenario) spawning
		
		SetVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier) -- set traffic density, default 1.0
		SetParkedVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier_parked) -- set random parked vehicles (parked car scenarios)
		SetRandomVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier_scenario) -- set random vehicles (car scenarios / cars driving off from a parking spot etc)
		SetGarbageTrucks(CONFIG.VEHICLES.spawn_garbage_trucks) -- garbage trucks randomly spawning
		SetRandomBoats(CONFIG.VEHICLES.spawn_boats) -- random boats spawning in the water
		
		for key,pedNpc in pairs(GetGamePool("CPed")) do
			if IsPedNpc(pedNpc) and not IsPedMiniGameAi(pedNpc) then
				SetEntityInvincible(pedNpc, CONFIG.NPC.invincible)
				if CONFIG.NPC.clear_injuries then
					ResetPedVisibleDamage(pedNpc)
					ClearPedBloodDamage(pedNpc, true)
				end
				
				SetPedCanRagdoll(pedNpc, not CONFIG.NPC.prevent_ragdoll)
				SetPedRagdollOnCollision(pedNpc, not CONFIG.NPC.prevent_ragdoll)
				SetPedCanBeKnockedOffVehicle(pedNpc, not CONFIG.NPC.stick_to_vehicle)
				
				SetPedCanBeDraggedOut(pedNpc, not CONFIG.NPC.cant_carjack)
				SetPedCanBeTargetted(pedNpc, not CONFIG.NPC.cant_target)
				SetPedCanEvasiveDive(pedNpc, not CONFIG.NPC.prevent_evasive_driving)
				
				if CONFIG.NPC.stop_speaking > 0 then StopPedSpeaking(pedNpc, true) end
				if CONFIG.NPC.stop_speaking == 2 then DisablePedPainAudio(pedNpc, true) end
				
				if CONFIG.NPC.non_combat then SetPedCombatAttributes(pedNpc, 17, true) end
				
				if CONFIG.NPC.ignore_players == 2 then
					SetPedAlertness(pedNpc,0)
					SetPedFleeAttributes(pedNpc, 0, false)
					SetBlockingOfNonTemporaryEvents(pedNpc, true)
					
					if IsPedInAnyVehicle(pedNpc, false) then
						SetDriverAggressiveness(pedNpc, 0.0)
					end
				end
				
				if CONFIG.NPC.clear_weapons and IsPedArmed(pedNpc, 7) then
					RemoveAllPedWeapons(pedNpc, true)
				end
				
				if CONFIG.NPC.del_disturbing_peds then
					for key,pedHash in pairs(CONSTANT.DISTURBING_PEDS) do
						if IsPedModel(pedNpc, pedHash) then
							d_print("Deleting restricted ped:  " .. pedHash)
							DeletePed(pedNpc)
							break
						end
					end
				end
				if CONFIG.NPC.del_minimal_clothing_peds then
					for key,pedHash in pairs(CONSTANT.MIN_CLOTHING_PEDS) do
						if IsPedModel(pedNpc, pedHash) then
							d_print("Deleting restricted ped:  " .. pedHash)
							DeletePed(pedNpc)
							break
						end
					end
				end
			end
		end
		
		
		if CONFIG.VEHICLES.invincible == 2
				or CONFIG.VEHICLES.prevent_damage == 2
				or CONFIG.VEHICLES.keep_clean == 2 then
			for key,Vehicle in pairs(GetGamePool('CVehicle')) do
				if not IsVehicleMiniGameAi(Vehicle) then
					VehicleLimitDamage(Vehicle, 2)
				end
			end
		end
	end
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000) -- Repeat every second
		ClientClock = ClientClock +1 -- Count every second
		
		if CONFIG.TRAINER.allow_parental_controls and TimeRemaining > -1 then
			if not TimerIsPaused and not GameIsForcePaused and TimeRemaining > 0 then TimeRemaining = TimeRemaining - 1000 end
			if CONFIG.PARENTAL.timer_end_with_blackout and TimeIsExpired and TimeExpiredClockRemaining > 0 then TimeExpiredClockRemaining = TimeExpiredClockRemaining -1000 end
			
			if CONFIG.PARENTAL.timer_allow_pause_break then
				local LastSelected, Selected = GetPauseMenuSelection()
				
				if not TimerIsPaused and IsPauseMenuActive() and PauseMenuIndex == nil then
					PauseMenuActive = true
					TimerIsPaused = true
					PauseMenuIndex = Selected
					SendParentalEvent("PauseTimer", true)
				elseif TimerIsPaused and PauseMenuActive and (not IsPauseMenuActive() or PauseMenuIndex ~= Selected) then
					PauseMenuActive = false
					TimerIsPaused = false
					
					if PauseMenuIndex ~= Selected then
						ShowNotification("You're no longer taking a break.", true, "pausemenuignore")
					end
					
					SendParentalEvent("PauseTimer", false)
				end
				if PauseMenuIndex ~= nil and not IsPauseMenuActive() then
					PauseMenuIndex = nil
				end
			end
		end
		
		if CONFIG.WORLD.lock_time_to_hour == -1 then
			local year, month, day, hour, minute, second = GetLocalTime()
			NetworkOverrideClockTime(hour, minute, 0)
		elseif CONFIG.WORLD.lock_time_to_hour > -1 and CONFIG.WORLD.lock_time_to_hour <= 23 then
			NetworkOverrideClockTime(CONFIG.WORLD.lock_time_to_hour, 0, 0)
		end
		
		-- Prevent being over-run with spawned vehicles
		if #VehiclesSpawned > CONFIG.VEHICLES.max_spawned_per_player then
			local PurgeCount = 1
			if #VehiclesSpawned >= (CONFIG.VEHICLES.max_spawned_per_player + 5) then PurgeCount = #VehiclesSpawned - CONFIG.VEHICLES.max_spawned_per_player end
			
			for i=1, #VehiclesSpawned do
				if i > PurgeCount then break end
				
				if DoesEntityExist(VehiclesSpawned[1]) and not IsAnyPlayerInVehicle(VehiclesSpawned[1]) then DeleteEntity(VehiclesSpawned[1]) end
				table.remove(VehiclesSpawned, 1)
			end
		end
		
		if PlayerVehicle.is_inside and PlayerVehicle.seat == -1 then
			if CONFIG.VEHICLES.lock_player_vehicle_colour
				and CONFIG.VEHICLES.lock_primary_colour_to ~= VehicleColourForced then
					ForceVehicleColour(PlayerVehicle.vehicle, CONSTANT.COLOURS[CONFIG.VEHICLES.lock_primary_colour_to], CONFIG.VEHICLES.also_lock_secondary_colour)
					VehicleColourForced = CONFIG.VEHICLES.lock_primary_colour_to
			elseif not CONFIG.VEHICLES.lock_player_vehicle_colour and VehicleColourForced:gsub("%W", "") ~= "" then
				ForceVehicleColour(PlayerVehicle.vehicle, CONSTANT.COLOURS[VehicleColourForced], CONFIG.VEHICLES.also_lock_secondary_colour)
				VehicleColourForced = " "
			end
		end
		
		if RunEveryX(10, true) then -- Run every 10 seconds
			if CONFIG.PLAYERS.disable_idle_cam then
				InvalidateIdleCam()
				InvalidateVehicleIdleCam()
			end
			
			if PlayerVehicle.is_inside then
				VehicleRepairDamage(PlayerVehicle.vehicle, 1)
				for key,Vehicle in pairs(GetGamePool('CVehicle')) do
					VehicleRepairDamage(Vehicle, 2)
				end
				
				if CONFIG.VEHICLES.taxi_npcs and CONFIG.VEHICLES.taxi_drop_off then
					if PlayerVehicle.vehicle == VehicleTaxi and PlayerVehicle.seat == -1 then
						if VehicleTaxiDropOffClock >= 30 then
							if (math.random (0, 10) <= 7) then
								VehicleTaxiDropOffAtNextStop = true
							end
							VehicleTaxiDropOffClock = 0
						end
					else
						VehicleTaxiDropOffClock = 0
						VehicleTaxiDropOffAtNextStop = false
					end
					
					VehicleTaxiDropOffClock = VehicleTaxiDropOffClock + 10
				end
			end
			
			-- Clear blips and markers for active players to refresh them every 10 seconds
			PurgePlayerFx()
			PurgePlayerBlips()
			for key,ActivePlayer in pairs(GetNetworkPlayers(false)) do
				-- Add new blips and markers every 10 seconds
				AddPlayerVisualIdentifier(ActivePlayer, false)
				if CONFIG.NETWORK.active_player_blips then AddPlayerBlip(ActivePlayer) end
			end
		end
	end
end)
------------------------------
------------------------------
---- LOOPING THREADS END -----
------------------------------
------------------------------

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
	if CONFIG.PLAYERS.random_spawn_ped then
		local rand = math.random(TableLength(SPAWN_ITEMS.PEDS))
		local pass = 1
		d_print("Setting the player ped model to number " .. rand .. " in the table")
		
		for model,name in pairs(SPAWN_ITEMS.PEDS) do
			if pass == rand then
				d_print("Random player model is:  " .. model)
				SetPlayerPed(model)
				break
			end
			pass = pass +1
		end
		
		PedChangedAtSpawn = true
	end
	
	if CONFIG.WORLD.lock_weather ~= "" then	
		SetWeatherOwnedByNetwork(false)
		SetWeatherTypeNowPersist(CONFIG.WORLD.lock_weather)
	end
end)