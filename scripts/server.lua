---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- KID FRIENDLY MOD for FiveM by Jackson92 --------------------------------------------------------
-----FOR NORMAL USE, YOU SHOULD NOT NEED TO EDIT PAST THIS POINT!----------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local ServerClock = 0
local PlayersConnected = {}
local PlayersPaused = {}
local TimeRemaining = -1
local TimerIsPaused = false
local ForcePauseEveryone = false
local LastUpdateReason = ""
local TimerExpiredTriggered = false
local TimeExpiredClockRemaining = 60000

function RunEveryX(S)
	if ServerClock % S == 0 then return true
	else return false end
end

function AddToSet(set, key, value)
	if not value then set[key] = true
	else set[key] = value end
end

function RemoveFromSet(set, key)
	set[key] = nil
end

function DoesSetContain(set, key)
	return set[key] ~= nil
end

function TableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

AddEventHandler('playerJoining', function (source, oldId)
	print("Player " .. GetPlayerName(source) .. " joined")
	
	AddToSet(PlayersConnected, source)
	if TimeRemaining ~= -1 then
		SyncTimerWithPlayers(LastUpdateReason, TimeRemaining, source)
	end
end)

AddEventHandler('playerDropped', function (reason)
	print("Player " .. GetPlayerName(source) .. " dropped (Reason: " .. reason .. ")")
	
	RemoveFromSet(PlayersConnected, source)
	if DoesSetContain(PlayersPaused, source) then
		RemoveFromSet(PlayersPaused, source)
		RefreshPauseState()
	end
end)

-- FROM Client
RegisterNetEvent("SetTimer")
AddEventHandler('SetTimer', function(Time)
	print(("Timer set: %s from %i"):format(Time, source))
	
	local NewTime = Time
	if Time ~= -1 and TimeRemaining ~= -1 then NewTime = TimeRemaining + Time end
	
	local Reason = nil
	if TimeRemaining == -1 then Reason = "newtimer"
	elseif NewTime > TimeRemaining then Reason = "timerextended"
	elseif Time == -1 then  Reason = "canceltimer" end
	
	SyncTimerWithPlayers(Reason, NewTime)
	TimeRemaining = NewTime
end)

function SyncTimerWithPlayers(Reason, Time, PushTo)
	local packet = {
		reason = Reason,
		time_remaining = Time,
		old_time = TimeRemaining,
		is_paused = TimerIsPaused,
		force_pause = ForcePauseEveryone
	}
	
	if Time ~= 0 then
		TimerExpiredTriggered = false
		TimeExpiredClockRemaining = 60000
	end
	
	if Reason ~= "" then LastUpdateReason = Reason end
	if not PushTo then PushTo = -1 end
	TriggerClientEvent("SyncTimer", PushTo, packet)
end

RegisterNetEvent("PauseTimer")
AddEventHandler('PauseTimer', function(Pause)
	print(('Player paused? %s player %i'):format(Pause, source))
	if TimeRemaining > 0 then
		if Pause then AddToSet(PlayersPaused, source, nil)
		elseif DoesSetContain(PlayersPaused, source) then RemoveFromSet(PlayersPaused, source) end
		
		RefreshPauseState()
	end
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
	print(('Force players pause? %s from player %i'):format(Pause, source))
	if TimeRemaining > 0 then
		ForcePauseEveryone = Pause
		SyncTimerWithPlayers("forcepause", TimeRemaining)
	end
end)

Citizen.CreateThread(function()
	print ("Kid friendly server side loaded")
	
	while true do
		Citizen.Wait(1000) -- Repeat every second
		ServerClock = ServerClock +1
		if not TimerIsPaused and not ForcePauseEveryone and TimeRemaining > 0 then TimeRemaining = TimeRemaining - 1000 end
		if TimerExpiredTriggered and TimeExpiredClockRemaining > 0 then
			TimeExpiredClockRemaining = TimeExpiredClockRemaining - 1000
			print("Timeout player kick in:  " .. TimeExpiredClockRemaining .. " seconds")
		end
		
		-- Ensure all clients are in sync every 200 seconds
		if RunEveryX(200) and TimeRemaining > -1 then
			SyncTimerWithPlayers("", TimeRemaining)
			print("Syncing with players")
		end
		
		if TimeRemaining == 0 and not TimerExpiredTriggered then
			print("Game timer expired, running timeout counter")
			SyncTimerWithPlayers("timeexpiried", 0)
			TimerExpiredTriggered = true
		end
		
		--[[
		TESTING - DROP PLAYERS ON TIMER END
		if TimeExpiredClockRemaining == 0 then
			for source,_ in pairs(PlayersConnected) do
				DropPlayer(source, "Game timer timed out.")
				RemoveFromSet(PlayersConnected, source)
				print("Dropping player:   " .. source)
			end
		end
		]]--
	end
end)