if SERVER then
	for _, ent in ipairs(ents.GetAll()) do
		if ent:GetClass() == "bkeypads_map_link" then
			ent:Remove()
		end
	end
end

bKeypads.MapLinking = {}

bKeypads.MapLinking.Links = {}
bKeypads.MapLinking.LinkEnts = {}

bKeypads.MapLinking.F_PSEUDOLINK = 2^0
bKeypads.MapLinking.F_DISABLE_ENT = 2^1
bKeypads.MapLinking.F_REDIRECT_USE = 2^2

bKeypads.MapLinking.F_BUTTON_HIDE = 2^0
bKeypads.MapLinking.F_BUTTON_TOGGLE = 2^1
bKeypads.MapLinking.F_BUTTON_DOUBLE_TOGGLE = 2^2
bKeypads.MapLinking.F_BUTTON_HOLD = 2^3

bKeypads.MapLinking.F_DOOR_NOLOCKPICK = 2^0
bKeypads.MapLinking.F_DOOR_TOGGLE = 2^1
bKeypads.MapLinking.F_DOOR_LOCK = 2^2

function bKeypads.MapLinking:GetRootDoor(ent)
	local prnt = ent:GetParent()
	if IsValid(prnt) and bKeypads.MapLinking:IsDoor(prnt) then
		return bKeypads.MapLinking:GetRootDoor(prnt)
	else
		return ent
	end
end

do
	local DoorDarkRPMode = DarkRP and FindMetaTable("Entity").isDoor ~= nil or false
	local doorEntities = {
		["func_door"] = true,
		["func_door_rotating"] = true,
		["prop_door_rotating"] = true,
		["func_movelinear"] = true,
		["prop_dynamic"] = true
	}
	function bKeypads.MapLinking:IsDoor(door)
		if not bKeypads.Config.MapLinking.Doors then return false end
		if door:GetNWBool("bKeypads.IsDoor") then return true end
		if DoorDarkRPMode then
			return door:isDoor() or doorEntities[door:GetClass()] or false
		else
			return doorEntities[door:GetClass()] or false
		end
	end

	hook.Add("canLockpick", "bKeypads.MapLinking.canLockpick", function(ply, ent)
		if IsValid(ent) and bKeypads.MapLinking:IsDoor(ent) then
			local links = bKeypads.MapLinking:GetLinks(ent)
			if links then
				for keypad, linkData in pairs(links) do
					if not IsValid(keypad) then continue end

					local link = select(2, next(linkData))
					if not IsValid(link) then continue end

					if link:HasGeneralFlag(bKeypads.MapLinking.F_DISABLE_ENT) or link:HasDoorFlag(bKeypads.MapLinking.F_DOOR_NOLOCKPICK) then
						return false
					end
				end
			end
		end
	end)

	function bKeypads.MapLinking:IsSandboxButton(btn)
		return btn:GetClass() == "gmod_button"
	end

	local btnEntities = {
		["func_button"] = true,
		["func_rot_button"] = true
	}
	function bKeypads.MapLinking:IsMapButton(btn)
		if not bKeypads.Config.MapLinking.Buttons then return false end
		if btn:GetNWBool("bKeypads.IsButton") then return true end
		return btnEntities[btn:GetClass()]
	end

	function bKeypads.MapLinking:IsButton(btn)
		return bKeypads.MapLinking:IsMapButton(btn) or bKeypads.MapLinking:IsSandboxButton(btn)
	end

	function bKeypads.MapLinking:IsLinkEntity(ent)
		return bKeypads.MapLinking:IsDoor(ent) or bKeypads.MapLinking:IsButton(ent)
	end
end

function bKeypads.MapLinking:GetLinks(keypad_or_ent)
	return bKeypads.MapLinking.Links[keypad_or_ent] or bKeypads.MapLinking.Links[keypad_or_ent] or nil
end

function bKeypads.MapLinking:IsLinked(keypad, ent)
	return IsValid(keypad) and IsValid(ent) and bKeypads.MapLinking.Links[ent] and bKeypads.MapLinking.Links[ent][keypad] and next(bKeypads.MapLinking.Links[ent][keypad]) ~= nil
end

function bKeypads.MapLinking:RegisterLink(link, keypad, ent, accessType)
	bKeypads.MapLinking.Links[keypad] = bKeypads.MapLinking.Links[keypad] or {}
	bKeypads.MapLinking.Links[keypad][ent] = bKeypads.MapLinking.Links[keypad][ent] or {}
	bKeypads.MapLinking.Links[keypad][ent][accessType] = link

	bKeypads.MapLinking.Links[ent] = bKeypads.MapLinking.Links[ent] or {}
	bKeypads.MapLinking.Links[ent][keypad] = bKeypads.MapLinking.Links[ent][keypad] or {}
	bKeypads.MapLinking.Links[ent][keypad][accessType] = link
end

function bKeypads.MapLinking:DeregisterLink(keypad, ent, accessType)
	if bKeypads.MapLinking.Links[ent] and bKeypads.MapLinking.Links[ent][keypad] and bKeypads.MapLinking.Links[ent][keypad][accessType] then
		bKeypads.MapLinking.Links[ent][keypad] = nil
		if table.IsEmpty(bKeypads.MapLinking.Links[ent]) then
			bKeypads.MapLinking.Links[ent] = nil
		end
	end
	if bKeypads.MapLinking.Links[keypad] and bKeypads.MapLinking.Links[keypad][ent] and bKeypads.MapLinking.Links[keypad][ent][accessType] then
		bKeypads.MapLinking.Links[keypad][ent] = nil
		if table.IsEmpty(bKeypads.MapLinking.Links[keypad]) then
			bKeypads.MapLinking.Links[keypad] = nil
		end
	end
end

-- TODO add halos on persistence tool

function bKeypads.MapLinking:BuildLinksTable()
	bKeypads.MapLinking.RebuildLinkTable = nil

	bKeypads.MapLinking.Links = {}

	for link in pairs(bKeypads.MapLinking.LinkEnts) do
		if not IsValid(link) then
			bKeypads.MapLinking.LinkEnts[link] = nil
			continue
		end

		local keypad, ent, accessType = link:GetKeypad(), link:GetLinkedEnt(), link:GetAccessType()
		if IsValid(ent) and IsValid(keypad) then
			bKeypads.MapLinking:RegisterLink(link, keypad, ent, accessType)
		end

		if IsValid(ent) and link:HasButtonFlag(bKeypads.MapLinking.F_BUTTON_HIDE) then
			bKeypads.MapLinking:Hide(ent)
		end
	end

	if CLIENT then bKeypads.ESP:Refresh() end
end

do
	local function FindUseEntity(ply, defaultEnt)
		local linker = ply:GetTool()
		if not linker or linker.Mode ~= "bkeypads_linker" then linker = nil end

		local links = bKeypads.MapLinking:GetLinks(defaultEnt)
		if links then
			local redirectKeypad
			local closest_dist = math.huge
			for ent, linkData in pairs(links) do
				local link = select(2, next(linkData))
				if not IsValid(link) then continue end

				if link:HasGeneralFlag(bKeypads.MapLinking.F_REDIRECT_USE) and IsValid(link:GetKeypad()) then
					local dist = link:GetKeypad():WorldSpaceCenter():DistToSqr(defaultEnt:WorldSpaceCenter())
					if dist < closest_dist then
						closest_dist = dist
						redirectKeypad = link:GetKeypad()
					end
				end
			end

			if linker then
				linker.m_eFindUseEntity = defaultEnt
				linker.m_iFindUseEntityTick = engine.TickCount()
			end
			return redirectKeypad
		end

		if linker then
			linker.m_eFindUseEntity = nil
			linker.m_iFindUseEntityTick = engine.TickCount()
		end
	end

	function bKeypads.MapLinking.RedirectUse(ply, defaultEnt)
		if IsValid(defaultEnt) and not defaultEnt.bKeypad then
			local root = bKeypads.MapLinking:GetRootDoor(defaultEnt)
			if IsValid(root) and root ~= defaultEnt then
				return FindUseEntity(ply, root) or FindUseEntity(ply, defaultEnt)
			else
				return FindUseEntity(ply, defaultEnt)
			end
		end
	end

	hook.Add("FindUseEntity", "bKeypads.FindUseEntity", bKeypads.MapLinking.RedirectUse)
end

if CLIENT then
	function bKeypads.MapLinking:Hide(ent)
		if not IsValid(ent) then return end
		if not bKeypads.MapLinking:IsMapButton(ent) then return end
		if ent.bKeypads_MapLinking_SetNoDraw == nil then
			ent.bKeypads_MapLinking_SetNoDraw = not ent:GetNoDraw() or nil
		end
		ent:SetNoDraw(true)
	end

	function bKeypads.MapLinking:Show(ent)
		if not IsValid(ent) then return end
		if not bKeypads.MapLinking:IsMapButton(ent) then return end
		if ent.bKeypads_MapLinking_SetNoDraw then
			ent.bKeypads_MapLinking_SetNoDraw = nil
			ent:SetNoDraw(false)
		end
	end
end

local readyFuncs = {}
function bKeypads.MapLinking:Ready(callback)
	if bKeypads_MapLinking_Ready == true then
		bKeypads:InitPostEntity(callback)
	else
		table.insert(readyFuncs, callback)
	end
end
hook.Add("bKeypads.MapLinking.Ready", "bKeypads.MapLinking.Ready.Internal", function()
	bKeypads:InitPostEntity(function()
		if bKeypads_MapLinking_Ready then return end
		bKeypads_MapLinking_Ready = true
		for _, f in ipairs(readyFuncs) do f() end
		readyFuncs = nil
	end)
end)