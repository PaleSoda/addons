--## Materials/Colors ##--

local matRadial = Material("bkeypads/radial_gradient.png", "smooth")
local matKeypadCracker = Material("bkeypads/keypad_cracker_selection")

local RT
local RTMat = CreateMaterial("bKeypads_CrackerESP", "UnlitGeneric", {
	["$vertexalpha"] = 1,
	["$translucent"] = 1
})

--## Data ##--

bKeypads.Cracker.Dropped = bKeypads.Cracker.Dropped or {}
bKeypads.Cracker.DroppedDict = bKeypads.Cracker.DroppedDict or {}
-- lua_run_cl table.insert(bKeypads.Cracker.Dropped, TRACE_ENT()) bKeypads.Cracker.DroppedDict[TRACE_ENT()] = true

--## Config ##--

local fadeDist = 200000
local fade2DDist = 100
local circleRadius = 40

local mins, maxs = Vector(-1.5, -4.0125, -0.075), Vector(2.25, 2.85, 3.3)
local pivot = (mins + maxs) / 2

--## Circle ##--

local circlePoly = (function(seggs)
	local x, y = circleRadius, circleRadius

	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })

	for i = 0, seggs do
		local a = math.rad((i / seggs) * -360)
		table.insert(cir, { x = x + math.sin(a) * circleRadius, y = y + math.cos(a) * circleRadius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end

	local a = math.rad(0)
	table.insert(cir, { x = x + math.sin(a) * circleRadius, y = y + math.cos(a) * circleRadius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

	return cir
end)(64)

local circleTranslation = Matrix()
circleTranslation:SetTranslation(Vector(-circleRadius, -circleRadius))

local circleDiameter = circleRadius * 2

--## Drawing ##--

local animStart
local distFrac
local dist2DFrac
local fadeFrac
local scaleFrac = 0
local HUDCracker
local x, y

local prevCracker, prevOptimizing
local scaleMatrix = Matrix()
local nextCheck
function bKeypads.Cracker:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if bDrawingDepth or bDrawingSkybox or render.GetRenderTarget() ~= nil then return end
	if not bKeypads.Cracker.Config.SeeDroppedCrackerThroughWalls then return end

	if not nextCheck or SysTime() > nextCheck then
		nextCheck = SysTime() + .25

		HUDCracker = nil

		local HUDCrackerDist = math.huge
		for _, cracker in ipairs(bKeypads.Cracker.Dropped) do
			if not IsValid(cracker) or cracker.m_iAnimationStage ~= cracker.ANIM.FINISHED or cracker:GetDestroyed() then continue end
			
			local center = cracker:LocalToWorld(pivot)
			local screenPos = center:ToScreen()
			if not screenPos.visible then continue end

			local dist3D = center:DistToSqr(EyePos())
			local xDist = math.abs((ScrW() / 2) - screenPos.x)
			local yDist = math.abs((ScrH() / 2) - screenPos.y)

			local dist = (xDist + yDist) * dist3D
			if dist < HUDCrackerDist then
				HUDCracker, HUDCrackerDist = cracker, dist
			end
		end
	end

	if not IsValid(HUDCracker) or HUDCracker.m_iAnimationStage ~= HUDCracker.ANIM.FINISHED or HUDCracker:GetDestroyed() then
		HUDCracker = nil
		return
	end

	local needsRedraw = prevCracker ~= HUDCracker or prevOptimizing ~= bKeypads.Performance:Optimizing()
	if prevCracker ~= HUDCracker then
		animStart = CurTime()
	end
	
	local screenPos = HUDCracker:LocalToWorld(pivot):ToScreen()
	x, y = screenPos.x, screenPos.y

	local xDist = math.abs((ScrW() / 2) - screenPos.x)
	local yDist = math.abs((ScrH() / 2) - screenPos.y)
	dist2DFrac = ((xDist + yDist) - (fade2DDist / 2)) / fade2DDist

	local EyePos, WorldSpaceCenter = EyePos(), HUDCracker:WorldSpaceCenter()
	distFrac = math.Clamp((EyePos:DistToSqr(WorldSpaceCenter) - (fadeDist / 2)) / fadeDist, 0, 1)
	scaleFrac = math.min(bKeypads.ease.InOutSine(math.Clamp(math.TimeFraction(animStart, animStart + .5, CurTime()), 0, 1)), distFrac)
	fadeFrac = math.min(scaleFrac, dist2DFrac)

	if not needsRedraw or distFrac <= 0 then return end
	prevCracker = HUDCracker
	prevOptimizing = bKeypads.Performance:Optimizing()

	if distFrac == 1 and not HUDCracker.m_bESPSeen then
		HUDCracker:EmitSound(bKeypads.Cracker.Sounds["warning"].path, 511)
	end
	HUDCracker.m_bESPSeen = true

	if not RT then
		RT = GetRenderTarget("bKeypads_CrackerESPxxxxxxxxxxx", circleDiameter, circleDiameter)
		RTMat:SetTexture("$basetexture", RT:GetName())
		RTMat:Recompute()
	end

	local ang = (EyePos - WorldSpaceCenter):Angle()
	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), 90)
	
	render.PushRenderTarget(RT)

		render.Clear(0, 0, 0, 0, true)
		render.OverrideAlphaWriteEnable(true, true)
		render.SetWriteDepthToDestAlpha(false)

		cam.Start2D()
			draw.NoTexture()
			surface.SetDrawColor(255, 255, 255)
			surface.DrawPoly(circlePoly)

			surface.SetMaterial(matRadial)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawPoly(circlePoly)

			if bKeypads.Performance:Optimizing() then
				local imgW, imgH = circleDiameter, (128 / 256) * circleDiameter
				surface.SetMaterial(matKeypadCracker)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect((circleDiameter - imgW) / 2, circleRadius - ((128 / 256) * circleDiameter) / 1.5, imgW, imgH)
			end
		cam.End2D()

		if not bKeypads.Performance:Optimizing() then
			if not IsValid(bKeypads_ClientsideESPCracker) then
				bKeypads_ClientsideESPCracker = ClientsideModel("models/bkeypads/cracker.mdl", RENDERGROUP_OTHER)
				bKeypads_ClientsideESPCracker:SetNoDraw(true)
			end

			local FOV = 60
			local camPos = WorldSpaceCenter + HUDCracker:GetUp() * 10
			local camAng = HUDCracker:GetAngles()
			camAng:RotateAroundAxis(camAng:Right(), -90)

			cam.Start3D(camPos, camAng, FOV, 0, 0, circleDiameter, circleDiameter, 5, 4096)
				render.SuppressEngineLighting(true)
					bKeypads_ClientsideESPCracker:SetModelScale(HUDCracker:GetModelScale())
					bKeypads_ClientsideESPCracker:SetPos(HUDCracker:GetPos())
					bKeypads_ClientsideESPCracker:SetAngles(HUDCracker:GetAngles())
					bKeypads_ClientsideESPCracker:SetupBones()
					bKeypads_ClientsideESPCracker:DrawModel()
					HUDCracker.DrawWorldScreen(bKeypads_ClientsideESPCracker)
				render.SuppressEngineLighting(false)
			cam.End3D()
		end

		render.OverrideAlphaWriteEnable(false)

	render.PopRenderTarget()
end

function bKeypads.Cracker:PreDrawViewModel()
	if not RTMat or not IsValid(HUDCracker) then return end

	scaleMatrix:SetUnpacked(
		scaleFrac, 0, 0, (1 - scaleFrac) * x,
		0, scaleFrac, 0, (1 - scaleFrac) * y,
		0, 0, 0, 0,
		0, 0, 0, 1
	)
	
	cam.Start2D()
		cam.PushModelMatrix(scaleMatrix)
			surface.SetDrawColor(255, 255, 255, fadeFrac * 255)
			bKeypads:DrawSubpixelClippedMaterial(RTMat, x - (circleRadius), y - (circleRadius), circleDiameter, circleDiameter)
		cam.PopModelMatrix()
	cam.End2D()
end

if bKeypads.Cracker.Config and bKeypads.Cracker.Config.SeeDroppedCrackerThroughWalls then
	hook.Add("PreDrawViewModel", "bKeypads.Cracker.PreDrawViewModel", bKeypads.Cracker.PreDrawViewModel)
	hook.Add("PostDrawTranslucentRenderables", "bKeypads.Cracker.PostDrawTranslucentRenderables", bKeypads.Cracker.PostDrawTranslucentRenderables)
else
	hook.Remove("PreDrawViewModel", "bKeypads.Cracker.PreDrawViewModel")
	hook.Remove("PostDrawTranslucentRenderables", "bKeypads.Cracker.PostDrawTranslucentRenderables")
end

if IsValid(bKeypads_ClientsideESPCracker) then bKeypads_ClientsideESPCracker:Remove() end