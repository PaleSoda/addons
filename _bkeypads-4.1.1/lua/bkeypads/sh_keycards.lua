bKeypads.Keycards = bKeypads.Keycards or {}

local function SanitizeConfigData()
	bKeypads.Keycards.Levels = bKeypads.Config.Keycards.Levels
	bKeypads.Keycards.Levels[1] = bKeypads.Keycards.Levels[1] or {
		Name  = "Level 1",
		Color = Color(255,0,0)
	}

	bKeypads.Keycards.SpawnWithoutKeycard = {}
	for _, v in pairs(bKeypads.Config.Keycards.SpawnWithoutKeycard) do
		bKeypads.Keycards.SpawnWithoutKeycard[v] = true
	end
end
hook.Add("bKeypads.ConfigUpdated", "bKeypads.UpdateKeycardLevels", SanitizeConfigData)
SanitizeConfigData()

hook.Add("PlayerLoadout", "bKeypads.SpawnWithKeycard", function(ply)
	if not bKeypads.Config.Keycards.SpawnWithKeycard or bKeypads.Keycards.SpawnWithoutKeycard[ply:Team()] then return end
	ply:Give("bkeycard")
end)

if SERVER then
	hook.Add("PlayerDeath", "bKeypads.DropKeycardOnDeath", function(ply)
		if not bKeypads.Config.Keycards.DropKeycardOnDeath then return end

		local bkeycard = ply:GetWeapon("bkeycard")
		if IsValid(bkeycard) and not bkeycard:GetWasPickedUp() then
			bKeypads.Keycards.Inventory:DropKeycard(ply, 0, true)
		end

		if bKeypads.Keycards.Inventory.Cards[ply] then
			for id in pairs(bKeypads.Keycards.Inventory.Cards[ply]) do
				bKeypads.Keycards.Inventory:DropKeycard(ply, id, true)
			end
		end
	end)
end

local LevelRegistry
do
	local function UpdateLevelRegistry()
		if not bKeypads.Keycards then return end

		LevelRegistry = {
			Teams = {},
			Usergroups = {},
			customChecks = {}
		}

		for level, metadata in pairs(bKeypads.Keycards.Levels) do
			if metadata.Teams then
				for i, team_index in pairs(metadata.Teams) do
					if tonumber(team_index) then
						LevelRegistry.Teams[team_index] = LevelRegistry.Teams[team_index] or {}
						table.insert(LevelRegistry.Teams[team_index], level)
					end
				end
			end
			if metadata.Usergroups then
				for _, usergroup in ipairs(metadata.Usergroups) do
					LevelRegistry.Usergroups[usergroup] = LevelRegistry.Usergroups[usergroup] or {}
					table.insert(LevelRegistry.Usergroups[usergroup], level)
				end
			end
			if metadata.customCheck then
				LevelRegistry.customChecks[metadata.customCheck] = LevelRegistry.customChecks[metadata.customCheck] or {}
				table.insert(LevelRegistry.customChecks[metadata.customCheck], level)
			end
		end

		if DarkRP and RPExtraTeams then
			for _, job in ipairs(RPExtraTeams) do
				local level = tonumber(job.KeycardLevel)
				if level then
					local team_index = job.index
					LevelRegistry.Teams[team_index] = LevelRegistry.Teams[team_index] or {}
					table.insert(LevelRegistry.Teams[team_index], level)
				end
			end
		end

		-- Sorts the ordered table
		for k, v in pairs(LevelRegistry) do
			for _k, _v in pairs(v) do
				table.sort(_v)
			end
		end
	end
	hook.Add("bKeypads.ConfigUpdated", "bKeypads.UpdateLevelRegistry", UpdateLevelRegistry)
	UpdateLevelRegistry()

	concommand.Add("bkeypads_debug_keycards", function()
		local teamLevels = {}

		MsgC("\n")
		bKeypads:print("============= TEAMS ===============")
		for team_index, levels in pairs(LevelRegistry.Teams) do
			local keycards = ""

			for _, level in ipairs(levels) do
				teamLevels[level] = teamLevels[level] or {}
				teamLevels[level][team_index] = true
				keycards = keycards .. ((bKeypads.Keycards.Levels[level] or {Name="ERROR " .. level}).Name or "Level " .. level) .. ", "
			end

			bKeypads:print("[" .. team.GetName(team_index) .. "] = (Found: " .. #levels .. ") " .. keycards:sub(1, -3), bKeypads.PRINT_TYPE_SPECIAL)
		end

		MsgC("\n")
		bKeypads:print("============ KEYCARDS =============")
		for level, teams in pairs(teamLevels) do
			local teamsStr = ""
			local teamsCount = 0

			for team_index in pairs(teams) do
				teamsStr = teamsStr .. team.GetName(team_index) .. ", "
				teamsCount = teamsCount + 1
			end

			bKeypads:print("[" .. ((bKeypads.Keycards.Levels[level] or {Name="ERROR " .. level}).Name or "Level " .. level) .. "] = (Found: " .. teamsCount .. ") " .. teamsStr:sub(1, -3), bKeypads.PRINT_TYPE_SPECIAL)
		end
		MsgC("\n")
	end)
end

local function insert_levels(keycardData, insert)
	if #insert == 1 then
		if not keycardData.LevelsDict[insert[1]] then
			table.insert(keycardData.Levels, insert[1])
			keycardData.LevelsDict[insert[1]] = true
		end
		return insert[1]
	else
		local max_level = 1
		for _, level in ipairs(insert) do
			if not keycardData.LevelsDict[level] then
				table.insert(keycardData.Levels, level)
				keycardData.LevelsDict[level] = true
			end
			max_level = math.max(max_level, level)
		end
		return max_level
	end
end

function bKeypads.Keycards:GetKeycardData(ply)
	local keycardData = {
		Levels = {},
		LevelsDict = {},
		PrimaryLevel = 1,
		SteamID = ply:SteamID(),
		PlayerModel = ply:GetModel(),
		Team = ply:Team(),
		PlayerBind = ply:SteamID()
	}

	for func, levels in pairs(LevelRegistry.customChecks) do
		if func(ply) == true then
			keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, insert_levels(keycardData, levels))
		end
	end

	if OpenPermissions and OpenPermissions.GetUserGroups then
		if not table.IsEmpty(LevelRegistry.Usergroups) then
			local usergroups = OpenPermissions:GetUserGroups(ply)
			for usergroup in pairs(usergroups) do
				local usergroupLevels = LevelRegistry.Usergroups[usergroup]
				if usergroupLevels then
					keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, insert_levels(keycardData, usergroupLevels))
				end
			end
		end
	else
		local usergroupLevels = LevelRegistry.Usergroups[ply:GetUserGroup()]
		if usergroupLevels then
			keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, insert_levels(keycardData, usergroupLevels))
		end
	end

	local teamLevels = LevelRegistry.Teams[ply:Team()]
	if teamLevels then
		keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, insert_levels(keycardData, teamLevels))
	end

	local extraLevels = hook.Run("bKeypads.GetLevels", ply, {})
	if extraLevels then
		for level in pairs(extraLevels) do
			if not keycardData.LevelsDict[level] then
				table.insert(keycardData.Levels, level)
				keycardData.LevelsDict[level] = true
			end
			keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, level)
		end
	end

	table.sort(keycardData.Levels)

	return keycardData
end

bKeypads_Keycards_ID = bKeypads_Keycards_ID or 0
bKeypads_Keycards_Registry = bKeypads_Keycards_Registry or {}
function bKeypads.Keycards:GetByID(ID)
	return bKeypads_Keycards_Registry[ID]
end
if SERVER then
	function bKeypads.Keycards:AssignID(droppedKeycard)
		if droppedKeycard:GetIsChildKeycard() then return end

		local id
		if droppedKeycard:GetID() ~= 0 then
			id = droppedKeycard:GetID()
		else
			bKeypads_Keycards_ID = bKeypads_Keycards_ID + 1
			id = bKeypads_Keycards_ID
		end

		droppedKeycard:SetID(id)
		--print("Assigned ID", id, droppedKeycard)
	end
	for _, droppedKeycard in ipairs(ents.GetAll()) do
		if droppedKeycard:GetClass() ~= "bkeycard_pickup" then continue end
		bKeypads.Keycards:AssignID(droppedKeycard)
	end
end

if SERVER then
	function bKeypads.Keycards:SpawnKeycard(keycard, ply)
		if ply:Alive() then ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP) end

		local ent = ents.Create("bkeycard_pickup")
		ent.m_DroppedBy = ply:SteamID()
		ent:SetQuantity(1)
		ent:SetTouchToPickup(false)
		ent:SetPhysicsEnabled(true)

		if keycard == 0 then
			assert(IsValid(ply), "Tried to drop the personal keycard of an invalid player!")

			local keycardData = bKeypads.Keycards:GetKeycardData(ply)
			ent:SetSteamID(ply:SteamID())
			ent:SetPlayerModel(ply:GetModel())
			ent:SetTeam(ply:Team())
			ent:SetLevelsStr(table.concat(keycardData.Levels, ","))
			ent:SetPlayerKeycardDataBind(ply:SteamID())
		else
			local keycardData = bKeypads.Keycards:GetByID(keycard)
			ent:SetIsChildKeycard(true)
			ent:SetID(keycard)
			ent:SetLevelsStr(table.concat(keycardData.Levels, ","))
			ent:SetSteamID(keycardData.SteamID or "")
			ent:SetPlayerModel(keycardData.PlayerModel or "models/player/kleiner.mdl")
			ent:SetTeam(keycardData.Team or 0)
		end

		-- shamelessly stolen from DarkRP
		-- https://github.com/FPtje/DarkRP/blob/cefc171d3236f979bd8d0b721ee4d8f9d6b6eda5/gamemode/modules/base/sv_util.lua#L125-L139
		local tr = util.TraceLine({
			start = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 50,
			filter = {ply, ent}
		})

		local ang = ply:EyeAngles()
		ang.pitch = 0
		ang.yaw = ang.yaw + 180
		ang.roll = 0
		ent:SetAngles(ang)

		local vFlushPoint = tr.HitPos - (tr.HitNormal * 512)
		vFlushPoint = ent:NearestPoint(vFlushPoint)
		vFlushPoint = ent:GetPos() - vFlushPoint
		vFlushPoint = tr.HitPos + vFlushPoint
		ent:SetPos(vFlushPoint)

		ent:Spawn()

		--print("Spawned", ent, keycard)

		return ent:GetID(), ent
	end
end

if SERVER then
	util.AddNetworkString("bKeypads.Keycards.Persistence.Save")

	function bKeypads.Keycards:DeletePersistent(ent)
		if bKeypads.Keycards.ShuttingDown or bKeypads.Keycards.BlockPersistenceSave then return end
		if IsValid(ent) and bKeypads.Keycards.Persistent and ent.bKeypads_PersistID and bKeypads.Keycards.Persistent.Keycards[ent.bKeypads_PersistID] then
			bKeypads.Keycards.Persistent.Keycards[ent.bKeypads_PersistID] = nil
			file.Write("bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", util.TableToJSON(bKeypads.Keycards.Persistent))
		end
	end

	function bKeypads.Keycards:SavePersistent(ent, block_write_file)
		if bKeypads.Keycards.ShuttingDown or bKeypads.Keycards.BlockPersistenceSave then return end

		if not bKeypads.Keycards.Persistent then
			bKeypads:print("Refusing to write to the dropped keycards persistence file because it is corrupted!", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")

			bKeypads:print("If you want to use persistence again, you'll have to delete the persistence file.", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")
			bKeypads:print("The persistence file can be found in:", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")
			bKeypads:print("garrysmod/data/bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", bKeypads.PRINT_TYPE_SPECIAL, "PERSISTENCE")

			return
		end

		if not ent:GetInfinite() and ent:GetQuantity() == 0 then return end

		if not ent.bKeypads_PersistID then
			bKeypads.Keycards.Persistent.ID = bKeypads.Keycards.Persistent.ID + 1
			ent.bKeypads_PersistID = bKeypads.Keycards.Persistent.ID
		end

		ent:SetPersist(true)

		local prevSaveData = bKeypads.Keycards.Persistent.Keycards[ent.bKeypads_PersistID]
		local saveData = {
			Infinite = ent:GetInfinite() or nil,
			Quantity = not ent:GetInfinite() and (prevSaveData ~= nil and prevSaveData.Quantity or ent:GetQuantity()) or nil,
			PlayerModel = ent:GetPlayerModel(),
			HideToHolders = ent:GetHideToHolders() or nil,
			Levels = ent:GetLevelsStr(),
			TouchToPickup = ent:GetTouchToPickup() or nil,
			Pos = not ent:GetPhysicsEnabled() and (prevSaveData ~= nil and prevSaveData.Pos) or ent:GetPos(),
			Angles = not ent:GetPhysicsEnabled() and (prevSaveData ~= nil and prevSaveData.Angles) or ent:GetAngles()
		}

		if prevSaveData then
			saveData.PhysicsEnabled = prevSaveData.Physics
		else
			saveData.PhysicsEnabled = ent:GetPhysicsEnabled()
		end

		bKeypads.Keycards.Persistent.Keycards[ent.bKeypads_PersistID] = saveData

		if not block_write_file and not table.IsEmpty(bKeypads.Keycards.Persistent.Keycards) then
			file.CreateDir("bkeypads/persistence/" .. game.GetMap())
			file.Write("bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", util.TableToJSON(bKeypads.Keycards.Persistent))
		end
	end

	function bKeypads.Keycards:SaveAllPersistent()
		if bKeypads.Keycards.ShuttingDown or bKeypads.Keycards.BlockPersistenceSave then return end

		for _, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "bkeycard_pickup" and v.bKeypads_PersistID then
				bKeypads.Keycards:SavePersistent(v, true)
			end
		end

		if bKeypads.Keycards.Persistent.Keycards and not table.IsEmpty(bKeypads.Keycards.Persistent.Keycards) then
			file.CreateDir("bkeypads/persistence/" .. game.GetMap())
			file.Write("bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", util.TableToJSON(bKeypads.Keycards.Persistent))
		end
	end

	function bKeypads.Keycards:SpawnPersistent(saveData)
		bKeypads.Keycards.Persistent = saveData

		local spawned = 0
		for i, keycard in pairs(saveData.Keycards) do
			spawned = spawned + 1

			local ent = ents.Create("bkeycard_pickup")
			ent.bKeypads_PersistID = i
			ent:SetPersist(true)
			ent:SetInfinite(keycard.Infinite or false)
			if not keycard.Infinite then
				ent:SetQuantity(keycard.Quantity)
			end
			ent:SetLevelsStr(keycard.Levels)
			ent:SetPlayerModel(keycard.PlayerModel or "models/player/kleiner.mdl")
			ent:SetTouchToPickup(keycard.TouchToPickup or false)
			ent:SetPhysicsEnabled(keycard.PhysicsEnabled or false)
			ent:SetHideToHolders(keycard.HideToHolders or false)
			ent:SetPos(keycard.Pos)
			ent:SetAngles(keycard.Angles)
			ent:Spawn()
		end

		bKeypads:print("Spawned " .. spawned .. " persistent dropped keycard(s)", bKeypads.PRINT_TYPE_SPECIAL, "PERSISTENCE")
	end

	function bKeypads.Keycards:LoadPersistent()
		bKeypads.Keycards.BlockPersistenceSave = true

		bKeypads.Keycards.Persistent = { ID = 0, Keycards = {} }

		for _, v in ipairs(ents.GetAll()) do
			if v:GetClass() ~= "bkeycard_pickup" then continue end
			v.bKeypads_PersistID = nil
			v:SetPersist(false)
			v:Remove()
		end

		if not file.Exists("bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", "DATA") then
			bKeypads.Keycards.BlockPersistenceSave = nil
			return
		end

		local droppedKeycards = file.Read("bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", "DATA")
		if droppedKeycards then
			droppedKeycards = util.JSONToTable(droppedKeycards)
			if droppedKeycards then
				local succ = xpcall(bKeypads.Keycards.SpawnPersistent, function(err)
					ErrorNoHalt("\n" .. err .. "\n")
					debug.Trace()
				end, bKeypads.Keycards, droppedKeycards)

				if succ then
					bKeypads.Keycards.BlockPersistenceSave = nil
					return
				end
			end
		end

		bKeypads:print("The dropped keycards persistence file is corrupted!", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")
		bKeypads:print("Please open a support ticket and include the persistence file and the error(s) below with the ticket.\n", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")

		bKeypads:print("If you want to use persistence again, you'll have to delete the persistence file.", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")
		bKeypads:print("The persistence file can be found in:", bKeypads.PRINT_TYPE_BAD, "PERSISTENCE")
		bKeypads:print("garrysmod/data/bkeypads/persistence/" .. game.GetMap() .. "/dropped_keycards.json", bKeypads.PRINT_TYPE_SPECIAL, "PERSISTENCE")

		MsgC("\n")

		bKeypads.Keycards.Persistent = nil
		bKeypads.Keycards.BlockPersistenceSave = nil
	end

	bKeypads:InitPostEntity(function()
		timer.Simple(1, function()
			bKeypads.Keycards:LoadPersistent()
		end)
	end)

	hook.Add("PreCleanupMap", "bKeypads.Keycards.Persistence.PreCleanupMap", function()
		bKeypads.Keycards:SaveAllPersistent()
		bKeypads.Keycards.BlockPersistenceSave = true
	end)
	hook.Add("PostCleanupMap", "bKeypads.Keycards.Persistence.PostCleanupMap", function()
		bKeypads.Keycards.BlockPersistenceSave = nil
		bKeypads.Keycards:LoadPersistent()
	end)
	hook.Add("ShutDown", "bKeypads.Keycards.Persistence.Save", function()
		bKeypads.Keycards:SaveAllPersistent()
		bKeypads.Keycards.ShuttingDown = true
	end)

	hook.Add("PhysgunDrop", "bKeypads.Keycards.Persistence.Save", function(ply, ent)
		if not bKeypads.Permissions:Check(ply, "persistence/manage_persistent_keypads") then return end
		if ent:GetClass() == "bkeycard_pickup" and ent.bKeypads_PersistID then
			bKeypads.Keycards:SavePersistent(ent)

			net.Start("bKeypads.Keycards.Persistence.Save")
			net.Send(ply)
		end
	end)
else
	net.Receive("bKeypads.Keycards.Persistence.Save", function()
		notification.AddLegacy(bKeypads.L"PersistentKeycardSave", NOTIFY_GENERIC, 3)
		surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
	end)
end