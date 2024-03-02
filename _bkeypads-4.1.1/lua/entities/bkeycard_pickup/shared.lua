ENT.Type = "anim"
ENT.Base = "bkeypads_networkvarpostnotify"

ENT.PrintName = "#bKeypads_DroppedKeycard"
ENT.Category = "Billy's Keypads"
ENT.Author = "Billy"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:Initialize()
	self.bKeycard = true
	self:SetModel(bKeypads.MODEL.KEYCARD)

	if SERVER then
		self:PhysicsInit(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		self:SetUseType(SIMPLE_USE)

		bKeypads.Keycards:AssignID(self)

		self:PhysicsEnabledSet("PhysicsEnabled", nil, self:GetPhysicsEnabled())
		self:TouchToPickupSet("TouchToPickup", nil, self:GetTouchToPickup())
	end

	self:IDAssigned("ID", nil, self:GetID())
	self:LevelsStrSet("LevelsStr", nil, self:GetLevelsStr())
	self:UpdateKeycardData()
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
	self:NetworkVar("Int", 1, "Quantity", { KeyName = "Quantity" })
	self:NetworkVar("Int", 2, "Team", { KeyName = "Team" })

	self:NetworkVar("String", 0, "LevelsStr", { KeyName = "Levels" })
	self:NetworkVar("String", 1, "PlayerModel", { KeyName = "PlayerModel" })
	self:NetworkVar("String", 2, "SteamID", { KeyName = "SteamID" })
	self:NetworkVar("String", 3, "PlayerKeycardDataBind")

	self:NetworkVar("Bool", 0, "IsChildKeycard")
	self:NetworkVar("Bool", 1, "Persist")
	self:NetworkVar("Bool", 1, "Infinite", { KeyName = "Infinite" })
	self:NetworkVar("Bool", 2, "HideToHolders", { KeyName = "HideToHolders" })
	self:NetworkVar("Bool", 3, "PhysicsEnabled", { KeyName = "PhysicsEnabled" })
	self:NetworkVar("Bool", 4, "TouchToPickup", { KeyName = "TouchToPickup" })

	self:NetworkVarPostNotify("ID", self.IDAssigned)
	self:NetworkVarPostNotify("IsChildKeycard", self.IDAssigned)
	self:NetworkVarPostNotify("LevelsStr", self.LevelsStrSet)

	self:NetworkVarPostNotify("SteamID", self.UpdateKeycardData)
	self:NetworkVarPostNotify("PlayerModel", self.UpdateKeycardData)
	self:NetworkVarPostNotify("Team", self.UpdateKeycardData)
	self:NetworkVarPostNotify("PlayerKeycardDataBind", self.UpdateKeycardData)

	if SERVER then
		self:NetworkVarPostNotify("PhysicsEnabled", self.PhysicsEnabledSet)
		self:NetworkVarPostNotify("TouchToPickup", self.TouchToPickupSet)
	end
end

function ENT:IDAssigned(_, __, newVal)
	if newVal == 0 then return end
	self:UpdateKeycardData()
end

function ENT:LevelsStrSet(_, __, levels)
	if self:GetID() == 0 then return end

	if not self:GetIsChildKeycard() then
		bKeypads_Keycards_Registry[self:GetID()] = nil
	end
	self:UpdateKeycardData()
end

function ENT:BuildKeycardDataTable()
	return {
		Keycard = self,
		Levels = {},
		LevelsDict = {},
		PrimaryLevel = 1,
		SteamID = self:GetSteamID() ~= "" and self:GetSteamID() or nil,
		PlayerModel = self:GetPlayerModel() ~= "" and self:GetPlayerModel() or nil,
		Team = self:GetTeam() ~= 0 and self:GetTeam() or nil,
		PlayerBind = self:GetPlayerKeycardDataBind() ~= "" and self:GetPlayerKeycardDataBind() or nil
	}
end

function ENT:UpdateKeycardData()
	self:UpdateHash()

	local id = self:GetID()
	if id == 0 then return end

	local keycardData
	if self:GetIsChildKeycard() then
		keycardData = bKeypads.Keycards:GetByID(id)
	else
		keycardData = bKeypads.Keycards:GetByID(id) or self:BuildKeycardDataTable()

		keycardData.Keycard = self
		keycardData.SteamID = self:GetSteamID() ~= "" and self:GetSteamID() or nil
		keycardData.PlayerModel = self:GetPlayerModel() ~= "" and self:GetPlayerModel() or nil
		keycardData.Team = self:GetTeam() ~= 0 and self:GetTeam() or nil
		keycardData.PlayerBind = self:GetPlayerKeycardDataBind() ~= "" and self:GetPlayerKeycardDataBind() or nil

		keycardData.Levels = {}
		for _, level in ipairs(string.Explode(",", self:GetLevelsStr())) do
			local level = tonumber(level)
			if not level then continue end

			table.insert(keycardData.Levels, level)
			keycardData.LevelsDict[level] = true
			keycardData.PrimaryLevel = math.max(keycardData.PrimaryLevel, level)
		end

		table.sort(keycardData.Levels)

		bKeypads_Keycards_Registry[id] = keycardData
	end

	return keycardData
end

function ENT:GetKeycardData()
	if self:GetID() ~= 0 then
		local keycardData = bKeypads.Keycards:GetByID(self:GetID())
		if keycardData then
			return keycardData
		elseif not self:GetIsChildKeycard() then
			return self:UpdateKeycardData()
		end
	end

	return self:BuildKeycardDataTable()
end

function ENT:GetLevels()
	return self:GetKeycardData().Levels
end

function ENT:GetLevelsDictionary()
	return self:GetKeycardData().LevelsDict
end

function ENT:GetPrimaryLevel()
	return self:GetKeycardData().PrimaryLevel
end

function ENT:GetKeycardMetadata()
	return bKeypads.Keycards.Levels[self:GetPrimaryLevel()] or {}
end

function ENT:GetKeycardColor()
	return self.KeycardColor or self:GetKeycardMetadata().Color or bKeypads.COLOR.RED
end

function ENT:GetKeycardName()
	return self:GetKeycardMetadata().Name or bKeypads.L("KeycardLevel"):format(tonumber(primaryLevel) or 1)
end

function ENT:UpdateHash()
	local levelsSorted = {}
	for _, level in ipairs(string.Explode(",", self:GetLevelsStr())) do
		local level = tonumber(level)
		if level then
			table.insert(levelsSorted, level)
		end
	end
	table.sort(levelsSorted)

	self.m_Hash = util.CRC(self:GetSteamID() .. self:GetPlayerModel() .. table.concat(levelsSorted, ",") .. self:GetTeam())

	return self.m_Hash
end

function ENT:GetHash()
	return self.m_Hash or self:UpdateHash()
end

--[[ FIXME https://github.com/Facepunch/garrysmod-issues/issues/642

function ENT:SetCollisionRule(ply, shouldCollide)
	--[[if self:GetID() == 0 or not IsValid(ply) then return end

	self:CollisionRulesChanged()
	ply:CollisionRulesChanged()

	self.m_CollisionRules = self.m_CollisionRules or {}
	self.m_CollisionRules[ply] = (not shouldCollide) or nil

	self:CollisionRulesChanged()
	ply:CollisionRulesChanged()

	self:SetCustomCollisionCheck(true)
end
hook.Add("ShouldCollide", "bKeypads.Keycards.ShouldCollide", function(ent1, ent2)

	local ply, keycard

	if ent1:GetClass() == "bkeycard_pickup" then
		keycard = ent1
		if keycard:GetID() == 0 then return end
		if ent2:IsPlayer() then
			ply = ent2
		else
			return
		end
	elseif ent2:GetClass() == "bkeycard_pickup" then
		keycard = ent2
		if keycard:GetID() == 0 then return end
		if ent1:IsPlayer() then
			ply = ent1
		else
			return
		end
	else
		return
	end

	if keycard.m_CollisionRules[ply] then
		return false
	end
end)
]]

bKeypads_Initialize_Fix(ENT)