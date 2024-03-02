AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.Spawnable = false

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/tfa_starwars/w_thermal.mdl" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self:DrawShadow( true )
	end
	self:EmitSound("weapons/tfa_starwars/ThermalDetonator_Beeps_01.wav")
	self.ExplodeTimer = CurTime() + 2.5
end

function ENT:Think()
	if SERVER and self.ExplodeTimer <= CurTime() then
		self:Explode()
		self:Remove()
	end
end

function ENT:PhysicsCollide( data )
	if SERVER and data.Speed > 150 then
	self:EmitSound( "TFA_CSGO_HEGrenade.Bounce" )
	end
end

function ENT:OnRemove()
end

function ENT:Explode()
	local effectdata = EffectData()
    effectdata:SetOrigin( self:GetPos() )
    util.Effect("Explosion", effectdata)
	util.BlastDamage( self, self.Owner, self:GetPos(), 350, 150 )
	local spos = self:GetPos()
	local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-32), filter=self})
	util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)    
end