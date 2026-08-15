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
local ServerClock = 0
local LastActivePlayersUpdate = {}
local PlayersGhosting = {}
local PlayersPaused = {}
local TimeRemaining = -1
local TimerIsPaused = false
local ForcePauseEveryone = false
local LastUpdateReason = ""
local TimerExpiredTriggered = false
local TrustedPedModels = {}

function RunEveryX(S)
	if ServerClock % S == 0 then return true
	else return false end
end

AddEventHandler('playerConnecting', function(_, _, deferrals)
	local source = source
	
	if CONFIG.LOADING_SCREEN.loading_screen_enabled then
		deferrals.handover({
			name = GetPlayerName(source),
			player_count = TableLength(LastActivePlayersUpdate) + 1
		})
	end
end)

AddEventHandler('playerJoining', function (source, oldId)
	print("Player " .. GetPlayerName(source) .. " (" .. source .. ") joined, identifiers:  " .. dump(GetPlayerIdentifiers(source)))
	
	if TimeRemaining ~= -1 then
		SyncTimerWithPlayers(LastUpdateReason, TimeRemaining, source)
	end
	
	SetRoutingBucket(source)
end)

AddEventHandler('playerDropped', function (reason)
	print("Player " .. GetPlayerName(source) .. " dropped, reason: " .. reason)
	
	if DoesSetContain(PlayersPaused, source, true) then
		RemoveFromSet(PlayersPaused, source, true)
		RefreshPauseState()
	end
	
	if DoesSetContain(PlayersGhosting, source, true) then RemoveFromSet(PlayersGhosting, source, true) end
	if DoesSetContain(LastActivePlayersUpdate, source, true) then RemoveFromSet(LastActivePlayersUpdate, source, true) end
	
	TriggerClientEvent("ActivePlayerDropped", -1, tostring(source))
end)

RegisterNetEvent("ResourceStopped")
AddEventHandler('ResourceStopped', function(Resource)
	print("Resource:  " .. Resource .. " has been stopped on the client, player:  " .. source .. ", kicking?  " .. tostring(CONFIG.NETWORK_PROTECTION.auto_kick))
	
	if CONFIG.NETWORK_PROTECTION.auto_kick then DropPlayer(source, "You appear to have stopped one of our scripts, you've been kicked to prevent hacking and to protect our community.") end
end)

RegisterNetEvent("SetTimer")
AddEventHandler('SetTimer', function(Time)
	if type(Time) ~= "number" or Time ~= Time or Time <= -math.huge or Time >= math.huge or Time < -1 then
		d_print("Rejected invalid timer value from player:  " .. source, 3)
		return
	end

	d_print(("Timer set: %s from %i"):format(Time, source), 3)
	
	local NewTime = Time
	if Time ~= -1 and TimeRemaining ~= -1 then NewTime = TimeRemaining + Time end
	
	local Reason = nil
	if TimeRemaining == -1 then Reason = "newtimer"
	elseif NewTime > TimeRemaining then Reason = "timerextended"
	elseif Time == -1 then  Reason = "canceltimer" end
	
	if CONFIG.PARENTAL.timer_server_wide then
		SyncTimerWithPlayers(Reason, NewTime)
		TimeRemaining = NewTime
	else
		d_print("Ignoring timer, CONFIG.PARENTAL.timer_server_wide not set true!", 3)
	end
end)

function SyncTimerWithPlayers(Reason, Time, PushTo)
	local packet = {
		reason = Reason,
		time_remaining = Time,
		old_time = TimeRemaining,
		is_paused = TimerIsPaused,
		force_pause = ForcePauseEveryone
	}
	
	if Time ~= 0 then TimerExpiredTriggered = false	end
	
	if Reason ~= "" then LastUpdateReason = Reason end
	if not PushTo then PushTo = -1 end
	TriggerClientEvent("SyncTimer", PushTo, packet)
end

RegisterNetEvent("PauseTimer")
AddEventHandler('PauseTimer', function(Pause)
	if type(Pause) ~= "boolean" then return end

	d_print(('Player paused? %s player %i'):format(Pause, source), 3)
	
	if Pause and not DoesSetContain(PlayersPaused, source, true) then AddToSet(PlayersPaused, source, nil, true)
	elseif not Pause and DoesSetContain(PlayersPaused, source, true) then RemoveFromSet(PlayersPaused, source, true) end
		
	if TimeRemaining > 0 then RefreshPauseState() end
end)

function RefreshPauseState()
	local ChangeState = false
	
	if not TimerIsPaused and TableLength(PlayersPaused) > 0 then
		TimerIsPaused = true
		ChangeState = true
	elseif TimerIsPaused and TableLength(PlayersPaused) == 0 then
		TimerIsPaused = false
		ChangeState = true
	end
	
	if ChangeState then 
		SyncTimerWithPlayers("pausestate", TimeRemaining)
	end
end

RegisterNetEvent("ForcePausePlayers")
AddEventHandler('ForcePausePlayers', function(Pause)
	if type(Pause) ~= "boolean" then return end

	print(('Force players pause? %s from player %i'):format(Pause, source))
	if TimeRemaining > 0 then
		ForcePauseEveryone = Pause
		SyncTimerWithPlayers("forcepause", TimeRemaining)
	end
end)

function IsPedModelLegal(ModelHash, IgnoreTrustedCheck)
	if CONFIG.NETWORK_PROTECTION.disable_known_inappropriate_ped_models then
		if DoesSetContain(CONSTANT.RESTRICTED_PEDS, ModelHash) then return false, 1 end
	end
	if CONFIG.NETWORK_PROTECTION.trusted_ped_models_only
		and not IgnoreTrustedCheck
		and next(SPAWN_ITEMS.PEDS) ~= nil then
			if not DoesSetContain(TrustedPedModels, ModelHash) then return false, 0 end
	end
	
	return true, -1
end

function IllegalPlayerPed(Player, Type)
	local TypeStr = "Ped model is not trusted."
	if Type == 1 then TypeStr = "Ped model is in the RESTRICTED_PEDS list!" end
	
	d_print("Player: " .. Player .. " has an illegal player ped model loaded! " .. TypeStr, 3)
	
	local NewModelHash = nil
	if LastActivePlayersUpdate[Player] ~= nil then
		NewModelHash = LastActivePlayersUpdate[Player].ped_model
	elseif CONFIG.NETWORK_PROTECTION.trusted_ped_models_only
		and next(SPAWN_ITEMS.PEDS) ~= nil then
			local Model, Name = next(SPAWN_ITEMS.PEDS)
			NewModelHash = GetHashKey(Model)
	else
		NewModelHash = GetHashKey("ig_bankman")
	end
	
	SetPlayerPed(Player, {
		model_hash = NewModelHash,
		model_name = "reverted to a trusted model (:",
		vehicle_net_id = 0,
		seat = -2
	})
end

function SetPlayerPed(Player, Data)
	if type(Data) ~= "table" or type(Data.model_hash) ~= "number" then
		TriggerClientEvent("SpawnServerDecision", Player, {type = 0, error = true, decision = "invalid ped request."})
		return
	end

	local Legal = IsPedModelLegal(Data.model_hash)
	if not Legal then
		TriggerClientEvent("SpawnServerDecision", Player, {type = 0, error = true, decision = "not a permitted ped model."})
		return
	end

	local PlayerPed = GetPlayerPed(Player)
	if not DoesEntityExist(PlayerPed) then
		TriggerClientEvent("SpawnServerDecision", Player, {type = 0, error = true, decision = "player ped was not available."})
		return
	end

	if GetEntityModel(PlayerPed) ~= Data.model_hash then
		SetPlayerModel(Player, Data.model_hash)

		local Timeout = GetGameTimer() + 5000
		repeat
			Citizen.Wait(50)
			PlayerPed = GetPlayerPed(Player)
		until (DoesEntityExist(PlayerPed) and GetEntityModel(PlayerPed) == Data.model_hash)
			or GetGameTimer() >= Timeout

		if not DoesEntityExist(PlayerPed) or GetEntityModel(PlayerPed) ~= Data.model_hash then
			TriggerClientEvent("SpawnServerDecision", Player, {type = 0, error = true, decision = "ped model change timed out."})
			return
		end
	end

	if LastActivePlayersUpdate[Player] ~= nil then
		LastActivePlayersUpdate[Player].ped_model = GetEntityModel(PlayerPed)
	end

	if type(Data.vehicle_net_id) == "number"
		and Data.vehicle_net_id > 0
		and NetworkDoesEntityExistWithNetworkId(Data.vehicle_net_id) then
			local Vehicle = NetworkGetEntityFromNetworkId(Data.vehicle_net_id)
			if DoesEntityExist(Vehicle) then
				TaskWarpPedIntoVehicle(PlayerPed, Vehicle, tonumber(Data.seat) or -1)
			end
	end

	local ModelName = type(Data.model_name) == "string" and Data.model_name or tostring(Data.model_hash)
	TriggerClientEvent("SpawnServerDecision", Player, {type = 0, error = false, decision = "Player model changed to:  ~g~" .. ModelName})
end

RegisterNetEvent("ChangePlayerPed")
AddEventHandler('ChangePlayerPed', function(Data)
	SetPlayerPed(source, Data)
end)

function IsFiniteNumber(Value)
	return type(Value) == "number" and Value == Value and Value > -math.huge and Value < math.huge
end

function RejectVehicleSpawn(Player, Reason)
	TriggerClientEvent("SpawnServerDecision", Player, {type = 1, error = true, decision = Reason})
end

local SpawnedVehicles = {}
RegisterNetEvent("SpawnVehicle")
AddEventHandler('SpawnVehicle', function(Data)
	local ModelHash = nil
	local IsClone = false
	local Player = source
	local PlayerPed = GetPlayerPed(Player)
	local QuickSpawn = Data and Data.quick_spawn == true
	local TeleportInside = Data and Data.teleport_inside == true
	local RequestedSpeed = Data and IsFiniteNumber(Data.speed) and Data.speed or 0.0

	if type(Data) ~= "table" or type(Data.coords) ~= "table" or not DoesEntityExist(PlayerPed) then
		RejectVehicleSpawn(Player, "invalid vehicle spawn request.")
		return
	end

	if not IsFiniteNumber(Data.coords.x) or not IsFiniteNumber(Data.coords.y)
		or not IsFiniteNumber(Data.coords.z) or not IsFiniteNumber(Data.heading) then
			RejectVehicleSpawn(Player, "invalid vehicle spawn position.")
			return
	end

	local PlayerCoords = GetEntityCoords(PlayerPed)
	local DeltaX = Data.coords.x - PlayerCoords.x
	local DeltaY = Data.coords.y - PlayerCoords.y
	local DeltaZ = Data.coords.z - PlayerCoords.z
	if (DeltaX * DeltaX) + (DeltaY * DeltaY) + (DeltaZ * DeltaZ) > 10000.0 then
		RejectVehicleSpawn(Player, "vehicle spawn position is too far from the player.")
		return
	end
	
	if IsVarSetTrue(Data.force_model) then
		if type(Data.force_model) ~= "string" or SPAWN_ITEMS.VEHICLES[Data.force_model] == nil then
			RejectVehicleSpawn(Player, "vehicle model is not permitted.")
			return
		end
		ModelHash = GetHashKey(Data.force_model)
	else
		if type(Data.clone_entity) ~= "number"
			or not NetworkDoesEntityExistWithNetworkId(Data.clone_entity) then
				RejectVehicleSpawn(Player, "vehicle to clone is not available.")
				return
		end
		local CloneEntity = NetworkGetEntityFromNetworkId(Data.clone_entity)
		if not DoesEntityExist(CloneEntity) or GetEntityType(CloneEntity) ~= 2 then
			RejectVehicleSpawn(Player, "entity to clone is not a vehicle.")
			return
		end
		ModelHash = GetEntityModel(CloneEntity)
		IsClone = true
	end
	
	if not DoesSetContain(SpawnedVehicles, Player) then
		AddToSet(SpawnedVehicles, Player, {
			quick_spawn = 0,
			anti_flood = {}
		})
	end
	if QuickSpawn and DoesEntityExist(SpawnedVehicles[Player].quick_spawn) then
		if not DoesEntityExist(GetLastPedInVehicleSeat(SpawnedVehicles[Player].quick_spawn, -1)) then
			DeleteEntity(SpawnedVehicles[Player].quick_spawn)
		else table.insert(SpawnedVehicles[Player].anti_flood, SpawnedVehicles[Player].quick_spawn) end
	end
	if #SpawnedVehicles[Player].anti_flood >= CONFIG.VEHICLES.max_spawned_per_player then
		local PurgeCount = #SpawnedVehicles[Player].anti_flood - CONFIG.VEHICLES.max_spawned_per_player
		
		for i=1, #SpawnedVehicles[Player].anti_flood do
			if DoesEntityExist(SpawnedVehicles[Player].anti_flood[1])
				and not IsAnyPlayerInVehicle(SpawnedVehicles[Player].anti_flood[1]) then
					DeleteEntity(SpawnedVehicles[Player].anti_flood[1])
					d_print("Vehicle anti-flood, deleting vehicle:  " .. SpawnedVehicles[Player].anti_flood[1], 2)
			end
			table.remove(SpawnedVehicles[Player].anti_flood, 1)
			
			if i >= PurgeCount then break end
		end
		
		Citizen.Wait(200)
	end
	
	local SpawnVeh = CreateVehicle(ModelHash, Data.coords.x, Data.coords.y, Data.coords.z, Data.heading, true, false)
	d_print("Vehicle spawned as per request of player:  " .. Player .. ", hash:  " .. ModelHash, 2)
	
	local SpawnTimeout = GetGameTimer() + 10000
	while SpawnVeh ~= 0 and not DoesEntityExist(SpawnVeh) and GetGameTimer() < SpawnTimeout do
		Citizen.Wait(100)
	end
	if SpawnVeh == 0 or not DoesEntityExist(SpawnVeh) then
		RejectVehicleSpawn(Player, "vehicle creation failed or timed out.")
		return
	end
	
	SetRoutingBucket(nil, SpawnVeh)
	if TeleportInside then TaskWarpPedIntoVehicle(PlayerPed, SpawnVeh, -1) end
	if QuickSpawn then SpawnedVehicles[Player].quick_spawn = SpawnVeh
	else table.insert(SpawnedVehicles[Player].anti_flood, SpawnVeh) end
	
	local ModelName = type(Data.model_name) == "string" and Data.model_name:sub(1, 80) or tostring(ModelHash)
	TriggerClientEvent("SpawnServerDecision", Player, {type = 1, error = false, decision = "Vehicle spawned:  ~g~" .. ModelName, entity = NetworkGetNetworkIdFromEntity(SpawnVeh), is_a_clone = IsClone, is_quick_spawn = QuickSpawn, speed = RequestedSpeed})
	
	d_print("Vehicles spawned by player:  " .. Player .. ",  " .. dump(SpawnedVehicles), 2)
end)


RegisterNetEvent("PlayerToggleGhost")
AddEventHandler('PlayerToggleGhost', function(Ghost)
	if type(Ghost) ~= "boolean" then return end

	if Ghost and not DoesSetContain(PlayersGhosting, source, true) then AddToSet(PlayersGhosting, source, nil, true)
	elseif not Ghost and DoesSetContain(PlayersGhosting, source, true) then RemoveFromSet(PlayersGhosting, source, true) end
	
	TriggerClientEvent("UpdatedPlayerData", -1, {player = tostring(source), data = GetNetPlayerData(source)})
end)

RegisterNetEvent("GetUpdatedPlayerData")
AddEventHandler('GetUpdatedPlayerData', function(NetPlayer)
	if type(NetPlayer) ~= "string" and type(NetPlayer) ~= "number" then return end
	if GetPlayerName(NetPlayer) == nil then return end

	TriggerClientEvent("UpdatedPlayerData", source, {player = NetPlayer, data = GetNetPlayerData(NetPlayer)})
end)

RegisterNetEvent("ReportLocationUpdated")
AddEventHandler('ReportLocationUpdated', function()
	TriggerClientEvent("UpdatedPlayerData", -1, {player = tostring(source), data = GetNetPlayerData(source)})
end)

function GetNetPlayerData(NetPlayer)
	local NetPlayerPed = GetPlayerPed(NetPlayer)
	
	if DoesEntityExist(NetPlayerPed) then
		local NetPlayerPedId = NetworkGetNetworkIdFromEntity(NetPlayerPed)
		local NetPlayerPedModel = nil
		if DoesSetContain(LastActivePlayersUpdate, NetPlayer) then 
			NetPlayerPedModel = LastActivePlayersUpdate[NetPlayer].ped_model
		else
			CheckPedValidity(NetPlayer, NetPlayerPed, true)
			NetPlayerPedModel = GetEntityModel(NetPlayerPed)
		end
		
		local Coords = GetEntityCoords(NetPlayerPed)
		local IsPaused, IsGhost = false, false
		if DoesSetContain(PlayersPaused, NetPlayer, true) then IsPaused = true end
		if DoesSetContain(PlayersGhosting, NetPlayer, true) then IsGhost = true end
		
		return {
			ped = NetPlayerPedId,
			ped_model = NetPlayerPedModel,
			coords = Coords,
			is_paused = IsPaused,
			is_ghost = IsGhost,
			player_name = (CONFIG.NETWORK.gamertag_format):gsub("%%GAMERTAG%%", GetPlayerName(NetPlayer))
		}
	else
		return nil
	end
end

function CheckPedValidity(NetPlayer, NetPlayerPed, IgnoreTrustedCheck)
	if DoesEntityExist(NetPlayerPed) then
		local NewPedModel = GetEntityModel(NetPlayerPed)
		if (LastActivePlayersUpdate[NetPlayer] ~= nil and LastActivePlayersUpdate[NetPlayer].ped_model ~= NewPedModel)
			or LastActivePlayersUpdate[NetPlayer] == nil then
				d_print("New ped model detected, checking if model is trusted", 2)
				local Legal, Type = IsPedModelLegal(NewPedModel, IgnoreTrustedCheck)
				if not Legal then
					IllegalPlayerPed(NetPlayer, Type)
					NewPedModel = GetEntityModel(GetPlayerPed(NetPlayer))
				end
				
				if LastActivePlayersUpdate[NetPlayer] ~= nil then
					LastActivePlayersUpdate[NetPlayer].ped_model = NewPedModel
				end
		end
	end
end

function SetRoutingBucket(Player, Entity)
	if CONFIG.NETWORK_PROTECTION.spawn_protection then
		if IsVarSetTrue(Player) then SetPlayerRoutingBucket(Player, 1)
		elseif IsVarSetTrue(Entity) then SetEntityRoutingBucket(Entity, 1)
		else
			SetRoutingBucketEntityLockdownMode(1, "relaxed")
			SetRoutingBucketPopulationEnabled(1, true)
		end
		
		d_print("Routing bucket 1 updated:  Player(" .. tostring(Player) .. "), Entity(" .. tostring(Entity) .. ")", 2)
	end
end

Citizen.CreateThread(function()
	print ("FiveM Kid Friendly server side loaded.")
	
	SetRoutingBucket()
	
	if CONFIG.NETWORK_PROTECTION.trusted_ped_models_only then
		if next(SPAWN_ITEMS.PEDS) ~= nil then
			for model,name in pairs(SPAWN_ITEMS.PEDS) do
				AddToSet(TrustedPedModels, GetHashKey(model))
				d_print("Ped added to trusted peds:  " .. model, 3)
			end
		end
	end
	
	while true do
		Citizen.Wait(1000) -- Repeat every second
		ServerClock = ServerClock + 1
		if not TimerIsPaused and not ForcePauseEveryone and TimeRemaining > 0 then TimeRemaining = TimeRemaining - 1000 end
		
		-- Ensure all clients are in sync every 120 seconds
		if RunEveryX(120) and TimeRemaining > -1 then
			SyncTimerWithPlayers("", TimeRemaining)
			d_print("Syncing timer with players", 2)
		end
		
		if TimeRemaining == 0 and not TimerExpiredTriggered then
			d_print("Game timer expired, running timeout counter", 3)
			SyncTimerWithPlayers("timeexpiried", 0)
			TimerExpiredTriggered = true
		end
		
		if RunEveryX(2) then
			if (CONFIG.NETWORK_PROTECTION.trusted_ped_models_only
				or CONFIG.NETWORK_PROTECTION.disable_known_inappropriate_ped_models)
				and next(LastActivePlayersUpdate) ~= nil then
					for NetPlayer, Data in pairs(LastActivePlayersUpdate) do
						local NetPlayerPed = GetPlayerPed(NetPlayer)
						CheckPedValidity(NetPlayer, NetPlayerPed)
					end
			end
		end
		
		if RunEveryX(10) then
			local NetPlayers = GetPlayers()
		
			if #NetPlayers > 0 then
				d_print("Active players found, count:  " .. #NetPlayers .. ", data:  " .. dump(NetPlayers), 2)
				local ActivePlayers = {}
				
				for index, NetPlayer in ipairs(NetPlayers) do
					local NetPlayerData = GetNetPlayerData(NetPlayer)
					if NetPlayerData ~= nil then AddToSet(ActivePlayers, NetPlayer, NetPlayerData) end
				end
				LastActivePlayersUpdate = ActivePlayers
				
				if next(ActivePlayers) ~= nil then
					d_print("Active player data compiled, data:  " .. dump(ActivePlayers), 2)
					
					if #NetPlayers > 1 then
						Citizen.CreateThread(function()
							for index, NetPlayer in ipairs(NetPlayers) do
								if DoesEntityExist(GetPlayerPed(NetPlayer)) then
									local PushPlayers = {}
									for PushPlayer, Data in pairs(ActivePlayers) do
										
										if PushPlayer ~= NetPlayer then
											AddToSet(PushPlayers, PushPlayer, Data) 
										end
									end
									
									if next(PushPlayers) ~= nil then
										d_print("Sending detected active players to player:  " .. NetPlayer .. ", data:  " .. dump(PushPlayers), 2)
										TriggerClientEvent("UpdateActivePlayers", NetPlayer, PushPlayers)
										
										Citizen.Wait(100) -- To save bandwidth
									end
								end
							end
						end)
					end
				end
			end
		end
	end
end)
