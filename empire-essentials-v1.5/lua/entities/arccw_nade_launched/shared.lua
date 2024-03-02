ENT.Type = "anim"
ENT.Base = "arccw_thr"
ENT.PrintName = "Grenade Launcher Rocket"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Model = "models/arccw/masita/grenades/tdunprimed.mdl"
ENT.FuseTime = 4
ENT.ArmTime = 1
ENT.ImpactFuse = true

AddCSLuaFile()

function ENT:Initialize()
    if SERVER then
		ParticleEffectAttach( "astw2_halo_reach_grenade_launcher_trail", PATTACH_POINT_FOLLOW, self, 1 )
		util.SpriteTrail( self, 0, Color(255,185,20,185), false, 16, 4, 0.22, 0.01, "effects/halo3/trail/basic_trail" )
		util.SpriteTrail( self, 0, Color(255,155,20,155), false, 12, 4, 0.25, 0.01, "effects/halo3/trail/flaming_trail" )
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
            phys:EnableGravity( true )
        end

        self.kt = CurTime() + self.FuseTime
        self.motorsound = CreateSound( self, "weapons/masita_extras/cw/wpn_rep_unit_lockon_lp.wav")
		self.motorsound:Play()
    end
	if CLIENT then
	ParticleEffectAttach( "astw2_halo_reach_grenade_launcher_trail", PATTACH_POINT_FOLLOW, self, 1 )
	end
    self.at = CurTime() + self.ArmTime
    self.Armed = false
end

function ENT:OnRemove()
    if SERVER then
        self.motorsound:Stop()
    end
end


function ENT:PhysicsCollide(data, physobj)
if SERVER then
		if data.Speed > 25 then
            self:EmitSound(Sound("weapons/grenades/wpn_fraggrenade_1p_hardsurface_bounce_01_lr_v" .. math.random(1,2) .. ".wav"))
		end
		end
	if self.at <= CurTime() and self.ImpactFuse then
            self:Detonate()


        end
		local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
        util.Effect( "StunstickImpact", effectdata)
end

function ENT:Arm()
    if SERVER then
        
    end
end

function ENT:Think()



    if CurTime() >= self.at and !self.Armed then
        self:Arm()
        self.Armed = true
    end

    if SERVER then

        if self.Armed then
            local phys = self:GetPhysicsObject()
        end
	
	if CurTime() >= self.at then
            local targets = ents.FindInSphere(self:GetPos(), 16)
            for _, k in pairs(targets) do
                if k:IsPlayer() or k:IsNPC() then
                    if self:Visible( k ) and k:Health() > 0 then
                        self:Detonate()
                    end
                elseif (k:IsValid() and scripted_ents.IsBasedOn( k:GetClass(), "base_nextbot" )) then
                    self:Detonate()
                end
            end
        end

        if CurTime() >= self.kt then
            self:Detonate()
        end
    end

    if CLIENT then
        -- if self:IsValid() then
            -- local emitter = ParticleEmitter(self:GetPos())

            -- if !self:IsValid() or self:WaterLevel() > 2 then return end

	-- local smoke = emitter:Add("effects/halo3/muzzle_magnum", self:GetPos())
        -- smoke:SetGravity( Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-20, -25)) )
        -- smoke:SetVelocity( self:GetAngles():Forward() * 100 )
        -- smoke:SetDieTime( math.Rand(0.1,0.15) )
        -- smoke:SetStartAlpha( 255 )
        -- smoke:SetEndAlpha( 0 )
        -- smoke:SetStartSize( 3 )
        -- smoke:SetEndSize( 0 )
        -- smoke:SetRoll( math.Rand(-180, 180) )
        -- smoke:SetRollDelta( math.Rand(-0.2,0.2) )
        -- smoke:SetColor( 255, 125, 55 )
        -- smoke:SetAirResistance( 2 )
        -- smoke:SetPos( self:GetPos() )
        -- smoke:SetLighting( false )
		
        -- emitter:Finish()
        -- end
    end
end

function ENT:Detonate()
    if SERVER then
        if !self:IsValid() then return end
        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )

        if self:WaterLevel() >= 1 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
        else
            ParticleEffect( "astw2_halo_3_frag_explosion", self:GetPos(), self:GetAngles() )
	-- sound.Play( "halo/halo_reach/weapons/grenade_launcher_expl" .. math.random(1,3) .. ".ogg",  self:GetPos(), 100, 100 )
	self:EmitSound("grenades/gren_expl" .. math.random(1,4) .. "_close.ogg", 120, 100, 1, CHAN_AUTO)
        end

        local attacker = self

        if self.Owner:IsValid() then
            attacker = self.Owner
        end
	local targets = ents.FindInSphere(self:GetPos(), 300)
        for _, k in pairs(targets) do
            if k != self and k:GetPos().z < self:GetPos().z + 64 then
                local damage = DamageInfo()
                damage:SetAttacker( self:GetOwner() )
                damage:SetDamage( 5 )
                damage:SetDamageType( DMG_SHOCK )
                damage:SetInflictor( self )
                k:TakeDamageInfo( damage )
            end
        end
	util.Decal( "astw2_halo_reach_impact_soft_terrain_explosion", self:GetPos(), self:GetPos() - Vector(0, 0, 32), self )
         util.BlastDamage(self, attacker, self:GetPos(), 300, 250)
	 util.ScreenShake(self:GetPos(),4500,100,0.6,1024)
	 
        self:Remove()
    end
end

function ENT:Draw()
    if CLIENT then
        self:DrawModel()

        if self.Armed then
            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
                render.SetMaterial( Material("effects/halo3/8pt_ringed_star_flare") ) -- Tell render what material we want, in this case the flash from the gravgun
                render.DrawSprite( self:GetPos(), math.random(25, 50), math.random(30, 55), Color(255, 200, 150) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
            cam.End3D()
        end
    end
end