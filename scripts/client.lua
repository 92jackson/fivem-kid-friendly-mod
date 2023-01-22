---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- KID FRIENDLY MOD for FiveM by Jackson92 --------------------------------------------------------
-----FOR NORMAL USE, YOU SHOULD NOT NEED TO EDIT PAST THIS POINT!----------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Github:	https://github.com/92jackson/fivem-kid-friendly-mod -----------------------------------
-- Discord:	https://discord.gg/e3eXGTJbjx (join for support, feedback, fixes, updates etc) --------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local PlayerSpawnReady = false
local ClientClock = 0
local RunEveryXLastCalled = {}
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
local CurrentCoords = nil
local PlayerVehicle = {is_entering = false, is_inside = false, vehicle = 0, seat = -2}
local LastPlayerVehicle = {vehicle = 0, seat = -2}
local IsEnteringVehicle = false
local IsTeleporting = false
local VehicleTaxi = 0
local VehicleTaxiFull = false
local VehicleTaxiDropOffClock = 0
local VehicleTaxiDropOffAtNextStop = false
local ActivePlayers = {}
local NetworkPlayerIsEnteringVehicle = {}
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
local LastSetPedAnim = {}
local IneffeciveWeapons = {}
local HandheldAllowWeapons = {}
local VehiclesAllowWeapons = {}
local QuickPedIndex = 1
local QuickSpawnIndex = 1
local LastQuickSpawn = 0
local QuickSpawnRequested = 0
local AllowParentalControl = false
local ExpectingPlayerUpdatePush = -1
local PlayerUpdatePushRecieved = false
local CurrentMilisecondsPerMin = -1
local CurrentLockHour = nil
local ProcessedPeds = {}
local ProcessedVehicles = {}
local RunPurgeProcessed = false
local PlayerPassengerInVehicle = 0

--------------------------------
--------------------------------
--- GENERAL CUSTOM NATIVES  ----
--------------------------------
--------------------------------
function RunEveryX(S, ForceRunAtOne, NameIndex, FirstRunImmediate)
	local LastCalled = -1
	if IsVarSetTrue(NameIndex) then
		if DoesSetContain(RunEveryXLastCalled, NameIndex) then LastCalled = RunEveryXLastCalled[NameIndex] end
	end
	
	if (ClientClock % S == 0 and ClientClock > LastCalled)
		or (IsVarSetTrue(NameIndex) and FirstRunImmediate and LastCalled == -1) then
			if IsVarSetTrue(NameIndex) then
				AddToSet(RunEveryXLastCalled, NameIndex, ClientClock)
				--d_print(NameIndex .. "  last called recorded:  " .. ClientClock)
			end
			return true
	elseif ForceRunAtOne and ClientClock == 1 then return true
	else return false end
end

function SetPedInvincibleWithRagdoll(Ped, InvincibleFlag, RagdollFlag)
	SetPedCanRagdoll(Ped, not RagdollFlag.disable_all)
	
	local SetInvincible = false
	if InvincibleFlag and RagdollFlag.disable_all then
		SetInvincible = true
	elseif InvincibleFlag and not RagdollFlag.disable_all then
		local BulletProof = true
		if (not RagdollFlag._prevent_when_shot and not InvincibleFlag)
			or (not RagdollFlag._prevent_when_shot and InvincibleFlag and CONFIG.WEAPONS.make_weapons_ineffective) then
				BulletProof = false
		end
		local ExplosionProof = true
		if (not RagdollFlag._prevent_on_explosion and not InvincibleFlag)
			or (not RagdollFlag._prevent_on_explosion and InvincibleFlag and CONFIG.WEAPONS.make_weapons_ineffective) then
				ExplosionProof = false
		end
		
		SetEntityProofs(Ped, BulletProof, true, ExplosionProof, true, true, true, true, true)
		
		SetPedDiesWhenInjured(Ped, false)
		SetPedDiesInSinkingVehicle(Ped, false)
		SetPedDiesInVehicle(Ped, false)
		SetPedDiesInWater(Ped, false)
		SetPedDiesInstantlyInWater(Ped, false)
		
		SetPedSuffersCriticalHits(Ped, false)
		
		SetPedConfigFlag(Ped, 2, true) -- CPED_CONFIG_FLAG_NoCriticalHits
		SetPedConfigFlag(Ped, 3, false) -- CPED_CONFIG_FLAG_DrownsInWater 
		SetPedConfigFlag(Ped, 33, false) -- CPED_CONFIG_FLAG_DieWhenRagdoll
		SetPedConfigFlag(Ped, 188, true) -- CPED_CONFIG_FLAG_DisableHurt
		SetPedConfigFlag(Ped, 456, false) -- CPED_CONFIG_FLAG_CanBeIncapacitated
	end
	
	SetEntityInvincible(Ped, SetInvincible)
	
	if not SetInvincible and not RagdollFlag.disable_all then
		if RagdollFlag._prevent_when_shot then SetRagdollBlockingFlags(Ped, 1) end
		if RagdollFlag._prevent_run_down then SetRagdollBlockingFlags(Ped, 2) end
		if RagdollFlag._prevent_on_fire then
			SetRagdollBlockingFlags(Ped, 4)
			SetPedConfigFlag(NpcPed, 430, true) -- CPED_CONFIG_FLAG_IgnoreBeingOnFire
		end
	end
end

function MaintainPedHealth(Ped, InvincibleFlag, RagdollFlag, InVehicle)
	if InvincibleFlag and not RagdollFlag.disable_all then
		if IsPedFalling(Ped) and RagdollFlag._prevent_when_falling then
			local DistanceToGround = GetEntityHeightAboveGround(Ped)
			if DistanceToGround <= 8.0 and DistanceToGround > 2.0 then
				if RunEveryX(1, false, "fallragdollprevent" .. Ped, true) then
					ClearPedTasksImmediately(Ped)
					d_print("Ped falling, preventing impact for ped:  " .. Ped)
				end
			end
		end
		
		if Ped == PlayerPed and VehicleJustExitedWhileMoving then
			ClearPedTasksImmediately(Ped)
			d_print("Vehicle exited while moving! Clearing your ped tasks immediately to prevent ragdoll animation.")
			VehicleJustExitedWhileMoving = false
		end
		
		if IsVarSetTrue(InVehicle) and RagdollFlag._prevent_in_vehicle then SetEntityInvincible(Ped, true)
		elseif not IsVarSetTrue(InVehicle) and RagdollFlag._prevent_in_vehicle then SetEntityInvincible(Ped, false) end
		
		local MaxHealth = GetEntityMaxHealth(Ped)
		local CurrentHealth = GetEntityHealth(Ped)
		
		if CurrentHealth < 5 then
			ReviveInjuredPed(Ped)
			d_print("PED_DYING: Attempting to revive ped:  " .. Ped)
		end
		
		if IsEntityDead(Ped) then
			ResurrectPed(Ped)
			d_print("PED_DEAD: Attempting to resurrect ped:  " .. Ped)
		end
		
		if CurrentHealth < MaxHealth then SetEntityHealth(Ped, MaxHealth) end
		if GetPedArmour(Ped) < 100 then SetPedArmour(Ped, 100) end
	end
end

function KeepPedClean(Ped, KeepClean)
	if KeepClean then
		ResetPedVisibleDamage(Ped)
		ClearPedBloodDamage(Ped, true)
		ClearPedEnvDirt(Ped)
	end
	
	if CONFIG.WORLD.prevent_blood_pools then
		if IsPedRagdoll(Ped) or IsPedDeadOrDying(Ped, true) or IsPedProne(Ped) then
			local Coords = GetEntityCoords(Ped, false)
			RemoveDecalsInRange(Coords.x, Coords.y, Coords.z, 5.0)
		end
	end
end

function AllocatePermittedWeaponsToPlayer()
	if CONFIG.WEAPONS.remove_all_weapons ~= 2
		and CONFIG.WEAPONS.auto_allocate_permitted
		and next(CONFIG.WEAPONS.permitted_weapons) ~= nil
		and next(HandheldAllowWeapons) ~= nil then
			for WeaponHash,found in pairs(HandheldAllowWeapons) do
				if HasPedGotWeapon(PlayerPed, WeaponHash, false) then return end
				
				GiveWeaponToPed(PlayerPed, WeaponHash, 10, false, false)
				d_print("Giving weapon to player ped:  " .. PlayerPed .. ", weapon hash:  " .. WeaponHash)
			end
	end
end

function SetWeaponHandling(Ped, Vehicle)
	local PedTypeFlag = 1
	if IsPedAPlayer(Ped) then PedTypeFlag = 2 end
	
	local PedIsParachuting = false
	if IsPedFalling(Ped)
		and GetEntityHeightAboveGround(Ped) > 8
		and ((PedTypeFlag == 2 and CONFIG.PLAYERS.auto_parachute)
		or (PedTypeFlag == 1 and CONFIG.NPC.auto_parachute ))
		and ((Ped == PlayerPed) or (PedTypeFlag == 1)) then
			if not HasPedGotWeapon(Ped, CONSTANT.ParachuteHash, false) then
				d_print("Giving a parachute to falling ped:  " .. Ped)
				
				GiveWeaponToPed(Ped, CONSTANT.ParachuteHash, 10, false, false)
			end
			
			if IsPedInParachuteFreeFall(Ped) then ForcePedToOpenParachute(Ped) end
			PedIsParachuting = true
	end
	
	if CONFIG.WEAPONS.remove_all_weapons >= PedTypeFlag
		and IsPedArmed(Ped, 7)
		and not PedIsParachuting
		and ((Ped == PlayerPed) or (PedTypeFlag == 1)) then
			d_print("Removing weapons from ped:  " .. Ped)
			RemoveAllPedWeapons(Ped, true)
	elseif CONFIG.WEAPONS.make_weapons_ineffective
		and IsPedArmed(Ped, 7) then
			local Found, CurrentWeapon = GetCurrentPedWeapon(Ped, true)
			if Found then
				if not DoesSetContain(IneffeciveWeapons, CurrentWeapon) then
					d_print("Modifying weapon damage modifier for:  " .. CurrentWeapon)
					
					SetWeaponDamageModifier(CurrentWeapon, 0.0)
					AddToSet(IneffeciveWeapons, CurrentWeapon)
				end
			end
	end
	
	if CONFIG.WEAPONS.remove_all_weapons ~= 2
		and CONFIG.WEAPONS.restrict_to_permitted_only
		and ((Ped == PlayerPed) or (PedTypeFlag == 1)) then
			if IsPedArmed(Ped, 7) then
				local Found, CurrentWeapon = GetCurrentPedWeapon(Ped, true)
				if Found then
					if not DoesSetContain(HandheldAllowWeapons, CurrentWeapon)
						and CurrentWeapon ~= CONSTANT.ParachuteHash then
							RemoveWeaponFromPed(Ped, CurrentWeapon)
							d_print("Removing illegal weapon from ped:  " .. Ped .. ", weapon hash:  " .. CurrentWeapon)
					end
				end
			end
	end
	
	if Ped == PlayerPed then
		if CONFIG.WEAPONS.prevent_all_aim_fire then
			DisablePlayerFiring(PlayerID, true)
			SetDisableAmbientMeleeMove(PlayerID, true)
			--HudWeaponWheelIgnoreControlInput(true)
		elseif CONFIG.PLAYERS.disable_close_combat then
			if GetSelectedPedWeapon(Ped) == GetHashKey('weapon_unarmed') then
				DisableControlAction(0, 25, true) -- INPUT_AIM
				DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
				DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATIVE
			end
			DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
		end
	else
		if CONFIG.WEAPONS.prevent_all_aim_fire then
			SetPedConfigFlag(Ped, 122, true) -- CPED_CONFIG_FLAG_DisableMelee
			SetPedConfigFlag(Ped, 186, true) -- CPED_CONFIG_FLAG_EnableWeaponBlocking
			SetPedCombatAttributes(Ped, 1424, false) -- BF_PlayerCanUseFiringWeapons
		end
	end
	
	if IsVarSetTrue(Vehicle) and ((Ped == PlayerPed) or (PedTypeFlag == 1)) then
		if IsVarSetTrue(CONFIG.WEAPONS.disable_vehicle_weapons) and DoesVehicleHaveWeapons(Vehicle) then
			local VehicleModel = GetEntityModel(Vehicle)
			
			if not DoesSetContain(VehiclesAllowWeapons, VehicleModel) then
				--d_print("Vehicle has weapons, attempting to disable.")
				
				local Found, VehicleWeaponHash = GetCurrentPedVehicleWeapon(Ped)
				if Found then DisableVehicleWeapon(true, VehicleWeaponHash, Vehicle, Ped) end
			end
		end
	end
end

function GetPedVehicleSeat(Ped, Vehicle)
	for i=-2, GetVehicleMaxNumberOfPassengers(Vehicle) do
		if GetPedInVehicleSeat(Vehicle, i) == Ped then return i end
	end
	return -2
end

--[[function IsAnyPlayerInVehicle(Vehicle, IgnoreSelf)
	for i=-1, GetVehicleMaxNumberOfPassengers(Vehicle) do
		local PedInSeat = GetPedInVehicleSeat(Vehicle, i)
		if IsPedAPlayer(PedInSeat) and (not IgnoreSelf or (IgnoreSelf and PedInSeat ~= PlayerPed)) then return true end
	end
	return false
end]]--

function GetVehicleFirstFreeSeat(Vehicle, ExcludeDriver)
	local StartSeat = -1
	if ExcludeDriver then StartSeat = 0 end
	
	local FirstNpcInSeat = -2
	local MaxPassengers = GetVehicleMaxNumberOfPassengers(Vehicle)
	
	if MaxPassengers > 0 then
		for i = StartSeat, MaxPassengers do
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

function IsPedNpc(Ped)
	if DoesEntityExist(Ped)
		--and not IsEntityDead(Ped)
		and IsEntityAPed(Ped)
		and IsPedHuman(Ped)
		and not IsPedAPlayer(Ped) then return true
	else return false end
end

function GetNearbyPeds(X, Y, Z, Radius, MaxNum)
	local NearbyPeds = {}
	local LoopNum = 0
	
	for _, Ped in pairs(GetGamePool("CPed")) do
		if LoopNum >= MaxNum then break end
		
		if IsPedNpc(Ped) and not IsPedInAnyVehicle(Ped, true) then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
				LoopNum = LoopNum +1
			end
		end
	end
	
	return NearbyPeds
end

function CollectNpcPassengers(Vehicle, ForceLeave, HotkeySame)
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
		elseif ForceLeave or (HotkeySame and VehicleTaxiFull) then
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

function TaskNpcLeaveVehicle(Vehicle, Ped, Immediate, Flag)
	Flag = Flag or 0
	
	if Immediate then DeletePed(Ped)
	else
		TaskLeaveVehicle(Ped, Vehicle, Flag)
		TaskWanderStandard(Ped, 10.0, 10)
	end
end

function ForceAllNpcToLeaveVehicle(Vehicle, Immediate, ExcludeDriver)
	local NpcsInside = GetVehicleAllNpcsInside(Vehicle, ExcludeDriver)
	
	if next(NpcsInside) ~= nil then
		d_print(#NpcsInside .. " NPCs leaving vehicle  " .. Vehicle)
		
		for key,Ped in pairs(NpcsInside) do
			TaskNpcLeaveVehicle(Vehicle, Ped, Immediate)
		end
		return #NpcsInside
	end
	return 0
end

function EjectAllNpcIfNoDriver(Vehicle)
	if DoesEntityExist(Vehicle) and not DoesEntityExist(GetPedInVehicleSeat(Vehicle, -1)) then
		ForceAllNpcToLeaveVehicle(Vehicle, false)
	end
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

function SetNpcAsDriverForPlayer(Vehicle, SeatPlayerEntering)
	if IsVarSetTrue(Vehicle) then
		local Driver = GetPedInVehicleSeat(Vehicle, -1)
		if DoesEntityExist(Driver) and not IsPedAPlayer(Driver) then
			SetEntityAsMissionEntity(Vehicle, false, false)
			SetEntityAsMissionEntity(Driver, false, false)
			
			local _, DriverGroup = AddRelationshipGroup("bus_driver")
			SetRelationshipBetweenGroups(0, DriverGroup, GetHashKey("PLAYER"))
			SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), DriverGroup)
			SetPedCanBeDraggedOut(Driver, false)
			
			local PassengersInside = GetVehicleAllNpcsInside(Vehicle, true)
			if next(PassengersInside) ~= nil then
				for key,Ped in pairs(PassengersInside) do
					SetPedCanBeDraggedOut(Ped, false)
				end
			end
			
			if not IsVehicleStopped(Vehicle) then TaskVehicleTempAction(Driver, Vehicle, 6, 2) end
		elseif CONFIG.VEHICLES.all_unlocked and not DoesEntityExist(Driver) then
			SetVehicleDoorsLocked(Vehicle, 1)
		end
		
		if PlayerVehicle.is_entering then ClearPedTasksImmediately(PlayerPed) end
		TaskEnterVehicle(PlayerPed, Vehicle, 10000, SeatPlayerEntering, 2.0, 1, 0)
		SetPedConfigFlag(PlayerPed, 184, true) -- CPED_CONFIG_FLAG_PreventAutoShuffleToDriversSeat
		
		if DoesEntityExist(Driver) and not IsPedAPlayer(Driver) then
			Citizen.CreateThread(function()
				while not PlayerVehicle.is_inside and PlayerVehicle.vehicle == Vehicle do
					Wait(100)
					TaskSetBlockingOfNonTemporaryEvents(Driver, true)
				end
				
				Wait(1000)
				TaskVehicleDriveWander(Driver, Vehicle, 10.0, 447)
				d_print("Vehicle entered as passenger")
			end)
		end
		
		PlayerPassengerInVehicle = Vehicle
	elseif IsVarSetTrue(PlayerPassengerInVehicle) then
		local Driver = GetPedInVehicleSeat(PlayerPassengerInVehicle, -1)
		if DoesEntityExist(Driver) and not IsPedAPlayer(Driver) then
			SetPedCanBeDraggedOut(Driver, not CONFIG.NPC.cant_carjack)
			
			SetEntityCleanupByEngine(PlayerPassengerInVehicle, true)
			SetEntityCleanupByEngine(Driver, true)
			
			if not IsVehicleStopped(PlayerPassengerInVehicle) then
				Citizen.CreateThread(function()
					TaskVehicleTempAction(Driver, PlayerPassengerInVehicle, 6, 2)
					Wait(1000)
					TaskVehicleDriveWander(Driver, PlayerPassengerInVehicle, 10.0, 447)
					
					PlayerPassengerInVehicle = 0
				end)
			end
			
			d_print("Vehicle exited as passenger")
		else
			PlayerPassengerInVehicle = 0
		end
		
		SetPedConfigFlag(PlayerPed, 184, false) -- CPED_CONFIG_FLAG_PreventAutoShuffleToDriversSeat
	end
end

function TaskPlayerEnterVehicleAsPassenger()
	local ClosestVehicle = GetClosestVehicle(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, 10.0, 0, 70)
	
	if IsVarSetTrue(ClosestVehicle) then
		local Seat = GetVehicleFirstFreeSeat(ClosestVehicle, true)
		
		if Seat > -1 then
			SetNpcAsDriverForPlayer(ClosestVehicle, Seat)
		end
	end
end

function TaskPlayerPerformFriendlyCarjack(Vehicle, Ped, NetworkPlayer)
	local Player = NetworkPlayer or PlayerID
	if Vehicle.is_entering and (not DoesSetContain(NetworkPlayerIsEnteringVehicle, Player) or NetworkPlayerIsEnteringVehicle[Player] ~= Vehicle.vehicle) then
		AddToSet(NetworkPlayerIsEnteringVehicle, Player, Vehicle.vehicle)
		d_print("Player:  " .. Player .. " is attempting to enter vehicle:  " .. dump(Vehicle))
		
		if not NetworkPlayer then AnimatePed(PlayerPed, nil) end
		
		local PedInSeatPlayerEnt = GetPedInVehicleSeat(Vehicle.vehicle, Vehicle.seat)
		
		if Vehicle.seat == -1 and not DoesEntityExist(PedInSeatPlayerEnt) then
			if CONFIG.VEHICLES.all_unlocked then SetVehicleDoorsLocked(Vehicle.vehicle, 1) end
			if CONFIG.VEHICLES.no_hotwire then SetVehicleNeedsToBeHotwired(Vehicle.vehicle, false) end
		elseif CONFIG.NPC.prevent_visual_carjack > 0 and DoesEntityExist(PedInSeatPlayerEnt) and not IsPedAPlayer(PedInSeatPlayerEnt) then
			d_print("NPC sat in vehicle seat active player is entering, forcing ped to leave to skip jacking animations.")
			
			Citizen.CreateThread(function()
				if CONFIG.NPC.prevent_visual_carjack < 3 then
					if CONFIG.NPC.prevent_visual_carjack_passngers and Vehicle.seat == -1 then ForceAllNpcToLeaveVehicle(Vehicle.vehicle, true)
					else DeletePed(PedInSeatPlayerEnt) end
				end -- Delete ped in seat
				if CONFIG.NPC.prevent_visual_carjack == 2 and not NetworkPlayer then TaskEnterVehicle(Ped, Vehicle.vehicle, 5, Vehicle.seat, 2.0, 16, 0) end -- Teleport to seat
				if CONFIG.NPC.prevent_visual_carjack >= 3 then
					if CONFIG.NPC.prevent_visual_carjack == 4 and not NetworkPlayer then AnimatePed(Ped, {name = "wave_e", dict = "friends@frj@ig_1"}, 2000) end
					
					if Vehicle.seat ~= -1 then
						TaskNpcLeaveVehicle(Vehicle.vehicle, Ped, false, 131072)
					else
						if not IsVehicleStopped(Vehicle.vehicle) then TaskVehicleTempAction(PedInSeatPlayerEnt, Vehicle.vehicle, 6, 2) end
						
						if CONFIG.NPC.prevent_visual_carjack_passngers then ForceAllNpcToLeaveVehicle(Vehicle.vehicle, false, true) end
						
						-- 0 = normal exit and closes door, 1 = normal exit and closes door, 16 = teleports outside, door kept closed, 64 = normal exit and closes door, maybe a bit slower animation than 0, 256 = normal exit but does not close the door, 4160 = ped is throwing himself out, even when the vehicle is still, 262144 = ped moves to passenger seat first, then exits normally  
						--TaskLeaveVehicle(PedInSeatPlayerEnt, Vehicle.vehicle, 256)
						TaskLeaveVehicle(PedInSeatPlayerEnt, Vehicle.vehicle, 131072)
						
						if not NetworkPlayer then
							while GetVehiclePedIsIn(PedInSeatPlayerEnt, false) == Vehicle.vehicle do
								Citizen.Wait(5) -- Wait for the NPC to get out
							end
							ClearPedTasksImmediately(PedInSeatPlayerEnt)
							
							--Citizen.CreateThread(function()
								if CONFIG.NPC.prevent_visual_carjack == 4 then
									Citizen.CreateThread(function()
										TaskGotoEntityOffsetXy(PedInSeatPlayerEnt, Vehicle.vehicle, 5000, 0.0, 20.0, 0.0, 2.0, true)
										
										Citizen.Wait(4000)
										
										TaskWanderStandard(PedInSeatPlayerEnt, 10.0, 10) -- Prevents npc reclaiming vehicle
										AnimatePed(PedInSeatPlayerEnt, {name = "thumbs_up", dict = "anim@mp_player_intcelebrationmale@thumbs_up"})
									end)
								else
									TaskWanderStandard(PedInSeatPlayerEnt, 10.0, 10) -- Prevents npc reclaiming vehicle
								end
								d_print("Forcing previous driver NPC to wander.")
							--end)
							
							local Timeout = 10
							local InvalidateRequest = false
							while GetPedVehicleSeat(Ped, Vehicle.vehicle) ~= Vehicle.seat and Timeout > 0 do
								Citizen.Wait(5)
								if RunEveryX(5, false, "checkisentering") then
									Timeout = Timeout - 2
									
									local CheckRequestValidity = GetVehiclePedIsInOrEntering(Ped)
									if Vehicle.vehicle ~= CheckRequestValidity.vehicle and IsVarSetTrue(CheckRequestValidity.vehicle) then
										InvalidateRequest = true
										d_print("Vehicle no longer of interest:  " .. Vehicle.vehicle)
										break
									end
									
									if GetVehiclePedIsEntering(Ped) ~= Vehicle.vehicle
										and GetVehiclePedIsTryingToEnter(Ped) ~= Vehicle.vehicle
										and GetVehiclePedIsIn(Ped, false) ~= Vehicle.vehicle then
											d_print("Task enter vehicle timed out, resending command")
											ClearPedTasksImmediately(Ped)
											TaskEnterVehicle(Ped, Vehicle.vehicle, 1000, -1, 2.0, 1, 0)
									end
								end
							end
							
							-- Overcome issue with player ped getting back out once inside jacked vehicle, as well as other issues with getting in vehicle normally
							if not InvalidateRequest then
								-- MORE TESING REQUIRED
								--ClearPedTasksImmediately(Ped)
								TaskWarpPedIntoVehicle(Ped, Vehicle.vehicle, -1)
								--SetPedIntoVehicle(Ped, Vehicle.vehicle, -1)
								--SetPedKeepTask(Ped, true)
								SetVehicleDoorsShut(Vehicle.vehicle, false)
							end
						end
					end
				end	
			end)
		end
	end
end

function IsPlayerAGhost(ActivePlayer)
	if DoesSetContain(ActivePlayers, ActivePlayer) then
		if CONFIG.TRAINER.allow_ghost_to_others and ActivePlayers[ActivePlayer].is_ghost then return true end
	end
	return false
end

function RequestNewPedModel(Model, Name)
	TriggerServerEvent("ChangePlayerPed", {
		model_hash = GetHashKey(Model),
		model_name = Name,
		vehicle = PlayerVehicle.vehicle,
		seat = PlayerVehicle.seat
	})
end

RegisterNetEvent("SpawnServerDecision")
AddEventHandler("SpawnServerDecision", function(Data)
	d_print("The server has sent a decision based on your spawn request:  " .. dump(Data))
	
	if IsVarSetTrue(Data.error) then
		ShowNotification("~r~ ERROR:  " .. Data.decision, true, "spawndecisionerr")
	else
		ShowNotification(Data.decision, false, "spawndecision")
		
		if Data.type == 0 then -- Player ped swap
			--PlayerPed = PlayerPedId()
			--AllocatePermittedWeaponsToPlayer()
			--PedIsInvisible = false
		elseif Data.type == 1 then -- Vehicle spawn
			ShowNotification(Data.decision, false, "spawndecision")
			local SpawnVeh = GetEntityFromNetwork(Data.entity)
			
			if Data.is_a_clone then
				if CONFIG.VEHICLES.match_cloned_vehicle_speed then
					SetVehicleEngineOn(SpawnVeh, true, true, false)
					SetVehicleForwardSpeed(SpawnVeh, Data.speed)
				end
			end
			
			if Data.is_quick_spawn then
				LastQuickSpawn = SpawnVeh
				QuickSpawnRequested = 0
			end
		end
	end
end)

function GetTailPlayerCoords(Ped, ForceOutdoor, TailingEntity, TailingHash, SpawnInfront)
	local Entity = Ped
	if IsPedInAnyVehicle(Ped, false) then Entity = GetVehiclePedIsIn(Ped, false) end
	TailingEntity = TailingEntity or Entity
	TailingHash = TailingHash or GetEntityModel(TailingEntity)
	
	local Heading = GetEntityHeading(Entity)
	
	local MinPos, MaxPos = GetModelDimensions(GetEntityModel(Entity))
	local EntityLength = MaxPos.y - MinPos.y
	local MinPosTail, MaxPosTail = GetModelDimensions(TailingHash)
	local TailingEntityLength = MaxPosTail.y - MinPosTail.y
	
	local yVal = -(TailingEntityLength + (EntityLength / 2)+ 2)
	if SpawnInfront then 
		local EntityWidth = MaxPosTail.x - MinPosTail.x
		yVal = EntityWidth + 2
		Heading = Heading + 90
	end
	
	local Offset = GetOffsetFromEntityInWorldCoords(Entity, 0.0, yVal, 2)
	
	if ForceOutdoor then
		local EntityCoords = GetEntityCoords(Entity)
		if (IsPointOnRoad(EntityCoords.x, EntityCoords.y, EntityCoords.z, Entity) and not IsPointOnRoad(Offset.x, Offset.y, Offset.z, Entity))
			or not IsCollisionMarkedOutside(Offset.x, Offset.y, Offset.z) then
				local Retval, OutPosition, OutHeading = GetClosestVehicleNodeWithHeading(Offset.x, Offset.y, Offset.z, 1, 3.0, 0)
				
				d_print("Tailing coords not outdoors, found closest road. Old coords:  " .. dump(Offset) .. ", new coords:  " .. dump(OutPosition))
				Offset = OutPosition
				Heading = OutHeading
		end
	end
	
	return Offset, Heading
end

function TeleportPlayer(X, Y, Z, Heading, VehicleEntity, IntoVehicleSeat, ConfirmEntityGround)
	X = X or 0.0
	Y = Y or 0.0
	Z = Z or 0.0
	Heading = Heading or 0.0
	VehicleEntity = VehicleEntity or 0
	IntoVehicleSeat = IntoVehicleSeat or -2
	ConfirmEntityGround = ConfirmEntityGround or 0
	local WithVehicle = false
	if IsVarSetTrue(VehicleEntity) then WithVehicle = true end
	
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
		--Citizen.CreateThread(function()
			Citizen.Wait(1000)
			
			local GroundCheck = 0.0
			SetFocusPosAndVel(X, Y, GroundCheck)
			local Ground, GroundZ = GetGroundZFor_3dCoord(X, Y, 999.0, false)
			
			while not Ground and GroundCheck <= 800.0 do
				GroundCheck = GroundCheck + 40.0
				SetFocusPosAndVel(X, Y, GroundCheck)
				Ground, GroundZ = GetGroundZFor_3dCoord(X, Y, 999.0, true)
				Citizen.Wait(10)
			end
			ClearFocus()

			if Ground then
				d_print("Ground Z detected:  " .. GroundZ)
				SetEntityCoords(ConfirmEntityGround, X, Y, GroundZ, true, false, false)
			end
			
		--end)
	end
	
	--DoScreenFadeIn(500)
	BusyspinnerOff()
	RunPurgeProcessed = true
end

function IsPlayerNearby(ActivePlayerPed)
	if IsPedInAnyVehicle(ActivePlayerPed, false) and (GetVehiclePedIsIn(ActivePlayerPed, false) == PlayerVehicle.vehicle) then return true
	elseif IsPedInAnyVehicle(ActivePlayerPed, false) and not PlayerVehicle.is_inside then return false end
	
	local ActivePlayerPos = GetEntityCoords(ActivePlayerPed, false)
	if Vdist2(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, ActivePlayerPos.x, ActivePlayerPos.y, ActivePlayerPos.z) <= 5 then return true end
	
	return false
end

function BringPlayerIntoOneSyncScope(ActivePlayer)
	ExpectingPlayerUpdatePush = ActivePlayer
	TriggerServerEvent("GetUpdatedPlayerData", ActivePlayer)
	
	while ClientClock < ClientClock + 2 do
		if PlayerUpdatePushRecieved then
			d_print("Using updated player data to find entity scope")
			PlayerUpdatePushRecieved = false
			break
		end
		Citizen.Wait(100)
	end
	
	StartPlayerTeleport(PlayerID, ActivePlayers[ActivePlayer].coords.x, ActivePlayers[ActivePlayer].coords.y, 999.0, 0, true, false, true)
	SetFreezePlayer(true)
	
	while IsPlayerTeleportActive() do
		Citizen.Wait(100)
	end
	
	SetFreezePlayer(false)
	
	while ClientClock < ClientClock + 5 do
		if DoesEntityExist(GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped)) then
			d_print("Entity now in scope, entity:  " .. ActivePlayers[ActivePlayer].ped)
			return true
		end
		Citizen.Wait(100)
	end
	
	d_print("Entity still not found, entity:  " .. ActivePlayers[ActivePlayer].ped)
	return false
end

function TeleportToPlayer()
	Citizen.CreateThread(function()
		if not IsTeleporting then
			IsTeleporting = true
			
			local hasTeleported = false
			local alreadyWithActivePlayer = false
			local currentLocation = CurrentCoords
			local locationHasChanged = false
			
			d_print("Looking for active network players to teleport to.")
			d_print(dump(ActivePlayers))
			
			local ActivePlayerIndexes = RandomiseIndexes(ActivePlayers)
			d_print("Active players randomised:  " .. dump(ActivePlayerIndexes))
			if next(ActivePlayerIndexes) ~= nil then
				for _,ActivePlayer in pairs(ActivePlayerIndexes) do
					if not ActivePlayers[ActivePlayer].is_ghost then
						local ActivePlayerPed = GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped)
						
						local InScope = true
						if not DoesEntityExist(ActivePlayerPed) then
							d_print("Active player's ped not found in your scope, trying to fix by teleporting to player's pos, player:  " .. ActivePlayer)
							InScope = BringPlayerIntoOneSyncScope(ActivePlayer)
							locationHasChanged = true
							ActivePlayerPed = GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped)
						end
						if InScope and DoesEntityExist(ActivePlayerPed) then
							if not IsPlayerNearby(ActivePlayerPed) then
								if IsVarSetTrue(PlayerVehicle.vehicle) and PlayerVehicle.seat == -1 then
									d_print("Teleporting with vehicle to active player's location.")
									
									if PlayerVehicle.is_entering then ForcePedInVehicleNow(PlayerPed, PlayerVehicle.vehicle) end
									
									local coords, heading = GetTailPlayerCoords(ActivePlayerPed, true, PlayerVehicle.vehicle)
									TeleportPlayer(coords.x, coords.y, coords.z, heading, PlayerVehicle.vehicle)
									
									if CONFIG.NETWORK.teleport_match_vehicle_speed and IsPedInAnyVehicle(ActivePlayerPed, false) then
										SetVehicleEngineOn(PlayerVehicle.vehicle, true, true, false)
										SetVehicleForwardSpeed(PlayerVehicle.vehicle, GetEntitySpeed(ActivePlayerPed))
									end
									
									hasTeleported = true
								end
								if IsPedInAnyVehicle(ActivePlayerPed, false) and not hasTeleported then
									local vehIn = GetVehiclePedIsIn(ActivePlayerPed, false)
									local firstFreeSeat = GetVehicleFirstFreeSeat(vehIn)
									
									if firstFreeSeat > -2 then
										d_print("Teleporting to active player's vehicle.")
										TeleportPlayer(nil, nil, nil, nil, vehIn, firstFreeSeat)
										hasTeleported = true
									end
								end
								if not hasTeleported then
									d_print("Teleporting to active player's location.")
									
									local coords, heading = GetTailPlayerCoords(ActivePlayerPed, false, PlayerPed)
									TeleportPlayer(coords.x, coords.y, coords.z, heading)
									hasTeleported = true
								end
								
								if hasTeleported then
									ShowNotification("Teleported to:   ~g~" .. ActivePlayers[ActivePlayer].player_name, false, "teleportplayer")
									break
								end
							else
								alreadyWithActivePlayer = true
							end
						end
					end
				end
				
				if locationHasChanged and not hasTeleported then
					TeleportPlayer(currentLocation.x, currentLocation.y, currentLocation.z, 0)
				end
				
				if not hasTeleported and alreadyWithActivePlayer then
					ShowNotification("~r~You're already close to the only available active player(s)", true, "teleportplayer")
				elseif not hasTeleported then
					ShowNotification("~r~Unable to teleport you to any active player(s)", true, "teleportplayer")
				else
					TriggerServerEvent("ReportLocationUpdated")
					d_print("Reporting to server that local player has teleported")
				end
			else
				d_print("No active network players found to teleport to.")
				ShowNotification("~r~No players found to teleport to", true, "teleportplayer")
			end
			
			IsTeleporting = false
		end
	end)
end

function TeleportToWaypoint()
	local Waypoint = GetFirstBlipInfoId(8)
	
	if Waypoint ~= 0 then
		local Coords = GetBlipCoords(Waypoint)
		local Heading = 0
		local WithVehicle = nil
		local CheckEntity = PlayerPed
		
		if IsVarSetTrue(PlayerVehicle.vehicle) and PlayerVehicle.seat == -1 then
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
		
		TriggerServerEvent("ReportLocationUpdated")
		d_print("Reporting to server that local player has teleported")
		
		return true
	end
	ShowNotification("~r~No waypoint set", true, "teleportwaypoint")
	return false
end

function CloneVehicle(ForceModelByName, ForceFacing)
	if IsVarSetTrue(ForceModelByName) or IsPedInAnyVehicle(PlayerPed, false) then
		local ModelHash = nil
		local ModelName = nil
		if IsVarSetTrue(ForceModelByName) then
			ModelHash = GetHashKey(ForceModelByName)
			ModelName = SPAWN_ITEMS.VEHICLES[ForceModelByName]
		else
			ModelHash = GetEntityModel(PlayerVehicle.vehicle)
			ModelName = GetLabelText(GetDisplayNameFromVehicleModel(ModelHash))
		end
		
		local Facing = false
		local TeleportInside = CONFIG.VEHICLES.teleport_inside_spawned
		local QuickSpawn = false
		if ForceFacing or (not TeleportInside and IsVarSetTrue(ForceModelByName)) then
			Facing = true
			TeleportInside = false
			if ForceFacing then QuickSpawn = true end
		end
		local Coords, Heading = GetTailPlayerCoords(PlayerPed, true, nil, ModelHash, Facing)
		
		TriggerServerEvent("SpawnVehicle", {
			clone_entity = NetworkGetNetworkIdFromEntity(PlayerVehicle.vehicle),
			force_model = ForceModelByName,
			model_name = ModelName,
			coords = Coords,
			heading = Heading,
			speed = GetEntitySpeed(PlayerPed),
			teleport_inside = TeleportInside,
			quick_spawn = QuickSpawn
		})
	end
end

function ForcePedInVehicleNow(Ped, Vehicle, Seat)
	Seat = Seat or -1
	
	local PedInSeat = GetPedInVehicleSeat(Vehicle, Seat)
	if IsPedNpc(PedInSeat) then ForceAllNpcToLeaveVehicle(Vehicle, true)
	elseif IsPedAPlayer(PedInSeat) then Seat = GetVehicleFirstFreeSeat(Vehicle) end
	
	if Seat > -2 then TaskWarpPedIntoVehicle(Ped, Vehicle, Seat) end
	Citizen.Wait(500) -- Wait to confirm ped is in vehicle
end

function HasPedVehicleChanged(Ped, LastVehicle)
	local VehicleCurrent = 0
	if IsPedInAnyVehicle(Ped, false) then VehicleCurrent = GetVehiclePedIsIn(Ped, false)
	elseif DoesEntityExist(GetVehiclePedIsTryingToEnter(Ped)) then VehicleCurrent = GetVehiclePedIsTryingToEnter(Ped) end
	
	return VehicleCurrent ~= LastVehicle.vehicle
end

function GetVehiclePedIsInOrEntering(Ped)
	local PedVehicle = {is_entering = false, is_inside = false, vehicle = 0, seat = -2}
	
	if IsPedInAnyVehicle(Ped, false) then
		PedVehicle.is_inside = true
		PedVehicle.vehicle = GetVehiclePedIsIn(Ped, false)
		PedVehicle.seat = GetPedVehicleSeat(Ped, PedVehicle.vehicle)
		
		if PlayerPed == Ped then
			LastPlayerVehicle.vehicle = 0
			LastPlayerVehicle.seat = -2
		end
	elseif DoesEntityExist(GetVehiclePedIsTryingToEnter(Ped)) then
		PedVehicle.is_entering = true
		PedVehicle.vehicle = GetVehiclePedIsTryingToEnter(Ped)
		PedVehicle.seat = GetSeatPedIsTryingToEnter(Ped)
	end
	
	if PlayerPed == Ped then
		if PlayerVehicle.is_inside and IsVarSetTrue(PlayerVehicle.vehicle) and PlayerVehicle.vehicle ~= PedVehicle.vehicle then
			LastPlayerVehicle.vehicle = PlayerVehicle.vehicle
			LastPlayerVehicle.seat = PlayerVehicle.seat
			
			if not CONFIG.PLAYERS.prevent_ragdoll_flags.disable_all
				and CONFIG.PLAYERS.prevent_ragdoll_flags._prevent_when_leaving_moving_vehicle
				and GetEntitySpeed(LastPlayerVehicle.vehicle) > 5.0
				and not PedVehicle.is_inside then
					VehicleJustExitedWhileMoving = true
			end
			
			if VehicleIsInvisible then
				NetworkSetEntityInvisibleToNetwork(LastPlayerVehicle.vehicle, false)
				SetEntityAlpha(LastPlayerVehicle.vehicle, 255, false)
				if PedIsInvisible then SetEntityAlpha(PlayerPed, 200, false) end
				VehicleIsInvisible = false
			end
			
			EjectAllNpcIfNoDriver(LastPlayerVehicle.vehicle)
			if PlayerVehicle.seat == -1 then ForceVehicleColour(LastPlayerVehicle.vehicle) end
		end
		
		if PlayerVehicle.vehicle ~= PedVehicle.vehicle
			or PlayerVehicle.seat ~= PedVehicle.seat
			or PlayerVehicle.is_inside ~= PedVehicle.is_inside then
			if CONFIG.VEHICLES.lock_player_vehicle_colour and PedVehicle.is_inside and PedVehicle.seat == -1 then
				ForceVehicleColour(PedVehicle.vehicle, CONSTANT.COLOURS[CONFIG.VEHICLES.lock_primary_colour_to], CONFIG.VEHICLES.also_lock_secondary_colour)
			end
			
			if PedVehicle.is_inside or (not PedVehicle.is_inside and not PedVehicle.is_entering) then
				local PassengerCapacity = 0
				local VehicleColour = nil
				if PedVehicle.is_inside then
					PassengerCapacity = GetVehicleMaxNumberOfPassengers(PedVehicle.vehicle)
					if CONFIG.VEHICLES.lock_player_vehicle_colour then VehicleColour = CONSTANT.COLOURS[CONFIG.VEHICLES.lock_primary_colour_to] end
				end
				-- Currently unused - v0.2
				TriggerServerEvent("PlayerVehicleChanged", {vehicle = PedVehicle.vehicle, seat = PedVehicle.seat, passenger_capacity = PassengerCapacity, vehicle_colour = VehicleColour})
			
				d_print("New vehicle/seat recorded: " .. dump(PedVehicle))
				d_print("Last vehicle recorded: " .. dump(LastPlayerVehicle))
			end
			
			if PedVehicle.is_inside and PedVehicle.vehicle == LastQuickSpawn then
				LastQuickSpawn = 0
			end
			
			if IsVarSetTrue(PlayerPassengerInVehicle) and PlayerPassengerInVehicle ~= PedVehicle.vehicle then
				SetNpcAsDriverForPlayer()
			end
		end
	end
	
	return PedVehicle
end

function VehicleLimitDamage(Vehicle, OccupiedPedType)
	-- OccupiedPedType: 1 = Player, 2 = Player + NPC
	
	if CONFIG.VEHICLES.invincible >= OccupiedPedType then
		SetEntityInvincible(Vehicle, true)
		SetDisableVehicleEngineFires(Vehicle, true)
		SetDisableVehiclePetrolTankDamage(Vehicle, true)
		SetVehicleExplodesOnHighExplosionDamage(Vehicle, false)
		
		if CONFIG.VEHICLES.invincible_keep_damage_physics then
			SetEntityCanBeDamaged(Vehicle, true)
			SetEntityProofs(Vehicle, false, true, false, true, true, true, true, true)
		end
	end
	
	if CONFIG.VEHICLES.repair_damage >= OccupiedPedType then
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
		
	if CONFIG.VEHICLES.repair_damage == OccupiedPedType then
		if IsVehicleVisibilyDamaged(Vehicle) then
			SetVehicleFixed(Vehicle)
		end
	end
	
	if CONFIG.VEHICLES.keep_clean == OccupiedPedType and GetVehicleDirtLevel(Vehicle) > 0.0 then
		WashDecalsFromVehicle(Vehicle, 1.0)
		SetVehicleDirtLevel(Vehicle, 0.0)
	end
end

--[[
function IsComboControlKeysSet(KeyOne, KeyTwo)
	if KeyOne ~= -1 or KeyTwo ~= -1 then return true end
	return false
end

function IsComboControlJustPressed(KeyOne, KeyTwo)
	if not IsComboControlKeysSet(KeyOne, KeyTwo) then return false end
	if IsControlJustPressed(0, KeyOne) and (KeyTwo == -1 or IsControlPressed(0, KeyTwo)) then return true end
	if IsControlJustPressed(0, KeyTwo) and (KeyOne == -1 or IsControlPressed(0, KeyOne)) then return true end
	return false
end

function IsComboControlPressed(KeyOne, KeyTwo)
	if not IsComboControlKeysSet(KeyOne, KeyTwo) then return false end
	if IsControlPressed(0, KeyOne) and (KeyTwo == -1 or IsControlPressed(0, KeyTwo)) then return true end
	if IsControlPressed(0, KeyTwo) and (KeyOne == -1 or IsControlPressed(0, KeyOne)) then return true end
	return false
end
]]--

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
		StopAudioScenes()
		StartAudioScene("END_CREDITS_SCENE") -- No background noises (traffic etc), only radios
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
		DisplayScreenText(TableLength(ActivePlayers) +1 .. " online", 0.18, 0.94, 0.2)
	end
end

function DisplayCoords()
	if not FullscreenBlackout and CurrentCoords ~= nil then
		local CurrentVehicleName = ""
		if PlayerVehicle.is_inside then CurrentVehicleName = ", Vehicle: " .. GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(PlayerVehicle.vehicle))) end
		DisplayScreenText("X: " .. string.format("%.3f", CurrentCoords.x) .. " Y: " .. string.format("%.3f", CurrentCoords.y) .. " Z: " .. string.format("%.3f", CurrentCoords.z) .. CurrentVehicleName, 0.18, 0.96, 0.2)
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

function AnimatePed(Ped, Emote, Duration)
	if Emote == nil then
		if DoesSetContain(LastSetPedAnim, Ped) then
			if IsEntityPlayingAnim(Ped, LastSetPedAnim[Ped].dict, LastSetPedAnim[Ped].name, 3) then
				d_print("Stopping emote:  " .. dump(LastSetPedAnim[Ped]) .. " from playing with ped:  " .. Ped)
				StopAnimTask(Ped, LastSetPedAnim[Ped].dict, LastSetPedAnim[Ped].name, 1.0)
			end
			RemoveFromSet(LastSetPedAnim, Ped)
		end
	else
		AnimatePed(Ped, nil)
		d_print("Emote called:  " .. dump(Emote))
		
		Duration = Duration or 5000
		
		LoadAnimDict(Emote.dict)
		TaskPlayAnim(Ped, Emote.dict, Emote.name, 8.0, 8.0, Duration, 120, 1, false, false, false)

		AddToSet(LastSetPedAnim, Ped, Emote)
	end
end

function ForceVehicleColour(Vehicle, Colour, IncludeSecondary)
	if Colour ~= nil then
		SetVehicleCustomPrimaryColour(Vehicle, Colour.r, Colour.g, Colour.b)
		if IncludeSecondary then SetVehicleCustomSecondaryColour(Vehicle, Colour.r, Colour.g, Colour.b) end
	else
		ClearVehicleCustomPrimaryColour(Vehicle)
		ClearVehicleCustomSecondaryColour(Vehicle)
	end
end

function OverrideNetworkTime(Miliseconds, LockHour)
	if LockHour ~= nil and LockHour >= -1 and CurrentLockHour ~= LockHour then
		local LockMin = 0
		if LockHour == -1 then
			local year, month, day, hour, minute, second = GetLocalTime()
			LockHour = hour
			LockMin = minute
		end
		NetworkOverrideClockTime(LockHour, LockMin, 0)
		CurrentLockHour = LockHour
	end
		
	if CurrentMilisecondsPerMin ~= Miliseconds then
		NetworkOverrideClockMillisecondsPerGameMinute(Miliseconds)
		CurrentMilisecondsPerMin = Miliseconds
	end
end
--------------------------------
--------------------------------
-- GENERAL CUSTOM NATIVES END --
--------------------------------
--------------------------------

--------------------------------
--------------------------------
-- NET PLAYER HANDLERS START ---
--------------------------------
--------------------------------
function GetEntityFromNetwork(NetEntity)
	return NetworkDoesEntityExistWithNetworkId(NetEntity) and NetworkGetEntityFromNetworkId(NetEntity) or nil
end

function PurgePlayerBlip(ActivePlayer, ForceRefresh)
	if next(ActivePlayerBlips) ~= nil and DoesSetContain(ActivePlayerBlips, ActivePlayer) then
		local ActivePlayerPed = nil
		if DoesSetContain(ActivePlayers, ActivePlayer) then
			ActivePlayerPed = GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped)
		end
		
		if not DoesSetContain(ActivePlayers, ActivePlayer)
			or (ActivePlayerBlips[ActivePlayer].on_entity and not DoesEntityExist(ActivePlayerPed))
			or (not ActivePlayerBlips[ActivePlayer].on_entity and DoesEntityExist(ActivePlayerPed))
			or IsPlayerAGhost(ActivePlayer) then
			
			d_print("Dropping blip for player:  " .. ActivePlayer .. ", blip details:  ".. dump(ActivePlayerBlips[ActivePlayer]))
			if DoesBlipExist(ActivePlayerBlips[ActivePlayer].blip) then RemoveBlip(ActivePlayerBlips[ActivePlayer].blip) end
			ActivePlayerBlips[ActivePlayer] = nil
			
			if ForceRefresh and DoesSetContain(ActivePlayers, ActivePlayer) then
				d_print("Blip status change detected, forcing refresh for player:  " .. ActivePlayer)
				MakeMarkersForPlayer(ActivePlayer)
			end
		end
	end
end

function PurgeAllPlayerBlips(ForceRefresh)
	if next(ActivePlayerBlips) ~= nil then
		for ActivePlayer, Blip in pairs(ActivePlayerBlips) do
			PurgePlayerBlip(ActivePlayer, ForceRefresh)
		end
	end
end

function PurgeAllPlayerFx()
	if next(ActivePlayersWithFxAttached) ~= nil then
		for ActivePlayer, Fx in pairs(ActivePlayersWithFxAttached) do
			local ActivePlayerPed = nil
			if ActivePlayers[ActivePlayer] ~= nil then ActivePlayerPed = GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped) end
			
			if not DoesEntityExist(ActivePlayerPed)
				or not IsPedAPlayer(ActivePlayerPed)
				or IsPlayerAGhost(ActivePlayer) then
					d_print("Dropping FX for player:  " .. ActivePlayer .. ", FX:  ".. Fx)
					if DoesParticleFxLoopedExist(Fx) then RemoveParticleFx(Fx, false) end
					ActivePlayersWithFxAttached[ActivePlayer] = nil
				end
		end
	end
	
	if next(VehiclesWithFxAttached) ~= nil then
		for Vehicle, Fx in pairs(VehiclesWithFxAttached) do
			if not IsAnyPlayerInVehicle(Vehicle, PlayerPed) or not DoesEntityExist(Vehicle) then
				d_print("Dropping FX for vehicle:  " .. Vehicle .. ", FX:  ".. Fx)
				if DoesParticleFxLoopedExist(Fx) then RemoveParticleFx(Fx, false) end
				VehiclesWithFxAttached[Vehicle] = nil
			end
		end
	end
end

RegisterNetEvent("ActivePlayerDropped")
AddEventHandler("ActivePlayerDropped", function(Player)
	d_print("Active player has dropped:  " .. Player .. ",  adjusting ActivePlayers list and purging blips and FX")
	
	RemoveFromSet(ActivePlayers, Player, true)
	PurgePlayerBlip(Player)
	PurgeAllPlayerFx()
end)

RegisterNetEvent("UpdatedPlayerData")
AddEventHandler("UpdatedPlayerData", function(Data)
	if GetPlayerServerId(PlayerID) ~= Data.player and Data.data ~= nil then
		if ExpectingPlayerUpdatePush == Data.player then
			PlayerUpdatePushRecieved = true
			ExpectingPlayerUpdatePush = -1
		end
		ActivePlayers[Data.player] = Data.data
		
		d_print("Updated player data recieved for:  " .. Data.player .. ", data:  " .. dump(ActivePlayers[Data.player]))
		PurgePlayerBlip(Data.player, true)
	end
end)

RegisterNetEvent("UpdateActivePlayers")
AddEventHandler("UpdateActivePlayers", function(NetPlayers)
	ActivePlayers = NetPlayers
	d_print("Active player data recieved:  " .. dump(ActivePlayers))
	
	RefreshAllPlayerMarkers()
end)

function MakeMarkersForPlayer(ActivePlayer)
	local ActivePlayerPed = GetEntityFromNetwork(ActivePlayers[ActivePlayer].ped)
	local ActivePlayerLocalId = NetworkGetPlayerIndexFromPed(ActivePlayerPed)
	
	--d_print("Ped found for Active player:  " .. ActivePlayer .. " (local ID: " .. ActivePlayerLocalId .. ", with ped:  " .. tostring(ActivePlayerPed))
	
	local DrawNewBlip = true
	local UpdateBlipCoords = false
	if next(ActivePlayerBlips) ~= nil then
		if DoesSetContain(ActivePlayerBlips, ActivePlayer) then
			DrawNewBlip = false
			UpdateBlipCoords = true
		end
	end
	
	if CONFIG.NETWORK.active_player_blips and DrawNewBlip and not IsPlayerAGhost(ActivePlayer) then
		if DoesEntityExist(ActivePlayerPed) then
			local Blip = AddBlipForEntity(ActivePlayerPed)
			ShowOutlineIndicatorOnBlip(Blip, CONFIG.NETWORK.outline_nearby_blips)
			SetBlipSprite(Blip, 480) -- Blip IDs: https://docs.fivem.net/docs/game-references/blips/
			SetBlipDisplay(Blip, 2) -- 2 = Bothn 3 = Map only, 5 = Minimap only
			SetBlipScale(Blip, 1.0)
			SetBlipColour(Blip, 2) -- Colours: https://docs.fivem.net/docs/game-references/blips/#BlipColors
			SetBlipAsShortRange(Blip, CONFIG.NETWORK.nearby_blips_only) -- Sets whether or not the specified blip should only be displayed when nearby, or on the minimap
			
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(ActivePlayers[ActivePlayer].player_name)
			EndTextCommandSetBlipName(Blip)
			
			AddToSet(ActivePlayerBlips, ActivePlayer, {on_entity = true, blip = Blip})
			d_print("Adding blip for player:  " .. ActivePlayer .. ", with ped:  " .. ActivePlayerPed)
		else
			local Blip = AddBlipForCoord(ActivePlayers[ActivePlayer].coords.x, ActivePlayers[ActivePlayer].coords.y, ActivePlayers[ActivePlayer].coords.z)
			--SetBlipShrink(Blip, true)
			SetBlipSprite(Blip, 480) -- Blip IDs: https://docs.fivem.net/docs/game-references/blips/
			SetBlipDisplay(Blip, 2) -- 2 = Bothn 3 = Map only, 5 = Minimap only
			SetBlipScale(Blip, 1.0)
			SetBlipColour(Blip, 2) -- Colours: https://docs.fivem.net/docs/game-references/blips/#BlipColors
			SetBlipAsShortRange(Blip, CONFIG.NETWORK.nearby_blips_only) -- Sets whether or not the specified blip should only be displayed when nearby, or on the minimap
			
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(ActivePlayers[ActivePlayer].player_name)
			EndTextCommandSetBlipName(Blip)
			
			AddToSet(ActivePlayerBlips, ActivePlayer, {on_entity = false, blip = Blip})
			d_print("Adding blip for player:  " .. ActivePlayer .. ", with coords:  " .. dump(ActivePlayers[ActivePlayer].coords))
		end
	elseif UpdateBlipCoords and not DoesEntityExist(ActivePlayerPed) then
		local Blip = ActivePlayerBlips[ActivePlayer].blip
		SetBlipCoords(Blip, ActivePlayers[ActivePlayer].coords.x, ActivePlayers[ActivePlayer].coords.y, ActivePlayers[ActivePlayer].coords.z)
		
		d_print("Updating blip for player:  " .. ActivePlayer .. ", with coords:  " .. dump(ActivePlayers[ActivePlayer].coords))
	end
	
	local ActivePlayerVehicle = 0
	if DoesEntityExist(ActivePlayerPed) and not IsPlayerAGhost(ActivePlayer) then
		if CONFIG.NETWORK.show_animated_marker then
			if IsPedInAnyVehicle(ActivePlayerPed, false) then
				ActivePlayerVehicle = GetVehiclePedIsIn(ActivePlayerPed, false)
			end
			
			local MakeNewFx = false
			if IsVarSetTrue(ActivePlayerVehicle) then
				if DoesSetContain(VehiclesWithFxAttached, ActivePlayerVehicle) then
					MakeNewFx = not DoesParticleFxLoopedExist(VehiclesWithFxAttached[ActivePlayerVehicle])
					if MakeNewFx then RemoveFromSet(VehiclesWithFxAttached, ActivePlayerVehicle) end
				else
					MakeNewFx = true
				end
				
				if DoesSetContain(ActivePlayersWithFxAttached, ActivePlayer) then
					if DoesParticleFxLoopedExist(ActivePlayersWithFxAttached[ActivePlayer]) then
						RemoveParticleFx(ActivePlayersWithFxAttached[ActivePlayer], false)
					end
					RemoveFromSet(ActivePlayersWithFxAttached, ActivePlayer)
				end
			else
				if DoesSetContain(ActivePlayersWithFxAttached, ActivePlayer) then
					MakeNewFx = not DoesParticleFxLoopedExist(ActivePlayersWithFxAttached[ActivePlayer])
					if MakeNewFx then RemoveFromSet(ActivePlayersWithFxAttached, ActivePlayer) end
				else
					MakeNewFx = true
				end
			end
			
			if MakeNewFx then
				LoadFxDict(CONSTANT.PARTICLES.flare.dict)
				
				local Entity = ActivePlayerPed
				if IsVarSetTrue(ActivePlayerVehicle) then Entity = ActivePlayerVehicle end
				
				local Fx = StartParticleFxLoopedOnEntity(CONSTANT.PARTICLES.flare.name, Entity, 0, 0, 3.0, 0, 0, 0, 1.0, false, false, false)
				SetParticleFxLoopedColour(Fx, CONSTANT.COLOURS.green.r, CONSTANT.COLOURS.green.g, CONSTANT.COLOURS.green.b, false)
				if IsVarSetTrue(ActivePlayerVehicle) then AddToSet(VehiclesWithFxAttached, ActivePlayerVehicle, Fx)
				else AddToSet(ActivePlayersWithFxAttached, ActivePlayer, Fx) end
				
				d_print("Starting animated marker for player:  " .. ActivePlayer .. ", FX:  "  .. tostring(Fx))
			end
		end
		
		if CONFIG.NETWORK.show_gamertag_above_ped or CONFIG.NETWORK.show_chevron_above_ped then
			if not IsMpGamerTagActive(ActivePlayerLocalId) then
				-- Create gamer tag
				d_print("Adding a new game tag for player:  " .. ActivePlayer)
				CreateMpGamerTagWithCrewColor(ActivePlayerLocalId, ActivePlayers[ActivePlayer].player_name, false, false, "", 0, 0, 0, 0)
				SetMpGamerTagVisibility(ActivePlayerLocalId, 0, CONFIG.NETWORK.show_gamertag_above_ped)
				SetMpGamerTagVisibility(ActivePlayerLocalId, 21, CONFIG.NETWORK.show_chevron_above_ped)
			end
		end
	else
		if IsMpGamerTagActive(ActivePlayerLocalId) then RemoveMpGamerTag(ActivePlayerLocalId) end
	end
end

function RefreshAllPlayerMarkers()
	PurgeAllPlayerBlips()
	PurgeAllPlayerFx()
	
	for ActivePlayer,Data in pairs(ActivePlayers) do
		if GetPlayerServerId(PlayerID) == ActivePlayer then
			ActivePlayers[ActivePlayer] = nil
			if IsMpGamerTagActive(PlayerID) then RemoveMpGamerTag(PlayerID) end
		else
			MakeMarkersForPlayer(ActivePlayer)
		end
	end
end


AddEventHandler('onClientResourceStop', function(resource)
	TriggerServerEvent('ResourceStopped', resource)
end)
--------------------------------
--------------------------------
-- NET PLAYER HANDLERS END -----
--------------------------------
--------------------------------

------------------------------
------------------------------
---- KEY MAPS ----------------
------------------------------
------------------------------
local ComboKeyPressed = {
	["trainer_toggle"] = {
		[1] = false,
		[2] = false
	},
	["trainer_parental"] = {
		[1] = false,
		[2] = false
	},
	["teleport_to_player"] = {
		[1] = false,
		[2] = false
	},
	["vehicle_quick_spawn"] = {
		[1] = false,
		[2] = false
	},
	["ped_quick_change"] = {
		[1] = false,
		[2] = false
	},
	["teleport_to_last_vehicle"] = {
		[1] = false,
		[2] = false
	},
	["clone_vehicle"] = {
		[1] = false,
		[2] = false
	},
	["taxi_call"] = {
		[1] = false,
		[2] = false
	},
	["taxi_leave"] = {
		[1] = false,
		[2] = false
	},
	["enter_as_passenger"] = {
		[1] = false,
		[2] = false
	},
	["simple_emote"] = {
		[1] = false,
		[2] = false
	}
}

function RunHotkey(RunFunction, ComboButton, RunOnExit, OnlyRunIfClear)
	if ComboButton ~= nil then ComboKeyPressed[RunFunction][ComboButton] = not ComboKeyPressed[RunFunction][ComboButton] end
	
	local isClear = true
	if OnlyRunIfClear 
		and ((CONFIG.TRAINER.allow_trainer and _menuPool:IsAnyMenuOpen()) 
			or IsPauseMenuActive()
			or IsHudComponentActive(19)) then
				isClear = false
	end
	
	if isClear
		and (ComboButton == nil
		or (ComboKeyPressed[RunFunction][1] and ComboKeyPressed[RunFunction][2])
		or (RunOnExit and ComboButton ~= nil and not ComboKeyPressed[RunFunction][1] and not ComboKeyPressed[RunFunction][2])) then
			if RunFunction == "trainer_toggle" then
				mainMenu:Visible(not mainMenu:Visible())
			elseif RunFunction == "trainer_parental" then
				if ComboButton == nil then AllowParentalControl = not AllowParentalControl end
				if ComboKeyPressed["trainer_parental"][1] and ComboKeyPressed["trainer_parental"][2] then AllowParentalControl = true end
				if RunOnExit and ComboButton ~= nil and not ComboKeyPressed["trainer_parental"][1] and not ComboKeyPressed["trainer_parental"][2] then AllowParentalControl = false end
			elseif RunFunction == "teleport_to_player" then
				if TableLength(ActivePlayerBlips) == 0 then TeleportToWaypoint() 
				else TeleportToPlayer() end
			elseif RunFunction == "ped_quick_change" then
				if not PlayerVehicle.is_inside and next(SPAWN_ITEMS.VEHICLES) ~= nil then
					if QuickPedIndex > TableLength(SPAWN_ITEMS.PEDS) then QuickPedIndex = 1 end
					
					local Model, Name = GetFromSetAtPosX(SPAWN_ITEMS.PEDS, QuickPedIndex)
					d_print("Random ped model is:  " .. Model)
					RequestNewPedModel(Model, Name)
					
					QuickPedIndex = QuickPedIndex + 1
				end
			elseif RunFunction == "vehicle_quick_spawn" then
				if not PlayerVehicle.is_inside and next(SPAWN_ITEMS.VEHICLES) ~= nil then
					if ClientClock > QuickSpawnRequested then
						if IsVarSetTrue(LastQuickSpawn) then
							if DoesEntityExist(LastQuickSpawn) then DeleteEntity(LastQuickSpawn) end
							LastQuickSpawn = 0
						end
						
						if QuickSpawnIndex > TableLength(SPAWN_ITEMS.VEHICLES) then QuickSpawnIndex = 1 end
						
						local Model, Name = GetFromSetAtPosX(SPAWN_ITEMS.VEHICLES, QuickSpawnIndex)
						d_print("Random vehicle model is:  " .. Model)
						
						QuickSpawnIndex = QuickSpawnIndex + 1
						QuickSpawnRequested = ClientClock + 2
						CloneVehicle(Model, true)
					end
				end
			elseif RunFunction == "teleport_to_last_vehicle" then
				if not PlayerVehicle.is_inside and DoesEntityExist(LastPlayerVehicle.vehicle) then
					local RegainSeat = LastPlayerVehicle.seat
					local IsSeatTaken = GetPedInVehicleSeat(LastPlayerVehicle.vehicle, LastPlayerVehicle.seat)
					if IsVarSetTrue(IsSeatTaken) then RegainSeat = GetVehicleFirstFreeSeat(LastPlayerVehicle.vehicle) end
					
					ForcePedInVehicleNow(PlayerPed, LastPlayerVehicle.vehicle, RegainSeat)
				end
			elseif RunFunction == "clone_vehicle" then
				if PlayerVehicle.is_inside then
					CloneVehicle()
				end
			elseif RunFunction == "taxi_call" or RunFunction == "taxi_leave" then
				if PlayerVehicle.is_inside and PlayerVehicle.seat == -1 then
					local HotkeySame = false
					if ComboButton == nil and CONFIG.VEHICLES.taxi_npcs_call_keyboard_hotkey == CONFIG.VEHICLES.taxi_npcs_leave_keyboard_hotkey then HotkeySame = true end
					if ComboButton ~= nil and CONFIG.VEHICLES.taxi_npcs_call_controller_hotkey == CONFIG.VEHICLES.taxi_npcs_leave_controller_hotkey then HotkeySame = true end
					
					if RunFunction == "taxi_leave" and not HotkeySame then
						CollectNpcPassengers(PlayerVehicle.vehicle, true, false)
					else
						CollectNpcPassengers(PlayerVehicle.vehicle, false, HotkeySame)
					end
				end
			elseif RunFunction == "enter_as_passenger" then
				if not PlayerVehicle.is_inside then
					TaskPlayerEnterVehicleAsPassenger()
				end
			elseif RunFunction == "simple_emote" then
				if not PlayerVehicle.is_inside and not PlayerVehicle.is_entering then
					AnimatePed(PlayerPed, CONSTANT.EMOTES[math.random(#CONSTANT.EMOTES)])
				end
			end
	end
	
	d_print("Hotkey pressed for function:  " .. RunFunction .. ", combo keys currently pressed:  " .. dump(ComboKeyPressed[RunFunction]))
end

function SetHotkeys(RunFunction, ControllerOne, ControllerTwo, Keyboard, Description, RunOnDepress, OnlyRunIfClear)
	local Combo1Suffix = ""
	local Combo2Suffix = ""
	if IsVarSetTrue(ControllerOne) and IsVarSetTrue(ControllerTwo) then
		Combo1Suffix = " combo 1"
		Combo2Suffix = " combo 2"
	end
	
	if not IsVarSetTrue(ControllerOne) then ComboKeyPressed[RunFunction][1] = true
	else RegisterKeyMapping("+" .. RunFunction .. "_cntrl_1" .. CONFIG.HOTKEY_VER, Description  .. " controller" .. Combo1Suffix, "pad_digitalbutton", ControllerOne) end
	if not IsVarSetTrue(ControllerTwo) then ComboKeyPressed[RunFunction][2] = true
	else RegisterKeyMapping("+" .. RunFunction .. "_cntrl_2" .. CONFIG.HOTKEY_VER, Description .. " controller" .. Combo2Suffix, "pad_digitalbutton", ControllerTwo) end
	if IsVarSetTrue(Keyboard) then RegisterKeyMapping("+" .. RunFunction .. "_kb" .. CONFIG.HOTKEY_VER, Description .. " keyboard", "keyboard", Keyboard) end

	RegisterCommand("+" .. RunFunction .. "_kb" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, nil, false, OnlyRunIfClear) end, false)
	RegisterCommand("-" .. RunFunction .. "_kb" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, nil, RunOnDepress, OnlyRunIfClear) end, false)
	RegisterCommand("+" .. RunFunction .. "_cntrl_1" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, 1, false, OnlyRunIfClear) end, false)
	RegisterCommand("-" .. RunFunction .. "_cntrl_1" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, 1, RunOnDepress, OnlyRunIfClear) end, false)
	RegisterCommand("+" .. RunFunction .. "_cntrl_2" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, 2, false, OnlyRunIfClear) end, false)
	RegisterCommand("-" .. RunFunction .. "_cntrl_2" .. CONFIG.HOTKEY_VER, function() RunHotkey(RunFunction, 2, RunOnDepress, OnlyRunIfClear) end, false)
	
	d_print(RunFunction .. " keybinds: (_kb) " .. tostring(Keyboard) .. " (_cntrl_1) " .. tostring(ControllerOne) .. " (_cntrl1_2) " .. tostring(ControllerTwo))
end

function RecordCommand(Description, Keyboard, ControllerOne, ControllerTwo)
	-- Intended for use with getting and displaying hotkey buttons, not currently implimented
	-- TO CHECK:
	--https://forum.cfx.re/t/how-to-advanced-registerkeymapping-with-nuifocus-in-true/4778790
	--https://forum.cfx.re/t/instructional-buttons/53283
	-- Command hashes generated by: http://tools.povers.fr/hashgenerator/
	--	"+function_cntrl_1"
	local Command = {
		description = Description,
		kb = Keyboard,
		cntrl_1 = ControllerOne,
		cntrl_2 = ControllerTwo
	}
	--table.insert(SetCommands, Command)
	--if next(SetCommands) == nil then table.insert(SetCommands, Command) end -- for testing only
end

-- Toggle trainer
if CONFIG.TRAINER.allow_trainer then
	SetHotkeys(
		"trainer_toggle",
		CONFIG.TRAINER.trainer_toggle_controller_hotkey_combo_1,
		CONFIG.TRAINER.trainer_toggle_controller_hotkey_combo_2,
		CONFIG.TRAINER.trainer_toggle_keyboard_hotkey,
		"Trainer"
	)
	RecordCommand("Trainer", 0x652C1197, 0x94B81E00, 0x9F05329A)
	
	-- Allow parental access
	if CONFIG.TRAINER.allow_parental_controls then
		if not IsVarSetTrue(CONFIG.TRAINER.parental_access_controller_hotkey_combo_1)
			and not IsVarSetTrue(CONFIG.TRAINER.parental_access_controller_hotkey_combo_2)
			and not IsVarSetTrue(CONFIG.TRAINER.parental_access_keyboard_hotkey) then
				AllowParentalControl = true
		else
			SetHotkeys(
				"trainer_parental",
				CONFIG.TRAINER.parental_access_controller_hotkey_combo_1,
				CONFIG.TRAINER.parental_access_controller_hotkey_combo_2,
				CONFIG.TRAINER.parental_access_keyboard_hotkey,
				"Unknown",
				true
			)
			RecordCommand("Unknown", 0x7A7341AE, 0x52D552A3, 0x848C3614)
		end
	end
end

-- Teleport to player
if CONFIG.NETWORK.allow_teleport_to_player then
	SetHotkeys(
		"teleport_to_player",
		CONFIG.NETWORK.teleport_player_controller_hotkey_combo_1,
		CONFIG.NETWORK.teleport_player_controller_hotkey_combo_2,
		CONFIG.NETWORK.teleport_player_keyboard_hotkey,
		"Teleport to player",
		false,
		true
	)
	RecordCommand("Teleport to player", 0x67BE8860, 0x32FB96EB, 0x24407971)
end

-- Quick change ped
if CONFIG.PLAYERS.ped_quick_change then
	SetHotkeys(
		"ped_quick_change",
		CONFIG.PLAYERS.ped_quick_change_controller_hotkey_combo_1,
		CONFIG.PLAYERS.ped_quick_change_controller_hotkey_combo_2,
		CONFIG.PLAYERS.ped_quick_change_keyboard_hotkey,
		"Quick change player ped",
		false,
		true
	)
	RecordCommand("Vehicle quick spawn", 0x73264154, 0xDB620120, 0xFDF6A1A)
end

-- Quick spawn a vehicle
if CONFIG.VEHICLES.quick_spawn_new then
	SetHotkeys(
		"vehicle_quick_spawn",
		CONFIG.VEHICLES.quick_spawn_controller_hotkey_combo_1,
		CONFIG.VEHICLES.quick_spawn_controller_hotkey_combo_2,
		CONFIG.VEHICLES.quick_spawn_keyboard_hotkey,
		"Vehicle quick spawn",
		false,
		true
	)
	RecordCommand("Vehicle quick spawn", 0x4AB53D2C, 0xEA460274, 0x19FCE1E1)
end

-- Teleport to last vehicle
if CONFIG.VEHICLES.teleport_to_last_vehicle then
	SetHotkeys(
		"teleport_to_last_vehicle",
		CONFIG.VEHICLES.teleport_to_last_vehicle_controller_hotkey_combo_1,
		CONFIG.VEHICLES.teleport_to_last_vehicle_controller_hotkey_combo_2,
		CONFIG.VEHICLES.teleport_to_last_vehicle_keyboard_hotkey,
		"Go to last vehicle",
		false,
		true
	)
	RecordCommand("Go to last vehicle", 0xE25140AB, 0x58C59666, 0x881C7513)
end

-- Clone vehicle
if CONFIG.VEHICLES.clone_vehicles then
	SetHotkeys(
		"clone_vehicle",
		CONFIG.VEHICLES.clone_vehicle_controller_hotkey_combo_1,
		CONFIG.VEHICLES.clone_vehicle_controller_hotkey_combo_2,
		CONFIG.VEHICLES.clone_vehicle_keyboard_hotkey,
		"Clone vehicle",
		false,
		true
	)
	RecordCommand("Clone vehicle", 0xEF65269D, 0x2DA962A1, 0xBF690622)
end

-- Taxi NPCs
if CONFIG.VEHICLES.taxi_npcs then
	SetHotkeys(
		"taxi_call",
		CONFIG.VEHICLES.taxi_npcs_call_controller_hotkey,
		nil,
		CONFIG.VEHICLES.taxi_npcs_call_keyboard_hotkey,
		"Get passengers",
		false,
		true
	)
	RecordCommand("Get passengers", 0x824A6CC2, 0xD1B27BF7, nil)
	SetHotkeys(
		"taxi_leave",
		CONFIG.VEHICLES.taxi_npcs_leave_controller_hotkey,
		nil,
		CONFIG.VEHICLES.taxi_npcs_leave_keyboard_hotkey,
		"Remove passengers",
		false,
		true
	)
	RecordCommand("Remove passengers", 0xAA37C7C, 0xF1020095, nil)
end

-- Enter vehicle as passenger
if CONFIG.VEHICLES.enter_as_passenger then
	SetHotkeys(
		"enter_as_passenger",
		CONFIG.VEHICLES.enter_passenger_controller_hotkey_combo_1,
		CONFIG.VEHICLES.enter_passenger_controller_hotkey_combo_2,
		CONFIG.VEHICLES.enter_passenger_keyboard_hotkey,
		"Enter as passenger",
		false,
		true
	)
	RecordCommand("Enter as passenger", 0x14F280B6, 0xD491BA12, 0xE35BD7A6)
end

-- Simple emote
if CONFIG.PLAYERS.allow_simple_emote then
	SetHotkeys(
		"simple_emote",
		CONFIG.PLAYERS.simple_emote_controller_hotkey_combo_1,
		CONFIG.PLAYERS.simple_emote_controller_hotkey_combo_2,
		CONFIG.PLAYERS.simple_emote_keyboard_hotkey,
		"Simple emote",
		false,
		true
	)
	RecordCommand("Simple emote", 0xB23D191C, 0x97478358, 0xC9B9E83C)
end
------------------------------
------------------------------
---- END KEY MAPS ------------
------------------------------
------------------------------

------------------------------
------------------------------
-- NATIVEUI FUNCTIONS START --
------------------------------
------------------------------
local NativeUIMenuItems = {}
function AddMenuItem(Menu, IsSubmenu, ItemName, Type, Data, Description, Disabled, RightLabel, ListIndex)
	ItemName = ItemName or "-----------------------------"
	Type = Type or 0
	Data = Data or {id = nil, value = nil}
	Description = Description or ""
	Disabled = Disabled or false
	ListIndex = ListIndex or 0
	
	if type(Data) == "string" then Data = {id = Data, value = nil} end
	
	local MenuItem = nil
	if Type == 1 then MenuItem = NativeUI.CreateListItem(ItemName, Data.value, ListIndex, Description)
	elseif Type == 2 then MenuItem = NativeUI.CreateCheckboxItem(ItemName, Data.value, Description)
	else
		MenuItem = NativeUI.CreateItem(ItemName, Description)
		if RightLabel then MenuItem:RightLabel(RightLabel) end
	end
	
	if Disabled then MenuItem:Enabled(false)
	else AddToSet(NativeUIMenuItems, MenuItem, Data) end
	
	--if IsSubmenu then Menu.SubMenu:AddItem(MenuItem)
	Menu:AddItem(MenuItem)
	return MenuItem
end

function AddMenuVehicles(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Vehicles")
	local Colours = {}
	
	if CONFIG.TRAINER.show_vehicle_colour_picker then
		local SetColourIndex = 0
		local CurrentColourIndex = 1
		for Colour, RGB in pairs(CONSTANT.COLOURS) do
			if Colour == CONFIG.VEHICLES.lock_primary_colour_to then SetColourIndex = CurrentColourIndex end
			
			local ColourName = Colour:gsub("%W", " ")
			table.insert(Colours, ColourName)
			CurrentColourIndex = CurrentColourIndex + 1
		end
		if SetColourIndex == 0 then
			CONFIG.VEHICLES.lock_primary_colour_to = Colours[1]:gsub("%W", "_")
			SetColourIndex = 1
			d_print("No primary vehicle colour set, overridden as:  " .. CONFIG.VEHICLES.lock_primary_colour_to)
		end
		AddMenuItem(submenu, true, "Change colour of your vehicle", 1, {id = "vehiclecolourselect", value = Colours}, "Pick your favourite colour.", false, nil, SetColourIndex)
		
		submenu.OnListChange = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "vehiclecolourselect" then
					colourIndex = (item:IndexToItem(index)):gsub("%W", "_")
					CONFIG.VEHICLES.lock_primary_colour_to = colourIndex
					
					if ((CONFIG.VEHICLES.lock_player_vehicle_colour or PlayerVehicle.is_inside) and PlayerVehicle.seat == -1)
						or (CONFIG.VEHICLES.lock_player_vehicle_colour and not PlayerVehicle.is_inside) then
							if PlayerVehicle.is_inside then ForceVehicleColour(PlayerVehicle.vehicle, CONSTANT.COLOURS[CONFIG.VEHICLES.lock_primary_colour_to], CONFIG.VEHICLES.also_lock_secondary_colour) end
							ShowNotification("Your vehicle colour is set to:  ~g~" .. colourIndex, false, "vehiclecolour")
					else
						ShowNotification("You need to be the driver of a vehicle before you can change the colour.", false, "vehiclecolour")
					end
				end
			end
		end
		
		AddMenuItem(submenu, true, "Lock colour to all Player Vehicles?", 2, {id = "lockcolour", value = CONFIG.VEHICLES.lock_player_vehicle_colour}, "Apply the colour set above to all cars the player enters.")
		AddMenuItem(submenu, true, "Use colour as the Vehicle's Secondary Colour?", 2, {id = "locksecondary", value = CONFIG.VEHICLES.also_lock_secondary_colour}, "Apply the colour set abovee to the vehicle's secondary coloured parts.")
	end
	
	if CONFIG.TRAINER.show_teleport_inside_spawned_check then
		local checkitem = AddMenuItem(submenu, true, "Teleport inside Spawned Vehicles?", 2, {id = "teleportinside", value = CONFIG.VEHICLES.teleport_inside_spawned}, "Teleport inside of newly spawned vehicles? Also affects cloned vehicles!")
	end
	
	submenu.OnCheckboxChange = function(sender, item, checked_)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id == "lockcolour" then
				CONFIG.VEHICLES.lock_player_vehicle_colour = checked_
				ShowNotification("Lock Vehicle Colour?   ~y~" .. tostring(checked_))
				
				if CONFIG.VEHICLES.lock_player_vehicle_colour and PlayerVehicle.is_inside and PlayerVehicle.seat == -1 then
					ForceVehicleColour(PlayerVehicle.vehicle, CONSTANT.COLOURS[CONFIG.VEHICLES.lock_primary_colour_to], CONFIG.VEHICLES.also_lock_secondary_colour)
					ShowNotification("Your vehicle colour is set to:  ~g~" .. CONFIG.VEHICLES.lock_primary_colour_to, false, "vehiclecolour")
				end
			elseif GetItem.id == "locksecondary" then
				CONFIG.VEHICLES.also_lock_secondary_colour = checked_
				ShowNotification("Secondary Colour matched?   ~y~" .. tostring(checked_))
			elseif GetItem.id == "teleportinside" then
				CONFIG.VEHICLES.teleport_inside_spawned = checked_
				ShowNotification("Teleport inside Spawned Vehicles?   ~y~" .. tostring(checked_))
			end
		end
	end
	
	AddMenuItem(submenu, true, "------- Spawn a Vehicle -------", 0, nil, nil, true)
	
	if next(SPAWN_ITEMS.VEHICLES) ~= nil then
		for model,name in pairs(SPAWN_ITEMS.VEHICLES) do
			AddMenuItem(submenu, true, name, 0, {id = "spawnvehicle", value = model}, "Spawn vehicle: " .. model)
		end
		
		submenu.OnItemSelect = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "spawnvehicle" then
					CloneVehicle(GetItem.value)
				end
			end
		end
	else
		AddMenuItem(submenu, true, "NO VEHICLES ADDED IN SPAWN_ITEMS!", 0, nil, "Edit the SPAWN_ITEMS table in this script's config.lua to add vehicles.", true)
	end
end

function AddMenuPlayerModel(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Character Models")
	AddMenuItem(submenu, true, "------- Change your Character -------", 0, nil, nil, true)
	
	if next(SPAWN_ITEMS.PEDS) ~= nil then
		for model,name in pairs(SPAWN_ITEMS.PEDS) do
			AddMenuItem(submenu, true, name, 0, {id = "playerped", value = model}, "Change player model to: " .. model)
		end
		
		submenu.OnItemSelect = function(sender, item, index)
			local GetItem = NativeUIMenuItems[item]
			
			if GetItem ~= nil then
				if GetItem.id == "playerped" then
					RequestNewPedModel(GetItem.value, SPAWN_ITEMS.PEDS[GetItem.value])
				end
			end
		end
	else
		AddMenuItem(submenu, true, "NO PEDS ADDED IN SPAWN_ITEMS!", 0, nil, "Edit the SPAWN_ITEMS table in this script's config.lua to add peds.", true)
	end
end

function AddMenuGameTimer(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Parental Controls")
	
	AddMenuItem(submenu, true, "Set/append game timer", 0, "starttimer", "Start/append the timer by 15 minutes each time clicked.", false, "+15 mins")
	AddMenuItem(submenu, true, "Cancel current game timer", 0, "canceltimer", "Cancel the set timer.")
	if CONFIG.TRAINER.parental_show_force_pause_option then AddMenuItem(submenu, true, "Force toggle pause player(s)", 0, "forcepausetoggle", "Blackout the screen and pause the running timer.") end
	
	submenu.OnItemSelect = function(sender, item, index)
		if AllowParentalControl then	
			local GetItem = NativeUIMenuItems[item]
		
			if GetItem ~= nil then
				if GetItem.id == "starttimer" then
					if not SendParentalEvent("SetTimer", MinToMiliseconds(15)) then
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
		else
			ShowNotification("~r~~h~Access denied! Hold the access keys.", true, "timer")
		end
	end
end

function AddMenuConfig(menu)
	local submenu = _menuPool:AddSubMenu(menu, "Modify Config")
	
	local ConfigListItems = {}
	local ConfigListSets = {}
	for setName,configs in pairs(CONFIG) do
		if type(configs) == "table" and setName ~= "TRAINER" then			
			AddMenuItem(submenu, true, "------- " .. setName .. " -------", 0, nil, nil, true)
			
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
	
	AddMenuItem(mainMenu, false, nil, 0, nil, nil, true)
	
	if CONFIG.TRAINER.show_change_weather then AddMenuItem(mainMenu, false, "Change local weather", 1, {id = "changeweather", value = CONSTANT.WEATHER}, "Change your weather", false, nil, GetKeyFromValue(CONSTANT.WEATHER, CONFIG.WORLD.lock_weather)) end
	if CONFIG.TRAINER.show_change_time then
		local Times = {"Default", "Super fast nights", "Fast", "Match system", "Morning", "Noon", "Evening", "Midnight"}
		
		local CurrentSet = CONFIG.WORLD.lock_time_to_hour
		if CurrentSet == -4 then CurrentSet = 1
		elseif CurrentSet == -3 then CurrentSet = 2
		elseif CurrentSet == -2 then CurrentSet = 3
		elseif CurrentSet == -1 then CurrentSet = 4
		elseif CurrentSet >= 3 and CurrentSet <= 11 then CurrentSet = 5
		elseif CurrentSet >= 12 and CurrentSet <= 17 then CurrentSet = 6
		elseif CurrentSet >= 18 and CurrentSet <= 22 then CurrentSet = 7
		elseif CurrentSet >= 23 or CurrentSet <= 2 then CurrentSet = 8 end
		
		AddMenuItem(mainMenu, false, "Change local time", 1, {id = "changetime", value = Times}, "Change your time", false, nil, CurrentSet)
	end
	if CONFIG.TRAINER.show_teleport_to_waypoint then AddMenuItem(mainMenu, false, "Teleport to Waypoint", 0, "teleportwaypoint", "Teleport to your waypoint (set waypoint first).") end
	if CONFIG.TRAINER.show_teleport_to_player then AddMenuItem(mainMenu, false, "Teleport to an Active Player", 0, "teleportplayer", "Teleport to a random player currently in the server.") end
	if CONFIG.TRAINER.show_clone_vehicle then AddMenuItem(mainMenu, false, "Clone your Current Vehicle", 0, "clonevehicle", "Clone the vehicle that you're currently inside.") end
	if CONFIG.TRAINER.allow_ghost_to_others then AddMenuItem(mainMenu, false, "Become a Ghost", 0, "ghostmode", "You will be invisible to active players and will not show up on the map.") end
	
	AddMenuItem(mainMenu, false, nil, 0, nil, nil, true)
	
	if CONFIG.TRAINER.allow_parental_controls then AddMenuGameTimer(mainMenu) end
	if CONFIG.TRAINER.show_this_config then AddMenuConfig(mainMenu) end
	
	_menuPool:ResetCursorOnOpen(true)
	_menuPool:MouseControlsEnabled(false)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:RefreshIndex()
	
	mainMenu.OnItemSelect = function(sender, item, index)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id == "teleportwaypoint" then TeleportToWaypoint()
			elseif GetItem.id == "teleportplayer" then TeleportToPlayer()
			elseif GetItem.id == "clonevehicle" then CloneVehicle()
			elseif GetItem.id == "ghostmode" then
				InvisibleToNetwork = not InvisibleToNetwork
				TriggerServerEvent("PlayerToggleGhost", InvisibleToNetwork)
				ShowNotification("Invisible to active players?  ~y~" .. tostring(InvisibleToNetwork), true, "ghostmode")
			end
		end
	end
	
	mainMenu.OnListChange = function(sender, item, index)
		local GetItem = NativeUIMenuItems[item]
		
		if GetItem ~= nil then
			if GetItem.id  == "changeweather" then
				weatherIndex = item:IndexToItem(index)
				if weatherIndex == "DEFAULT" then
					ClearWeatherTypePersist()
					SetWeatherOwnedByNetwork(true)
				else
					SetWeatherOwnedByNetwork(false)
					SetWeatherTypeNowPersist(weatherIndex)
					CONFIG.WORLD.lock_weather = weatherIndex
				end
				ShowNotification("Weather changed to:  ~g~" .. weatherIndex, false, "weatherselect")
			elseif GetItem.id  == "changetime" then
				indexSelected = item:IndexToItem(index)
				
				local timeIndex = -4
				if indexSelected == "Super fast nights" then timeIndex = -3
				elseif indexSelected == "Fast" then timeIndex = -2
				elseif indexSelected == "Match system" then timeIndex = -1
				elseif indexSelected == "Morning" then timeIndex = 7
				elseif indexSelected == "Noon" then timeIndex = 12
				elseif indexSelected == "Evening" then timeIndex = 18
				elseif indexSelected == "Midnight" then timeIndex = 0 end
				
				
				CONFIG.WORLD.lock_time_to_hour = timeIndex
				ShowNotification("Time changed", false, "timeselect")
				d_print("User's time index changed to:  " .. CONFIG.WORLD.lock_time_to_hour)
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
	
	exports.spawnmanager:setAutoSpawn(true)
	
	if CONFIG.PLAYERS.invincible and CONFIG.PLAYERS.prevent_ragdoll_flags.disable_all then SetPlayerInvincible(PlayerID, true)
	elseif CONFIG.PLAYERS.invincible then SetPlayerInvincibleKeepRagdollEnabled(PlayerID, true) end
	
	SetMaxWantedLevel(CONFIG.POLICE.max_wated_level)
	SetPoliceIgnorePlayer(PlayerID, CONFIG.POLICE.ignore_players)
	if CONFIG.NPC.ignore_players > 0 then
		SetEveryoneIgnorePlayer(PlayerID, true)
		SetIgnoreLowPriorityShockingEvents(PlayerID, true)
		
		-- testing
		SetRelationshipBetweenGroups(1, GetHashKey("CIVMALE"), GetHashKey("PLAYER"))
		SetRelationshipBetweenGroups(1, GetHashKey("CIVFEMALE"), GetHashKey("PLAYER"))
	end
	SetPlayerCanBeHassledByGangs(PlayerID, not CONFIG.NPC.gangs_leave_alone)
	SetPlayerCanDoDriveBy(PlayerID, not CONFIG.PLAYERS.prevent_middle_finger)
	SetPlayerCanUseCover(PlayerID, not CONFIG.PLAYERS.disable_duck_and_cover)
	if CONFIG.WEAPONS.prevent_weapon_pickups then DisablePlayerVehicleRewards(PlayerID) end
	
	SetCreateRandomCops(CONFIG.POLICE.spawn_police) -- random cops walking/driving around
	SetCreateRandomCopsNotOnScenarios(CONFIG.POLICE.spawn_police) -- random cops (not in a scenario) spawning
	SetCreateRandomCopsOnScenarios(CONFIG.POLICE.spawn_police_scenarios) -- random cops (in a scenario) spawning
	SetRandomBoats(CONFIG.VEHICLES.spawn_boats) -- random boats spawning in the water
	
	if CONFIG.WORLD.disable_ambient_speech then
		StopAudioScenes()
		StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
		SetAudioFlag("PoliceScannerDisabled", true)
	end
	
	if CONFIG.VEHICLES.disable_cinematic_cam then
		SetCinematicButtonActive(false)
		SetCinematicModeActive(false)
	end
	
	if not CONFIG.NETWORK.players_are_friendly then
		NetworkSetFriendlyFireOption(true)
	end
	
	if CONFIG.WEAPONS.remove_all_weapons ~= 2
		and CONFIG.WEAPONS.restrict_to_permitted_only
		and next(CONFIG.WEAPONS.permitted_weapons) ~= nil
		and next(HandheldAllowWeapons) == nil then
			d_print("Checking for permitted weapons.")
			
			for key,WeaponModel in pairs(CONFIG.WEAPONS.permitted_weapons) do
				local WeaponHash = GetHashKey(WeaponModel)
				AddToSet(HandheldAllowWeapons, WeaponHash)
				d_print("Adding weapon hash to permited handsheld weapons list:  " .. WeaponModel .. " (" .. WeaponHash .. ")")
			end
			
			d_print("Weapons found:  " .. dump(HandheldAllowWeapons))
	end
	
	if CONFIG.WEAPONS.disable_vehicle_weapons == 1
		and next(CONFIG.WEAPONS.permitted_vehicle_weapons) ~= nil
		and next(VehiclesAllowWeapons) == nil then
			d_print("Checking for permitted vehicle weapons.")
			
			for key,VehicleModel in pairs(CONFIG.WEAPONS.permitted_vehicle_weapons) do
				AddToSet(VehiclesAllowWeapons, GetHashKey(VehicleModel))
				d_print("Adding vehicle hash to permited vehicle weapons list:  " .. VehicleModel)
			end
			
			d_print("Vehicle weapons found:  " .. dump(VehiclesAllowWeapons))
	end
	
	--[[if CONFIG.WORLD.remove_adult_interiors and next(CONFIG.WORLD.interiors_doors_to_restrict) ~= nil then
		for _, Type in pairs(CONFIG.WORLD.interiors_doors_to_restrict) do
			if DoesSetContain(CONSTANT.RESTRICTED_AREAS, Type) then
				for Interior, _ in pairs(CONSTANT.RESTRICTED_AREAS[Type]) do
					UnpinInterior(Interior)
					d_print("Interior disabled:  " .. Interior .. " (" .. Type .. ")")
				end
			end
		end
	end]]--
	
	
	while true do
		Citizen.Wait(0) -- Prevent crashing, repeat every tick
		if PlayerSpawnReady then
			FullscreenBlackout = false
			DisplayGamePlayTimer()
			DisplayOnlineCount()
			DisplayCoords()
			
			if CONFIG.TRAINER.allow_trainer then
				_menuPool:ProcessMenus()
				--_menuPool:ControlDisablingEnabled(false)
			end
			
			SetPedDensityMultiplierThisFrame(CONFIG.NPC.spawn_density_multiplier) -- set npc/ai peds density, default 1.0
			SetScenarioPedDensityMultiplierThisFrame(CONFIG.NPC.spawn_density_multiplier_scenario, CONFIG.NPC.spawn_density_multiplier_scenario) -- set random npc/ai peds or scenario peds
			SetVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier) -- set traffic density, default 1.0
			SetParkedVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier_parked) -- set random parked vehicles (parked car scenarios)
			SetRandomVehicleDensityMultiplierThisFrame(CONFIG.VEHICLES.spawn_density_multiplier_scenario) -- set random vehicles (car scenarios / cars driving off from a parking spot etc)
			
			local PurgeProcessedPeds = {}
			local PurgeProcessedVehicles = {}
			if not RunPurgeProcessed then RunPurgeProcessed = RunEveryX(10, false, "purgeprocessed") end
			local RunOncePerSec = RunEveryX(1, false, "delayedchecks", true) or RunPurgeProcessed
			
			-- Local player ped/vehicle related
			if PlayerPed ~= PlayerPedId() or not DoesSetContain(ProcessedPeds, PlayerPed) then
				PlayerPed = PlayerPedId()
				SetPedInvincibleWithRagdoll(PlayerPed, CONFIG.PLAYERS.invincible, CONFIG.PLAYERS.prevent_ragdoll_flags)
				PedIsInvisible = false
				
				if not CONFIG.NETWORK.players_are_friendly then
					SetCanAttackFriendly(PlayerPed, true, true)
					SetPedCanBeTargetted(PlayerPed, true)
				end
				
				if CONFIG.PLAYERS.stick_to_vehicle then SetPedCanBeKnockedOffVehicle(PlayerPed, 1) end
				SetPedCanBeDraggedOut(PlayerPed, not CONFIG.PLAYERS.cant_carjack)
				
				AllocatePermittedWeaponsToPlayer()
				SetPedInfiniteAmmoClip(PlayerPed, true)
				
				AddToSet(ProcessedPeds, PlayerPed)
			end
			if RunPurgeProcessed then AddToSet(PurgeProcessedPeds, PlayerPed) end
			
			PlayerVehicle = GetVehiclePedIsInOrEntering(PlayerPed)
			MaintainPedHealth(PlayerPed, CONFIG.PLAYERS.invincible, CONFIG.PLAYERS.prevent_ragdoll_flags, PlayerVehicle.vehicle)
			KeepPedClean(PlayerPed, CONFIG.PLAYERS.clear_injuries)
			CurrentCoords = GetEntityCoords(PlayerPed)
			SetWeaponHandling(PlayerPed, PlayerVehicle.vehicle)
			
			if PlayerVehicle.is_entering then
				TaskPlayerPerformFriendlyCarjack(PlayerVehicle, PlayerPed)
			elseif DoesSetContain(NetworkPlayerIsEnteringVehicle, PlayerID) then
				RemoveFromSet(NetworkPlayerIsEnteringVehicle, PlayerID)
			elseif PlayerVehicle.is_inside and not DoesSetContain(ProcessedVehicles, PlayerVehicle.vehicle) then
				VehicleLimitDamage(PlayerVehicle.vehicle, 1)
				
				if CONFIG.VEHICLES.disable_radio > 0 or (CONFIG.VEHICLES.disable_radio == 0 and CONFIG.VEHICLES.radio_driver_only and PlayerVehicle.seat ~= -1) then
					SetVehicleRadioEnabled(PlayerVehicle.vehicle, false)
					SetUserRadioControlEnabled(false)
				end
				
				AddToSet(ProcessedVehicles, PlayerVehicle.vehicle)
			elseif PlayerVehicle.is_inside then
				DisplaySpeedo()
				
				if CONFIG.VEHICLES.disable_radio > 0 or (CONFIG.VEHICLES.radio_driver_only and PlayerVehicle.seat ~= -1) then
					if GetPlayerRadioStationName() ~= nil then
						SetVehRadioStation(PlayerVehicle.vehicle, "OFF")
					end
				end
				
				if CONFIG.VEHICLES.muted_sirens > 0 and CONFIG.VEHICLES.muted_sirens ~= 3 then
					if IsVehicleSirenAudioOn(PlayerVehicle.vehicle) then SetVehicleHasMutedSirens(PlayerVehicle.vehicle, true) end
				end
				
				if CONFIG.VEHICLES.taxi_npcs and VehicleTaxiDropOffAtNextStop then
					if IsVehicleStopped(PlayerVehicle.vehicle) then
						VehicleTaxiDropOffAtNextStop = false
						DropNpcPassengerOff(PlayerVehicle.vehicle)
					end
				end
			else
				if CONFIG.PLAYERS.no_low_stamina and RunOncePerSec then ResetPlayerStamina(PlayerID) end
			end
			
			if RunPurgeProcessed and IsVarSetTrue(PlayerVehicle.vehicle) then AddToSet(PurgeProcessedVehicles, PlayerVehicle.vehicle) end
			
			if InvisibleToNetwork then
				if not PedIsInvisible then
					SetEntityAlpha(PlayerPed, 200, false)
					PedIsInvisible = true
				end
				if PlayerVehicle.is_inside and not VehicleIsInvisible then
					SetEntityAlpha(PlayerVehicle.vehicle, 100, false)
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
			
			
			-- Network player ped/vehicle related
			if next(ActivePlayers) ~= nil then
				for ActivePlayer,Data in pairs(ActivePlayers) do
					local ActivePlayerPed = GetEntityFromNetwork(Data.ped)
					
					if CONFIG.NETWORK.show_static_line_marker and not IsPlayerAGhost(ActivePlayer) then
						local ActivePlayerCoords = nil
						if DoesEntityExist(ActivePlayerPed) then ActivePlayerCoords = GetEntityCoords(ActivePlayerPed)
						elseif not CONFIG.NETWORK.nearby_line_markers_only then ActivePlayerCoords = Data.coords end
						
						if ActivePlayerCoords ~= nil then
							DrawLine(ActivePlayerCoords.x, ActivePlayerCoords.y, ActivePlayerCoords.z, ActivePlayerCoords.x, ActivePlayerCoords.y, 999.0, 255, 0, 0, 200)
						end
					end
					
					if DoesEntityExist(ActivePlayerPed) then
						if not DoesSetContain(ProcessedPeds, ActivePlayerPed) then
							SetPedInvincibleWithRagdoll(ActivePlayerPed, CONFIG.PLAYERS.invincible, CONFIG.PLAYERS.prevent_ragdoll_flags)
							if CONFIG.PLAYERS.stick_to_vehicle then SetPedCanBeKnockedOffVehicle(ActivePlayerPed, 1) end
							SetPedCanBeDraggedOut(ActivePlayerPed, not CONFIG.PLAYERS.cant_carjack)
							
							AddToSet(ProcessedPeds, ActivePlayerPed)
						end
						if RunPurgeProcessed then AddToSet(PurgeProcessedPeds, ActivePlayerPed) end
						
						local ActivePlayerVehicle = GetVehiclePedIsInOrEntering(ActivePlayerPed)
						MaintainPedHealth(ActivePlayerPed, CONFIG.PLAYERS.invincible, CONFIG.PLAYERS.prevent_ragdoll_flags, ActivePlayerVehicle.vehicle)
						KeepPedClean(ActivePlayerPed, CONFIG.PLAYERS.clear_injuries)
						
						if ActivePlayerVehicle.is_entering then
							TaskPlayerPerformFriendlyCarjack(ActivePlayerVehicle, ActivePlayerPed, ActivePlayer)
						elseif DoesSetContain(NetworkPlayerIsEnteringVehicle, ActivePlayer) then
							RemoveFromSet(NetworkPlayerIsEnteringVehicle, ActivePlayer)
						elseif ActivePlayerVehicle.is_inside and not DoesSetContain(ProcessedVehicles, ActivePlayerVehicle.vehicle) then
							VehicleLimitDamage(ActivePlayerVehicle.vehicle, 1)
							
							AddToSet(ProcessedVehicles, ActivePlayerVehicle.vehicle)
						elseif ActivePlayerVehicle.is_inside then
							if CONFIG.VEHICLES.muted_sirens > 0 and CONFIG.VEHICLES.muted_sirens ~= 3 then
								if IsVehicleSirenAudioOn(ActivePlayerVehicle.vehicle) then SetVehicleHasMutedSirens(ActivePlayerVehicle.vehicle, true) end
							end
						end
						if RunPurgeProcessed and IsVarSetTrue(ActivePlayerVehicle.vehicle) then AddToSet(PurgeProcessedVehicles, ActivePlayerVehicle.vehicle) end
						
						
						if IsPlayerAGhost(ActivePlayer) then
							--SetPlayerInvisibleLocally(GetPlayerFromServerId(ActivePlayer), true)
							SetEntityLocallyInvisible(ActivePlayerPed)
							if IsVarSetTrue(ActivePlayerVehicle.vehicle) and ActivePlayerVehicle.vehicle ~= PlayerVehicle.vehicle then
								SetEntityLocallyInvisible(ActivePlayerVehicle.vehicle)
							end
						end
					end
				end
			end
			
			
			-- NPC ped related
			for key,NpcPed in pairs(GetGamePool("CPed")) do
				if IsPedNpc(NpcPed) then
					local NpcVehicle = GetVehiclePedIsIn(NpcPed, false)
					SetPedInvincibleWithRagdoll(NpcPed, CONFIG.NPC.invincible, CONFIG.NPC.prevent_ragdoll_flags)
					
					if not DoesSetContain(ProcessedPeds, NpcPed) then
						SetPedCanBeTargetted(NpcPed, not CONFIG.NPC.cant_target)
						if CONFIG.NPC.stick_to_vehicle then SetPedCanBeKnockedOffVehicle(NpcPed, 1) end
						SetPedCanBeDraggedOut(NpcPed, not CONFIG.NPC.cant_carjack)
					
						if CONFIG.NPC.non_combat then
							SetPedCombatAttributes(NpcPed, 17, true) -- Peds just flee when they face enemies with weapons
							SetPedConfigFlag(NpcPed, 128, false) -- CPED_CONFIG_FLAG_CanBeAgitated
							SetPedConfigFlag(NpcPed, 183, false) -- CPED_CONFIG_FLAG_IsAgitated
							SetPedCombatAttributes(NpcPed, 2, false) -- BF_CanDoDrivebys
							SetPedCombatAttributes(NpcPed, 20, false) -- BF_CanTauntInVehicle
							SetPedConfigFlag(NpcPed, 422, true) -- CPED_CONFIG_FLAG_DisableVehicleCombat
							SetDriverAggressiveness(NpcPed, 0.0)
						end
						
						if CONFIG.NPC.ignore_players == 2 then
							if IsVarSetTrue(GetPedAlertness(NpcPed)) then SetPedAlertness(NpcPed,0) end
							SetPedFleeAttributes(NpcPed, 0, false)
							SetPedCanCowerInCover(NpcPed, false)
							SetPedHearingRange(NpcPed, 0.0)
							SetBlockingOfNonTemporaryEvents(NpcPed, true)
							SetPedConfigFlag(NpcPed, 17, true) -- CPED_CONFIG_FLAG_BlockNonTemporaryEvents
							SetPedConfigFlag(NpcPed, 24, true) -- CPED_CONFIG_FLAG_IgnoreSeenMelee
							SetPedConfigFlag(NpcPed, 208, true) -- CPED_CONFIG_FLAG_DisableExplosionReactions
							SetPedConfigFlag(NpcPed, 209, false) -- CPED_CONFIG_FLAG_DodgedPlayer
							SetPedConfigFlag(NpcPed, 225, true) -- CPED_CONFIG_FLAG_DisablePotentialToBeWalkedIntoResponse
							SetPedConfigFlag(NpcPed, 226, true) -- CPED_CONFIG_FLAG_DisablePedAvoidance
							SetPedConfigFlag(NpcPed, 294, true) -- CPED_CONFIG_FLAG_DisableShockingEvents
						end
						
						if CONFIG.NPC.prevent_evasive_driving then
							if IsVarSetTrue(NpcVehicle) then SetVehicleCanBeUsedByFleeingPeds(NpcVehicle, false) end
							SetPedCanEvasiveDive(NpcPed, false)
							SetPedConfigFlag(NpcPed, 39, true) -- CPED_CONFIG_FLAG_DisableEvasiveDives
							SetPedConfigFlag(NpcPed, 229, true) -- CPED_CONFIG_FLAG_DisablePanicInVehicle
							SetPedConfigFlag(NpcPed, 359, false) -- CPED_CONFIG_FLAG_IsDuckingInVehicle
						end
						
						if CONFIG.NPC.stop_speaking > 0 then StopPedSpeaking(NpcPed, true) end
						if CONFIG.NPC.stop_speaking == 2 then DisablePedPainAudio(NpcPed, true) end
						
						if IsVarSetTrue(NpcVehicle) then
							if CONFIG.VEHICLES.disable_radio == 2 then
								SetVehicleRadioEnabled(NpcVehicle, false)
							end
						end
						
						AddToSet(ProcessedPeds, NpcPed)
					end
					if RunPurgeProcessed then AddToSet(PurgeProcessedPeds, NpcPed) end
					
					MaintainPedHealth(NpcPed, CONFIG.NPC.invincible, CONFIG.NPC.prevent_ragdoll_flags, NpcVehicle)	
					KeepPedClean(NpcPed, CONFIG.NPC.clear_injuries)
					if RunOncePerSec then SetWeaponHandling(NpcPed, NpcVehicle) end
					
					if CONFIG.NPC.stop_speaking > 0 then
						if IsAnySpeechPlaying(NpcPed) then
							d_print("SOUNDS_NPC_SPEECH: Blocking NPC speech. Ped:  " .. NpcPed)
							StopCurrentPlayingAmbientSpeech(NpcPed)
							StopCurrentPlayingSpeech(NpcPed)
						end
					end
					
					if RunOncePerSec then
						if CONFIG.NPC.ignore_players == 2 then
							if IsPedFleeing(NpcPed) and not IsVarSetTrue(NpcVehicle) then
								d_print("Stopping an NPC from fleeing:  " .. NpcPed)
								ClearPedTasksImmediately(NpcPed)
								TaskSetBlockingOfNonTemporaryEvents(NpcPed, true)
								TaskWanderStandard(NpcPed, 10.0, 10)
							end
						end
						
						if IsVarSetTrue(NpcVehicle) then
							if CONFIG.NPC.prevent_evasive_driving then
								if IsPedEvasiveDiving(NpcPed) or IsPedFleeing(NpcPed) then
									d_print("Stopping evasive drive with NPC:  " .. NpcPed)
									--ClearPedTasksImmediately(NpcPed)
									ClearPedTasks(NpcPed)
									TaskSetBlockingOfNonTemporaryEvents(NpcPed, true)
									TaskWarpPedIntoVehicle(NpcPed, NpcVehicle, -1)
									TaskVehicleDriveWander(NpcPed, NpcVehicle, 10.0, 447)
									SetPedCanEvasiveDive(NpcPed, false)
								end
							end
							
							if CONFIG.VEHICLES.muted_sirens >= 2 then
								if IsVehicleSirenAudioOn(NpcVehicle) then SetVehicleHasMutedSirens(NpcVehicle, true) end
							end
						end
						
						if CONFIG.NPC.del_disturbing_peds or CONFIG.NPC.del_minimal_clothing_peds then
							local PedHash = GetEntityModel(NpcPed)
							if DoesSetContain(CONSTANT.RESTRICTED_PEDS, PedHash) then
								if (CONFIG.NPC.del_disturbing_peds and CONSTANT.RESTRICTED_PEDS[PedHash] == 1)
									or (CONFIG.NPC.del_minimal_clothing_peds and CONSTANT.RESTRICTED_PEDS[PedHash] == 2) then
										d_print("Deleting restricted ped:  " .. PedHash .. ", from group:  " .. CONSTANT.RESTRICTED_PEDS[PedHash])
										DeletePed(NpcPed)
								end
							end
						end
					end
				end
			end
			
			if RunOncePerSec then
				if CONFIG.VEHICLES.invincible == 2 or CONFIG.VEHICLES.repair_damage == 2 then
					for key,Vehicle in pairs(GetGamePool('CVehicle')) do
						if not DoesSetContain(ProcessedVehicles, Vehicle) then
							VehicleLimitDamage(Vehicle, 2)
							AddToSet(ProcessedVehicles, Vehicle)
						end
						if RunPurgeProcessed then AddToSet(PurgeProcessedVehicles, Vehicle) end
					end
				end
				
				--[[if CONFIG.WORLD.remove_adult_interiors and next(CONFIG.WORLD.interiors_doors_to_restrict) ~= nil then
					for _, Type in pairs(CONFIG.WORLD.interiors_doors_to_restrict) do
						if DoesSetContain(CONSTANT.RESTRICTED_AREAS, Type) then
							for Interior, _ in pairs(CONSTANT.RESTRICTED_AREAS[Type]) do
								if IsInteriorReady(Interior) then
									DisableInterior(Interior)
									--RemoveIpl("stripperhome")
									d_print("Interior disabled:  " .. Interior .. " (" .. Type .. ")")
								end
							end
						end
					end
				end]]--
				
				--d_print(GetInteriorAtCoords(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z))
				
				if CONFIG.WORLD.lock_adult_doors and next(CONFIG.WORLD.interiors_doors_to_restrict) ~= nil then
					for _, Type in pairs(CONFIG.WORLD.interiors_doors_to_restrict) do
						if DoesSetContain(CONSTANT.RESTRICTED_AREAS, Type) then
							for Interior, Doors in pairs(CONSTANT.RESTRICTED_AREAS[Type]) do
								local DoorPairCheck = 0.0
								
								for _, Door in pairs(CONSTANT.RESTRICTED_AREAS[Type][Interior]) do
									local BlockDoor = false
									if Door.coords.z ~= DoorPairCheck then
										if Vdist2(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, Door.coords.x, Door.coords.y, Door.coords.z) < 30.0 then
											DoorPairCheck = Door.coords.z
											BlockDoor = true
											
											if RunEveryX(5, false, "doorlocked", true) then ShowNotification("~r~Sorry, closed for business.", true, "lockeddoor") end
										end
									else
										BlockDoor = true
									end
									
									if BlockDoor then
										local DoorObject = GetClosestObjectOfType(Door.coords.x, Door.coords.y, Door.coords.z, 5.0, Door.door_hash, false, false, false)
										if DoesEntityExist(DoorObject) and RunEveryX(10, false, "doorlocked" .. DoorObject, true) then
											FreezeEntityPosition(DoorObject, true)
											d_print("Blocking access to door:  " .. Door.door_hash .. " at interior:  " .. Interior)
										end
									end
								end
							end
						end
					end
				end
				
				if RunPurgeProcessed then
					ProcessedPeds = PurgeProcessedPeds
					ProcessedVehicles = PurgeProcessedVehicles
					d_print("Processed peds and vehicles lists purged")
					RunPurgeProcessed = false
				end
			end
		end
	end
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000) -- Repeat every second
		if PlayerSpawnReady then
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
			
			if CONFIG.WORLD.lock_time_to_hour == -3 then
				if GetClockHours() > 19 or GetClockHours() < 5 then
					OverrideNetworkTime(500)
				else
					OverrideNetworkTime(1000)
				end
			elseif CONFIG.WORLD.lock_time_to_hour == -2 then
				OverrideNetworkTime(1000)
			elseif CONFIG.WORLD.lock_time_to_hour == -1 then
				OverrideNetworkTime(60000, -1)
			elseif CONFIG.WORLD.lock_time_to_hour > -1 and CONFIG.WORLD.lock_time_to_hour <= 23 then
				OverrideNetworkTime(0, CONFIG.WORLD.lock_time_to_hour)
			elseif NetworkIsClockTimeOverridden() then
				NetworkClearClockTimeOverride()
			end
			
			if RunEveryX(4) then -- Run every 4 seconds
				PurgeAllPlayerBlips(true)
			end
			
			if RunEveryX(10) then -- Run every 10 seconds
				if CONFIG.PLAYERS.disable_idle_cam then
					InvalidateIdleCam()
					InvalidateVehicleIdleCam()
				end
				
				if CONFIG.VEHICLES.repair_damage == 2 or CONFIG.VEHICLES.keep_clean == 2 then
					for key,Vehicle in pairs(GetGamePool('CVehicle')) do
						VehicleRepairDamage(Vehicle, 2)
					end
				elseif PlayerVehicle.is_inside and CONFIG.VEHICLES.repair_damage == 1 or CONFIG.VEHICLES.keep_clean == 1 then
					VehicleRepairDamage(PlayerVehicle.vehicle, 1)
				end
					
				if PlayerVehicle.is_inside then
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
			end
		end
	end
end)
------------------------------
------------------------------
---- LOOPING THREADS END -----
------------------------------
------------------------------

------------------------------
------------------------------
---- ON PLAYER PED SPAWN -----
------------------------------
------------------------------
RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
	if CONFIG.PLAYERS.random_spawn_ped and next(SPAWN_ITEMS.PEDS) ~= nil then
		local Model, Name = GetFromSetAtPosX(SPAWN_ITEMS.PEDS, math.random(TableLength(SPAWN_ITEMS.PEDS)))
		d_print("Setting the player ped model to:  " .. Model)
		RequestNewPedModel(Model, Name)
	end
	
	if CONFIG.WORLD.lock_weather ~= "" and CONFIG.WORLD.lock_weather ~= "DEFAULT" then	
		SetWeatherOwnedByNetwork(false)
		SetWeatherTypeNowPersist(CONFIG.WORLD.lock_weather)
	end
	
	if not PlayerSpawnReady then
		ShutdownLoadingScreenNui()
		PlayerSpawnReady = true
	end
	
	--[[if not PlayerSpawnReady and CONFIG.LOADING_SCREEN.loading_screen_enabled then
		local serializedTable = serpent.dump(SetCommands)
		SendLoadingScreenMessage(serializedTable)
		
		Citizen.CreateThread(function()
			Citizen.Wait(2000)
			
			if not PlayerSpawnReady then
				ShutdownLoadingScreenNui()
				PlayerSpawnReady = true
			end
		end)
	elseif not PlayerSpawnReady then
		PlayerSpawnReady = true
	end]]--
end)

RegisterNetEvent("HashedSetCommands")
AddEventHandler("HashedSetCommands", function(data)
	HashedSetCommands = json.decode(data)

	d_print(dump(HashedSetCommands))
	
	if not PlayerSpawnReady then
		ShutdownLoadingScreenNui()
		PlayerSpawnReady = true
	end
end)
------------------------------
------------------------------
-- ON PLAYER PED SPAWN END ---
------------------------------
------------------------------
