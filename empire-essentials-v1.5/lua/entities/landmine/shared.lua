ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "LandMine"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.Model = "models/weapons/star_wars_battlefront/com_weap_inf_landmine_placed.mdl"

AddCSLuaFile()

function ENT:Initialize()
    if SERVER then
        self:SetModel( self.Model )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
        self:DrawShadow( true )
        self:SetUseType( CONTINUOUS_USE )

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetBuoyancyRatio(0)
        end

    self.Armed = false

    end
end

function ENT:OnTakeDamage()
    if SERVER then
        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
        if self:WaterLevel() >= 1 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
        else
            util.Effect( "ManhackSparks", effectdata)
        end
        self:Remove()
    end
end

function ENT:PhysicsCollide(data, physobj)
    if SERVER and !self.Armed then
        self:EmitSound( "weapons/star_wars_battlefront/gcw/wpn_all_unit_lockon_lp.wav" )
        self:SetAngles( data.HitNormal:Angle() + Angle( 0, 0, 0 ) )
        self:SetPos( data.HitPos + (data.HitNormal * -1) )
        -- self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        -- self:SetMoveType( MOVETYPE_NONE )
        if !data.HitEntity:IsPlayer() and data.HitEntity:GetClass() != "worldspawn" then
            self:SetParent( data.HitEntity )
        end

        self.st = CurTime() + 1.5
        self.armtime = CurTime() + 3.5
        self.Armed = true
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
            ParticleEffect( "astw2_swbf_explosion_thermal_detonator", self:GetPos(), self:GetAngles() )
			sound.Play( "weapons/star_wars_battlefront/common/exp_obj_med0" .. math.random(1,5) .. ".wav",  self:GetPos(), 100, 100 )
			util.ScreenShake(self:GetPos(),36000,500,2.2,2048)
        end
		
		
        util.BlastDamage(self, self.Owner, self:GetPos(), 512, 256)

        self:Remove()

    end
end

function ENT:Think()
    if SERVER then

        if self.Armed and CurTime() >= self.st then
            -- self:EmitSound( "weapons/svm/mine_beep.wav", 75, 100 , 0.5)
            self.st = CurTime() + 0.85
			self:SetAngles(Angle(0,0,0))
        end

       
        end

		 if self.Armed and self.armtime < CurTime() then

    local targets = ents.FindInSphere(self:GetPos(), 160)
        for _, k in pairs(targets) do
            -- if (k:IsPlayer() and k:GetVelocity():Length() > 75) then
                 -- self:Detonate()
		-- k:Ignite( 5 )
				 -- else
		if k:IsNPC() or k:IsPlayer() then
		-- k:Ignite( 8 )
		self:Detonate()
				 end
		 if (k:IsValid() and scripted_ents.IsBasedOn( k:GetClass(), "base_nextbot" ) and (!k.FriendlyToPlayers or k:GetOwner()!=self.Owner) ) then
                    self:Detonate()
			-- k:Ignite( 8 ) 
                end
            end
        end
    end


function ENT:Draw()
        self:DrawModel()
		-- if self.Armed then
            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
                render.SetMaterial( Material("effects/swbf/flare1") ) -- Tell render what material we want, in this case the flash from the gravgun
                render.DrawSprite( self:GetPos(), math.random(8, 32), math.random(8, 32), Color(255, 50, 50) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
            cam.End3D()
        -- end
end