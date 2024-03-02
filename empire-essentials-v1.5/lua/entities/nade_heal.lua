ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "explosive Grenade"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.AdminSpawnable = false 

ENT.BounceSound = Sound("TFA_CSGO_SmokeGrenade.Bounce")
ENT.ExplodeSound = Sound("weapons/tfa_starwars/Smoke_Explosive_Puff_01.wav")

AddCSLuaFile()

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/forrezzur/bactagrenade.mdl") 
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(1)
		end
		
		self.Delay = CurTime() + 2
		self.NextParticle = 0
		self.ParticleCount = 0
		self.First = true
		self.IsDetonated = false
	end
	self:EmitSound("TFA_CSGO_SmokeGrenade.Throw")
end

function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		self.HitP = data.HitPos
		self.HitN = data.HitNormal

		if self:GetVelocity():Length() > 30 then
			self:EmitSound(self.BounceSound)
		end
		
		if self:GetVelocity():Length() < 5 then
			self:SetMoveType(MOVETYPE_NONE)
		end
		
	end
end

function ENT:Think()
    if SERVER then    
        if CurTime() > self.Delay then
            if self.IsDetonated == false then
                self:Detonate(self,self:GetPos())
                self.IsDetonated = true
            end
        end
    end
    if self.IsDetonated == true then
        for k, v in pairs( ents.FindInSphere( self:GetPos(), 216 ) ) do
        if v:IsPlayer() then
            if v:Health() < v:GetMaxHealth() and v:Alive() then
				v:SetHealth( math.Clamp( v:Health() + math.random( 2, 4 ), 0, v:GetMaxHealth() ) )
                    end
                end
            end
        end
    self:NextThink( CurTime() + 0.75 )
    return true
end
	
function ENT:Detonate(self,pos)
	self.ParticleCreated = false
	self.ExtinguishParticleCreated = false
	if SERVER then
		if not self:IsValid() then return end
		self:SetNWBool("IsDetonated",true)
		self:EmitSound(self.ExplodeSound)
		local gas = EffectData()
		gas:SetOrigin(pos)
		gas:SetEntity(self.Owner)
		util.Effect("tfa_csgo_healnade", gas)
	end
	
	self:SetMoveType( MOVETYPE_NONE )
	
	if SERVER then
		SafeRemoveEntityDelayed(self,15)
	end
	
end

function ENT:Draw()
	if CLIENT then
		self:DrawModel()
	end
end