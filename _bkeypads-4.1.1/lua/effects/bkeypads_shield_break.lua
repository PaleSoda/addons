function EFFECT:Init(data)
	self.StartTime = CurTime()
	self.EndTime = self.StartTime + .65

	self.Target = data:GetEntity()
	self.Origin = data:GetOrigin()

	--## Shield Break Circle ##--

	self.Target:ShieldBrokenEffect(.65)

	--## Halo Effect ##--

	self.TargetHalo = { self.Target }
	self.Color = Color(0, 183, 159)

	--## Sparks ##--

	local mins, maxs = self.Target:WorldSpaceAABB()
	local numParticles = math.Clamp(self.Target:BoundingRadius() * 8, 32, 256)
	local emitter = ParticleEmitter(self.Origin)
	for i = 0, numParticles do
		local vPos = Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z))
		local particle = emitter:Add("effects/spark", vPos)
		if particle then
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)

			particle:SetVelocity((vPos - self.Origin) * 5)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.5, 1.0))
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(2)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(0)

			particle:SetAirResistance(100)
			particle:SetCollide(true)
			particle:SetBounce(0.3)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return IsValid(self.Target) and self.EndTime > CurTime()
end

function EFFECT:Render()
	if not IsValid(self.Target) then return end

	local frac = math.sin(math.TimeFraction(self.StartTime, self.EndTime, CurTime()) * math.pi)
	local distFrac = math.Clamp(1 - math.TimeFraction(1024, 64000, EyePos():DistToSqr(self.Origin)), 0.15, 1)

	self.Color.a = frac * 255

	halo.Add(self.TargetHalo, self.Color, 16 * distFrac * frac, 16 * distFrac * frac, bKeypads.Performance:Optimizing() and 1 or 4)
end