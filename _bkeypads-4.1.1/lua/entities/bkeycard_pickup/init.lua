DEFINE_BASECLASS("base_gmodentity")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Use(ply)
	if not IsValid(ply) then return end

	bKeypads.Keycards.Inventory:PickupKeycard(ply, self, self:GetID())

	ply:SelectWeapon("bkeycard")
	if IsValid(ply:GetWeapon("bkeycard")) and bKeypads.Keycards.Inventory:IsHoldingKeycard(ply, self:GetID()) then
		ply:GetWeapon("bkeycard"):SetSelectedKeycard(self:GetID())
	end
end

function ENT:SpawnFunction(ply, tr, class)
	if IsValid(ply) then
		net.Start("bKeypads.KeycardPickup.Spawn")
		net.Send(ply)
	else
		return BaseClass.SpawnFunction(self, ply, tr, class)
	end
end

function ENT:TouchToPickupSet(_, old_enable, enable)
	if old_enable == enable then return end
	self.StartTouch = enable and self.TouchFunc or nil
end
function ENT:TouchFunc(ply)
	if ply:IsPlayer() and not bKeypads.Keycards.Inventory:IsHoldingKeycard(ply, self:GetID()) then
		bKeypads.Keycards.Inventory:PickupKeycard(ply, self, self:GetID())

		if IsValid(ply:GetWeapon("bkeycard")) and bKeypads.Keycards.Inventory:IsHoldingKeycard(ply, self:GetID()) then
			ply:GetWeapon("bkeycard"):SetSelectedKeycard(self:GetID())
		end
	end
end

function ENT:PhysicsEnabledSet(_, __, enable)
	self:SetMoveType(enable and MOVETYPE_VPHYSICS or MOVETYPE_NONE)
end

function ENT:OnRemove()
	bKeypads.Keycards:DeletePersistent(self)
end

util.AddNetworkString("bKeypads.KeycardPickup.Spawn")
net.Receive("bKeypads.KeycardPickup.Spawn", function(_, ply)
	if gamemode.Call("PlayerSpawnSENT", ply, "bkeycard_pickup") == false then return end

	local persist = net.ReadBool() and bKeypads.Permissions:Check(ply, "persistence/manage_persistent_keycards")
	local touch_to_pickup = net.ReadBool()
	local physics = net.ReadBool()
	local hide_to_holders = net.ReadBool()
	local quantity = net.ReadUInt(32)
	local playermodel = net.ReadString()
	local levelCount = net.ReadUInt(32)

	if hide_to_holders then
		physics = false
	end

	if levelCount <= 0 or quantity < 0 or #playermodel == 0 or not playermodel:lower():match("^models/.-%.mdl$") then return end

	local levels = {}
	for i = 1, levelCount do
		levels[i] = net.ReadUInt(32)
	end

	local ent = BaseClass.SpawnFunction(ENT, ply, bKeypads:GetToolTrace(ply), "bkeycard_pickup")
	ent:SetLevelsStr(table.concat(levels, ","))
	ent:SetTouchToPickup(touch_to_pickup)
	ent:SetPhysicsEnabled(physics)
	ent:SetHideToHolders(hide_to_holders)
	ent:SetInfinite(quantity == 0)
	if quantity > 0 then
		ent:SetQuantity(quantity)
	end
	ent:SetPlayerModel(playermodel)

	if persist then
		bKeypads.Keycards:SavePersistent(ent)
	else
		ent:SetCreator(ply)

		undo.Create("bkeycard_pickup")
			undo.AddEntity(ent)
			undo.SetPlayer(ply)
		undo.Finish()
	end
end)