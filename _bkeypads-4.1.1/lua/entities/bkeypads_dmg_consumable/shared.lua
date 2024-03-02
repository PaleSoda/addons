AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
DEFINE_BASECLASS(ENT.Base)

ENT.Author = "Billy"
ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetBaseModelScale(m_iModelScale, time)
	self.m_iBaseModelScale = self.m_iBaseModelScale or m_iModelScale
	return self:SetModelScale(m_iModelScale, time)
end

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:PhysWake()

		self:SetTrigger(true)
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:StartTouch(ent)
		if ent.bKeypad and ent:GetDestructible() and not self.m_bConsumed and self:Consume(ent) then
			self.m_bConsumed = true
			self:SetConsumedBy(ent)

			self:SetModelScale(0, 0.5)

			self:ForcePlayerDrop()
			DropEntityIfHeld(self)

			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableGravity(false)
				phys:EnableCollisions(false)
				phys:EnableMotion(false)
				phys:EnableMotion(true)
				phys:SetDamping(0, 0)
				phys:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)

				local dir = ent:WorldSpaceCenter() - phys:GetPos()
				local dist = dir:Length()
				dir:Normalize()

				phys:ApplyForceCenter(dir * phys:GetMass() * dist)
			end

			timer.Simple(1, function()
				if IsValid(self) then
					self:Remove()
				end
			end)
		end
	end

	function ENT:Use(ply)
		if IsValid(ply) and ply:IsPlayer() then
			ply:PickupObject(self)
		end
	end
else
	local scale_3d2d = 0.04
	function ENT:Draw(flags)
		if bit.band(flags, STUDIO_TRANSPARENCY) == 0 or bit.band(flags, STUDIO_TWOPASS) == 0 then
			self:DrawModel()
		end
	end

	function ENT:DrawTranslucent(flags)
		self:Draw(flags)

		if halo.RenderedEntity() == self then return end

		if self:GetModelScale() == self.m_iBaseModelScale then
			if LocalPlayer():GetEyeTrace().Entity == self then
				local mins, maxs = self:GetRotatedAABB(self:OBBMins(), self:OBBMaxs())
				local center = (maxs + mins) / 2

				local pos = LocalToWorld(center, angle_zero, self:GetPos(), angle_zero)
				pos.z = math.max(LocalToWorld(maxs, angle_zero, self:GetPos(), angle_zero).z, LocalToWorld(mins, angle_zero, self:GetPos(), angle_zero).z)

				local ang = (EyePos() - pos):Angle()
				ang:RotateAroundAxis(ang:Up(), 90)
				ang:RotateAroundAxis(ang:Forward(), 90)

				cam.Start3D2D(pos, ang, scale_3d2d)
					self:DrawHUDLabel()
				cam.End3D2D()
			end
		elseif IsValid(self:GetConsumedBy()) then
			local animFrac = self:GetModelScale() / self.m_iBaseModelScale

			local pos = self:WorldSpaceCenter()
			pos.z = pos.z + (10 * (1 - animFrac))

			local ang = (EyePos() - pos):Angle()
			ang:RotateAroundAxis(ang:Up(), 90)
			ang:RotateAroundAxis(ang:Forward(), 90)

			cam.Start3D2D(pos, ang, scale_3d2d * 2)
				surface.SetAlphaMultiplier(animFrac)
					self:DrawConsumedLabel()
				surface.SetAlphaMultiplier(1)
			cam.End3D2D()
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "ConsumedBy")
end

function ENT:GravGunPunt()
	return true
end