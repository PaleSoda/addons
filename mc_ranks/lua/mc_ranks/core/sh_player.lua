-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

function MRS.GetPlayerGroup(tm)
	for k, v in pairs(MRS.Ranks) do
		if v.job[team.GetName(tm)] then
			return k
		end
	end
end

function MRS.GetPlyRank(ply, grp)
	if not MRS.Ranks[grp] then return false end

	if ply.MRSdata and ply.MRSdata.Stored and ply.MRSdata.Stored[grp] then
		return ply.MRSdata.Stored[grp].rank, ply.MRSdata.Stored[grp].time
	end

	return 1
end

function MRS.Notify(a, b, c, d)
	if SERVER then
		net.Start("MRS.Notify")
		net.WriteString(b)
		net.WriteString(c)
		net.WriteUInt(d, 2)
		net.Send(a)
	else
		MRS.DoNotify(a, b, c)
	end
end

function MRS.SmallNotify(message, ply, type)
	if SERVER then
		if DarkRP then
			DarkRP.notify(ply, type, 5, message)
		elseif ix then
			ix.util.Notify(message, ply)
		else
			ply:ChatPrint(message)
		end
	else
		if GAMEMODE.AddNotify then
			GAMEMODE:AddNotify(message, type, 5)
		elseif ix then
			ix.util.Notify(message)
		else
			ply:ChatPrint(message)
		end
	end
end

function MRS.IsAdministrator(ply)
	if ply:EntIndex() == 0 then return true end
	return MRS.Administrators[ply:GetUserGroup()]
end

function MRS.RankPermissions(ply)
	if MRS.IsAdministrator(ply) then
		return true, true
	end

	local group = MRS.GetNWdata(ply, "Group")
	local rank = MRS.GetNWdata(ply, "Rank")

	if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then return false end

	local rank_tbl = MRS.Ranks[group].ranks[rank]

	return rank_tbl.can_promote, rank_tbl.can_demote
end

function MRS.GetNWdata(ply, id)
	if not ply.MRSdata or not ply.MRSdata[id] then return false end

	return ply.MRSdata[id]
end

function MRS.GetSelfNWdata(ply, id)
	if not ply.MRSdata_self or not ply.MRSdata_self[id] then return false end

	return ply.MRSdata_self[id]
end

function MRS.DataShare(ply)
	if SERVER then
		MRS.SendDataToClient({
			index = "Ranks",
			data = table.Copy(MRS.Ranks)
		}, ply)
	else
		net.Start("MRS.DataShare")
		net.SendToServer()
	end
end

timer.Simple(5, function()
	local meta = FindMetaTable("Player")
	meta.MRSOGName = meta.MRSOGName or meta.Name

	function meta:Name()
		if MRS.Config.ChangePlayerName then
			local group = MRS.GetNWdata(self, "Group")
			local rank = MRS.GetNWdata(self, "Rank")
			if not group or not rank or not MRS.Ranks[group] then return self:MRSOGName() end
			if CLIENT and not MRS.Ranks[group].cansee and MRS.GetNWdata(LocalPlayer(), "Group") ~= group then return self:MRSOGName() end
			rank = MRS.Ranks[group].ranks[rank]
			if not rank then return self:MRSOGName() end
			return MRS.NameFormats[MRS.Config.PlayerNameFormat] and MRS.StringFormat(MRS.NameFormats[MRS.Config.PlayerNameFormat], MRS.Ranks[group].show_sn and rank.srt_name or rank.name, self:MRSOGName()) or self:MRSOGName()
		end
		return self:MRSOGName()
	end

	meta.Nick = meta.Name
	meta.GetName = meta.Name
end)

if CLIENT then
	net.Receive("MRS.GetBigData", function(l, ply)
		local bytes_number = net.ReadUInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local real_data = MRS.TableDecompress(compressed_data)

		if real_data.isplayerdata then
			local pl_d = Player(real_data.isplayerdata)
			if not IsValid(pl_d) then return end

			if not pl_d.MRSdata then
				pl_d.MRSdata = {}
				pl_d.MRSdata.Stored = {}
			end

			if not pl_d.MRSdata.Stored then
				pl_d.MRSdata.Stored = {}
			end

			if real_data.index == "none" then
				pl_d.MRSdata = real_data.data
			else
				pl_d.MRSdata.Stored[real_data.index] = real_data.data
			end

			return
		end

		MRS[real_data.index] = real_data.data

		if real_data.mod then
			for k, v in pairs(MRS[real_data.index]) do
				if v[real_data.mod] then
					v[real_data.mod] = Player(v[real_data.mod])
				end
			end
		end
	end)

	net.Receive("MRS.SetPData", function()
		local id = net.ReadString()
		local data = net.ReadString()
		local ply = net.ReadEntity()

		if tonumber(data) then data = tonumber(data) end

		if ply and IsValid(ply) and ply:IsPlayer() then
			if not ply.MRSdata then
				ply.MRSdata = {}
			end

			if data == "" then
				ply.MRSdata[id] = nil
			else
				ply.MRSdata[id] = data
			end

		else
			if not LocalPlayer().MRSdata_self then
				LocalPlayer().MRSdata_self = {}
			end

			if data == "" then
				LocalPlayer().MRSdata_self[id] = nil
			else
				LocalPlayer().MRSdata_self[id] = data
			end
		end
	end)

	net.Receive("MRS.RanksUpdate", function()
		local id = net.ReadString()
		local data = net.ReadTable()
		if not id then return end
		MRS.Ranks[id] = data

		if MRS.SetupMenu then
			MRS.SetupMenu.OnRanksUpdate(id)
		end
	end)

	net.Receive("MRS.RanksRemove", function()
		local id = net.ReadString()
		MRS.Ranks[id] = nil

		if MRS.SetupMenu then
			MRS.SetupMenu.OnRanksUpdate(id)
		end
	end)

	net.Start("MRS.GetPData")
	net.SendToServer()
	MRS.DataShare()

end