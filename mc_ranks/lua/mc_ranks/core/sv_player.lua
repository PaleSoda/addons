-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

function MRS.SendDataToClient(data, ply)
	local json_data = util.TableToJSON(data, false)
	local compressed_data = util.Compress(json_data)
	local bytes_number = string.len(compressed_data)
	net.Start("MRS.GetBigData")
	net.WriteUInt(bytes_number, 32)
	net.WriteData(compressed_data, bytes_number)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MRS.SavePlayerData(ply, data)
	data = data or ply.MRSdata.Stored
	local sid = isstring(ply) and ply or MRS.PlayerID(ply)
	sid = MRS.DB.Escape(sid)
	local json = MRS.DB.Escape(util.TableToJSON(data))

	MRS.DB.Query("DELETE FROM mrs_player WHERE id=" .. sid, function()
		MRS.DB.Query("INSERT INTO mrs_player VALUES(" .. sid .. ", " .. json .. ")")
	end)
end

function MRS.SetSelfNWdata(ply, id, data)
	if not ply.MRSdata_self then ply.MRSdata_self = {} end

	ply.MRSdata_self[id] = data

	net.Start("MRS.SetPData")
		net.WriteString(id)
		net.WriteString(data or "")
	net.Send(ply)
end

function MRS.SetNWdata(ply, id, data)
	if not ply.MRSdata then ply.MRSdata = {} end

	net.Start("MRS.SetPData")
		net.WriteString(id)
		net.WriteString(data or "")
		net.WriteEntity(ply)
	net.Broadcast()

	ply.MRSdata[id] = data
end

function MRS.SetNWStoredData(ply, id, data)
	ply.MRSdata.Stored[id] = data
	MRS.SendDataToClient({index = id, data = data, isplayerdata = ply:UserID()})
	MRS.SavePlayerData(ply)
end

function MRS.RemoveRanksStats(ply)
	for _, wep in pairs(ply:GetWeapons()) do
		if IsValid(wep) and wep.MRS_weapon then
			ply:StripWeapon(wep:GetClass())
		end
	end
	for _, stat in pairs(MRS.PlayerStats) do
		if stat.revoke then stat.revoke(ply) end
	end
end

function MRS.RanksRemove(id)
	if not id or not MRS.Ranks[id] then return end

	MRS.Ranks[id] = nil
	net.Start("MRS.RanksRemove")
		net.WriteString(id)
	net.Broadcast()
	MRS.RemoveRanksData(id)
end

function MRS.SpamBlock(ply,t)
	if ply.MRSlasCkeck and ply.MRSlasCkeck + t > CurTime() then return true end
	ply.MRSlasCkeck = CurTime()
	return false
end

function MRS.SetPlayerRank(ply, group, rid, silent)
	if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rid] then return end

	if MRS.GetNWdata(ply, "Group") == group then
		local oldr = MRS.GetNWdata(ply, "Rank")
		MRS.SetNWdata(ply, "Rank", rid)
		MRS.RemoveRanksStats(ply)
		MRS.SetupRankStats(ply, rid, group)
		if not silent then
			local promoted = rid > oldr

			MRS.Notify(ply, promoted and MSD.GetPhrase("mrs_promoted") or MSD.GetPhrase("mrs_demoted"), MRS.Ranks[group].ranks[rid].name, promoted and 1 or 2)
		end
	end

	MRS.SetNWStoredData(ply, group, {rank = rid, time = 0})
	MRS.SetSelfNWdata(ply, "progress", nil)
end

function MRS.PromotePlayer(ply, found)
	local promote = MRS.RankPermissions(ply)
	if not promote then return end
	local pg, fg = MRS.GetNWdata(ply, "Group"), MRS.GetNWdata(found, "Group")
	if pg ~= fg then return end
	local fr = MRS.GetPlyRank(found, fg)
	MRS.ChangePlayerRank(ply, found, fg, fr + 1)
end

function MRS.DemotePlayer(ply, found)
	local promote = MRS.RankPermissions(ply)
	if not promote then return end
	local pg, fg = MRS.GetNWdata(ply, "Group"), MRS.GetNWdata(found, "Group")
	if pg ~= fg then return end
	local fr = MRS.GetPlyRank(found, fg)
	MRS.ChangePlayerRank(ply, found, fg, fr - 1)
end

function MRS.ChangePlayerRank(ply, found, group, rank)
	local promote, demote = MRS.RankPermissions(ply)
	local full_access = MRS.IsAdministrator(ply)

	if not promote and not demote then return end
	if not found or not group or not rank then return end

	if ply == found and not full_access then
		MRS.SmallNotify("Can't do actions on yourself", ply, 1)
		return
	end

	local rank_id = rank
	rank = MRS.Ranks[group].ranks[rank]

	if not MRS.Ranks[group] or not rank then
		MRS.SmallNotify("Invalid rank", ply, 1)
		return
	end

	local erank_id = MRS.GetPlyRank(ply, group)
	local frank_id = MRS.GetPlyRank(found, group)

	if not erank_id or not frank_id then return end

	local erank = MRS.Ranks[group].ranks[erank_id]
	local frank = MRS.Ranks[group].ranks[frank_id]

	if not erank or not frank then return end

	if not full_access then

		if erank_id <= frank_id or erank_id <= rank_id then
			MRS.SmallNotify("No permissions", ply, 1)
			return
		end

		if not promote and rank_id >= frank_id then
			MRS.SmallNotify("Can't promote", ply, 1)
			return
		end

		if promote and rank_id >= frank_id and erank.promote_limit and erank.promote_limit < rank_id then
			MRS.SmallNotify(MSD.GetPhrase("mrs_nopower"), ply, 1)
			return
		end

		if not demote and rank_id <= frank_id then
			MRS.SmallNotify("Can't demote", ply, 1)
			return
		end

		if demote and rank_id <= frank_id and erank.demote_limit and erank.demote_limit > rank_id then
			MRS.SmallNotify(MSD.GetPhrase("mrs_nopower"), ply, 1)
			return
		end

	end

	MRS.SetPlayerRank(found, group, rank_id)

	hook.Call( "MRS.OnPromotion", nil, found, ply, group, rank_id, frank_id, erank_id, rank.name, frank.name)
end

net.Receive("MRS.RanksSubmit", function(l, ply)
	if not MRS.IsAdministrator(ply) then return end
	if MRS.SpamBlock(ply,1) then return end

	local bytes_number = net.ReadUInt(32)
	local compressed_data = net.ReadData(bytes_number)
	local json_data = util.Decompress(compressed_data)
	local ranks = util.JSONToTable(json_data)

	if not ranks then return end
	local id = ranks.id

	if not MRS.CheckID(id) then
		MRS.SmallNotify(MSD.GetPhrase("inv_quest") .. " ID", ply, 1)
		return
	end

	if ranks.oldid and ranks.oldid ~= id and MRS.Ranks[ranks.oldid] then
		MRS.RanksRemove(ranks.oldid)
	end

	ranks.id = nil
	ranks.oldid = nil
	MRS.Ranks[id] = ranks
	net.Start("MRS.RanksUpdate")
		net.WriteString(id)
		net.WriteTable(ranks)
	net.Broadcast()
	MRS.SaveRanksData(id, ranks)
end)

net.Receive("MRS.RanksRemove", function(l, ply)
	if not MRS.IsAdministrator(ply) then return end
	if MRS.SpamBlock(ply,1) then return end
	local id = net.ReadString()
	MRS.RanksRemove(id)
end)

net.Receive("MRS.GetPlayersRanks", function(l, ply)
	if MRS.SpamBlock(ply,1) then return end
	if not MRS.IsAdministrator(ply) then return end
	local sid = net.ReadString()
	local tbl = MRS.DB.GetPlayerData(sid)

	if not tbl or table.IsEmpty(tbl) then return end

	tbl.initdata = nil

	net.Start("MRS.GetPlayersRanks")
	net.WriteString(sid)
	net.WriteUInt(table.Count(tbl),32)

	for k,v in pairs(tbl) do
		net.WriteString(k)
		net.WriteUInt(tonumber(v.rank), 32)
		net.WriteUInt(tonumber(v.time), 32)
	end

	net.Send(ply)
end)

net.Receive("MRS.SavePlayerRankList", function(l, ply)

	if MRS.SpamBlock(ply,1) then return end
	if not MRS.IsAdministrator(ply) then return end
	local sid = net.ReadString()
	local group = net.ReadString()
	local rank = net.ReadUInt(32)

	if not sid or not group or not rank then return end
	if not MRS.Ranks[group] then return end

	local data = MRS.DB.GetPlayerData(sid) or {}

	data[group] = {rank = rank, time = 0}

	MRS.SavePlayerData(sid, data)
end)

net.Receive("MRS.GetPData", function(l, ply)
	if ply.MRSgotData then return end

	for _, pl in ipairs(player.GetAll()) do

		if not pl.MRSdata or not pl.MRSdata.Rank or not pl.MRSdata.Group then continue end
		net.Start("MRS.SetPData")
			net.WriteString("Rank")
			net.WriteString(pl.MRSdata.Rank)
			net.WriteEntity(pl)
		net.Send(ply)

		net.Start("MRS.SetPData")
			net.WriteString("Group")
			net.WriteString(pl.MRSdata.Group)
			net.WriteEntity(pl)
		net.Send(ply)

	end

	ply.MRSgotData = true
end)

net.Receive("MRS.DataShare", function(l, ply)
	MRS.DataShare(ply)
end)

net.Receive("MRS.RequestStoredData", function(l, ply)
	if not MRS.IsAdministrator(ply) then return end
	if MRS.SpamBlock(ply,0.5) then return end

	local uid = net.ReadUInt(32)
	local pl = Player(uid)

	if not IsValid(pl) then return end

	if table.IsEmpty(pl.MRSdata.Stored) then return end

	pl.MRSdata.Stored.initdata = nil

	net.Start("MRS.RequestStoredData")
	net.WriteEntity(pl)
	net.WriteUInt(table.Count(pl.MRSdata.Stored),32)

	for k,v in pairs(pl.MRSdata.Stored) do
		net.WriteString(k)
		net.WriteUInt(tonumber(v.rank), 32)
		net.WriteUInt(tonumber(v.time), 32)
	end

	net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "MRS.PlayerInitialSpawn", function(ply)
	if not ply.MRSdata then ply.MRSdata = {} end
	if not ply.MRSdata.Stored then ply.MRSdata.Stored = {initdata = 0} end
	local sid = MRS.DB.Escape(MRS.PlayerID(ply))
	MRS.DB.Query("SELECT * FROM mrs_player WHERE id=" .. sid, function(result)
		if result ~= nil and #result > 0 then

			local tbl = util.JSONToTable(result[1].value)

			if tbl and istable(tbl) then
				print("[MRS] Player's stored data loaded")
				ply.MRSdata.Stored = tbl
			end
		else
			MRS.DB.Query("INSERT INTO mrs_player VALUES(" .. sid .. ", '[]')")
			print("[MRS] No player stored data, creating one")
		end
	end)
end)

hook.Add("PlayerLoadedCharacter", "MRS.CharacterSelected", function(ply, character)
	local data = MRS.DB.GetPlayerData(ply:SteamID() .. character.id)
	ply.MRSdata.Stored = data or  {}
	if not data then
		MRS.DB.Query("INSERT INTO mrs_player VALUES(" .. MRS.PlayerID(ply) .. ", '[]')")
		print("[MRS] No player character stored data, creating one")
	end
	MRS.SetupRankData(ply, ply:Team())
end)

hook.Add("VoidChar.CharacterSelected", "MRS.CharacterSelected", function(ply, character)
	local data = MRS.DB.GetPlayerData(MRS.PlayerID(ply))
	ply.MRSdata.Stored = data or  {}
	if not data then
		MRS.DB.Query("INSERT INTO mrs_player VALUES(" .. MRS.PlayerID(ply) .. ", '[]')")
		print("[MRS] No player character stored data, creating one")
	end
	MRS.SetupRankData(ply, ply:Team())
end)