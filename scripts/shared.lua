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
CONSTANT = {
	RESTRICTED_PEDS = {
		-- Disturbing peds
		[GetHashKey("a_m_m_acult_01")] = 1,
		[GetHashKey("a_f_m_fatcult_01")] = 1,
		[GetHashKey("mp_m_cocaine_01")] = 1,
		[GetHashKey("mp_f_cocaine_01")] = 1,
		[GetHashKey("csb_stripper_01")] = 1,
		[GetHashKey("csb_stripper_02")] = 1,
		[GetHashKey("mp_f_stripperlite")] = 1,
		[GetHashKey("s_f_y_stripper_01")] = 1,
		[GetHashKey("s_f_y_stripper_02")] = 1,
		[GetHashKey("s_f_y_stripperlite")] = 1,
		[GetHashKey("cs_bradcadaver")] = 1,
		[GetHashKey("u_f_m_corpse_01")] = 1,
		[GetHashKey("u_f_y_corpse_01")] = 1,
		[GetHashKey("u_f_y_corpse_02")] = 1,
		[GetHashKey("u_m_y_corpse_01")] = 1,
		[GetHashKey("u_m_y_justin")] = 1,
		[GetHashKey("u_m_y_staggrm_01")] = 1,
		[GetHashKey("u_m_y_zombie_01")] = 1,
		-- Peds wearing minimal clothing
		[GetHashKey("a_f_m_beach_01")] = 2,
		[GetHashKey("a_f_m_bodybuild_01")] = 2,
		[GetHashKey("a_f_y_beach_01")] = 2,
		[GetHashKey("a_f_y_juggalo_01")] = 2,
		[GetHashKey("a_f_y_topless_01")] = 2,
		[GetHashKey("a_m_m_beach_02")] = 2,
		[GetHashKey("a_m_m_tranvest_01")] = 2,
		[GetHashKey("a_m_y_acult_02")] = 2,
		[GetHashKey("a_m_y_musclbeac_01")] = 2,
		[GetHashKey("s_f_y_baywatch_01")] = 2,
		[GetHashKey("ig_tracydisanto")] = 2,
		[GetHashKey("u_f_y_danceburl_01")] = 2,
		[GetHashKey("u_f_y_dancelthr_01")] = 2,
		[GetHashKey("u_f_y_dancerave_01")] = 2
	},
	
	RESTRICTED_AREAS = {
		["stripclub"] = {
			[197121] = {
				{door_hash = GetHashKey("prop_strip_door_01"), coords = {x = 127.955, y = -1298.503, z = 29.419}},
				{door_hash = GetHashKey("prop_magenta_door"), coords = {x = 96.091, y = -1284.854, z = 29.438}}
			}
		},
		["ammunation"] = {
			[180481] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = -324.273, y = 6077.109, z = 31.604}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = -326.112, y = 6075.270, z = 31.604}}
			},
			[200961] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 1699.937, y = 3753.420, z = 34.855}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 1698.176, y = 3751.506, z = 34.855}}
			},
			[175617] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = -1112.071, y = 2691.505, z = 18.704}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = -1114.009, y = 2689.770, z = 18.704}}
			},
			[176385] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = -3163.812, y = 1083.779, z = 20.988}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = -3164.845, y = 1081.392, z = 20.988}}
			},
			[178689] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 2568.304, y = 303.355, z = 108.884}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 2570.905, y = 303.355, z = 108.884}}
			},
			[140289] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 243.837, y = -46.523, z = 70.090}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 244.727, y = -44.079, z = 70.090}}
			},
			[164609] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = -1314.465, y = -391.647, z = 36.845}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = -1313.826, y = -389.125, z = 36.845}}
			},
			[168193] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = -662.641, y = -944.325, z = 21.979}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = -665.242, y = -944.325, z = 21.979}}
			},
			[153857] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 842.768, y = -1024.539, z = 28.344}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 845.369, y = -1024.539, z = 28.344}}
			},
			[137729] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 18.572, y = -1115.495, z = 29.946}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 16.127, y = -1114.606, z = 29.946}}
			},
			[248065] = {
				{door_hash = GetHashKey("v_ilev_gc_door03"), coords = {x = 810.576, y = -2148.270, z = 29.768}},
				{door_hash = GetHashKey("v_ilev_gc_door04"), coords = {x = 813.177, y = -2148.270, z = 29.768}}
			}
		},
		["liquor"] = {
			[170753] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = -1226.894, y = -903.121, z = 12.470}}
			},
			[168449] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = -1490.411, y = -383.845, z = 40.307}}
			},
			[154113] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = 1141.038, y = -980.322, z = 46.559}}
			},
			[175105] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = -2973.535, y = 390.141, z = 15.187}}
			},
			[200705] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = 1392.927, y = 3599.469, z = 35.130}},
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = 1395.371, y = 3600.358, z = 35.130}}
			}
		},
		["tattoo"] = {
			[180737] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = -289.175, y = 6199.112, z = 31.637}}
			},
			[199425] = {
				{door_hash = GetHashKey("v_ilev_ml_door1"), coords = {x = 1859.894, y = 3749.786, z = 33.181}}
			},
			[176897] = {
				{door_hash = GetHashKey("v_ilev_ta_door2"), coords = {x = -3174.213, y = 1073.962, z = 20.979}}
			},
			[140033] = {
				{door_hash = GetHashKey("v_ilev_ta_door2"), coords = {x = 320.510, y = 184.716, z = 103.736}} -- broken
			},
			[171521] = {
				{door_hash = GetHashKey("v_ilev_ta_door2"), coords = {x = -1149.503, y = -1426.590, z = 5.104}} -- broken
			},
			[251137] = {
				{door_hash = GetHashKey("v_ilev_ta_door2"), coords = {x = 1327.407, y = -1652.747, z = 52.426}}
			}
		},
		["drugs"] = {
			[200705] = {
				{door_hash = GetHashKey("v_ilev_ss_doorext"), coords = {x = 1388.499, y = 3614.828, z = 39.091}},
				{door_hash = GetHashKey("v_ilev_ss_doorext"), coords = {x = 1399.700, y = 3607.763, z = 39.091}},
				{door_hash = GetHashKey("v_ilev_ss_door04"), coords = {x = 1395.613, y = 3609.327, z = 35.130}}
			}
		},
		["misc"] = {
			-- Todo
			-- Tervor's caravan?
		}
	},
	
	WEATHER = {
		"DEFAULT", -- Match server
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
		light_pink = {r = 255, g = 160, b = 255},
		light_green = {r = 122, g = 255, b = 122},
		light_blue = {r = 0, g = 216, b = 255},
		light_grey = {r = 220, g = 220, b = 220},
	},
	
	ParachuteHash = GetHashKey("gadget_parachute")
}

function IsVarSetTrue(Var)
	if Var == nil then return false end
	if type(Var) == "boolean" then return Var end
	if type(Var) == "number" then
		if Var > 0 then return true
		else return false end
	end
	if type(Var) == "string" and Var ~= "" then return true end
	return false
end

function AddToSet(set, key, value, forceKeyString)
	if forceKeyString then key = tostring(key) end
	value = value or true
	
	set[key] = value
end

function RemoveFromSet(set, key, forceKeyString)
	if forceKeyString then key = tostring(key) end
	set[key] = nil
end

function DoesSetContain(set, key, forceKeyString)
	if forceKeyString then key = tostring(key) end
	return set[key] ~= nil
end

function GetFromSetAtPosX(Set, Position)
	local Pass = 1
	for Key,Val in pairs(Set) do
		if Pass == Position then return Key, Val end
		Pass = Pass + 1
	end
	return nil, nil
end

function GetKeyFromValue(T, Value)
	if IsVarSetTrue(Value) then
		for K,V in pairs(T) do
			if V == Value then return K end
		end
	end
	return nil
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
	if T ~= nil then
		for _ in pairs(T) do Count = Count +1 end
	end
	return Count
end

function RandomiseIndexes(List)
	local Indexes = {}
	if next(List) ~= nil then
		for Index,Data in pairs(List) do
			table.insert(Indexes, Index)
		end
	end
	return Shuffle(Indexes)
end

function dump(T)
	if type(T) == 'table' then
		local s = '{ '
		for k,v in pairs(T) do
			if type(k) ~= 'number' then k = '"'..tostring(k)..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(T)
	end
end

function d_print(S, Level)
	Level = Level or 1
	if CONFIG.DEBUG > 0 and CONFIG.DEBUG <= Level then print("[" .. tostring(debug.getinfo(2).name) .. "](" .. debug.getinfo(2).linedefined .. ")  " .. S) end
end

function IsAnyPlayerInVehicle(Vehicle, IgnoreSelf)
	if DoesEntityExist(Vehicle) then
		for i=-1, 6 do
			local PedInSeat = GetPedInVehicleSeat(Vehicle, i)
			if PedInSeat ~= nil then
				if IsPedAPlayer(PedInSeat) and (not IsVarSetTrue(IgnoreSelf) or (IsVarSetTrue(IgnoreSelf) and PedInSeat ~= IgnoreSelf)) then return true end
			end
		end
	end
	return false
end