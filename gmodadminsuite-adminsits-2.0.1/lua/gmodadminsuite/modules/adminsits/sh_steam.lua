GAS.AdminSits.Steam = {}

if (CLIENT) then
	local function L(phrase)
		return GAS:Phrase(phrase, "adminsits")
	end

	GAS_AdminSits_SteamProfileCache = GAS_AdminSits_SteamProfileCache or {}
	do
		local function GetProfile_Failed(reason, httpCode)
			if (httpCode ~= nil) then
				Derma_Message((L"SteamProfile_Failure"):format("HTTP " .. (httpCode or "XXX")), L"Error", L"Dismiss")
			elseif (reason ~= nil) then
				Derma_Message((L"SteamProfile_Failure"):format(reason or L"Unknown"), L"Error", L"Dismiss")
			end
		end
		function GAS.AdminSits.Steam:GetProfile(ply_or_steamid64, callback)
			local steamid64, account_id
			if (type(ply_or_steamid64) == "Player") then
				assert(IsValid(ply_or_steamid64), "NULL player")
				assert(ply_or_steamid64:IsPlayer(), "Not a player")
				if (ply_or_steamid64:IsBot()) then return end
				steamid64 = ply_or_steamid64:SteamID64()
				account_id = ply_or_steamid64:AccountID()
			else
				steamid64 = ply_or_steamid64
				account_id = GAS:SteamID64ToAccountID(steamid64)
			end

			local cached = GAS_AdminSits_SteamProfileCache[account_id]
			if (cached and os.time() < cached.Expires) then
				if (cached.success ~= nil and cached.success_xml ~= nil) then
					callback(cached)
				else
					table.insert(cached.callbacks, callback)
				end
			else
				local profile = {Expires = os.time() + 3600, callbacks = {callback}}
				GAS_AdminSits_SteamProfileCache[account_id] = profile

				function profile:CheckProgress()
					if (self.success ~= nil and self.success_xml ~= nil) then
						for _,f in ipairs(self.callbacks) do
							f(self)
						end
						self.callbacks = {}
					end
				end

				http.Fetch("https://steamcommunity.com/profiles/" .. steamid64, function(body, len, headers, httpCode)
					if (httpCode >= 200 and httpCode <= 299) then
						if (len > 0) then
							local VACBans = body:match("<div class=\"profile_ban\">.-(%S-) VAC bans? on record%s-<span class=\"profile_ban_info\">")
							profile.VACBans = VACBans or "0"

							local LastBan = body:match("<div class=\"profile_ban\">.-<span class=\"profile_ban_info\">.-(%d-) day%(s%) since last ban%s-</div>")
							profile.LastBan = LastBan or false

							local GameBans = body:match("<div class=\"profile_ban\">.-(%S-) game bans? on record%s-<span class=\"profile_ban_info\">")
							profile.GameBans = GameBans or "0"

							local GmodPlaytime = body:match("<div class=\"recent_game\">.-<div class=\"game_info_cap\">.-<a href=\"https://steamcommunity.com/app/4000\">.-<div class=\"game_info_details\">.-(%S-) hrs on record<br>.-<div class=\"game_name\"><a class=\"whiteLink\" href=\"https://steamcommunity.com/app/4000\">Garry's Mod</a></div>")
							profile.GmodPlaytime = GmodPlaytime or nil

							profile.success = true
							profile:CheckProgress()
						elseif (not profile.failed) then
							profile.failed = true
							GetProfile_Failed("Empty response (len = 0)", nil)

							profile.success = false
							profile:CheckProgress()
						end
					elseif (not profile.failed) then
						profile.failed = true
						GetProfile_Failed(nil, httpCode)

						profile.success = false
						profile:CheckProgress()
					end
				end, function(reason)
					if (not profile.failed) then
						profile.failed = true
						GetProfile_Failed(reason, nil)

						profile.success = false
						profile:CheckProgress()
					end
				end)

				http.Fetch("https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1", function(body, len, headers, httpCode)
					if (httpCode >= 200 and httpCode <= 299) then
						if (len > 0) then
							local MemberSince = body:match("<memberSince>(.-)</memberSince>")
							profile.MemberSince = MemberSince or nil

							local VACBanned = body:match("<vacBanned>(.-)</vacBanned>")
							if (VACBanned == "0") then
								profile.VACBans = "0"
							end

							local TradeBanned = body:match("<tradeBanState>Banned</tradeBanState>")
							profile.TradeBanned = TradeBanned ~= nil

							profile.success_xml = true
							profile:CheckProgress()
						elseif (not profile.failed) then
							profile.failed = true
							GetProfile_Failed("Empty response (len = 0)", nil)

							profile.success_xml = false
							profile:CheckProgress()
						end
					elseif (not profile.failed) then
						profile.failed = true
						GetProfile_Failed(nil, httpCode)

						profile.success_xml = false
						profile:CheckProgress()
					end
				end, function(reason)
					if (not profile.failed) then
						profile.failed = true
						GetProfile_Failed(reason, nil)

						profile.success_xml = false
						profile:CheckProgress()
					end
				end)
			end
		end
	end

	local function SteamFriendCheck()
		local requestKey = net.ReadUInt(32)
		local ply = net.ReadEntity()
		if (IsValid(ply)) then
			GAS:netStart("AdminSits.SteamFriends")
				net.WriteUInt(requestKey, 32)
				net.WriteBool(ply:GetFriendStatus())
			net.SendToServer()
		end
	end
	GAS:netReceive("AdminSits.SteamFriends", SteamFriendCheck)

	local function ReceiveSteamFriendsStatus()
		local ply1 = net.ReadEntity()
		local ply2 = net.ReadEntity()
		local isFriends = net.ReadBool()
		if (IsValid(ply1) and IsValid(ply2)) then
			Derma_Message((isFriends and (L"SteamFriendStatusYes"):format(ply1:Nick(), ply2:Nick())) or (L"SteamFriendStatusNo"):format(ply1:Nick(), ply2:Nick()), L"CheckSteamFriends" .. " - " .. ply1:Nick(), L"Dismiss")
		end
	end
	GAS:netReceive("AdminSits.CheckSteamFriends", ReceiveSteamFriendsStatus)

else
	
	do
		local CheckSteamFriendsRequests = {}

		local function ReceiveSteamFriendsStatus(ply)
			local requestKey = net.ReadUInt(32)
			local isFriends = net.ReadBool()
			if (CheckSteamFriendsRequests[requestKey]) then
				GAS:netStart("AdminSits.CheckSteamFriends")
					net.WriteEntity(CheckSteamFriendsRequests[requestKey][1])
					net.WriteEntity(CheckSteamFriendsRequests[requestKey][2])
					net.WriteBool(isFriends)
				net.Send(CheckSteamFriendsRequests[requestKey][3]:sequential())
				CheckSteamFriendsRequests[requestKey] = nil
			end
		end
		GAS:netReceive("AdminSits.SteamFriends", ReceiveSteamFriendsStatus)

		local function CheckSteamFriends(ply)
			local ply1 = net.ReadEntity() -- player in the sit
			local ply2 = net.ReadEntity()
			if (GAS.AdminSits:IsStaff(ply) and GAS.AdminSits:IsInSit(ply, ply1)) then
				local requestKey = tonumber(util.CRC(ply1:AccountID() .. ply2:AccountID()))
				local dispatch = CheckSteamFriendsRequests[requestKey] == nil
				CheckSteamFriendsRequests[requestKey] = CheckSteamFriendsRequests[requestKey] or {ply1, ply2, GAS:Registry()}
				CheckSteamFriendsRequests[requestKey][3](ply, true)
				if (dispatch) then
					GAS:netStart("AdminSits.SteamFriends")
						net.WriteUInt(requestKey, 32)
						net.WriteEntity(ply2)
					net.Send(ply1)
				end
			end
		end
		GAS:netReceive("AdminSits.CheckSteamFriends", CheckSteamFriends)
	end

end