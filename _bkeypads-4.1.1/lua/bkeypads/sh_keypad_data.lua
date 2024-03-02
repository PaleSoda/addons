bKeypads.KeypadData = {}

function bKeypads.KeypadData:AccessMatrix()
	return {
		bKeypads.ACCESS_GROUP.VERSION,

		[bKeypads.ACCESS_GROUP.PAYMENT] = false,

		[bKeypads.ACCESS_TYPE.WHITELIST] = {
			[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = false,
			[bKeypads.ACCESS_GROUP.PLAYER] = {},
			[bKeypads.ACCESS_GROUP.USERGROUP] = {},
			[bKeypads.ACCESS_GROUP.TEAM] = {},

			[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] = {},
			[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = false,

			[bKeypads.ACCESS_GROUP.DARKRP_JOB] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = {},

			[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = {},

			[bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION] = {},
			[bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP] = {},
			[bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION] = {},

			[bKeypads.ACCESS_GROUP.HELIX_FLAG] = {},

			[bKeypads.ACCESS_GROUP.MRS_RANK] = {},
			[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] = false,
		},

		[bKeypads.ACCESS_TYPE.BLACKLIST] = {
			[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = false,
			[bKeypads.ACCESS_GROUP.PLAYER] = {},
			[bKeypads.ACCESS_GROUP.USERGROUP] = {},
			[bKeypads.ACCESS_GROUP.TEAM] = {},

			[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] = {},
			[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = false,

			[bKeypads.ACCESS_GROUP.DARKRP_JOB] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = {},

			[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = {},
			[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = {},

			[bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION] = {},
			[bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP] = {},
			[bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION] = {},

			[bKeypads.ACCESS_GROUP.HELIX_FLAG] = {},

			[bKeypads.ACCESS_GROUP.MRS_RANK] = {},
			[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] = false,
		},
	}
end

-- TODO programmatic access matrices

local defaultEntries = {
	bKeypads.ACCESS_GROUP.PLAYER,
	bKeypads.ACCESS_GROUP.USERGROUP,
	bKeypads.ACCESS_GROUP.TEAM,

	bKeypads.ACCESS_GROUP.KEYCARD_LEVEL,

	bKeypads.ACCESS_GROUP.DARKRP_JOB,
	bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY,

	bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP,
	bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP,
	bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP,

	bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION,
	bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP,
	bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION,

	bKeypads.ACCESS_GROUP.HELIX_FLAG,
	bKeypads.ACCESS_GROUP.MRS_RANK,
}
function bKeypads.KeypadData:MergeAccessMatrix(accessMatrix)
	for _, key in ipairs(defaultEntries) do
		for _, access_type in ipairs(bKeypads.ACCESS_TYPES) do
			accessMatrix[access_type][key] = accessMatrix[access_type][key] or {}
		end
	end
end

function bKeypads.KeypadData:CreationData()
	return {
		GrantedKey = 0,
		GrantedDelay = 0,
		GrantedRepeats = 0,
		GrantedRepeatDelay = bKeypads.Config.Scanning.AccessGranted.MinimumRepeatDelay,

		DeniedKey = 0,
		DeniedDelay = 0,
		DeniedRepeats = 0,
		DeniedRepeatDelay = bKeypads.Config.Scanning.AccessDenied.MinimumRepeatDelay,

		--PIN = "",
		--ImageURL = "",
	}
end

--## FILE SERIALIZATION / DESERIALIZATION ##

bKeypads.KeypadData.File = {}
bKeypads.KeypadData.File.Instances = {}

do
	local function pack(...) return {...} end

	local f_debug_funcs = {"Close", "Flush", "Read", "ReadBool", "ReadByte", "ReadDouble", "ReadFloat", "ReadLine", "ReadLong", "ReadShort", "ReadULong", "ReadUShort", "Seek", "Size", "Skip", "Tell", "Write", "WriteBool", "WriteByte", "WriteDouble", "WriteFloat", "WriteLong", "WriteShort", "WriteULong", "WriteUShort"}
	local f_debug_func_overrides = {}
	for i, func in ipairs(f_debug_funcs) do
		f_debug_func_overrides[func] = function(self, ...)
			local argsStr = "\t"
			for k, v in ipairs({...}) do argsStr = argsStr .. "\t" .. tostring(v) end

			local returnArgs = pack(self.f[func](self.f, ...))

			local returnStr = "\t"
			for k, v in ipairs(returnArgs) do returnStr = returnStr .. "\t" .. tostring(v) end

			print(self.f:Tell(), func .. argsStr:sub(2) .. returnStr:sub(2))

			return unpack(returnArgs)
		end
	end

	function bKeypads.KeypadData.File:Open(name, write, path, debug)
		bKeypads.KeypadData.File:Close(name, path)

		local f = file.Open(name, write and "wb" or "rb", path)
		if debug then
			print(write and "====== FILE WRITE ======" or "====== FILE READ ======")
			local fakeFile = {f = f}
			for func, debug_func in pairs(f_debug_func_overrides) do
				fakeFile[func] = debug_func
			end
			return fakeFile
		else
			bKeypads.KeypadData.File.Instances[name .. path] = f
			return f
		end
	end

	function bKeypads.KeypadData.File:Close(name, path)
		local file_id = name .. path
		if bKeypads.KeypadData.File.Instances[file_id] ~= nil then
			bKeypads.KeypadData.File.Instances[file_id]:Close()
			bKeypads.KeypadData.File.Instances[file_id] = nil
		end
	end
end

function bKeypads.KeypadData.File:Serialize(f, accessMatrix)
	f:WriteByte(accessMatrix[1]) -- File version

	f:WriteBool(accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] ~= false)
	if accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] then
		f:WriteULong(accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT])
	end

	for _, list in ipairs({accessMatrix[bKeypads.ACCESS_TYPE.WHITELIST], accessMatrix[bKeypads.ACCESS_TYPE.BLACKLIST]}) do
		local access_type_count_pointer = f:Tell()
		f:Skip(1)

		local access_type_count = 0
		for access_type, data in pairs(list) do
			if istable(data) then
				if not table.IsEmpty(data) then
					f:WriteByte(access_type)

					local access_count_pointer = f:Tell()
					f:Skip(2)

					local access_count = 0
					for access, access_data in pairs(data) do
						if access_type == bKeypads.ACCESS_GROUP.PLAYER then
							f:WriteByte(#access)
							f:Write(string.sub(access, 1, 255)) -- steamid64
							if access_data == true then
								f:WriteBool(true)
							else
								f:WriteBool(false)
								f:WriteByte(#access_data)
								f:Write(string.sub(access_data, 1, 255)) -- nick
							end
						elseif (
							access_type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL
						) then
							f:WriteUShort(access)
						else
							f:WriteByte(#access)
							f:Write(string.sub(access, 1, 255))
						end

						access_count = access_count + 1
					end

					local bounce_back_pointer = f:Tell()
					f:Seek(access_count_pointer)
					f:WriteUShort(access_count)
					f:Seek(bounce_back_pointer)

					access_type_count = access_type_count + 1
				end
			elseif isbool(data) and data == true then
				f:WriteByte(access_type)
				access_type_count = access_type_count + 1
			end
		end

		local bounce_back_pointer = f:Tell()
		f:Seek(access_type_count_pointer)
		f:WriteByte(access_type_count)
		f:Seek(bounce_back_pointer)
	end

	f:Close()
end

function bKeypads.KeypadData.File:Deserialize(f)
	local accessMatrix = bKeypads.KeypadData:AccessMatrix()

	accessMatrix[1] = f:ReadByte()

	accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] = f:ReadBool() and f:ReadULong() or false

	for _, list in ipairs({accessMatrix[bKeypads.ACCESS_TYPE.WHITELIST], accessMatrix[bKeypads.ACCESS_TYPE.BLACKLIST]}) do
		local access_type_count = f:ReadByte()
		for i=1,access_type_count do
			local access_type = f:ReadByte()
			if bKeypads.ACCESS_GROUP_BOOL[access_type] then
				list[access_type] = true
			else
				local access_count = f:ReadUShort()
				for i=1,access_count do
					if access_type == bKeypads.ACCESS_GROUP.PLAYER then
						local steamid64 = f:Read(f:ReadByte())
						local nick = f:ReadBool() or f:Read(f:ReadByte())
						list[access_type][steamid64] = nick
					elseif (
						access_type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL
					) then
						list[access_type][f:ReadUShort()] = true
					else
						list[access_type][f:Read(f:ReadByte())] = true
					end
				end
			end
		end
	end

	f:Close()

	bKeypads.KeypadData:MergeAccessMatrix(accessMatrix)

	return accessMatrix
end

--## NET SERIALIZATION / DESERIALIZATION ##--

bKeypads.KeypadData.Net = {}

function bKeypads.KeypadData.Net:Serialize(accessMatrix)
	net.WriteBool(accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] ~= false)
	if accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] then
		net.WriteUInt(accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT], 32)
	end

	for _, list in ipairs({accessMatrix[bKeypads.ACCESS_TYPE.WHITELIST], accessMatrix[bKeypads.ACCESS_TYPE.BLACKLIST]}) do
		for access_type, data in pairs(list) do
			if istable(data) then
				if not table.IsEmpty(data) then
					net.WriteBool(true)
					net.WriteUInt(access_type, bKeypads.ACCESS_GROUP.BITS)

					for access, access_data in pairs(data) do
						net.WriteBool(true)
						if access_type == bKeypads.ACCESS_GROUP.PLAYER then
							net.WriteString(access)
							if access_data == true then
								net.WriteBool(true)
							else
								net.WriteBool(false)
								net.WriteString(access_data)
							end
						elseif (
							access_type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL
						) then
							net.WriteUInt(access, 16)
						else
							net.WriteString(access)
						end
					end

					net.WriteBool(false)
				end
			elseif isbool(data) and data == true then
				net.WriteBool(true)
				net.WriteUInt(access_type, bKeypads.ACCESS_GROUP.BITS)
			end
		end
		net.WriteBool(false)
	end
end

function bKeypads.KeypadData.Net:Deserialize()
	local accessMatrix = bKeypads.KeypadData:AccessMatrix()

	accessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] = net.ReadBool() and net.ReadUInt(32) or false

	local entry_count = 0
	for _, list in ipairs({accessMatrix[bKeypads.ACCESS_TYPE.WHITELIST], accessMatrix[bKeypads.ACCESS_TYPE.BLACKLIST]}) do
		local i = 0
		while (net.ReadBool() and i <= bKeypads.ACCESS_GROUP.LAST and entry_count < 4096) do
			i = i + 1
			local access_type = net.ReadUInt(bKeypads.ACCESS_GROUP.BITS)
			if bKeypads.ACCESS_GROUP_BOOL[access_type] then
				list[access_type] = true
				entry_count = entry_count + 1
			elseif list[access_type] ~= nil then
				if access_type == bKeypads.ACCESS_GROUP.PLAYER then
					while (net.ReadBool() and entry_count < 4096) do
						entry_count = entry_count + 1
						list[access_type][net.ReadString()] = net.ReadBool() or net.ReadString()
					end
				elseif access_type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL then
					while (net.ReadBool() and entry_count < 4096) do
						entry_count = entry_count + 1
						list[access_type][net.ReadUInt(16)] = true
					end
				else
					while (net.ReadBool() and entry_count < 4096) do
						entry_count = entry_count + 1
						list[access_type][net.ReadString()] = true
					end
				end
			end
		end

		if entry_count >= 4096 then break end
	end

	return accessMatrix
end

--## DarkRP Memeology ##--

bKeypads:GMInitialize(function() if DarkRP then
	local function OptimizedDarkRPDataStructures()
		bKeypads.DarkRP = {}

		bKeypads.DarkRP.JobCategories = {
			Members = {},
			Teams = {}
		}

		bKeypads.DarkRP.DoorGroups = {
			Members = {},
			Teams = {}
		}

		bKeypads.DarkRP.Agendas = {
			Members = {},
			Teams = {}
		}

		bKeypads.DarkRP.DemoteGroups = {}

		if DarkRPAgendas then
			for _, agenda in pairs(DarkRPAgendas) do
				bKeypads.DarkRP.Agendas.Members[agenda.Title] = agenda

				bKeypads.DarkRP.Agendas.Teams[agenda.Title] = {}

				for _, team_index in ipairs(agenda.Listeners) do
					bKeypads.DarkRP.Agendas.Teams[agenda.Title][team_index] = true
				end

				if not agenda.Manager then continue end
				if istable(agenda.Manager) then
					for _, team_index in ipairs(agenda.Manager) do
						bKeypads.DarkRP.Agendas.Teams[agenda.Title][team_index] = true
					end
				else
					bKeypads.DarkRP.Agendas.Teams[agenda.Title][agenda.Manager] = true
				end
			end
		end

		if RPExtraTeamDoors then
			for name, doorGroup in pairs(RPExtraTeamDoors) do
				bKeypads.DarkRP.DoorGroups.Members[name] = doorGroup

				bKeypads.DarkRP.DoorGroups.Teams[name] = {}
				for _, team_index in ipairs(doorGroup) do
					bKeypads.DarkRP.DoorGroups.Teams[name][team_index] = true
				end
			end
		end

		if DarkRP.getDemoteGroups then
			for _, demoteGroup in pairs(DarkRP.getDemoteGroups()) do
				if not demoteGroup.name then continue end
				bKeypads.DarkRP.DemoteGroups[demoteGroup.name] = bKeypads.DarkRP.DemoteGroups[demoteGroup.name] or {}
				bKeypads.DarkRP.DemoteGroups[demoteGroup.name][demoteGroup.value] = true
			end
		end

		if DarkRP.getCategories then
			local categories = DarkRP.getCategories()
			if categories then
				categories = DarkRP.getCategories().jobs
				if categories then
					for _, category in ipairs(categories) do
						bKeypads.DarkRP.JobCategories.Members[category.name] = category

						bKeypads.DarkRP.JobCategories.Teams[category.name] = {}
						for _, job in ipairs(category.members) do
							bKeypads.DarkRP.JobCategories.Teams[category.name][job.team] = true
						end
					end
				end
			end
		end
	end
	OptimizedDarkRPDataStructures()
	hook.Add("bKeypads.ConfigUpdated", "bKeypads.DarkRP.ConfigUpdated", OptimizedDarkRPDataStructures)
end end)

if SERVER then
	util.AddNetworkString("bKeypads.SteamFriends")

	local SteamFriends = {}
	net.Receive("bKeypads.SteamFriends", function(_, ply)
		local ply2 = net.ReadEntity()
		if IsValid(ply2) and ply2:IsPlayer() and ply2 ~= ply then
			SteamFriends[ply] = SteamFriends[ply] or {}
			SteamFriends[ply][ply2] = net.ReadBool() or nil
		end
	end)

	function bKeypads:IsSteamFriends(ply1, ply2)
		return SteamFriends[ply1] and SteamFriends[ply2] and SteamFriends[ply1][ply2] and SteamFriends[ply2][ply1]
	end
else
	local SteamFriends = {}
	timer.Create("bKeypads.SteamFriends", 10, 0, function()
		for _, ply in ipairs(player.GetHumans()) do
			if ply == LocalPlayer() then continue end
			local status = ply:GetFriendStatus() == "friend"
			if (status == true and not SteamFriends[ply]) or (status == false and SteamFriends[ply] == true) then
				SteamFriends[ply] = status
				net.Start("bKeypads.SteamFriends")
					net.WriteEntity(ply)
					net.WriteBool(status)
				net.SendToServer()
			end
		end
	end)
end