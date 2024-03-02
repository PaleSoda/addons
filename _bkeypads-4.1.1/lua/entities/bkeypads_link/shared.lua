AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "bkeypads_networkvarpostnotify"

ENT.PrintName = "Link (Billy's Keypads)"
ENT.Author = "Billy"

ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_OTHER

function ENT:Initialize()
	self:SetTransmitWithParent(true)

	self:DrawShadow(false)
	self:SetRenderMode(RENDERMODE_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)

	self:RegisterLink()

	if CLIENT then self:LinkChanged() end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "LinkedEnt")
	self:NetworkVar("Entity", 1, "Keypad")

	self:NetworkVar("Bool", 0, "AccessType")

	if CLIENT then
		self:NetworkVarPostNotify("LinkedEnt", self.LinkChanged)
		self:NetworkVarPostNotify("Keypad", self.LinkChanged)
		self:NetworkVarPostNotify("AccessType", self.LinkChanged)
	else
		self:NetworkVarPostNotify("Keypad", self.KeypadChanged)
	end
end

if CLIENT then
	function ENT:LinkChanged(name, old, new)
		self:LinkUpdated()
	end
	function ENT:OnRemove()
		self:LinkUpdated()
	end
else
	function ENT:OnRemove()
		self:DeregisterLink()
	end

	function ENT:KeypadChanged(_, old, new)
		if IsValid(old) then
			old:DontDeleteOnRemove(self)
		end
		if IsValid(new) then
			new:DeleteOnRemove(self)
			self:SetParent(new)
		end
	end
end