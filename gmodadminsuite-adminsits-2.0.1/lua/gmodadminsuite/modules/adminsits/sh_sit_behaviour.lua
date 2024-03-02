function GAS.AdminSits:IsInSit(ply)
	return (IsValid(ply) and GAS.AdminSits.SitPlayers[ply] ~= nil) or false
end

function GAS.AdminSits:IsInSitWith(ply1, ply2)
	if (IsValid(ply1) and IsValid(ply2)) then
		if (SERVER) then
			local ply1_Sit = GAS.AdminSits.SitPlayers[ply1]
			local ply2_Sit = GAS.AdminSits.SitPlayers[ply2]
			return ply1_Sit == ply2_Sit
		else
			return GAS.AdminSits.ActiveSit ~= nil and GAS.AdminSits.ActiveSit[ply1] ~= nil and GAS.AdminSits.ActiveSit[ply2] ~= nil
		end
	end
	return false
end

if (SERVER) then
	function GAS.AdminSits:GetPlayerSit(ply)
		return IsValid(ply) and GAS.AdminSits.SitPlayers[ply]
	end
end

do
	local function ShouldCollide(ent1, ent2)
		if (not IsValid(ent1) or not IsValid(ent2)) then return end

		local ply1 = ent1:IsPlayer() and ent1
		local ply2 = ent2:IsPlayer() and ent2
		if (ply1 and ply2) then
			if (GAS.AdminSits:IsInSit(ent1) or GAS.AdminSits:IsInSit(ent2)) then
				if (GAS.AdminSits:IsInSitWith(ent1, ent2)) then
					local staff, not_staff
					if (GAS.AdminSits:IsStaff(ent1)) then
						if (GAS.AdminSits:IsStaff(ent2)) then
							return false
						else
							staff = ent1
							not_staff = ent2
						end
					elseif (GAS.AdminSits:IsStaff(ent2)) then
						staff = ent2
						not_staff = ent1
					end
					if (IsValid(staff) and IsValid(not_staff)) then
						local wep = staff:GetActiveWeapon()
						if (IsValid(wep) and wep:GetClass() == "weapon_physgun" and staff:KeyDown(IN_ATTACK)) then
							return
						end
					end
				end
				
				return false
			end
		elseif (SERVER) then
			local ply = ply1 or ply2
			if (GAS.AdminSits.Bubbles and GAS.AdminSits.Bubbles.Players[ply]) then
				local ent = (not ply1 and ent1) or (not ply2 and ent2)
				if (GAS_AdminSits_NonBubbleEntities[ent]) then
					return false
				end
			end
		end
	end
	GAS:hook("ShouldCollide", "AdminSits.ShouldCollide", ShouldCollide)
end

do
	local function ActiveSitJoined(ply)
		GAS.AdminSits.ActiveSit = GAS.AdminSits.ActiveSit or GAS:Registry()
		GAS.AdminSits.ActiveSit(ply, true)
	end
	local function ActiveSitLeft(ply)
		if (GAS.AdminSits.ActiveSit) then
			GAS.AdminSits.ActiveSit(ply, nil)
			if (GAS.AdminSits.ActiveSit:len() == 0) then
				GAS.AdminSits.ActiveSit = nil
			end
		end
	end
	GAS:hook("GAS.AdminSits.SitJoined", "AdminSits.SitJoined", ActiveSitJoined)
	GAS:hook("GAS.AdminSits.SitLeft", "AdminSits.SitLeft", ActiveSitLeft)
end

function GAS.AdminSits:IsStaff(ply)
	return not ply:IsBot() and OpenPermissions:HasPermission(ply, "gmodadminsuite_adminsits/create_sits")
end

function GAS.AdminSits:CanTargetStaff(ply)
	return not ply:IsBot() and OpenPermissions:HasPermission(ply, "gmodadminsuite_adminsits/target_staff")
end

function GAS.AdminSits:CanJoinSit(ply)
	return not ply:IsBot() and OpenPermissions:HasPermission(ply, "gmodadminsuite_adminsits/join_any_sit")
end

local function NotAllowedInSit(ply)
	if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
		if (SERVER) then
			GAS:netStart("AdminSits.NotAllowedInSit")
			net.Send(ply)
		end
		return false
	end
end
for _,hook_name in ipairs({
	"CanTool",
	"CanUndo",
	"CanPlayerUnfreeze",
	"CanPlayerSuicide",
	"CanPlayerEnterVehicle",
	"PlayerCanJoinTeam",
	"PlayerCanPickupItem",
	"CanDrive",
	"CanProperty",
	"PlayerSwitchFlashlight",
	"PlayerShouldTaunt",
}) do
	GAS:hook(hook_name, "AdminSits." .. hook_name, NotAllowedInSit)
end

local function NotAllowedInSit_StaffToo(ply)
	if (GAS.AdminSits:IsInSit(ply)) then
		if (SERVER) then
			GAS:netStart("AdminSits.NotAllowedInSit")
			net.Send(ply)
		end
		return false
	end
end
for _,hook_name in ipairs({
	"PlayerSpawnProp",
	"PlayerSpawnEffect",
	"PlayerSpawnNPC",
	"PlayerSpawnRagdoll",
	"PlayerSpawnSENT",
	"PlayerSpawnSWEP",
	"PlayerSpawnVehicle",
}) do
	GAS:hook(hook_name, "AdminSits." .. hook_name, NotAllowedInSit_StaffToo)
end

local function PlayerNoClip(ply, desiredNoclip)
	if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply) and desiredNoclip) then
		if (SERVER) then
			GAS:netStart("AdminSits.NotAllowedInSit")
			net.Send(ply)
		end
		return false
	end
end
GAS:hook("PlayerNoClip", "AdminSits.PlayerNoClip", PlayerNoClip)

local function PlayerSwitchWeapon(ply, _, newWep)
	if (IsValid(newWep) and newWep:GetClass() ~= "gas_weapon_hands" and GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
		if (SERVER) then
			ply:Give("gas_weapon_hands")
			if (IsValid(ply:GetWeapon("gas_weapon_hands"))) then ply:SetActiveWeapon(ply:GetWeapon("gas_weapon_hands")) end
			ply:SelectWeapon("gas_weapon_hands")
		end
		return true
	end
end
GAS:hook("PlayerSwitchWeapon", "AdminSits.PlayerSwitchWeapon", PlayerSwitchWeapon)

if (SERVER) then
	local function PlayerLoadout(ply)
		if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
			ply:Give("gas_weapon_hands")
			if (IsValid(ply:GetWeapon("gas_weapon_hands"))) then ply:SetActiveWeapon(ply:GetWeapon("gas_weapon_hands")) end
			ply:SelectWeapon("gas_weapon_hands")
		end
	end
	GAS:hook("PlayerLoadout", "AdminSits.PlayerLoadout", PlayerLoadout)

	local function PlayerCanPickupWeapon(ply, wep)
		if (IsValid(wep) and wep:GetClass() ~= "gas_weapon_hands" and not ply.GAS_AdminSits_Unarresting and GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
			return false
		end
	end
	GAS:hook("PlayerCanPickupWeapon", "AdminSits.PlayerCanPickupWeapon", PlayerCanPickupWeapon)

	local function PlayerCanSeePlayersChat(txt, teamOnly, listener, speaker)
		if (GAS.AdminSits:IsInSit(listener) or GAS.AdminSits:IsInSit(speaker)) then
			if (teamOnly) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(ply)
				return false
			elseif (not GAS.AdminSits:IsInSitWith(listener, speaker)) then
				return false
			end
		end
	end
	GAS:hook("PlayerCanSeePlayersChat", "AdminSits.PlayerCanSeePlayersChat", PlayerCanSeePlayersChat)

	local function PlayerCanHearPlayersVoice(listener, speaker)
		if ((GAS.AdminSits:IsInSit(listener) or GAS.AdminSits:IsInSit(speaker)) and not GAS.AdminSits:IsInSitWith(listener, speaker)) then
			return false
		end
	end
	GAS:hook("PlayerCanHearPlayersVoice", "AdminSits.PlayerCanHearPlayersVoice", PlayerCanHearPlayersVoice)

	local function PlayerShouldTakeDamage(ply)
		if (GAS.AdminSits:IsInSit(ply)) then
			return false
		end
	end
	GAS:hook("PlayerShouldTakeDamage", "AdminSits.PlayerShouldTakeDamage", PlayerShouldTakeDamage)
else
	local function OnPlayerChat(ply)
		if (ply ~= LocalPlayer() and ((GAS.AdminSits:IsInSit(LocalPlayer()) or GAS.AdminSits:IsInSit(ply)) and not GAS.AdminSits:IsInSitWith(LocalPlayer(), ply))) then
			return true
		end
	end
	GAS:hook("OnPlayerChat", "AdminSits.OnPlayerChat", OnPlayerChat)
end

if (SERVER) then
	local function RespawnPlayerInSit(ply)
		if (GAS.AdminSits:IsInSit(ply)) then
			timer.Simple(0, function() ply:Spawn() end)
		end
	end
	GAS:hook("PostPlayerDeath", "AdminSits.RespawnPlayerInSit", RespawnPlayerInSit)

	local function ReturnToSit(ply)
		timer.Simple(0, function()
			timer.Simple(1, function()
				if (IsValid(ply)) then
					local Sit = GAS.AdminSits:GetPlayerSit(ply)
					if (Sit and not Sit.Ended) then
						GAS.AdminSits:TeleportPlayerToSit(ply, Sit)
					end
				end
			end)
		end)
	end
	GAS:hook("PlayerSpawn", "AdminSits.PlayerSpawn.ReturnToSit", ReturnToSit)
	GAS:hook("playerArrested", "AdminSits.playerArrested.ReturnToSit", ReturnToSit)

	local function playerUnArrested(ply)
		ply.GAS_AdminSits_Unarresting = true
		ReturnToSit(ply)
	end
	GAS:hook("playerUnArrested", "AdminSits.playerUnArrested.ReturnToSit", playerUnArrested)

	local function playerUnArrested_WeaponFix(ply)
		ply.GAS_AdminSits_Unarresting = nil
	end
	GAS:hook("PlayerSelectSpawn", "AdminSits.playerUnArrested.WeaponFix", playerUnArrested_WeaponFix)

	local function DisablePlayerChat(ply)
		if (ply:GetNWBool("GAS_AdminSits_ChatMuted")) then
			return ""
		end
	end
	GAS:hook("PlayerSay", "AdminSits.DisablePlayerChat", DisablePlayerChat)

	local function DisablePlayerVoice(_, ply)
		if (ply:GetNWBool("GAS_AdminSits_MicMuted")) then
			return false
		end
	end
	GAS:hook("PlayerCanHearPlayersVoice", "AdminSits.DisablePlayerVoice", DisablePlayerVoice)
end

do
	GAS:unhook("PhysgunPickup", "AdminSits.PhysgunPickup", PhysgunPickup)

	local PhysgunPickupHooks = hook.GetTable()["PhysgunPickup"]
	PhysgunPickupHooks = (PhysgunPickupHooks and #PhysgunPickupHooks > 0 and PhysgunPickupHooks) or nil

	if (PhysgunPickupHooks) then
		local Overriden_PhysgunPickup = {}
		for id,func in pairs(hook.GetTable()["PhysgunPickup"]) do -- dirty hack to force this behaviour
			Overriden_PhysgunPickup[id] = func
			hook.Remove("PhysgunPickup", id)
		end
	end

	local function PhysgunPickup(ply, ent)
		if (IsValid(ent) and ent:IsPlayer() and not GAS.AdminSits:IsInSitWith(ply, ent)) then
			return false
		end
	end
	GAS:hook("PhysgunPickup", "AdminSits.PhysgunPickup", PhysgunPickup)

	if (PhysgunPickupHooks) then
		for id,func in pairs(Overriden_PhysgunPickup) do
			hook.Add("PhysgunPickup", id, func)
		end
		Overriden_PhysgunPickup = nil
	end
end

local function PhysgunPickup_Disable(ply, ent)
	if (IsValid(ent) and GAS.AdminSits:IsInSit(ply) and not ent:IsPlayer()) then
		return false
	end
end
GAS:hook("PhysgunPickup", "AdminSits.PhysgunPickup.Disable", PhysgunPickup_Disable)

local function PickupDisable(ply, ent)
	if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
		return false
	end
end
GAS:hook("GravGunPickupAllowed", "AdminSits.GravGunPickupAllowed", PickupDisable)
GAS:hook("AllowPlayerPickup", "AdminSits.AllowPlayerPickup", PickupDisable)

if (SERVER) then do
	GAS:GMInitialize(function() GAS:InitPostEntity(function() if (DarkRP) then

		local blockedChatCommands = {["a"] = true, ["ooc"] = true, ["/"] = true, ["w"] = true, ["y"] = true, ["pm"] = true, ["me"] = true, ["broadcast"] = true, ["radio"] = true, ["g"] = true}
		local function canChatCommand(ply, cmd, args)
			if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply) and blockedChatCommands[cmd]) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(ply)
				return false
			end
		end
		GAS:hook("canChatCommand", "AdminSits.canChatCommand", canChatCommand)

		local function DarkRPActorNotAllowedInSit(target, actor)
			if (not GAS.AdminSits:IsStaff(actor) and (GAS.AdminSits:IsInSit(actor) or GAS.AdminSits:IsInSit(target))) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(actor)
				return false
			end
		end
		for _,hook_name in ipairs({
			"canRequestWarrant",
			"canRequestHit",
			"canWanted",
			"canUnwant",
		}) do
			GAS:hook(hook_name, "AdminSits.DarkRP." .. hook_name, DarkRPActorNotAllowedInSit)
		end

		local function DarkRPNotAllowedInSit(ply)
			if (GAS.AdminSits:IsInSit(ply) and not GAS.AdminSits:IsStaff(ply)) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(ply)
				return false
			end
		end
		for _,hook_name in ipairs({
			"CanChangeRPName",
			"canDemote",
			"canChangeJob",
			"playerCanChangeTeam",
			"canDarkRPUse",
			"canEditLaws",
			"canGoAFK",
			"canSleep",
			"canLockpick",
			"canAdvert",
			"canKeysLock",
			"canKeysUnlock",
			"canDoorRam",
			"canVote",
		}) do
			GAS:hook(hook_name, "AdminSits.DarkRP." .. hook_name, DarkRPNotAllowedInSit)
		end

		local function DarkRPNotAllowedInSit_StaffToo(ply)
			if (GAS.AdminSits:IsInSit(ply)) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(ply)
				return false
			end
		end
		for _,hook_name in ipairs({
			"canDropWeapon",
			"canDropPocketItem",
			"canPocket",
		}) do
			GAS:hook(hook_name, "AdminSits.DarkRP." .. hook_name, DarkRPNotAllowedInSit_StaffToo)
		end

		local function DarkRPCantBuy(ply)
			if (GAS.AdminSits:IsInSit(ply)) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(ply)
				return false, true
			end
		end
		for _,hook_name in ipairs({
			"canBuyAmmo",
			"canBuyCustomEntity",
			"canBuyPistol",
			"canBuyShipment",
			"canBuyVehicle",
		}) do
			GAS:hook(hook_name, "AdminSits.DarkRP." .. hook_name, DarkRPCantBuy)
		end

		local function canArrestOrUnarrest(actor, target)
			if (not GAS.AdminSits:IsStaff(actor) and (GAS.AdminSits:IsInSit(actor) or GAS.AdminSits:IsInSit(target))) then
				GAS:netStart("AdminSits.NotAllowedInSit")
				net.Send(actor)
				return false
			end
		end
		GAS:hook("canArrest", "AdminSits.DarkRP.canArrest", canArrestOrUnarrest)
		GAS:hook("canUnarrest", "AdminSits.DarkRP.canUnarrest", canArrestOrUnarrest)

		local function canChatSound(ply)
			if (GAS.AdminSits:IsInSit(ply)) then
				return false
			end
		end
		GAS:hook("canChatSound", "AdminSits.DarkRP.canChatSound", canChatSound)

	end end) end)
end end