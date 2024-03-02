if SERVER then
	for _, ent in ipairs(ents.GetAll()) do
		if ent:GetClass() == "bkeypads_fading_door_link" then
			ent:Remove()
		end
	end
end

if SERVER then util.AddNetworkString("bKeypads.FadingDoors.Fade") end

local L = bKeypads.L

bKeypads.FadingDoors = {}

cleanup.Register("_bkeypads_fading_doors")

hook.Add("canLockpick", "bKeypads.FadingDoors.canLockpick", function(ply, ent)
	if not bKeypads.Config.FadingDoors.Lockpick and IsValid(ent) and bKeypads.FadingDoors:IsFadingDoor(ent) then
		return false
	end
end)

function bKeypads.FadingDoors:IsFaded(fading_door)
	local controller = bKeypads.FadingDoors:GetController(fading_door)
	if IsValid(controller) then
		if controller:GetReversed() then
			return not fading_door.fadeActive
		else
			return fading_door.fadeActive
		end
	end
	return false
end

function bKeypads.FadingDoors:DoFade(fading_door)
	if not bKeypads.FadingDoors:IsFadingDoor(fading_door) then return end

	local controller = bKeypads.FadingDoors:GetController(fading_door)
	local config = controller:GetConfig()

	local shouldOpen = fading_door.fadeActive
	if config.Reversed then shouldOpen = not shouldOpen end

	if shouldOpen then

		if controller:GetRestoreData() then return end

		if controller.m_FadingDoorData.GetCustomCollisionCheck ~= nil then
			fading_door:SetCustomCollisionCheck(controller.m_FadingDoorData.GetCustomCollisionCheck)
			controller.m_FadingDoorData.GetCustomCollisionCheck = nil
		end
		controller.m_FadingDoorData.stuckPlys = nil
		if SERVER then timer.Remove(controller.StuckTickTimer) end

		controller:SaveRestoreData()

		fading_door:SetMaterial(config.FadeMaterial)
		fading_door:DrawShadow(false)
		fading_door:SetSolidFlags(FSOLID_CUSTOMRAYTEST)
		fading_door:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		local phys = fading_door:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		if SERVER and (not IsValid(fading_door:GetCreator()) or bKeypads.Permissions:Check(fading_door:GetCreator(), "fading_doors/sounds")) then
			if config.OpenSound then
				fading_door:EmitSound(config.OpenSound, 350, 100)
			end
			if config.ActiveSound then
				fading_door.FadeDoorSound = CreateSound(fading_door, config.ActiveSound)
				fading_door.FadeDoorSound:Play()
				fading_door.FadeDoorSound:ChangeVolume(.25)
			end
		end

	elseif SERVER then

		if not controller:GetRestoreData() then return end

		if bKeypads.Config.FadingDoors.KeepOpen then
			local stuckPlys = bKeypads.FadingDoors:GetStuckPlayers(fading_door)
			if #stuckPlys > 0 then
				local timerName = controller.StuckTickTimer
				if not timer.Exists(timerName) then
					timer.Create(timerName, engine.TickInterval() * bKeypads.Config.FadingDoors.TickIntervalMul, 0, function()
						if not IsValid(fading_door) or not IsValid(controller) or not bKeypads.FadingDoors:IsFadingDoor(fading_door) then
							timer.Remove(timerName)
							return
						end

						local doorMins, doorMaxs = fading_door:GetCollisionBounds()
						for i = #stuckPlys, 1, -1 do
							local ply = stuckPlys[i]
							if not IsValid(ply) or not bKeypads.FadingDoors:IsPlayerStuck(doorMins, doorMaxs, fading_door, ply) then
								table.remove(stuckPlys, i)
							end
						end

						if #stuckPlys == 0 then
							timer.Remove(timerName)

							if config.Reversed then
								fading_door:fadeActivate()
							else
								fading_door:fadeDeactivate()
							end
						end
					end)

					return
				end
			end
		end

		if not IsValid(fading_door:GetCreator()) or bKeypads.Permissions:Check(fading_door:GetCreator(), "fading_doors/sounds") then
			if config.CloseSound then
				fading_door:EmitSound(config.CloseSound, 350, 100)
			end
			if fading_door.FadeDoorSound then
				fading_door.FadeDoorSound:Stop()
				fading_door.FadeDoorSound = nil
			end
		end

		controller:Restore()

		--[[
		if SERVER and (not IsValid(fading_door:GetCreator()) or bKeypads.Permissions:Check(fading_door:GetCreator(), "fading_doors/sounds")) then
			if config.CloseSound then
				fading_door:EmitSound(config.CloseSound, 350, 100)
			end
			if fading_door.FadeDoorSound then
				fading_door.FadeDoorSound:Stop()
				fading_door.FadeDoorSound = nil
			end
		end

		if bKeypads.FadingDoors.PickedUp[fading_door] then
			bKeypads.FadingDoors.PickedUp[fading_door] = nil
		end

		controller:Restore()

		local stuckPlys = bKeypads.FadingDoors:GetStuckPlayers(fading_door)
		if #stuckPlys > 0 then
			controller.m_FadingDoorData.stuckPlys = stuckPlys
			controller.m_FadingDoorData.stuckPlysDict = {}

			controller.m_FadingDoorData.GetCustomCollisionCheck = fading_door:GetCustomCollisionCheck()
			fading_door:SetCustomCollisionCheck(true)

			if SERVER then
				net.Start("bKeypads.FadingDoors.StuckPlayers")
					net.WriteEntity(fading_door)
					for _, stuckPly in ipairs(stuckPlys) do
						controller.m_FadingDoorData.stuckPlysDict[stuckPly] = true

						net.WriteBool(true)
						net.WriteEntity(stuckPly)
					end
					net.WriteBool(false)
				net.Broadcast()

				local timerName = controller.StuckTickTimer
				timer.Create(controller.StuckTickTimer, engine.TickInterval() * 8, 0, function()
					if not IsValid(fading_door) or not IsValid(controller) or not bKeypads.FadingDoors:IsFadingDoor(fading_door) or not controller.m_FadingDoorData.stuckPlys then
						timer.Remove(timerName)
						return
					end

					local stuckPlys = bKeypads.FadingDoors:GetStuckPlayers(fading_door, controller.m_FadingDoorData.stuckPlys)
					if #stuckPlys == 0 then

						controller.m_FadingDoorData.stuckPlys = nil
						controller.m_FadingDoorData.stuckPlysDict = nil

						net.Start("bKeypads.FadingDoors.StuckPlayers")
							net.WriteEntity(fading_door)
							net.WriteBool(false)
						net.Broadcast()

					elseif #stuckPlys ~= #controller.m_FadingDoorData.stuckPlys then

						controller.m_FadingDoorData.stuckPlys = stuckPlys
						controller.m_FadingDoorData.stuckPlysDict = {}

						net.Start("bKeypads.FadingDoors.StuckPlayers")
							net.WriteEntity(fading_door)
							for _, stuckPly in ipairs(stuckPlys) do
								controller.m_FadingDoorData.stuckPlysDict[stuckPly] = true

								net.WriteBool(true)
								net.WriteEntity(stuckPly)
							end
							net.WriteBool(false)
						net.Broadcast()

					end
				end)
			end
		end
		]]
	end

	if CLIENT and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" then
		bKeypads.ESP:Refresh()
	end
end

do
	if SERVER then
		function bKeypads.FadingDoors:IsPlayerStuck(doorMins, doorMaxs, fading_door, ply)
			local plyPosRel = fading_door:WorldToLocal(ply:GetPos())

			local plyMins, plyMaxs = ply:GetCollisionBounds()
			plyMins:Mul(1.5) plyMaxs:Mul(1.5)
			plyMins:Add(plyPosRel) plyMaxs:Add(plyPosRel)

			return (doorMins[1] <= plyMaxs[1] and doorMaxs[1] >= plyMins[1])
			   and (doorMins[2] <= plyMaxs[2] and doorMaxs[2] >= plyMins[2])
			   and (doorMins[3] <= plyMaxs[3] and doorMaxs[3] >= plyMins[3])
		end

		function bKeypads.FadingDoors:GetStuckPlayers(fading_door)
			local stuckPlys = {}

			local doorMins, doorMaxs = fading_door:GetCollisionBounds()
			for _, ply in ipairs(player.GetAll()) do
				if bKeypads.FadingDoors:IsPlayerStuck(doorMins, doorMaxs, fading_door, ply) then
					table.insert(stuckPlys, ply)
				end
			end

			return stuckPlys
		end
	end

	-- FIXME https://github.com/Facepunch/garrysmod-issues/issues/642
	--[[local stuckTrOutput = {}
	local stuckTrData = {
		collisiongroup = COLLISION_GROUP_PLAYER,
		ignoreworld = true,
		output = stuckTrOutput
	}
	function bKeypads.FadingDoors:GetStuckPlayers(fading_door, checkPlys)
		fading_door:CollisionRulesChanged()

		local stuckPlys = {}
		local m_stuckPlys = checkPlys
		if not m_stuckPlys then
			local boxMins, boxMaxs = fading_door:GetCollisionBounds()
			boxMins, boxMaxs = fading_door:LocalToWorld(boxMins), fading_door:LocalToWorld(boxMaxs)
			m_stuckPlys = ents.FindInBox(boxMins, boxMaxs)
		end
		for _, ent in ipairs(m_stuckPlys) do
			local ply
			if ent:IsPlayer() then
				ply = ent
			elseif CLIENT and ent:IsWeapon() then
				-- Issue #4480
				local prnt = ent:GetParent()
				if prnt == LocalPlayer() then
					ply = prnt
				end
			end
			if IsValid(ply) then
				local mins, maxs = ply:GetCollisionBounds()
				local filter = { ply }
				stuckTrData.start = ply:GetPos()
				stuckTrData.endpos = ply:GetPos()
				stuckTrData.mins = mins
				stuckTrData.maxs = maxs
				stuckTrData.filter = filter
				while true do
					util.TraceHull(stuckTrData)
					if not stuckTrOutput.Hit or not IsValid(stuckTrOutput.Entity) then break end
					if stuckTrOutput.Entity == fading_door then
						table.insert(stuckPlys, ply)
						ply:CollisionRulesChanged()
						break
					end
					table.insert(filter, stuckTrOutput.Entity)
				end
			end
		end
		return stuckPlys
	end

	if SERVER then
		util.AddNetworkString("bKeypads.FadingDoors.StuckPlayers")
	else
		net.Receive("bKeypads.FadingDoors.StuckPlayers", function()
			local fading_door = net.ReadEntity()
			if not IsValid(fading_door) or not bKeypads.FadingDoors:IsFadingDoor(fading_door) then return end

			local controller = bKeypads.FadingDoors:GetController(fading_door)
			controller.m_FadingDoorData.stuckPlys = {}
			controller.m_FadingDoorData.stuckPlysDict = {}
			while net.ReadBool() do
				local ply = net.ReadEntity()
				table.insert(controller.m_FadingDoorData.stuckPlys, ply)
				controller.m_FadingDoorData.stuckPlysDict[ply] = true
			end
			if #controller.m_FadingDoorData.stuckPlys == 0 then
				controller.m_FadingDoorData.stuckPlys = nil
				controller.m_FadingDoorData.stuckPlysDict = nil
			end
		end)
	end
	hook.Add("ShouldCollide", "bKeypads.FadingDoors.StuckPlayers", function(ent1, ent2)
		local fading_door, ply
		if bKeypads.FadingDoors:IsFadingDoor(ent1) then
			fading_door = ent1
			ply = ent2
		elseif bKeypads.FadingDoors:IsFadingDoor(ent2) then
			fading_door = ent2
			ply = ent1
		end
		if not fading_door or not ply then return end

		local controller = bKeypads.FadingDoors:GetController(fading_door)
		if not controller or not controller.m_FadingDoorData.stuckPlysDict or not controller.m_FadingDoorData.stuckPlysDict[ply] then return end

		return false
	end)]]
end

function bKeypads.FadingDoors:CanFadingDoor(ent)
	return IsValid(ent) and ent:GetClass():lower():StartWith("prop_") and not ent:IsVehicle() and not bKeypads.MapLinking:IsDoor(ent)
end

function bKeypads.FadingDoors:GetController(fading_door)
	if IsValid(fading_door) and IsValid(fading_door.bKeypads_FadingDoor) then
		local controller = fading_door.bKeypads_FadingDoor
		if controller:GetParent() ~= fading_door then
			controller:ParentTo(fading_door) -- prevents weird error probably caused by NetworkVar being shit
		end
		return controller
	end
end

function bKeypads.FadingDoors:IsFadingDoor(ent)
	return IsValid(ent) and bKeypads.FadingDoors:GetController(ent) ~= nil
end

function bKeypads.FadingDoors:GetConfig(fading_door)
	return bKeypads.FadingDoors:IsFadingDoor(fading_door) and bKeypads.FadingDoors:GetController(fading_door):GetConfig()
end

if SERVER then
	function bKeypads.FadingDoors:Create(ply, ent, toggle, reversed, mat, opensound, activesound, closesound, key)
		if IsValid(ply) and not bKeypads.Permissions:Check(ply, "fading_doors/create") then return end

		if not list.Contains("bKeypads_FDoorMaterials", mat) then return end

		local opensound = bKeypads.Config.FadingDoors.EnableSounds and opensound ~= "" and opensound ~= 0 and list.Contains("bKeypads_FDoorSounds", opensound) and opensound or ""
		local activesound = bKeypads.Config.FadingDoors.EnableSounds and activesound ~= "" and activesound ~= 0 and list.Contains("bKeypads_FDoorLoopSounds", activesound) and activesound or ""
		local closesound = bKeypads.Config.FadingDoors.EnableSounds and closesound ~= "" and closesound ~= 0 and list.Contains("bKeypads_FDoorSounds", closesound) and closesound or ""

		local controller = bKeypads.FadingDoors:GetController(ent)
		if controller then
			ent:fadeCancel()
		else
			controller = ents.Create("bkeypads_fading_door")
			controller:SetCreator(ply)
			controller:ParentTo(ent)
			controller:Spawn()

			bKeypads_FadingDoors_Registry[ent] = controller

			if IsValid(ply) then
				ply:AddCount("_bkeypads_fading_doors", controller)
				ply:AddCleanup("_bkeypads_fading_doors", controller)

				undo.Create("bKeypads_FadingDoor")
					undo.AddEntity(controller)
					undo.SetPlayer(ply)
				undo.Finish()
			end
		end

		controller:SetToggle(toggle)
		controller:SetReversed(bKeypads.Config.FadingDoors.Reversible and reversed)
		controller:SetFadeMaterial(mat)
		if (not IsValid(ply) or bKeypads.Permissions:Check(ply, "fading_doors/keyboard")) and key > 0 then
			controller:SetKeyboardButton(key)
		end
		if not IsValid(ply) or bKeypads.Permissions:Check(ply, "fading_doors/sounds") then
			controller:SetOpenSound(opensound)
			controller:SetActiveSound(activesound)
			controller:SetCloseSound(closesound)
		end

		if controller.m_FadingDoorData.GetCustomCollisionCheck then
			bKeypads.FadingDoors:SetCustomCollisionCheck(controller.m_FadingDoorData.GetCustomCollisionCheck)
		end
		bKeypads.FadingDoors:DoFade(ent)
	end
	duplicator.RegisterEntityModifier("bKeypads.FadingDoor", function(ply, ent, data)
		bKeypads.FadingDoors:Create(ply, ent, data.Toggle, data.Reversed, data.FadeMaterial, data.OpenSound, data.ActiveSound, data.CloseSound, data.KeyboardButton)
	end)

	function bKeypads.FadingDoors:Remove(ent)
		local controller = bKeypads.FadingDoors:GetController(ent)
		if IsValid(controller) then
			controller:Remove()
		end
	end
else
	net.Receive("bKeypads.FadingDoors.Fade", function()
		local ent = net.ReadEntity()
		ent.fadeActive = net.ReadBool()
		bKeypads.FadingDoors:DoFade(ent)
	end)
end

--## Linking ##--

bKeypads.FadingDoors.Links = {}
bKeypads.FadingDoors.LinkEnts = {}

function bKeypads.FadingDoors:GetLinks(keypad_or_fading_door)
	return bKeypads.FadingDoors.Links[keypad_or_fading_door] or bKeypads.FadingDoors.Links[keypad_or_fading_door] or nil
end

function bKeypads.FadingDoors:IsLinked(keypad, fading_door)
	return IsValid(keypad) and IsValid(fading_door) and bKeypads.FadingDoors.Links[fading_door] and bKeypads.FadingDoors.Links[fading_door][keypad] and next(bKeypads.FadingDoors.Links[fading_door][keypad]) ~= nil
end

function bKeypads.FadingDoors:RegisterLink(link, keypad, fading_door, accessType)
	bKeypads.FadingDoors.Links[keypad] = bKeypads.FadingDoors.Links[keypad] or {}
	bKeypads.FadingDoors.Links[keypad][fading_door] = bKeypads.FadingDoors.Links[keypad][fading_door] or {}
	bKeypads.FadingDoors.Links[keypad][fading_door][accessType] = link

	bKeypads.FadingDoors.Links[fading_door] = bKeypads.FadingDoors.Links[fading_door] or {}
	bKeypads.FadingDoors.Links[fading_door][keypad] = bKeypads.FadingDoors.Links[fading_door][keypad] or {}
	bKeypads.FadingDoors.Links[fading_door][keypad][accessType] = link
end

function bKeypads.FadingDoors:DeregisterLink(keypad, fading_door, accessType)
	if bKeypads.FadingDoors.Links[fading_door] and bKeypads.FadingDoors.Links[fading_door][keypad] and bKeypads.FadingDoors.Links[fading_door][keypad][accessType] then
		bKeypads.FadingDoors.Links[fading_door][keypad] = nil
		if table.IsEmpty(bKeypads.FadingDoors.Links[fading_door]) then
			bKeypads.FadingDoors.Links[fading_door] = nil
		end
	end
	if bKeypads.FadingDoors.Links[keypad] and bKeypads.FadingDoors.Links[keypad][fading_door] and bKeypads.FadingDoors.Links[keypad][fading_door][accessType] then
		bKeypads.FadingDoors.Links[keypad][fading_door] = nil
		if table.IsEmpty(bKeypads.FadingDoors.Links[keypad]) then
			bKeypads.FadingDoors.Links[keypad] = nil
		end
	end
end

if SERVER then
	function bKeypads.FadingDoors:Link(keypad, fading_door, accessType, ply)
		if not IsValid(fading_door) or not IsValid(keypad) then return end

		bKeypads.FadingDoors:Unlink(keypad, fading_door)

		local link = ents.Create("bkeypads_fading_door_link")
		link:SetKeypad(keypad)
		link:SetLinkedEnt(fading_door)
		link:SetAccessType(accessType)

		bKeypads.FadingDoors:RegisterLink(link, keypad, fading_door, accessType)

		keypad:RefreshCanKeypadCrack()

		if SERVER then
			if IsValid(ply) then
				undo.Create("bKeypads_FadingDoor_Link")
					undo.SetPlayer(ply)
					undo.AddEntity(link)
				undo.Finish()

				hook.Run("bKeypads.Link.FadingDoor", ply, keypad, fading_door, accessType)
			end
		else
			bKeypads.ESP:Refresh()
		end
	end

	function bKeypads.FadingDoors:Unlink(keypad, fading_door, ply)
		local link = bKeypads.FadingDoors.Links[keypad] and bKeypads.FadingDoors.Links[keypad][fading_door] and (bKeypads.FadingDoors.Links[keypad][fading_door][true] or bKeypads.FadingDoors.Links[keypad][fading_door][false])
		if IsValid(link) then
			if IsValid(link:GetLinkedEnt()) then
				link:GetLinkedEnt():fadeCancel()
			end

			if IsValid(ply) and IsValid(keypad) and IsValid(fading_door) then
				hook.Run("bKeypads.Unlink.FadingDoor", ply, keypad, fading_door, link:GetAccessType())
			end

			link:Remove()
		end
	end
end

function bKeypads.FadingDoors:BuildLinksTable()
	bKeypads.FadingDoors.RebuildLinkTable = nil

	bKeypads.FadingDoors.Links = {}

	for link in pairs(bKeypads.FadingDoors.LinkEnts) do
		if not IsValid(link) then
			bKeypads.FadingDoors.LinkEnts[link] = nil
			continue
		end

		local keypad, fading_door, accessType = link:GetKeypad(), link:GetLinkedEnt(), link:GetAccessType()
		if IsValid(fading_door) and IsValid(keypad) then
			bKeypads.FadingDoors:RegisterLink(link, keypad, fading_door, accessType)
		end
	end

	if CLIENT then bKeypads.ESP:Refresh() end
end

--## STOOL ##--

bKeypads.FadingDoors.STOOL = {}

function bKeypads.FadingDoors.STOOL.Reset(self)
	self:SetOperation(0)
	self:SetStage(0)
end

function bKeypads.FadingDoors.STOOL.LeftClick(self, tr)
	if (
		not IsValid(self:GetOwner()) or
		not bKeypads.FadingDoors:CanFadingDoor(tr.Entity) or
		not bKeypads.Permissions:Check(self:GetOwner(), "fading_doors/create")
	) then return false end

	if not bKeypads.STOOL:CheckLimit(self:GetOwner(), bKeypads.STOOL.LIMIT_FADING_DOORS) then return true end

	-- Create/Update fading door
	if not tr.Entity.bKeypad then
		if not list.Contains("bKeypads_FDoorMaterials", self:GetClientInfo("mat")) then return false end

		if SERVER then
			bKeypads.FadingDoors:Create(
				self:GetOwner(),
				tr.Entity,
				self:GetClientNumber("toggle") == 1,
				self:GetClientNumber("reversed") == 1,
				self:GetClientInfo("mat"),
				self:GetClientInfo("opensound"),
				self:GetClientInfo("activesound"),
				self:GetClientInfo("closesound"),
				self:GetClientNumber("key")
			)
		elseif IsFirstTimePredicted() then
			if bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then
				notification.AddLegacy(L"FadingDoorUpdated", NOTIFY_UNDO, 4)
				surface.PlaySound("buttons/button5.wav")
			else
				notification.AddLegacy(L"FadingDoorCreated", NOTIFY_GENERIC, 2)
				surface.PlaySound("buttons/button5.wav")
			end
		end

		return true
	end

	return false
end

local copyDictionary = {
	["Toggle"] = "toggle",
	["Reversed"] = "reversed",
	["FadeMaterial"] = "mat",
	["ActiveSound"] = "activesound",
	["OpenSound"] = "opensound",
	["CloseSound"] = "closesound",
	["KeyboardButton"] = "key",
}
function bKeypads.FadingDoors.STOOL.RightClick(self, tr)
	if (
		not IsValid(self:GetOwner()) or
		not bKeypads.FadingDoors:IsFadingDoor(tr.Entity) or
		not bKeypads.Permissions:Check(self:GetOwner(), "fading_doors/create")
	) then return false end

	if CLIENT and IsFirstTimePredicted() then
		local config = bKeypads.FadingDoors:GetConfig(tr.Entity)
		for option, cvar in pairs(copyDictionary) do
			local ConVar = GetConVar("bkeypads_fading_door_" .. cvar)
			local val = config[option]
			if val ~= nil then
				if isbool(val) then
					ConVar:SetBool(val)
				elseif isnumber(val) then
					if val % 0 == 0 then
						ConVar:SetInt(val)
					else
						ConVar:SetFloat(val)
					end
				else
					ConVar:SetString(val)
				end
			end
		end

		notification.AddLegacy(L"FadingDoorSettingsCopied", NOTIFY_GENERIC, 2)
		surface.PlaySound("buttons/button5.wav")
	end

	return true
end

function bKeypads.FadingDoors.STOOL.Reload(self, tr)
	if not bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then return end

	if SERVER then
		bKeypads.FadingDoors:Remove(tr.Entity)
	elseif IsFirstTimePredicted() then
		notification.AddLegacy(L"FadingDoorRemoved", NOTIFY_ERROR, 2)
		surface.PlaySound("buttons/button6.wav")
	end

	return true
end

if CLIENT then
	local function HelpCategory_OnToggle(self)
		if not self:GetExpanded() then
			cookie.Set("bkeypads_fading_doors_help_viewed", 1)
		end
	end

	function bKeypads.FadingDoors.STOOL.BuildCPanel(CPanel)
		bKeypads:InjectSmoothScroll(CPanel)
		bKeypads:STOOLMatrix(CPanel)

		local KeypadOnlyFadingDoor = bKeypads:AddHelp(CPanel, L"KeypadOnlyFadingDoor")
		KeypadOnlyFadingDoor:DockMargin(0, 0, 0, 0)

		local FadingDoorLinkTip = bKeypads:AddHelp(CPanel, L"FadingDoorLinkTip")
		FadingDoorLinkTip:DockMargin(0, 0, 0, 0)

		CPanel.HelpCategory = vgui.Create("DForm", CPanel)
		CPanel.HelpCategory:SetLabel(L"Help")
		CPanel.HelpCategory:SetExpanded(cookie.GetNumber("bkeypads_fading_doors_help_viewed", 0) == 0)
		CPanel.HelpCategory.OnToggle = HelpCategory_OnToggle

			CPanel.Video = vgui.Create("bKeypads.DockedImage", CPanel.HelpCategory)
			CPanel.Video:SetMaterial(Material("bkeypads/fading_door_animation"))
			CPanel.Video:SetAspectRatio(330 / 512)
			CPanel.HelpCategory:AddItem(CPanel.Video)

			CPanel.HelpCategory:Help(L"FadingDoorHelp"):DockMargin(0, 0, 0, 0)

			CPanel.Tutorial = vgui.Create("DButton", CPanel)
			CPanel.Tutorial:SetText(L"Tutorial")
			CPanel.Tutorial:SetIcon("icon16/emoticon_grin.png")
			CPanel.Tutorial:SetTall(25)
			CPanel.Tutorial.DoClick = function()
				bKeypads.Tutorial:OpenMenu()
			end
			CPanel.HelpCategory:AddItem(CPanel.Tutorial)

		CPanel:AddItem(CPanel.HelpCategory)

		CPanel.ConfigCategory = vgui.Create("ControlPanel", CPanel)
		CPanel.ConfigCategory:SetLabel(L"Configuration")

			local OpenButtonLabel = CPanel.ConfigCategory:Help(L"FadingDoorKey")
			OpenButtonLabel:DockMargin(0, 0, 0, 0)
			OpenButtonLabel:SetContentAlignment(5)
			OpenButtonLabel:SetWrap(false)

			local OpenButton = vgui.Create("DBinder", CPanel)
			OpenButton:SetConVar("bkeypads_fading_door_key")
			OpenButton.bKeypads_Tooltip = L"FadingDoorKeyTip" .. "\n" .. L"FadingDoorLinkTip" .. "\n" .. L"DBinderTip"
			CPanel.ConfigCategory:AddItem(OpenButton)

			local Reversed = CPanel.ConfigCategory:CheckBox(L"Reversed", "bkeypads_fading_door_reversed")
			CPanel.ConfigCategory:CheckBox(L"ToggleActive", "bkeypads_fading_door_toggle")

			if bKeypads.Config.FadingDoors.EnableSounds then
				local SoundPreviewID = 0
				local ActiveSound
				local function PlaySoundOverride(self, ...)
					self:_OnCursorEntered(...)

					if IsValid(ActiveSound) then
						ActiveSound:Stop()
						ActiveSound = nil
					end

					if self.Data ~= "" then
						SoundPreviewID = SoundPreviewID + 1

						local myID = SoundPreviewID

						sound.PlayFile("sound/" .. self:GetValue(), "noplay", function(station, errCode, errStr)
							if myID == SoundPreviewID and IsValid(station) then
								station:Play()
								ActiveSound = station
							end
						end)
					end
				end
				local function StopSoundOverride(self, ...)
					self:_OnCursorExited(self, ...)

					if IsValid(ActiveSound) then
						ActiveSound:Stop()
						ActiveSound = nil
					end
				end
				local function StopSoundSelectedOverride(self, ...)
					if IsValid(ActiveSound) then
						ActiveSound:Stop()
						ActiveSound = nil
					end

					return self:_OnSelect(...)
				end
				local function SoundPreviewOverride(self, ...)
					self:_OpenMenu(...)

					if IsValid(self.Menu) then
						for k, option in ipairs(self.Menu:GetCanvas():GetChildren()) do
							option._OnCursorEntered = option.OnCursorEntered
							option.OnCursorEntered = PlaySoundOverride

							option._OnCursorExited = option.OnCursorExited
							option.OnCursorExited = StopSoundOverride

							option.Data = self:GetOptionData(k)
						end
					end
				end

				local OpenSound = CPanel.ConfigCategory:ComboBox(L"OpenSound", "bkeypads_fading_door_opensound")
				OpenSound:Dock(TOP)
				OpenSound:SetTall(25)
				OpenSound:SetSortItems(false)
				OpenSound:AddChoice(L"None", "", false, "icon16/cross.png")

				local CloseSound = CPanel.ConfigCategory:ComboBox(L"CloseSound", "bkeypads_fading_door_closesound")
				CloseSound:Dock(TOP)
				CloseSound:SetTall(25)
				CloseSound:SetSortItems(false)
				CloseSound:AddChoice(L"None", "", false, "icon16/cross.png")

				for _, snd in ipairs(list.Get("bKeypads_FDoorSounds")) do
					OpenSound:AddChoice(snd)
					CloseSound:AddChoice(snd)
				end

				local ActiveSound = CPanel.ConfigCategory:ComboBox(L"ActiveSound", "bkeypads_fading_door_activesound")
				ActiveSound:Dock(TOP)
				ActiveSound:SetTall(25)
				ActiveSound:SetSortItems(false)
				ActiveSound:AddChoice(L"None", "", false, "icon16/cross.png")
				for _, snd in ipairs(list.Get("bKeypads_FDoorLoopSounds")) do
					ActiveSound:AddChoice(snd)
				end

				OpenSound._OpenMenu = OpenSound.OpenMenu
				CloseSound._OpenMenu = CloseSound.OpenMenu
				ActiveSound._OpenMenu = ActiveSound.OpenMenu
				OpenSound.OpenMenu = SoundPreviewOverride
				CloseSound.OpenMenu = SoundPreviewOverride
				ActiveSound.OpenMenu = SoundPreviewOverride

				OpenSound._OnSelect = OpenSound.OnSelect
				CloseSound._OnSelect = CloseSound.OnSelect
				ActiveSound._OnSelect = ActiveSound.OnSelect
				OpenSound.OnSelect = StopSoundSelectedOverride
				CloseSound.OnSelect = StopSoundSelectedOverride
				ActiveSound.OnSelect = StopSoundSelectedOverride

				ActiveSound._Think = ActiveSound.Think
				ActiveSound.Think = function()
					if ActiveSound._Think then ActiveSound:_Think() end

					local has_permission = bKeypads.Permissions:Cached(LocalPlayer(), "fading_doors/sounds")
					OpenSound:SetDisabled(not has_permission)
					CloseSound:SetDisabled(not has_permission)
					ActiveSound:SetDisabled(not has_permission)

					local canKeyboardPress = bKeypads.Config.FadingDoors.EnableKeyboardPress and bKeypads.Permissions:Cached(LocalPlayer(), "fading_doors/keyboard")
					if canKeyboardPress ~= OpenButtonLabel:IsVisible() then
						OpenButtonLabel:SetVisible(canKeyboardPress)
						OpenButtonLabel:InvalidateParent()
					end
					if canKeyboardPress ~= OpenButton:IsVisible() then
						OpenButton:SetVisible(canKeyboardPress)
						OpenButton:InvalidateParent()
					end
					if canKeyboardPress == KeypadOnlyFadingDoor:IsVisible() then
						KeypadOnlyFadingDoor:SetVisible(not canKeyboardPress)
						KeypadOnlyFadingDoor:InvalidateParent()
					end

					if bKeypads.Config.FadingDoors.Reversible ~= Reversed:IsVisible() then
						Reversed:SetVisible(bKeypads.Config.FadingDoors.Reversible)
						Reversed:InvalidateParent()
					end
				end
			end

			CPanel.ConfigCategory:MatSelect("bkeypads_fading_door_mat", list.Get("bKeypads_FDoorMaterials"), true, 0.33, 0.33)

		CPanel:AddItem(CPanel.ConfigCategory)

		hook.Run("bKeypads.BuildCPanel", CPanel)
	end
end

if SERVER and bKeypads_FadingDoors_Registry then
	for _, controller in pairs(bKeypads_FadingDoors_Registry) do
		if IsValid(controller) then
			controller:Remove()
		end
	end
end
bKeypads_FadingDoors_Registry = {}

do
	bKeypads.FadingDoors.PickedUp = {}
	function bKeypads.FadingDoors:AllowPickup(ply, fadingDoor, pickup)
		if not IsValid(ply) or not IsValid(fadingDoor) then return end
		if pickup then
			if bKeypads.FadingDoors:IsFaded(fadingDoor) and (not bKeypads.FadingDoors.PickedUp[fadingDoor] or not bKeypads.FadingDoors.PickedUp[fadingDoor][ply]) then
				local canPickup = hook.Run("PhysgunPickup", ply, fadingDoor)
				if canPickup then
					fadingDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)

					bKeypads.FadingDoors.PickedUp[fadingDoor] = bKeypads.FadingDoors.PickedUp[fadingDoor] or {}
					bKeypads.FadingDoors.PickedUp[fadingDoor][ply] = true

					if CLIENT then
						net.Start("bKeypads.FadingDoors.Pickup")
							net.WriteEntity(fadingDoor)
						net.SendToServer()
					end
				end
			end
		else
			if bKeypads.FadingDoors.PickedUp[fadingDoor] and bKeypads.FadingDoors.PickedUp[fadingDoor][ply] then
				bKeypads.FadingDoors.PickedUp[fadingDoor][ply] = nil

				if table.IsEmpty(bKeypads.FadingDoors.PickedUp[fadingDoor]) then
					if bKeypads.FadingDoors:IsFaded(fadingDoor) then
						fadingDoor:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
						local phys = fadingDoor:GetPhysicsObject()
						if IsValid(phys) then
							phys:EnableMotion(false)
						end
					end
					bKeypads.FadingDoors.PickedUp[fadingDoor] = nil
				end
			end
		end
	end

	function bKeypads.FadingDoors:TraceActiveFadingDoor(ply)
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "weapon_physgun" and CurTime() >= (wep:GetNextPrimaryFire() or 0) then
			local tr = ply:GetEyeTrace()
			local rayEnts = ents.FindAlongRay(ply:EyePos(), ply:EyePos() + ply:EyeAngles():Forward() * 16384)
			for _, ent in ipairs(rayEnts) do
				if ent == ply or (IsValid(ent:GetParent()) and ent:GetParent() == ply) then
					continue
				end
				if bKeypads.FadingDoors:IsFadingDoor(ent) and bKeypads.FadingDoors:IsFaded(ent) and tr.HitPos:DistToSqr(tr.StartPos) >= ent:NearestPoint(tr.StartPos):DistToSqr(tr.StartPos) then
					return ent
				end
				break
			end
		end
	end

	hook.Add("OnPhysgunFreeze", "bKeypads.FadingDoors.CancelFade", function(wep, phys, ent, ply)
		if bKeypads.FadingDoors:IsFadingDoor(ent) and bKeypads.FadingDoors:IsFaded(ent) and bKeypads.FadingDoors.PickedUp[ent] and bKeypads.FadingDoors.PickedUp[ent][ply] and bKeypads.Permissions:Check(ply, "fading_doors/freeze_cancel") then
			ent.fadeActive = ent.fadeReversed
			bKeypads.FadingDoors:DoFade(ent)
		end
	end)

	hook.Add("PhysgunDrop", "bKeypads.FadingDoors.Drop", function(ply, ent)
		if IsValid(ent) and bKeypads.FadingDoors:IsFadingDoor(ent) then
			bKeypads.FadingDoors:AllowPickup(ply, ent, false)
		end
	end)

	if SERVER then
		util.AddNetworkString("bKeypads.FadingDoors.Pickup")
		net.Receive("bKeypads.FadingDoors.Pickup", function(_, ply)
			local ent = net.ReadEntity()
			if IsValid(ent) and bKeypads.FadingDoors:IsFadingDoor(ent) and ent == bKeypads.FadingDoors:TraceActiveFadingDoor(ply) then
				bKeypads.FadingDoors:AllowPickup(ply, ent, true)
			end
		end)
	else
		hook.Add("FinishMove", "bKeypads.FadingDoors.AllowPickup", function(mv)
			if mv:KeyDown(IN_ATTACK) then
				local wep = LocalPlayer():GetActiveWeapon()
				if IsValid(wep) and wep:GetClass() == "weapon_physgun" and CurTime() >= (wep:GetNextPrimaryFire() or 0) then
					local fadingDoor = bKeypads.FadingDoors:TraceActiveFadingDoor(LocalPlayer())
					if IsValid(fadingDoor) then
						bKeypads.FadingDoors:AllowPickup(LocalPlayer(), fadingDoor, true)
					end
					return
				end
			end
			if not table.IsEmpty(bKeypads.FadingDoors.PickedUp) then
				bKeypads.FadingDoors.PickedUp = {}
			end
		end)
	end
end