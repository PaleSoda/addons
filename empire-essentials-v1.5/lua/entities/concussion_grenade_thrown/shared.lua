ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Concussion Grenade (Thrown)"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.Model = "models/weapons/star_wars_battlefront/ThermalDetonator_thrown.mdl"
ENT.FuseTime = 3
ENT.ArmTime = 0
ENT.ImpactFuse = false

ENT.BlastRadius = 450

ENT.BlastDMG = 275

AddCSLuaFile()

function ENT:Initialize()
    if SERVER then
	-- util.SpriteTrail( self, 0, Color(155,255,75,155), false, 12, 0, 0.15, 1, "effects/swbf/red_beam" )
        self:SetModel( self.Model )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
        self:DrawShadow( true )

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
		phys:SetMass(1)
            phys:SetBuoyancyRatio(0)
        end
        self.kt = CurTime() + self.FuseTime
        self.at = CurTime() + self.ArmTime
		self.bt = CurTime() + 1
    end
end



function ENT:PhysicsCollide(data, physobj)
    if SERVER then
        if data.Speed > 75 then
            self:EmitSound(Sound("weapons/star_wars_battlefront/common/imp_grenade_stone_0" .. math.random(1,3) .. ".wav"))
	 -- local effectdata = EffectData()
        -- effectdata:SetOrigin( self:GetPos() )
        -- util.Effect( "StunstickImpact", effectdata)
        elseif data.Speed > 25 then
            self:EmitSound(Sound("weapons/star_wars_battlefront/common/imp_grenade_stone_0" .. math.random(1,3) .. ".wav"))
        end
		self:SetAngles(Angle(0,0,0))
        if self.at <= CurTime() and self.ImpactFuse then
            self:Detonate()
        end
	if !data.HitEntity:IsPlayer() and data.HitEntity:GetClass() != "worldspawn" then
		self:SetParent( data.HitEntity )
		if data.HitEntity:IsPlayer() and data.HitEntity:IsNPC() then
		self:EmitSound(Sound("star_wars_republic_commando/weapons/int_gen_selsonicgrn_01.wav"))
						end
        end
		if data.HitEntity:GetClass() != "worldspawn" then
			self:SetParent( data.HitEntity )
		end
		
        end
	
    end
 

function ENT:Think()
    if SERVER and CurTime() >= self.kt then
        self:Detonate()
    end
end

function ENT:Detonate()
    if SERVER then
        if not self:IsValid() then return end
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos() + Vector(0,0,25))

        if self:WaterLevel() >= 1 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
		-- sound.Play( "halo/halo_3/frag_expl_water" .. math.random(1,5) .. ".ogg",  self:GetPos(), 100, 100 )
        else
            ParticleEffect( "astw2_swbf_explosion_concussion_grenade", self:GetPos(), self:GetAngles() )
        end
		
		local inflictor = self
		
		if IsValid(self.Owner) then inflictor = self.Owner end

        util.BlastDamage(self, inflictor, self:GetPos(), self.BlastRadius, self.BlastDMG)
	sound.Play( "weapons/star_wars_battlefront/common/exp_ord_grenade0" .. math.random(1,3) .. ".wav",  self:GetPos(), 100, 100 )
	util.ScreenShake(self:GetPos(),10000,100,0.8,1024)
        self:Remove()

    end
end

function ENT:Draw()
    if CLIENT then
        self:DrawModel()
            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
                render.SetMaterial( Material("effects/swbf/flare0") ) -- Tell render what material we want, in this case the flash from the gravgun
                render.DrawSprite( self:GetPos(), math.random(30, 40), math.random(30, 40), Color(155, 125, 50) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
            cam.End3D()
    end
end