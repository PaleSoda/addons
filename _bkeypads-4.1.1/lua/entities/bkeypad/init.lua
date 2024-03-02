AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("bKeypads.UseKeycard")
util.AddNetworkString("bKeypads.ScanDenied")

function ENT:ServerInitialize()
	self.StartedLoading = SysTime()

	self:SetName("bkeypad_" .. self:GetCreationID())

	self:SetModel(bKeypads.MODEL.KEYPAD)
	self:SetUseType(SIMPLE_USE)
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

	self.PINDigits = ""

	self.CreationData = {}

	local ScanningPingTimer = "bKeypads.ScanningPing." .. self:GetCreationID()
	self.ScanningPingTimer = ScanningPingTimer
	timer.Create(self.ScanningPingTimer, self:GetScanPingInterval(), 0, function()
		if not IsValid(self) then
			timer.Remove(ScanningPingTimer)
		elseif IsValid(self:GetScanningPlayer()) and self.ScanningPing then
			self.ScanningPing:Stop()
			self.ScanningPing:Play()
		end
	end)
	timer.Stop(self.ScanningPingTimer)

	self.ScanningTimer = "bKeypads.Scanning." .. self:GetCreationID()
	self.ProcessTimer = "bKeypads.Process." .. self:GetCreationID()
	self.ScanningCheckTimer = "bKeypads.ScanningDist." .. self:GetCreationID()

	if IsValid(self:GetCreator()) then
		self.m_PlayerCreatorSteamID64 = self:GetCreator():SteamID64()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

do
	local InteractionDist = 4500

	util.AddNetworkString("bKeypads.PIN.InputKey")

	local function InteractionCheck(ply, keypad)
		return
			IsValid(keypad) and
			keypad.bKeypad and
			keypad:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.PIN and
			keypad:GetScanningStatus() == bKeypads.SCANNING_STATUS.IDLE and
			ply:EyePos():DistToSqr(keypad:GetPos()) <= InteractionDist and
			not keypad:IsPlayerBehind(ply)
	end

	local antispam = {}
	local function InputKey(_, ply)
		if antispam[ply] and antispam[ply] > SysTime() then return end
		antispam[ply] = SysTime() + .1

		local keypad = net.ReadEntity()
		local digit = net.ReadUInt(4)
		if InteractionCheck(ply, keypad) then
			if digit == 11 then
				if keypad:GetPINDigitsInput() ~= 0 then
					local hasAccess = keypad:TestPIN(keypad.PINDigits)

					bKeypads.AccessLogs:AddLog(keypad, ply, bKeypads.AUTH_MODE.PIN, hasAccess)

					keypad:Process(hasAccess, true, ply)
					keypad:SetPINDigitsInput(0)
					keypad.PINDigits = ""
				end
			elseif digit == 10 then
				if keypad:GetPINDigitsInput() ~= 0 then
					keypad:SetPINDigitsInput(0)
					keypad.PINDigits = ""
					keypad:EmitSound("buttons/button14.wav", 60)
				end
			elseif digit <= 9 and keypad:GetPINDigitsInput() < 6 then
				keypad:SetPINDigitsInput(keypad:GetPINDigitsInput() + 1)
				keypad.PINDigits = keypad.PINDigits .. digit
				keypad:EmitSound("buttons/button15.wav", 60)
			end
		end
	end
	net.Receive("bKeypads.PIN.InputKey", InputKey)
end

sound.Add({
	channel = CHAN_STATIC,
	name = "bKeypads.ScanningPing",
	level = 60,
	sound = "npc/turret_floor/ping.wav",
	volume = 1
})

function ENT:GetCreationData()
	return self.CreationData
end

function ENT:TestPIN(pin)
	return pin == self:LinkProxy():GetCreationData().PIN
end

function ENT:TestAccess(ply)
	local authMode = self:LinkProxy():GetAuthMode()

	local accessChecks = {
		[bKeypads.ACCESS_GROUP.PLAYER] = true,
		[bKeypads.ACCESS_GROUP.USERGROUP] = true,
		[bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION] = true,
		[bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP] = true,
		[bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION] = true,
	}
	if DarkRP and RPExtraTeams then
		accessChecks[bKeypads.ACCESS_GROUP.DARKRP_JOB] = true
		accessChecks[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = true
		accessChecks[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = true
		accessChecks[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = true
		accessChecks[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = true
	else
		accessChecks[bKeypads.ACCESS_GROUP.TEAM] = true
	end
	if ix and ix.flag then
		accessChecks[bKeypads.ACCESS_GROUP.HELIX_FLAG] = true
	end
	if MRS and MRS.Ranks then
		accessChecks[bKeypads.ACCESS_GROUP.MRS_RANK] = true
	end
	if authMode == bKeypads.AUTH_MODE.KEYCARD then
		accessChecks[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] = true
	end

	if IsValid(self:GetParentKeypad()) then

		return self:GetParentKeypad():TestAccess(ply)

	elseif self.AccessRegistry then

		local tests = {
			whitelisted = false,
			blacklisted = false,
			whitelist_active = false,
			blacklist_active = false
		}

		for _, list_type in ipairs(bKeypads.ACCESS_TYPES_REVERSE) do
			local list = self.AccessRegistry[list_type]

			if list then
				local test = list_type == bKeypads.ACCESS_TYPE.BLACKLIST and "blacklisted" or "whitelisted"
				local test_active = list_type == bKeypads.ACCESS_TYPE.BLACKLIST and "blacklist_active" or "whitelist_active"

				if list[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] then
					tests[test_active] = true
					if IsValid(self:GetCreator()) and bKeypads:IsSteamFriends(self:GetCreator(), ply) then
						tests[test] = true
						continue
					end
				end

				local bkeycard = authMode == bKeypads.AUTH_MODE.KEYCARD and IsValid(ply:GetWeapon("bkeycard")) and ply:GetWeapon("bkeycard") or nil

				for access_type, data in pairs(list) do
					if not accessChecks[access_type] then continue end
					tests[test_active] = true

					if access_type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL then
						if authMode ~= bKeypads.AUTH_MODE.KEYCARD then continue end

						if IsValid(bkeycard) then
							local primaryLevel, levels = bkeycard:GetPrimaryLevel(), bkeycard:GetLevels()

							if (
								(
									list_type == bKeypads.ACCESS_TYPE.WHITELIST and
									list[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] ~= nil and
									(#levels > 0 and levels[#levels] >= list[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS])
								) or (
									data[primaryLevel]
								)
							) then
								tests[test] = true
								break
							end

							if #levels > 1 then
								for _, level in ipairs(levels) do
									if data[level] then
										tests[test] = true
										break
									end
								end
							end
						end
					elseif access_type == bKeypads.ACCESS_GROUP.PLAYER then
						if data[ply:SteamID()] ~= nil then
							tests[test] = true
							break
						end
					elseif access_type == bKeypads.ACCESS_GROUP.USERGROUP then
						if OpenPermissions and OpenPermissions.GetUserGroups then
							for usergroup in pairs(OpenPermissions:GetUserGroups(ply)) do
								if data[usergroup] then
									tests[test] = true
									break
								end
							end
						else
							if data[ply:GetUserGroup()] then
								tests[test] = true
								break
							end
						end
					elseif access_type == bKeypads.ACCESS_GROUP.TEAM then
						if data[team.GetName(ply:Team())] then
							tests[test] = true
							break
						end
					elseif access_type == bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION then
						for id in pairs(data) do
							if bKeypads.CustomAccess.Addons.KeyTable[id] and bKeypads.CustomAccess.Addons.KeyTable[id].Function and bKeypads.CustomAccess.Addons.KeyTable[id].Function(self, ply, bkeycard) then
								tests[test] = true
								break
							end
						end
					elseif access_type == bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION then
						for lua_func_name in pairs(data) do
							if bKeypads.CustomAccess.UserConfig.LuaFunctions[lua_func_name] and bKeypads.CustomAccess.UserConfig.LuaFunctions[lua_func_name](self, ply, bkeycard) then
								tests[test] = true
								break
							end
						end
					elseif access_type == bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP then
						for team_group_name in pairs(data) do
							if bKeypads.CustomAccess.UserConfig.TeamGroups[team_group_name] and bKeypads.CustomAccess.UserConfig.TeamGroups[team_group_name][ply:Team()] then
								tests[test] = true
								break
							end
						end
					else
						if DarkRP and RPExtraTeams then
							if access_type == bKeypads.ACCESS_GROUP.DARKRP_JOB then
								if data[RPExtraTeams[ply:Team()].command] then
									tests[test] = true
									break
								end
							elseif access_type == bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY then
								if data[RPExtraTeams[ply:Team()].category] then
									tests[test] = true
									break
								end
							elseif access_type == bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP then
								for doorGroup in pairs(data) do
									if bKeypads.DarkRP.DoorGroups.Teams[doorGroup] and bKeypads.DarkRP.DoorGroups.Teams[doorGroup][ply:Team()] then
										tests[test] = true
										break
									end
								end
							elseif access_type == bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP then
								for demoteGroup in pairs(data) do
									if bKeypads.DarkRP.DemoteGroups[demoteGroup] and bKeypads.DarkRP.DemoteGroups[demoteGroup][ply:Team()] then
										tests[test] = true
										break
									end
								end
							elseif access_type == bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP then
								for agenda in pairs(data) do
									if bKeypads.DarkRP.Agendas.Teams[agenda] and bKeypads.DarkRP.Agendas.Teams[agenda][ply:Team()] then
										tests[test] = true
										break
									end
								end
							end
						end
						if ix then
							if ix.flag and access_type == bKeypads.ACCESS_GROUP.HELIX_FLAG then
								for flag in pairs(data) do
									if ply:GetCharacter() and ply:GetCharacter():HasFlags(flag) then
										tests[test] = true
										break
									end
								end
							end
						end
						if MRS and MRS.Ranks and access_type == bKeypads.ACCESS_GROUP.MRS_RANK then
							local nwGroup, nwRank = MRS.GetNWdata(ply, "Group"), MRS.GetNWdata(ply, "Rank")
							if nwGroup and nwRank and MRS.Ranks[nwGroup] and MRS.Ranks[nwGroup].ranks[nwRank] then
								local maxRankLevel = -math.huge
								local checkSuperiorLevels = list_type == bKeypads.ACCESS_TYPE.WHITELIST and list[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] ~= nil

								local nwRankName = MRS.Ranks[nwGroup].ranks[nwRank].name
								for rank in pairs(data) do
									local rank, group = rank:match("^(.-)\n(.-)$")
									if rank and group then
										if rank == nwRankName and group == nwGroup then
											tests[test] = true
											break
										end

										if checkSuperiorLevels then
											for level, v in pairs(MRS.Ranks[nwGroup].ranks) do
												if v.name == rank then
													maxRankLevel = math.max(maxRankLevel, level)
													break
												end
											end
										end
									end
								end

								if checkSuperiorLevels and nwRank >= maxRankLevel and maxRankLevel ~= -math.huge then
									tests[test] = true
								end
							end
						end
					end
				end
			end
		end

		return not tests.blacklisted and (tests.whitelist_active and tests.whitelisted)
	end

	hook.Run("bKeypads.TestAccess", ply, self, authMode, self.AccessRegistry)

	return false
end

function ENT:Reset()
	bKeypads:CancelScan(self)

	if self:WiremodEnabled() then
		Wire_TriggerOutput(self, "Scanning", 0)
		Wire_TriggerOutput(self, "Access Granted", 0)
		Wire_TriggerOutput(self, "Access Denied", 0)
		Wire_TriggerOutput(self, "Player", NULL)
	end

	timer.Stop(self.ScanningPingTimer)
	timer.Remove(self.ScanningTimer)
	timer.Remove(self.ProcessTimer)

	if self.ScanningPing then
		self.ScanningPing:Stop()
	end

	self:RefreshCanKeypadCrack()
end

function ENT:ServerOnRemove()
	bKeypads.KeypadsRegistry[self] = nil
	table.RemoveByValue(bKeypads.Keypads, self)

	self:Reset()

	if IsValid(self:GetCreator()) then
		if self:GetGrantedKey() > 0 then
			bKeypads.KeyPressing:Unlock(self:GetCreator(), self, self:GetGrantedKey())
		end
		if self:GetDeniedKey() > 0 then
			bKeypads.KeyPressing:Unlock(self:GetCreator(), self, self:GetDeniedKey())
		end
	end

	timer.Remove(self.ProcessTimer)
	timer.Remove(self.ScanningPingTimer)
end

util.AddNetworkString("bKeypads.PaymentPrompt")
net.Receive("bKeypads.PaymentPrompt", function(_, ply)
	local keypad = net.ReadEntity()
	local amount = net.ReadUInt(32)
	local authMode = net.ReadBool()
	if ply:Alive() and IsValid(keypad) and keypad.bKeypad and ply:GetUseEntity() == keypad and (keypad:GetSafePaymentAmount() > 0 and keypad:GetSafePaymentAmount() == amount) then
		if authMode == true then
			if keypad:GetAuthMode() == bKeypads.AUTH_MODE.FACEID then
				keypad:OnUse(ply, true)
			end
		else
			if keypad:GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD then
				local keycard = ply:GetWeapon("bkeycard")
				if IsValid(keycard) then
					keycard:ScanInKeypad(keypad)
				end
			end
		end
	end
end)
function ENT:PlayerRequiresPayment(ply, _hasAccess)
	local hasAccess
	if _hasAccess ~= nil then
		hasAccess = _hasAccess
	else
		hasAccess = self:TestAccess(ply)
	end

	return
		ply ~= self:GetCreator() and
		self:GetSafePaymentAmount() > 0 and
		(
			not IsValid(self:GetCreator()) or
			bKeypads.Permissions:Check(self:GetCreator(), "keypads/payments")
		) and (
			not self:GetCreationData().ChargeUnauthorized or
			not hasAccess
		)
end

function ENT:GetSafePaymentAmount()
	return math.abs(self:GetPaymentAmount())
end

function ENT:OnUse(ply, skipPaymentPrompt)
	if not IsValid(ply) or not ply:IsPlayer() or self:GetScanningStatus() ~= bKeypads.SCANNING_STATUS.IDLE or self:GetBroken() then return end

	self:ShowCamera(self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.FACEID)

	if self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD then
		local keycard = ply:GetWeapon("bkeycard")
		if IsValid(keycard) then
			keycard:ScanInKeypad(self)
		else
			net.Start("bKeypads.UseKeycard")
			net.Send(ply)
		end
	elseif self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.FACEID then
		if (bKeypads.Config.Payments.Prompt ~= false and not skipPaymentPrompt) and self:PlayerRequiresPayment(ply) then
			net.Start("bKeypads.PaymentPrompt")
				net.WriteEntity(self)
				net.WriteUInt(self:GetSafePaymentAmount(), 32)
				net.WriteBool(true)
			net.Send(ply)
		else
			if self:CanFaceScan(ply) then
				self:SetScanning(ply)
			else
				net.Start("bKeypads.ScanDenied")
					net.WriteEntity(self)
				net.Send(ply)
			end
		end
	end
end

function ENT:Use(ply)
	self:OnUse(ply)
end

function ENT:SetScanning(ply)
	bKeypads:ScanPlayer(self, ply)
end

function ENT:SetScanningInternal(ply)
	local ScanMethod = self:LinkProxy():GetAuthMode()
	if IsValid(ply) then
		local isFaceID = ScanMethod == bKeypads.AUTH_MODE.FACEID
		local isKeycard = ScanMethod == bKeypads.AUTH_MODE.KEYCARD

		self:SetScanningStatus(bKeypads.SCANNING_STATUS.SCANNING)

		self.ScanningPing = CreateSound(self, "bKeypads.ScanningPing")
		self.ScanningPing:SetSoundLevel(60)
		self.ScanningPing:Play()
		timer.Start(self.ScanningPingTimer)

		timer.Remove(self.ScanningTimer)
		timer.Create(self.ScanningTimer, tonumber(bKeypads.Config.Scanning.ScanTimes[isFaceID and "FaceID" or "Keycard"]) or 1.5, 1, function()
			if IsValid(ply) then
				local hasAccess = self:TestAccess(ply)
				if self:PlayerRequiresPayment(ply, hasAccess) then
					local amount = self:GetSafePaymentAmount()
					if bKeypads.Economy:canAfford(ply, amount) then
						bKeypads.Economy:addMoney(ply, -amount)

						bKeypads.Economy:CashEffect(self)

						bKeypads.Notifications:Send(ply, bKeypads.Notifications.PAYMENT_TAKEN, self)

						if IsValid(self:GetCreator()) then
							bKeypads.Notifications:Send(self:GetCreator(), bKeypads.Notifications.PAYMENT_RECEIVED, self, ply)
							bKeypads.Economy:addMoney(self:GetCreator(), amount)
						end

						self:Process(true, true)
						bKeypads.AccessLogs:AddLog(self, ply, self:LinkProxy():GetAuthMode(), true, amount)

						hook.Run("bKeypads.Payment", ply, self:GetCreator(), amount, self)
					else
						bKeypads.Notifications:Send(ply, bKeypads.Notifications.PAYMENT_CANT_AFFORD, self)

						self:Process(false, true)
						bKeypads.AccessLogs:AddLog(self, ply, self:LinkProxy():GetAuthMode(), false, amount)
					end
				else
					self:Process(hasAccess, true)
					bKeypads.AccessLogs:AddLog(self, ply, self:LinkProxy():GetAuthMode(), hasAccess)
				end
			else
				self:Reset()
			end
		end)

		if not isKeycard or bKeypads.Config.Scanning.KeycardFailTooFarAway == true then
			timer.Create(self.ScanningCheckTimer, .25, 0, function()
				if not IsValid(ply) or not IsValid(self) then
					timer.Remove(self.ScanningCheckTimer)
					return
				end

				local canScan
				if isKeycard then
					canScan = self:CanKeycardScan(ply)
				else
					canScan = self:CanFaceScan(ply)
				end
				if not canScan then
					self:EmitSound("npc/turret_floor/retract.wav", 60)
					timer.Remove(self.ScanningCheckTimer)
					self:Reset()
				end
			end)
		end

		if isKeycard then
			local keycard = ply:GetWeapon("bkeycard")
			self:SetScanningEntity(IsValid(keycard) and keycard or ply)
			self:EmitSound("buttons/combine_button1.wav", 60)

			if self:WiremodEnabled() then
				local wirePly
				if IsValid(keycard) then
					local sid = keycard:GetSteamID()
					if sid then
						if IsValid(ply) and ply:SteamID() == sid then
							wirePly = ply
						else
							wirePly = player.GetBySteamID(sid)
						end
					end
				end
				if not IsValid(wirePly) then
					wirePly = ply
				end
				if not IsValid(wirePly) then
					wirePly = NULL
				end
				Wire_TriggerOutput(self, "Player", wirePly)
			end
		elseif isFaceID then
			self:SetScanningEntity(ply)
			self:EmitSound("npc/turret_floor/deploy.wav", 60)

			if self:WiremodEnabled() then
				Wire_TriggerOutput(self, "Player", ply)
			end
		end

		if self:WiremodEnabled() then
			Wire_TriggerOutput(self, "Scanning", 1)
		end
	else
		timer.Remove(self.ScanningCheckTimer)
		timer.Remove(self.ScanningTimer)

		self:SetScanningStatus(bKeypads.SCANNING_STATUS.IDLE)

		if self.ScanningPing then self.ScanningPing:Stop() end
		timer.Stop(self.ScanningPingTimer)

		local ply = self:GetScanningPlayer()
		if IsValid(ply) then
			local keycard = ply:GetWeapon("bkeycard")
			if IsValid(keycard) then
				keycard:SetBeingScanned(false)
			end
		end

		if self:WiremodEnabled() then
			Wire_TriggerOutput(self, "Scanning", 0)
		end
	end
end

function ENT:Process(granted, prelogged, ply)
	local CreationData = self:GetCreationData()

	if not prelogged then
		if CreationData.Uncrackable or (not self:GetHacked() and self:GetBroken()) then return end

		local _, wep = debug.getlocal(2, 1, 1)
		if wep and isentity(wep) and IsValid(wep) and wep:IsWeapon() and IsValid(wep:GetOwner()) and wep:GetClass() ~= "gmod_tool" then
			bKeypads.AccessLogs:AddLog(self, wep:GetOwner(), self:LinkProxy():GetAuthMode(), granted, nil, true)
			hook.Run("bKeypads.Keypad.Cracked", self, wep:GetOwner())
		else
			bKeypads.AccessLogs:AddLog(self, nil, self:LinkProxy():GetAuthMode(), granted)
			hook.Run("bKeypads.Keypad.Cracked", self)
		end
		self:SetHacked(true)
		self:SetBroken(true)
	end

	local ply = ply or (IsValid(self:GetScanningPlayer()) and self:GetScanningPlayer()) or nil

	bKeypads:CancelScan(self)

	if self:GetBroken() and not self:GetHacked() then return end

	if CreationData.Wiremod and self:WiremodEnabled() then
		Wire_TriggerOutput(self, "Scanning", 0)
		Wire_TriggerOutput(self, "Player", ply)
	end

	local delayTime, holdLength, repeats, repeatDelay

	if granted then
		if ply and self:GetGrantedNotifications() then
			bKeypads.Notifications:Send(self:GetCreator(), bKeypads.Notifications.ACCESS_GRANTED, self, ply)
		end

		self:SetScanningStatus(bKeypads.SCANNING_STATUS.GRANTED)

		if not self:GetBroken() then self:EmitSound("buttons/button9.wav", 60) end

		delayTime = self:GetGrantedDelay()
		repeats = self:GetGrantedRepeats()
		repeatDelay = self:GetGrantedRepeatDelay()

		holdLength = self:GetGrantedTime()
	else
		if ply and self:GetDeniedNotifications() then
			bKeypads.Notifications:Send(self:GetCreator(), bKeypads.Notifications.ACCESS_DENIED, self, ply)
		end

		self:SetScanningStatus(bKeypads.SCANNING_STATUS.DENIED)

		if not self:GetBroken() then self:EmitSound("buttons/button11.wav", 60) end

		delayTime = self:GetDeniedDelay()
		repeats = self:GetDeniedRepeats()
		repeatDelay = self:GetDeniedRepeatDelay()

		holdLength = self:GetDeniedTime()
	end

	hook.Run(granted and "bKeypads.Keypad.AccessGranted" or "bKeypads.Keypad.AccessDenied", self, ply)

	timer.Create(self.ProcessTimer, delayTime, 1, function()
		local doRepeat

		local function doProcess()
			local revert = self:ProcessLinks(granted)
			timer.Create(self.ProcessTimer, holdLength, 1, function()
				self:RevertProcessLinks(revert)
				doRepeat()
			end)
		end

		local repeatsDone = 0
		function doRepeat()
			if repeatsDone < repeats then
				repeatsDone = repeatsDone + 1
				timer.Create(self.ProcessTimer, repeatDelay, 1, doProcess)
			else
				self:FinishProcessLinks()
			end
		end

		doProcess()
	end)
end

function ENT:ProcessLinks(granted)
	local revert = {}

	local fadingDoors = bKeypads.FadingDoors:GetLinks(self)
	if fadingDoors then
		for _, linkData in pairs(fadingDoors) do
			local link = linkData[granted]
			if not IsValid(link) then continue end

			local fadingDoor = link:GetLinkedEnt()
			if IsValid(fadingDoor) then
				if fadingDoor.fadeToggle then
					fadingDoor:fadeToggleActive()
				else
					fadingDoor:fadeActivate()
					revert.fadingDoors = revert.fadingDoors or {}
					table.insert(revert.fadingDoors, fadingDoor)
				end
			end
		end
	end

	local mapLinks = bKeypads.MapLinking:GetLinks(self)
	if mapLinks then
		for _, linkData in pairs(mapLinks) do
			local link = linkData[granted]
			if not IsValid(link) then continue end

			bKeypads.MapLinking:On(link, self:GetScanningPlayer())

			revert.links = revert.links or {}
			table.insert(revert.links, link)
		end
	end

	if self:WiremodEnabled() then
		Wire_TriggerOutput(self, granted and "Access Granted" or "Access Denied", 1)
	end

	local numpadKey = self:GetNumpadKey()
	if numpadKey then
		bKeypads.KeyPressing:Lock(self:GetCreator(), self, numpadKey)
		bKeypads.KeyPressing:Force(self:GetCreator(), self, numpadKey, true)
	end

	return revert
end

function ENT:RevertProcessLinks(revert)
	if revert.fadingDoors then
		for _, fadingDoor in ipairs(revert.fadingDoors) do
			if IsValid(fadingDoor) and bKeypads.FadingDoors:IsFadingDoor(fadingDoor) then
				fadingDoor:fadeDeactivate()
			end
		end
	end

	if revert.links then
		for _, link in ipairs(revert.links) do
			if IsValid(link) and IsValid(link:GetLinkedEnt()) then
				bKeypads.MapLinking:Off(link)
			end
		end
	end

	if not IsValid(self) then return end

	local numpadKey = self:GetNumpadKey()
	if numpadKey and bKeypads.KeyPressing:IsLocked(self:GetCreator(), self, numpadKey) then
		bKeypads.KeyPressing:Force(self:GetCreator(), self, numpadKey, false)
	end

	if self:WiremodEnabled() then
		Wire_TriggerOutput(self, "Player", NULL)
		Wire_TriggerOutput(self, "Access Granted", 0)
		Wire_TriggerOutput(self, "Access Denied", 0)
	end
end

function ENT:FinishProcessLinks()
	local numpadKey = self:GetNumpadKey()
	if numpadKey then
		bKeypads.KeyPressing:Unlock(self:GetCreator(), self, numpadKey)
	end

	if self:GetHacked() or not self:GetBroken() then
		self:SetScanningEntity(NULL)
		self:SetScanningStatus(bKeypads.SCANNING_STATUS.IDLE)

		if self:GetHacked() then
			self:SetHacked(false)
			self:SetBroken(false)
		else
			self:EmitSound("npc/turret_floor/retract.wav", 60)
		end
	end

	if self:WiremodEnabled() then
		Wire_TriggerOutput(self, "Player", NULL)
		Wire_TriggerOutput(self, "Access Granted", 0)
		Wire_TriggerOutput(self, "Access Denied", 0)
	end
end

function ENT:GetNumpadKey()
	if IsValid(self:GetCreator()) then
		if self:GetScanningStatus() == bKeypads.SCANNING_STATUS.GRANTED then
			return self:GetGrantedKey()
		elseif self:GetScanningStatus() == bKeypads.SCANNING_STATUS.DENIED then
			return self:GetDeniedKey()
		end
	end
end

function ENT:WiremodEnabled()
	local enabled = WireLib ~= nil and self:GetCreationData().Wiremod and bKeypads.Config.Wiremod.Enabled and (not IsValid(self:GetCreator()) or bKeypads.Permissions:Check(self:GetCreator(), "keypads/wiremod"))
	self:SetWiremodEnabled(enabled)
	return enabled
end

--## Creation stuff ##--

function ENT:RemoveWeld()
	self:SetWelded(false)

	local CreationData = self:GetCreationData()
	if IsValid(CreationData.WeldEnt) then
		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableCollisions(true)
		end

		local physObj = IsValid(CreationData.WeldEnt:GetTable().Ent2) and CreationData.WeldEnt:GetTable().Ent2:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableCollisions(true)
		end

		CreationData.WeldEnt:Remove()
	end

	CreationData.WeldEnt = nil
	CreationData.WeldToEnt = nil
	CreationData.WeldBone = nil
end

function ENT:CreateWeld(target_ent, remove_on_break)
	local CreationData = self:GetCreationData()
	if IsValid(target_ent) or target_ent:IsWorld() then
		if (
			util.IsValidPhysicsObject(target_ent, CreationData.WeldBone or 0) and
			util.IsValidPhysicsObject(self, 0) and
			(not IsValid(CreationData.WeldEnt) or target_ent ~= CreationData.WeldToEnt)
		) then
			self:RemoveWeld()
			CreationData.WeldEnt = constraint.Weld(self, target_ent, 0, CreationData.WeldBone or 0, 0, true, remove_on_break == true)
			CreationData.WeldToEnt = target_ent
			self:SetWelded(true)
		end
	else
		self:RemoveWeld()
	end
end

function ENT:EnableWiremod()
	if WireLib and not WireLib.HasPorts(self) then
		if bKeypads.Config.Wiremod.ScanningOutput then
			self.Outputs = WireLib.CreateOutputs(self, {"Scanning", "Access Granted", "Access Denied", "Player [ENTITY]"})
		else
			self.Outputs = WireLib.CreateOutputs(self, {"Access Granted", "Access Denied", "Player [ENTITY]"})
		end
		Wire_TriggerOutput(self, "Player", NULL)

		self:SetWiremodEnabled(true)
	end

	self:GetCreationData().Wiremod = true
end

function ENT:DisableWiremod()
	if WireLib and WireLib.HasPorts(self) then
		WireLib.Remove(self)
	end

	self:SetWiremodEnabled(false)
	self:GetCreationData().Wiremod = nil
end

function ENT:Freeze()
	local physObj = self:GetPhysicsObject()
	if IsValid(physObj) then
		physObj:EnableMotion(false)
	end

	self:GetCreationData().Freeze = true
end

function ENT:Unfreeze()
	local physObj = self:GetPhysicsObject()
	if IsValid(physObj) then
		physObj:EnableMotion(true)
	end

	self:GetCreationData().Freeze = nil
end

--## Linking ##--

function ENT:LinkToKeypad(keypad)
	bKeypads:LinkKeypads(keypad, self)
end

function ENT:UnlinkFromKeypad()
	bKeypads:UnlinkKeypad(self)
end

function ENT:SetCreationData(CreationData)
	self.CreationData = CreationData

	if not IsValid(self:GetCreator()) and IsValid(CreationData.Creator) then
		self:SetCreator(CreationData.Creator)
	end

	self:SetKeypadName(CreationData.KeypadName or "")

	self:SetAuthMode(CreationData.AuthMode)

	if CreationData.Freeze or IsValid(CreationData.WeldToEnt) then
		self:Freeze()
	else
		self:Unfreeze()
	end

	if CreationData.WeldToEnt ~= nil and (IsValid(CreationData.WeldToEnt) or CreationData.WeldToEnt:IsWorld()) then
		self:CreateWeld(CreationData.WeldToEnt, CreationData.WeldRemoveOnBreak)
	else
		self:RemoveWeld()
	end

	if CreationData.NoCollide == true then
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	else
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end

	if WireLib then
		if CreationData.Wiremod then
			self:EnableWiremod()
		else
			self:DisableWiremod()
		end
	end

	self:SetGrantedNotifications(CreationData.GrantedNotifications)
	self:SetDeniedNotifications(CreationData.DeniedNotifications)

	if self:GetGrantedKey() ~= 0 then
		bKeypads.KeyPressing:Unlock(self:GetCreator(), self, self:GetGrantedKey())
	end
	self:SetGrantedKey(math.max(CreationData.GrantedKey or 0, 0))
	self:SetGrantedTime(math.max(CreationData.GrantedTime or bKeypads.Config.Scanning.AccessGranted.MinimumTime, 0))
	self:SetGrantedDelay(math.max(CreationData.GrantedDelay or 0, 0))
	self:SetGrantedRepeats(math.max(CreationData.GrantedRepeats or 0, 0))
	self:SetGrantedRepeatDelay(math.max(CreationData.GrantedRepeatDelay or 0, 0))

	if self:GetDeniedKey() ~= 0 then
		bKeypads.KeyPressing:Unlock(self:GetCreator(), self, self:GetDeniedKey())
	end
	self:SetDeniedKey(math.max(CreationData.DeniedKey or 0, 0))
	self:SetDeniedTime(math.max(CreationData.DeniedTime or bKeypads.Config.Scanning.AccessDenied.MinimumTime, 0))
	self:SetDeniedDelay(math.max(CreationData.DeniedDelay or 0, 0))
	self:SetDeniedRepeats(math.max(CreationData.DeniedRepeats or 0, 0))
	self:SetDeniedRepeatDelay(math.max(CreationData.DeniedRepeatDelay or 0, 0))

	self:SetBackgroundColor(CreationData.BackgroundColor or 0x0096FF)

	if bKeypads.Config.KeypadDestruction.Enable then
		self:SetDestructionMode(CreationData.Destructible == false)
	else
		self:SetDestructionMode(CreationData.Destructible == true)
	end
	if CreationData.Destructible and CreationData.MaxHealth then
		self:SetMaxHealth(CreationData.MaxHealth)
		if CreationData.Shield then self:SetShield(CreationData.Shield) end
		self:SetHealth(self:GetMaxHealth())
		self:Repair()
	end

	self:SetImageURL("")
	if self:GetAuthMode() ~= bKeypads.AUTH_MODE.PIN and (not IsValid(self:GetCreator()) or not bKeypads.KeypadImages.Bans:Check(self:GetCreator())) and CreationData.ImageURL and #CreationData.ImageURL > 0 then
		if #CreationData.ImageURL > 512 then
			ErrorNoHalt("Image URL (" .. #CreationData.ImageURL .. " bytes) for this keypad is too long - max size is 512 bytes\n")
		else
			local verified, domain = bKeypads.KeypadImages:VerifyURL(CreationData.ImageURL)
			if not verified then
				if domain then
					ErrorNoHalt("Domain for this keypad's image URL is not whitelisted (" .. domain .. ")\n")
				else
					ErrorNoHalt("Image URL for this keypad is invalid (" .. CreationData.ImageURL .. ")\n")
				end
			else
				self:SetImageURL(CreationData.ImageURL)
			end
		end
	end

	if CreationData.Broken then
		self:SetBroken(CreationData.Broken)
	end
	if CreationData.Slanted then
		self:SetSlanted(CreationData.Slanted)
	end

	self:SetChargeUnauthorized(CreationData.ChargeUnauthorized == true)

	self:RefreshCanKeypadCrack()
	self:RefreshBodygroups()
end

function ENT:SetAccessMatrix(am)
	self.AccessMatrix = am

	if bKeypads.Config.Payments.Enable and self.AccessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] ~= false and (not IsValid(self:GetCreator()) or bKeypads.Permissions:Check(self:GetCreator(), "keypads/payments")) then
		self:SetPaymentAmount(math.Clamp(self.AccessMatrix[bKeypads.ACCESS_GROUP.PAYMENT], bKeypads.Config.Payments.MinimumPayment, bKeypads.Config.Payments.MaximumPayment ~= 0 and bKeypads.Config.Payments.MaximumPayment or ((2^31)-1)))
	else
		self:SetPaymentAmount(0)
	end

	local blockedAccessGroups = {}
	if DarkRP and RPExtraTeams then
		blockedAccessGroups[bKeypads.ACCESS_GROUP.TEAM] = true
	else
		blockedAccessGroups[bKeypads.ACCESS_GROUP.DARKRP_JOB] = true
		blockedAccessGroups[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = true
		blockedAccessGroups[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = true
		blockedAccessGroups[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = true
		blockedAccessGroups[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = true
	end

	self.AccessRegistry = {
		[bKeypads.ACCESS_TYPE.WHITELIST] = {},
		[bKeypads.ACCESS_TYPE.BLACKLIST] = {}
	}
	for access_type, registry in pairs(self.AccessRegistry) do
		for access_group, values in pairs(self.AccessMatrix[access_type]) do
			if blockedAccessGroups[access_group] then continue end
			if isbool(values) then
				registry[access_group] = values or nil
			elseif istable(values) and not table.IsEmpty(values) then
				if IsValid(self:GetCreator()) and access_group == bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION and not bKeypads.Permissions:Check(self:GetCreator(), "keypads/custom_lua_functions") then
					continue
				end
				registry[access_group] = values
			end
		end

		if self.AccessMatrix[access_type][bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] == true and registry[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] ~= nil then
			local greatest = 0
			for level in pairs(registry[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL]) do
				if level > greatest then
					greatest = level
				end
			end
			registry[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = greatest
		end
	end

	if table.IsEmpty(self.AccessRegistry[bKeypads.ACCESS_TYPE.WHITELIST]) then
		self.AccessRegistry[bKeypads.ACCESS_TYPE.WHITELIST] = nil
	end

	if table.IsEmpty(self.AccessRegistry[bKeypads.ACCESS_TYPE.BLACKLIST]) then
		self.AccessRegistry[bKeypads.ACCESS_TYPE.BLACKLIST] = nil
	end

	if self:GetScanningStatus() == bKeypads.SCANNING_STATUS.LOADING then
		timer.Simple(math.max(1 - (SysTime() - self.StartedLoading), 0), function()
			if not IsValid(self) then return end
			self:SetScanningStatus(bKeypads.SCANNING_STATUS.IDLE)
		end)
	end
end

function ENT:BrokenStatusChanged(_, prevBroken, broken)
	if prevBroken == broken then return end

	if broken then
		self:Reset()
	end

	if not IsValid(self.m_eDeployedCracker) then
		if not self.m_bSuppressSound then
			if broken then
				self:EmitSound("npc/roller/mine/rmine_predetonate.wav", 60)
			else
				self:EmitSound("npc/roller/remote_yes.wav", 60)
			end
		else
			self.m_bSuppressSound = nil
		end
	end

	if not self:GetHacked() then
		self.CreationData.Broken = broken or nil

		if broken then
			self.m_BrokenProcessRevert = self:ProcessLinks(true)
		elseif self.m_BrokenProcessRevert then
			self:RevertProcessLinks(self.m_BrokenProcessRevert)
		end
	end

	self:RefreshCanKeypadCrack(broken)
end

function ENT:SlantedStatusChanged(_, __, slanted)
	if not self:GetHacked() then
		self.CreationData.Slanted = slanted
	end
end

function ENT:RefreshCanKeypadCrack(isBroken)
	-- Keypad Cracker support
	self:SetUncrackable(isBroken or (self:GetCreationData() and self:GetCreationData().Uncrackable == true))
	self:SetIsLinked(not self:IsUseless())
end

-- Ugly hack to update the keypad's CanKeypadCrack status when tools are used on the keypad (e.g. wiremod tools)
hook.Add("CanTool", "bKeyapds.RefreshCanKeypadCrack", function(ply, tr)
	timer.Simple(0, function()
		if IsValid(tr.Entity) and tr.Entity.bKeypad then
			tr.Entity:RefreshCanKeypadCrack(tr.Entity.CreationData.Broken)
		end
	end)
end)

function ENT:IsUseless()
	-- Returns if the keypad is useless (keypad cracking it would have no effect)
	-- TODO keyboard press simulation check

	-- Granted key
	if self:GetGrantedKey() ~= 0 then return false end

	-- Map entities
	if bKeypads.MapLinking:GetLinks(self) then return false end

	-- Fading doors
	if bKeypads.FadingDoors:GetLinks(self) then return false end

	-- Wiremod outputs
	if self:GetCreationData().Wiremod and WireLib and self.Outputs and self.Outputs["Access Granted"] and not table.IsEmpty(self.Outputs["Access Granted"]["Connected"]) then return false end

	-- Custom hook
	if hook.Run("bKeypads.IsUseless", self) == false then return false end

	return true
end

function ENT:Break(slant)
	if slant == nil then
		self:SetSlanted(true)
	else
		self:SetSlanted(slant == true)
	end
	self:SetBroken(true)
end

function ENT:Repair()
	self:SetSlanted(false)
	self:SetBroken(false)
end

-- Ugly hack to make ENTITY:*Creator() work with disconnected + reconnected players on bKeypads
local ENTITY = FindMetaTable("Entity")
bKeypads_SetCreator = bKeypads_SetCreator or ENTITY.SetCreator
bKeypads_GetCreator = bKeypads_GetCreator or ENTITY.GetCreator

function ENTITY:GetCreator()
	if self.bKeypad then
		local ply = bKeypads_GetCreator(self)
		if IsValid(ply) then
			return ply
		elseif self.m_PlayerCreatorSteamID64 then
			local ply = bKeypads.player.GetBySteamID64(self.m_PlayerCreatorSteamID64)
			if IsValid(ply) then
				self.m_PlayerCreator = ply
				return ply
			else
				return NULL
			end
		end
	else
		return bKeypads_GetCreator(self)
	end
end
function ENTITY:SetCreator(ply)
	if self.bKeypad then
		if IsValid(ply) then
			self.m_PlayerCreatorSteamID64 = ply:SteamID64()
			self.m_PlayerCreator = ply
		else
			self.m_PlayerCreatorSteamID64 = nil
			self.m_PlayerCreator = nil
		end
		self:SetKeypadOwner(self.m_PlayerCreator)
	else
		return bKeypads_SetCreator(self, ply)
	end
end

--## Destruction ##--

local PITCH_SHIFT = 255 - 100

function ENT:GetHealthStage()
	return math.ceil(math.min(self:Health(), self:GetMaxHealth()) / (self:GetMaxHealth() / 4))
end

function ENT:OnTakeDamage(dmginfo)
	if not self:GetDestructible() then return end

	-- https://github.com/FPtje/DarkRP/issues/3070
	if DarkRP and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():IsWeapon() and dmginfo:GetInflictor():GetClass() == "stunstick" then return end

	local healthChanged = false
	if self:GetShield() > 0 then
		local shieldHealth = self:GetShield() - dmginfo:GetDamage() - dmginfo:GetDamageBonus()
		self:SetShield(math.max(shieldHealth, 0))

		if shieldHealth <= 0 then
			self:ShieldBrokenEffect()
		end
		if shieldHealth < 0 then
			self:SetHealth(math.max(self:Health() + shieldHealth, 0))
			healthChanged = true
		end
	else
		self:SetHealth(math.max(self:Health() - dmginfo:GetDamage() - dmginfo:GetDamageBonus(), 0))
		healthChanged = true
	end

	if healthChanged then
		local healthStage = self:GetHealthStage()
		if healthStage ~= self.m_iHealthStage then
			if healthStage > 0 then
				if healthStage == 1 then
					self:EmitSound("npc/scanner/scanner_siren2.wav", 75, 100 + (PITCH_SHIFT * .25))
				else
					self:EmitSound("npc/scanner/combat_scan4.wav", 75, 100 + (PITCH_SHIFT * (1 / healthStage)))
				end
			end
			self.m_iHealthStage = healthStage
		end
	end

	if self:Health() <= 0 and not self:GetBroken() then
		self:DamageBreak()
	end
end

function ENT:ShieldBrokenEffect()
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self:WorldSpaceCenter())
	util.Effect("bkeypads_shield_break", fx, true, true)

	self:EmitSound("weapons/physcannon/energy_disintegrate5.wav")
end

function ENT:DamageBreak()
	self:Break()

	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self:WorldSpaceCenter())
	util.Effect("cball_explode", fx)
	util.Effect("RPGShotDown", fx)

	self:StopSound("npc/scanner/scanner_siren2.wav")
	self:EmitSound("npc/scanner/scanner_pain" .. math.random(1,2) .. ".wav")
end

function ENT:HealthRegen()
	if self:Health() <= 0 then
		if not self:GetBroken() then
			self:DamageBreak()
		end
	elseif not self:GetHacked() then
		if self:GetBroken() then
			self:Repair()
		end

		if bKeypads.Config.KeypadDestruction.KeypadRegenRate > 0 and self:Health() < self:GetMaxHealth() and (not self.m_iNextHeal or CurTime() >= self.m_iNextHeal) then
			self.m_iNextHeal = CurTime() + bKeypads.Config.KeypadDestruction.KeypadRegenRate
			self:SetHealth(math.min(math.ceil(self:Health() + (self:GetMaxHealth() * bKeypads.Config.KeypadDestruction.KeypadRegenAmount)), self:GetMaxHealth()))
		end
	end
end

local DAMAGE_AIM = 3
function ENT:OnDestructionModeChanged(_, oldVal, newVal)
	if self:GetDestructible() then
		self:SetMaxHealth(bKeypads.Config.KeypadDestruction.KeypadHealth)
		self:SetHealth(self:GetMaxHealth())
		self.m_iHealthStage = self:GetHealthStage()

		self:SetSaveValue("m_takedamage", DAMAGE_AIM)

		if bKeypads.Config.KeypadDestruction.KeypadRegenRate ~= 0 and bKeypads.Config.KeypadDestruction.KeypadRegenAmount ~= 0 then
			self.Think = self.HealthRegen
		end
	else
		self:SetSaveValue("m_takedamage", 0)

		self.Think = nil
	end
end