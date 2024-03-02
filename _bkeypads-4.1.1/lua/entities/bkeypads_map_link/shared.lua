AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "bkeypads_link"

ENT.PrintName = "Map Link (Billy's Keypads)"
ENT.Author = "Billy"

ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_OTHER

DEFINE_BASECLASS(ENT.Base)

function ENT:Initialize()
	BaseClass.Initialize(self)

	if CLIENT then self:OnButtonFlagsChanged() end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", 1, "Active")

	self:NetworkVar("Int", 0, "GeneralFlags")
	self:NetworkVar("Int", 1, "ButtonFlags")
	self:NetworkVar("Int", 2, "DoorFlags")

	if CLIENT then
		self:NetworkVarPostNotify("ButtonFlags", self.OnButtonFlagsChanged)
	end
end

if CLIENT then
	function ENT:OnButtonFlagsChanged()
		local ent = self:GetLinkedEnt()
		if IsValid(ent) then
			if self:HasButtonFlag(bKeypads.MapLinking.F_BUTTON_HIDE) then
				bKeypads.MapLinking:Hide(ent)
			else
				bKeypads.MapLinking:Show(ent)
			end
		end
	end
end

function ENT:HasGeneralFlag(flag)
	return bit.band(self:GetGeneralFlags(), flag) ~= 0
end

function ENT:HasButtonFlag(flag)
	return bit.band(self:GetButtonFlags(), flag) ~= 0
end

function ENT:HasDoorFlag(flag)
	return bit.band(self:GetDoorFlags(), flag) ~= 0
end

function ENT:RegisterLink()
	bKeypads.MapLinking.LinkEnts[self] = true
end

if CLIENT then
	function ENT:LinkUpdated()
		if not bKeypads.MapLinking.RebuildLinkTable then
			bKeypads.MapLinking.RebuildLinkTable = true
			bKeypads:nextTick(bKeypads.MapLinking.BuildLinksTable)
		end
	end

	function ENT:OnRemove()
		BaseClass.OnRemove(self)

		if IsValid(self:GetLinkedEnt()) then
			bKeypads.MapLinking:Show(self:GetLinkedEnt())
		end
	end
else
	function ENT:DeregisterLink()
		bKeypads.MapLinking.LinkEnts[self] = nil
		bKeypads.MapLinking:DeregisterLink(self:GetKeypad(), self:GetLinkedEnt(), self:GetAccessType())
	end

	function ENT:OnRemove()
		if IsValid(self:GetKeypad()) and IsValid(self:GetLinkedEnt()) then
			bKeypads.MapLinking:Unlink(self:GetKeypad(), self:GetLinkedEnt())
		end
		BaseClass.OnRemove(self)
	end
end

bKeypads_Initialize_Fix(ENT)