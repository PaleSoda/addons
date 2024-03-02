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
		self:SetModel( "models/weapons/tfa_starwars/w_incendiary.mdl" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self:DrawShadow( true )
	end
	self:EmitSound("weapons/tfa_starwars/Incendiary_Charge_01.wav")
	self.ActiveTimer = CurTime() + 1
	self.IgniteEnd = 0
	self.IgniteEndTimer = CurTime()
	self.IgniteStage = 0
	self.IgniteStageTimer = CurTime()
	ParticleEffectAttach("incgrenade_thrown_trail",PATTACH_POINT_FOLLOW,self,1)
	self:PhysicsInitSphere( 8 )
end

function ENT:PhysicsCollide( data,phys )
	if SERVER and self.ActiveTimer > CurTime() || data.Speed >= 2000 then
		self:EmitSound( "TFA_CSGO_SmokeGrenade.Bounce" )
	end
	local ang = data.HitNormal:Angle()
	ang.p = math.abs( ang.p )
	ang.y = math.abs( ang.y )
	ang.r = math.abs( ang.r )
	
	if ang.p > 90 or ang.p < 60 then
		self.Entity:EmitSound(Sound("TFA_CSGO_SmokeGrenade.Bounce"))
	else
		if SERVER then
			local molotovfire = ents.Create( "tfa_battlefront_fire_2" )
			molotovfire:SetPos( self:GetPos() )
			molotovfire:SetOwner( self.Owner )
			molotovfire:Spawn()
			timer.Simple( 8, function()
				if IsValid( molotovfire ) then
					molotovfire:Remove()
				end
			end )
			
			local molotovfire = ents.Create( "tfa_battlefront_fire_1" )
			local pos = self:GetPos()
			molotovfire:SetPos( self:GetPos() )
			molotovfire:SetOwner( self.Owner )
			molotovfire:SetCreator( self )
			molotovfire:Spawn()
			timer.Simple( 8, function()
				if IsValid( molotovfire ) then
					molotovfire:Remove()
				end
			end )
			
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:PhysicsInit( SOLID_NONE )
			self:SetCollisionGroup( COLLISION_GROUP_NONE )
			self:SetRenderMode( RENDERMODE_TRANSALPHA )
			self:SetColor( Color( 255, 255, 255, 0 ) )
			self:DrawShadow( false )
			self:StopParticles()
		end
		self:EmitSound("TFA_CSGO_IncGrenade.Start")
		self.IgniteEnd = 1
		self.IgniteEndTimer = CurTime() + 7
		self.IgniteStage = 1
		self.IgniteStageTimer = CurTime() + 0.1
	end
end

function ENT:OnRemove()
	if SERVER then
		self:StopSound( "TFA_CSGO_Inferno.Loop" )
		self:EmitSound( "TFA_CSGO_Inferno.FadeOut" )
	end
end