local SOUND = {}
SOUND.STEAM_RELEASE = Sound("ambient/machines/steam_release_2.wav")
SOUND.CLICK = Sound("weapons/shotgun/shotgun_empty.wav")
SOUND.YES = Sound("npc/roller/remote_yes.wav")

function EFFECT:Init(data)
	local target = data:GetEntity()
	local origin = target:WorldSpaceCenter()

	target:EmitSound(SOUND.STEAM_RELEASE, 60, 135, 0.5)
	target:EmitSound(SOUND.CLICK, 60, 125)
	target:EmitSound(SOUND.YES, 60)

	if EyePos():DistToSqr(origin) >= 50000 then return end

	local emitter = ParticleEmitter(origin)
	local mins, maxs = target:GetModelBounds()
	for theta = 0, 360 do
		local pi2 = math.pi * 2
		while (theta < -math.pi) do
			theta = theta + pi2
		end
		while (theta > math.pi) do
			theta = theta - pi2
		end

		local w = (maxs.y - mins.y) * 0.94
		local h = (maxs.z - mins.z) * 0.92

		local rectAtan = math.atan2(h, w)
		local tanTheta = math.tan(theta)

		local region
		if theta > -rectAtan and theta <= rectAtan then                             region = 1
		elseif theta > rectAtan and theta <= (math.pi - rectAtan) then              region = 2
		elseif theta > (math.pi - rectAtan) or theta <= -(math.pi - rectAtan) then  region = 3
		else                                                                        region = 4
		end

		local edgePoint = Vector(origin)
		local yFactor = (region == 1 or region == 2) and -1 or 1
		local xFactor = (region == 3 or region == 4) and -1 or 1

		if region == 1 or region == 3 then
			edgePoint = edgePoint - (target:GetRight() * (xFactor * (w / 2)))
			edgePoint = edgePoint - (target:GetUp() * (yFactor * (w / 2) * tanTheta))
		else
			edgePoint = edgePoint - (target:GetRight() * (xFactor * (h / (2 * tanTheta))))
			edgePoint = edgePoint - (target:GetUp() * (yFactor * (h /  2)))
		end

		local particle = emitter:Add("particle/particle_smokegrenade", edgePoint)
		if particle then
			particle:SetVelocity((edgePoint - origin) * math.Rand(0.25, 0.4))
			particle:SetLifeTime(0)
			particle:SetDieTime(2)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(.75)
			particle:SetAirResistance(math.Rand(100, 300))
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end