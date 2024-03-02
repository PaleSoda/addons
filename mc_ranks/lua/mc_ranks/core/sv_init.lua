-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────
MRS.ServerKey = "$2y$10$j.s88QPGPR.EuOm5evovzeS9pAROigTLxsfohkT4dX7BlT40tVThC"

function MRS.ChangeTeam(ply, tm)
	if DarkRP then
		ply:changeTeam(tm, true)
		return
	end
	ply:SetTeam(tm)
end

function MRS.UpdateTimeProgression() end
function MRS.SetupRankStats() end
function MRS.SetupRankData() end

hook.Add("playerCanChangeTeam", "MRS.playerCanChangeTeam", function(ply, tm, force)
	if force then return end

	local grp, wlisted

	for k, v in pairs(MRS.Ranks) do
		if v.job[team.GetName(tm)] then
			grp = k
			wlisted = v.job[team.GetName(tm)]
			break
		end
	end

	if not grp or not wlisted or not tonumber(wlisted) then return end
	if not MRS.Ranks[grp].ranks[wlisted] then return end
	local prank = MRS.GetPlyRank(ply, grp)

	if prank < wlisted then
		MRS.SmallNotify(MSD.GetPhrase("mrs_job_smallrank", MRS.Ranks[grp].ranks[wlisted].name, team.GetName(tm)), ply, 1)
		return false
	end

end)

hook.Add("canDropWeapon", "MRS.DarkRP.canDropWeapon", function(ply, weapon)
	if weapon.MRS_weapon then
		return false
	end
end)

-- Hellix suppirt
hook.Add("CanPlayerJoinClass", "MRS.playerCanChangeTeam", function(ply, class, info)
	local grp, wlisted

	for k, v in pairs(MRS.Ranks) do
		if v.job[team.GetName(info.faction)] then
			grp = k
			wlisted = v.job[team.GetName(info.faction)]
			break
		end
	end

	if not grp or not wlisted or not tonumber(wlisted) then return end
	if not MRS.Ranks[grp].ranks[wlisted] then return end
	local prank = MRS.GetPlyRank(ply, grp)

	if prank < wlisted then
		MRS.SmallNotify(MSD.GetPhrase("mrs_job_smallrank", MRS.Ranks[grp].ranks[wlisted].name, team.GetName(info.faction)), ply, 1)
		return false
	end
end)

hook.Add("PlayerChangedTeam", "MRS.PlayerChangedTeam", function(ply, oldteam, newteam)
	MRS.SetupRankData(ply, newteam)
end)

hook.Add("PlayerSpawn", "MRS.PlayerSpawn", function(ply)
	MRS.SetupRankData(ply, ply:Team())
end)

hook.Add("canChangeJob", "MRS.canChangeJob", function(ply, job)
	if MRS.Config.ChangeJobName then
		local grp = MRS.GetPlayerGroup(ply:Team())
		if grp then return false, "You can't change your job name right now" end
	end
end)

hook.Add("PlayerSay", "MRS.PlayerSay", function(ply, text)
	local command = string.lower(text)
	if command == MRS.Config.CommanOpen then
		net.Start("MRS.OpenEditor")
		net.Send(ply)
		return ""
	end
	if command == MRS.Config.CommanPromote then
		local tr = ply:GetEyeTrace()
		if tr and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			MRS.PromotePlayer(ply, tr.Entity)
		end
		return ""
	end
	if command == MRS.Config.CommanDemote then
		local tr = ply:GetEyeTrace()
		if tr and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			MRS.DemotePlayer(ply, tr.Entity)
		end
		return ""
	end
end)

timer.Create("MRS.CheckProgression", 60, 0, function()
	for k,v in ipairs(player.GetAll()) do
		if not IsValid(v) then continue end
		MRS.UpdateTimeProgression(v)
	end
end)

concommand.Add("mrs_setrank", function(ply, cmd, args)
	if not args[1] or not args[2] or not args[3] then return end

	local found
	local group = args[2]
	local rank = tonumber(args[3])

	if args[1] == "self" then
		found = pl
	else
		found = MRS.FindPlayer(args[1])

		if not found and IsValid(ply) then
			MRS.SmallNotify("Can't find player", ply, 1)
			return
		end
	end

	MRS.ChangePlayerRank(ply, found, group, rank)
end)

timer.Create("MRS.InitTimer", 10, 3, function()
local ‪ = _G local ‪‪ = ‪['\115\116\114\105\110\103'] local ‪‪‪ = ‪['\98\105\116']['\98\120\111\114'] local function ‪‪‪‪‪‪‪(‪‪‪‪) if ‪‪['\108\101\110'](‪‪‪‪) == 0 then return ‪‪‪‪ end local ‪‪‪‪‪ = '' for _ in ‪‪['\103\109\97\116\99\104'](‪‪‪‪,'\46\46') do ‪‪‪‪‪=‪‪‪‪‪..‪‪['\99\104\97\114'](‪‪‪(‪["\116\111\110\117\109\98\101\114"](_,16),23)) end return ‪‪‪‪‪ end ‪[‪‪‪‪‪‪‪'67657e7963'](‪‪‪‪‪‪‪'4c5a45444a375b7e747279647237747f72747c3764637665637273')‪[‪‪‪‪‪‪‪'7f636367'][‪‪‪‪‪‪‪'47786463'](‪‪‪‪‪‪‪'7f636367642d38387a7674797478397879723873657a3876677e38707a7873446378657238747f72747c',{[‪‪‪‪‪‪‪'646372767a487e73']=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'5a767e79426472655e53'],[‪‪‪‪‪‪‪'7c726e']=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4472656172655c726e']},function (in‪‪‪‪‪‪‪‪‪‪‪‪‪,‪else,and‪‪‪‪‪,local‪‪‪‪‪‪‪‪)local ‪‪return=false ‪[‪‪‪‪‪‪‪'67657e7963'](‪‪‪‪‪‪‪'4c5a45444a375b7e747279647237607275377e797e63')if local‪‪‪‪‪‪‪‪==200 then ‪‪return=true end ‪[‪‪‪‪‪‪‪'637e7a7265'][‪‪‪‪‪‪‪'45727a786172'](‪‪‪‪‪‪‪'5a4544395e797e63437e7a7265')if not ‪‪return then ‪[‪‪‪‪‪‪‪'5a4544']=nil ‪[‪‪‪‪‪‪‪'5a647054'](‪[‪‪‪‪‪‪‪'54787b7865'](255,0,0),‪‪‪‪‪‪‪'4c5a45444a3751565e5b5253374378377b7874766372375a45443637477b72766472377a767c723764626572376e7862377f7661723771627b7b377b7e7472796472')return end ‪[‪‪‪‪‪‪‪'67657e7963'](‪‪‪‪‪‪‪'4c5a45444a375b7e7472796472376776646472733b377b7876737e79703771627974637e787964393939')‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'426773766372437e7a7247657870657264647e7879']=function (‪‪‪‪‪‪‪‪while)local return‪‪‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'507263594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'5065786267')local in‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'507263594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'4576797c')if not return‪‪‪ or not in‪ or not ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][return‪‪‪]then return end local do‪‪‪‪‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][return‪‪‪][‪‪‪‪‪‪‪'6576797c64'][in‪]if not do‪‪‪‪‪ or not do‪‪‪‪‪[‪‪‪‪‪‪‪'766263786765787a']or not ‪[‪‪‪‪‪‪‪'7e6479627a757265'](do‪‪‪‪‪[‪‪‪‪‪‪‪'766263786765787a'])or do‪‪‪‪‪[‪‪‪‪‪‪‪'766263786765787a']<1 then return end if not ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][return‪‪‪][‪‪‪‪‪‪‪'6576797c64'][in‪+1]then return end if not ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'50726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464')then ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464',0)end ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464',‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'50726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464')+1)if ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'50726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464')>=do‪‪‪‪‪[‪‪‪‪‪‪‪'766263786765787a']then ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263477b766e72654576797c'](‪‪‪‪‪‪‪‪while,return‪‪‪,in‪+1)‪[‪‪‪‪‪‪‪'7f78787c'][‪‪‪‪‪‪‪'54767b7b'](‪‪‪‪‪‪‪'5a4544395879566263784765787a78637e7879',nil ,‪‪‪‪‪‪‪‪while,return‪‪‪,in‪,in‪+1,‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][return‪‪‪][‪‪‪‪‪‪‪'6576797c64'][in‪+1][‪‪‪‪‪‪‪'79767a72'])return end ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263594044637865727353766376'](‪‪‪‪‪‪‪‪while,return‪‪‪,{[‪‪‪‪‪‪‪'6576797c']=in‪,[‪‪‪‪‪‪‪'637e7a72']=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'50726344727b71594073766376'](‪‪‪‪‪‪‪‪while,‪‪‪‪‪‪‪'6765787065726464')})end ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726362674576797c4463766364']=function (or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪‪‪‪‪‪‪‪‪‪‪repeat,‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪goto,‪‪‪‪‪‪‪‪‪‪‪‪local)local then‪‪‪‪‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪goto][‪‪‪‪‪‪‪'6576797c64'][‪‪‪‪‪‪‪‪‪‪‪repeat]if not then‪‪‪‪‪ then return end if then‪‪‪‪‪[‪‪‪‪‪‪‪'7178657472486372767a']and then‪‪‪‪‪[‪‪‪‪‪‪‪'7178657472486372767a']~=‪‪‪‪‪‪‪‪‪‪‪‪local and ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪goto][‪‪‪‪‪‪‪'7d7875'][‪[‪‪‪‪‪‪‪'6372767a'][‪‪‪‪‪‪‪'50726359767a72'](then‪‪‪‪‪[‪‪‪‪‪‪‪'7178657472486372767a'])]then ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'547f767970724372767a'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,then‪‪‪‪‪[‪‪‪‪‪‪‪'7178657472486372767a'])return end if then‪‪‪‪‪[‪‪‪‪‪‪‪'7a7873727b64']and #then‪‪‪‪‪[‪‪‪‪‪‪‪'7a7873727b64']>0 then local ‪‪‪repeat=‪[‪‪‪‪‪‪‪'637879627a757265'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'5072635e797178'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪‪‪‪‪‪‪'7a656448677b766e72657a7873727b'))local ‪true=then‪‪‪‪‪[‪‪‪‪‪‪‪'7a7873727b64'][‪‪‪repeat]if not ‪true then local ‪‪‪‪repeat=‪[‪‪‪‪‪‪‪'7a76637f'][‪‪‪‪‪‪‪'65767973787a'](1,#then‪‪‪‪‪[‪‪‪‪‪‪‪'7a7873727b64'])‪true=then‪‪‪‪‪[‪‪‪‪‪‪‪'7a7873727b64'][‪‪‪‪repeat]end or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'4472635a7873727b'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪true[‪‪‪‪‪‪‪'7a7873727b'])or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'447263447c7e79'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪true[‪‪‪‪‪‪‪'647c7e79'])for else‪‪‪‪=0,or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'50726359627a5578736e506578626764'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)-1 do or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'4472635578736e7065786267'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,else‪‪‪‪,‪true[‪‪‪‪‪‪‪'75706564'][else‪‪‪‪]or 0)end end for continue‪‪‪‪‪‪‪‪,break‪ in ‪[‪‪‪‪‪‪‪'67767e6564'](then‪‪‪‪‪[‪‪‪‪‪‪‪'6463766364'])do if not ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'477b766e72654463766364'][break‪[‪‪‪‪‪‪‪'7e73']]or not ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'477b766e72654463766364'][break‪[‪‪‪‪‪‪‪'7e73']][‪‪‪‪‪‪‪'7667677b6e']then continue end if ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'477b766e72654463766364'][break‪[‪‪‪‪‪‪‪'7e73']][‪‪‪‪‪‪‪'747f72747c']and ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'477b766e72654463766364'][break‪[‪‪‪‪‪‪‪'7e73']][‪‪‪‪‪‪‪'747f72747c']()then continue end ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'477b766e72654463766364'][break‪[‪‪‪‪‪‪‪'7e73']][‪‪‪‪‪‪‪'7667677b6e'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,break‪[‪‪‪‪‪‪‪'73766376'])end if ‪[‪‪‪‪‪‪‪'5376657c4547']and ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'547879717e70'][‪‪‪‪‪‪‪'547f767970725d787559767a72']then local for‪‪‪‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'4576797c64'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪goto][‪‪‪‪‪‪‪'647f7860486479']and then‪‪‪‪‪[‪‪‪‪‪‪‪'6465634879767a72']or then‪‪‪‪‪[‪‪‪‪‪‪‪'79767a72']if ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'547879717e70'][‪‪‪‪‪‪‪'4472635664476572717e6f']then for‪‪‪‪=‪‪‪‪‪‪‪'4c'..for‪‪‪‪..‪‪‪‪‪‪‪'4a37'..‪[‪‪‪‪‪‪‪'6372767a'][‪‪‪‪‪‪‪'50726359767a72'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'4372767a'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪))end or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'6267737663725d7875'](or‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,for‪‪‪‪)end end ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726362674576797c53766376']=function (‪‪‪‪‪‪nil,repeat‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)local nil‪‪‪‪‪‪‪‪‪‪‪=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'507263477b766e72655065786267'](repeat‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)if not nil‪‪‪‪‪‪‪‪‪‪‪ then ‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'4576797c',nil )‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'5065786267',nil )‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726344727b71594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'6765787065726464',nil )return end local break‪‪‪‪‪‪‪‪‪‪‪‪,‪‪‪‪‪function=‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'507263477b6e4576797c'](‪‪‪‪‪‪nil,nil‪‪‪‪‪‪‪‪‪‪‪)‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'4576797c',break‪‪‪‪‪‪‪‪‪‪‪‪)‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'447263594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'5065786267',nil‪‪‪‪‪‪‪‪‪‪‪)‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726344727b71594073766376'](‪‪‪‪‪‪nil,‪‪‪‪‪‪‪'6765787065726464',‪‪‪‪‪function)‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'45727a7861724576797c644463766364'](‪‪‪‪‪‪nil)‪[‪‪‪‪‪‪‪'637e7a7265'][‪‪‪‪‪‪‪'447e7a677b72'](0,function ()‪[‪‪‪‪‪‪‪'5a4544'][‪‪‪‪‪‪‪'44726362674576797c4463766364'](‪‪‪‪‪‪nil,break‪‪‪‪‪‪‪‪‪‪‪‪,nil‪‪‪‪‪‪‪‪‪‪‪,repeat‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)end )end ‪[‪‪‪‪‪‪‪'67657e7963'](‪‪‪‪‪‪‪'4c5a45444a3751627974637e787964377b7876737273')end ,function (‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪local)‪[‪‪‪‪‪‪‪'67657e7963'](‪‪‪‪‪‪‪'4c5a45444a37515643565b5b3752454558453b37547f72747c376e786265377e7963726579726337747879797274637e787936')end )
end)