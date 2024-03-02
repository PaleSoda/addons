AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "bkeypads_link"

ENT.PrintName = "Fading Door Link (Billy's Keypads)"
ENT.Author = "Billy"

ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_OTHER

DEFINE_BASECLASS(ENT.Base)

function ENT:RegisterLink()
	bKeypads.FadingDoors.LinkEnts[self] = true
end

if CLIENT then
	function ENT:LinkUpdated()
		if not bKeypads.FadingDoors.RebuildLinkTable then
			bKeypads.FadingDoors.RebuildLinkTable = true
			bKeypads:nextTick(bKeypads.FadingDoors.BuildLinksTable)
		end
	end
else
	function ENT:DeregisterLink()
		bKeypads.FadingDoors.LinkEnts[self] = nil
		bKeypads.FadingDoors:DeregisterLink(self:GetKeypad(), self:GetLinkedEnt(), self:GetAccessType())
	end
end