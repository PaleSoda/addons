AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "arccw_thr"
ENT.PrintName = "Fragnade"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/arccw/meeks/bacta_grenade.mdl"
ENT.TrailColor = Color(0, 187, 255)
ENT.TrailTexture = "sprites/bluelaser1" -- this is exactly the one hl2 frag uses. Why blue? idk blame gaben

local regenInterval = 0.125 -- Regeneration interval in seconds
local regenDuration = 3 -- Regeneration duration in seconds
local playersInRegenRange = {} -- Store players in regeneration range

-- Function to handle player health regeneration
local function RegenerateHealth(ply)
    if IsValid(ply) and ply:Alive() then
        local maxHealth = ply:GetMaxHealth()
        local currentHealth = ply:Health()
        local regenAmount = maxHealth * 0.05
        
        if currentHealth < maxHealth then
            ply:SetHealth(math.min(currentHealth + regenAmount, maxHealth))
        end
    end
end

-- Hook to start player health regeneration
hook.Add("Think", "PlayerHealthRegen", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local shouldRegenerate = playersInRegenRange[ply]
            
            if shouldRegenerate then
                if not ply.regenStartTime then
                    ply.regenStartTime = CurTime()
                end
                
                if CurTime() - ply.regenStartTime <= regenDuration then
                    if not ply.nextRegen or CurTime() >= ply.nextRegen then
                        RegenerateHealth(ply)
                        ply.nextRegen = CurTime() + regenInterval
                    end
                else
                    playersInRegenRange[ply] = nil
                    ply.regenStartTime = nil
                end
            end
        end
    end
end)

-- Hook to detect players entering and leaving regeneration range
hook.Add("PlayerEnteredRegenRadius", "PlayerEnteredRegenRadius", function(ply)
    if IsValid(ply) then
        playersInRegenRange[ply] = true
    end
end)

hook.Add("PlayerLeftRegenRadius", "PlayerLeftRegenRadius", function(ply)
    if IsValid(ply) then
        playersInRegenRange[ply] = nil
        ply.regenStartTime = nil
    end
end)



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
			phys:SetBuoyancyRatio(0)
		end
		
		self.Delay = CurTime() + 1.7
		self.NextParticle = 0
		self.ParticleCount = 0
		self.First = true
		self.IsDetonated = false

        self.SpawnTime = CurTime()
        self.Trail = util.SpriteTrail(self, 0, self.TrailColor, false, 4, 0, 0.5, 4, self.TrailTexture or "sprites/bluelaser1")
        if IsValid(self.Trail) then
            self.Trail:SetRenderMode(RENDERMODE_TRANSADD)
            self.Trail:SetRenderFX(kRenderFxNone)
        end
        self:SetPhysicsAttacker(self:GetOwner(), 10)
	end
    util.PrecacheSound("misc/BEEPTimer_Anticipation Beeps_08.wav")

    -- Play the sound when the entity is spawned
    self:EmitSound("misc/BEEPTimer_Anticipation Beeps_08.wav")
end

function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		self.HitP = data.HitPos
		self.HitN = data.HitNormal

		if self:GetVelocity():Length() > 60 then
			self:EmitSound(Sound("weapons/grenades/wpn_fraggrenade_1p_hardsurface_bounce_01_lr_v" .. math.random(1,2) .. ".wav"))
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
                self:Detonate(self, self:GetPos())
                self.IsDetonated = true
                
                -- Player entered the regeneration radius after detonation
                for _, v in pairs(ents.FindInSphere(self:GetPos(), 216)) do
                    if v:IsPlayer() then
                        hook.Call("PlayerEnteredRegenRadius", nil, v)
                    end
                end
            end
        end
    end
end

function ENT:Detonate(self,pos)
	self.ParticleCreated = false
	self.ExtinguishParticleCreated = false
	if SERVER then
		if not self:IsValid() then return end
		self:SetNWBool("IsDetonated",true)
		self:EmitSound("misc/EXPLDsgn_Implode_02.wav", 120, 100, 1, CHAN_AUTO)
		local gas = EffectData()
		gas:SetOrigin(pos)
		gas:SetEntity(self.Owner)
		util.Effect("tfa_csgo_healnade", gas)
	end
	
	self:SetMoveType( MOVETYPE_NONE )
	
	if SERVER then
		SafeRemoveEntityDelayed(self,0.5)
	end
	
end

function ENT:DrawTranslucent()
    self:Draw()
end

function ENT:Draw()
    self:DrawModel()
end