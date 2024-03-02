local L = bKeypads.L

local developer = GetConVar("developer")
local gmod_language

if bKeypads.Tutorial and IsValid(bKeypads.Tutorial.Menu) then
	bKeypads.Tutorial.Menu:Close()
end

bKeypads.Tutorial = {}

--## CONSTANTS ##--

local GRADIENT = Material("bkeypads/darken_gradient.png")
local GRADIENT_LIGHT = Material("bkeypads/darken_gradient_light.png")
local GRADIENT_LARGE = Material("bkeypads/darken_gradient_large.png")
local GRADIENT_LIGHT_LARGE = Material("bkeypads/darken_gradient_light_large.png")

local playerModels = {
	"models/player/Group01/Female_01.mdl",
	"models/player/Group01/Female_02.mdl",
	"models/player/Group01/Female_03.mdl",
	"models/player/Group01/Female_04.mdl",
	"models/player/Group01/Female_06.mdl",
	"models/player/group01/male_01.mdl",
	"models/player/Group01/Male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/Male_04.mdl",
	"models/player/Group01/Male_05.mdl",
	"models/player/Group01/Male_06.mdl",
	"models/player/Group01/Male_07.mdl",
	"models/player/Group01/Male_08.mdl",
	"models/player/Group01/Male_09.mdl"
}

local matToolgunTrace = Material("effects/tool_tracer")

local DRAW_MODEL_BITMASK_BOTH_1 = bit.bor(STUDIO_TWOPASS, STUDIO_RENDER)
local DRAW_MODEL_BITMASK_BOTH_2 = bit.bor(STUDIO_TWOPASS, STUDIO_RENDER, STUDIO_TRANSPARENCY)

--## SCENE DATA ##--

local activeScene
local activeFrame
local sceneStart
local sceneFrame
local sceneFrameStart
local sceneFrameMasterSequence
local sceneFrameTimeDelta
local sceneFramePrevFrameTimestamp
local sceneFrameObjects
local sceneFrameCaptionOverride
local sceneAdvanceFrame
local sceneCenter
local sceneTransitioning
local circleCamLastFrame
local circleCamLag

bKeypads.Tutorial.Shortcuts = {}
hook.Add("bKeypads.TutorialScenes", "bKeypads.Tutorial.Shortcuts", function()
	for _, category in ipairs(bKeypads.Tutorial.Categories) do
		if not category.Scenes then continue end
		for _, scene in ipairs(category.Scenes) do
			if istable(scene) and scene.Shortcut then
				bKeypads.Tutorial.Shortcuts[scene.Shortcut] = scene
			end
		end
	end
end)

local function InterpolateLanguageStrings(str, second_pass)
	local i = 1
	while true do
		local startPos, endPos = str:find("%%.-%%", i)
		if not startPos then break end
		str = str:sub(1, startPos - 1) .. (second_pass and bKeypads.L(str:sub(startPos + 1, endPos - 1)) or InterpolateLanguageStrings(bKeypads.L(str:sub(startPos + 1, endPos - 1)), true)) .. str:sub(endPos + 1)
		i = endPos + 1
	end
	return str
end

function bKeypads.Tutorial:GetSceneObject(objName)
	return sceneFrameObjects and sceneFrameObjects[objName] or NULL
end

--## SCENE RENDERING ##--

local sceneRT
local sceneRTMat

local sceneRTTransition
local sceneRTTransitionMat

local function createSceneRT()
	sceneRT = GetRenderTargetEx("bKeypads_Tutorial_SceneRT_" .. ScrW() .. "x" .. ScrH(), ScrW(), ScrH(), RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SHARED, bit.bor(512, 32768, 16, 4, 8, 8192), CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_BGRA8888)

	sceneRTMat = CreateMaterial("bKeypads_Tutorial_SceneRT", "UnlitGeneric", {
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
	})

	sceneRTMat:SetTexture("$basetexture", sceneRT:GetName())
	sceneRTMat:Recompute()

	sceneRTTransition = GetRenderTargetEx("bKeypads_Tutorial_SceneRT_Transition_" .. ScrW() .. "x" .. ScrH(), ScrW(), ScrH(), RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SHARED, bit.bor(512, 32768, 16, 4, 8, 8192), CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_BGRA8888)

	sceneRTTransitionMat = CreateMaterial("bKeypads_Tutorial_SceneRT_Transition", "UnlitGeneric", {
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
	})

	sceneRTTransitionMat:SetTexture("$basetexture", sceneRTTransition:GetName())
	sceneRTTransitionMat:Recompute()

	bKeypads.Tutorial.SCENE_RT = sceneRT
end
local function initSceneRT()
	hook.Add("OnScreenSizeChanged", "bKeypads.Tutorial.SceneRT", createSceneRT) createSceneRT()
end

local function DrawToolgunTracer(Life, StartPos, EndPos)
	local Alpha = 255 * (1 - Life)
	if Alpha < 1 then return end

	render.SetMaterial(matToolgunTrace)
	local texcoord = math.Rand(0, 1)

	local norm = (StartPos - EndPos) * Life
	local Length = norm:Length()

	for i = 1, 3 do
		render.DrawBeam(StartPos - norm, EndPos, 8, texcoord, texcoord + Length / 128, color_white)
	end

	render.DrawBeam(StartPos, EndPos, 8, texcoord, texcoord + ((StartPos - EndPos):Length() / 128), Color(255, 255, 255, 128 * (1 - Life)))

	Life = Life + FrameTime() * 4
	return Life
end

local function DrawModel(ent)
	if ent:GetRenderGroup() == RENDERGROUP_BOTH then
		ent:DrawModel(DRAW_MODEL_BITMASK_BOTH_1)
		ent:DrawModel(DRAW_MODEL_BITMASK_BOTH_2)
	else
		ent:DrawModel()
	end
end

-- Stupid hack to render halos in the correct 3D context
bKeypads_cam_Start3D = bKeypads_cam_Start3D or cam.Start3D
bKeypads_cam_End3D = bKeypads_cam_End3D or cam.End3D
local function noop() end

-- Stupid hack to render 3D2D UI on entities correctly
local sceneX, sceneY
local cam_Start3D2D, cam_End3D2D do
	local scene3D2DMatrix, scene3D2DVec = Matrix(), Vector()
	local scene3D2DPushed = false
	function cam_Start3D2D(pos, ang, scale)
		if not sceneX or not sceneY then
			scene3D2DPushed = false
			cam.Start3D2D(pos, ang, scale)
		else
			local translation = Vector(pos)
			translation:Add(ang:Forward() * (-sceneX * scale))
			translation:Add(ang:Right() * (-sceneY * scale))
			translation:Sub(ang:Up())

			scene3D2DMatrix:SetAngles(ang)
			scene3D2DMatrix:SetTranslation(translation)

			scene3D2DVec:SetUnpacked(scale, -scale, 1)
			scene3D2DMatrix:SetScale(scene3D2DVec)

			cam.PushModelMatrix(scene3D2DMatrix, true)

			scene3D2DPushed = true
		end
	end
	function cam_End3D2D()
		if scene3D2DPushed then
			cam.PopModelMatrix()
		else
			cam.End3D2D()
		end
	end
end

-- Stupid hack to clip 3D2D UI properly
local function clip_Scissor2D(self, w, h)
	bKeypads.clip:Scissor2D(w, h, self.ClipX, self.ClipY, self.ClipZ)
end

-- Hack to render sprites properly
bKeypads_Tutorial_EyePos = bKeypads_Tutorial_EyePos or EyePos
bKeypads_Tutorial_EyeAngles = bKeypads_Tutorial_EyeAngles or EyeAngles

local camPos, camAng
local function EyePos_Hack()
	return camPos or bKeypads_Tutorial_EyePos()
end
local function EyeAngles_Hack()
	return camAng or bKeypads_Tutorial_EyeAngles()
end

-- Dumb easing function for walking
local function walkEase(x)
	return x == 1 and 1 or 1 - (2 ^ (-20 * x))
end

if bKeypads_Tutorial_SceneObjects then for _, ent in pairs(bKeypads_Tutorial_SceneObjects) do if IsValid(ent) then ent:Remove() end end end
bKeypads_Tutorial_SceneObjects = nil
-- lua_run_cl for _, v in ipairs(ents.GetAll()) do if v:EntIndex() == -1 then v:Remove() end end

if bKeypads_Tutorial_ScenePanels then for _, ent in pairs(bKeypads_Tutorial_ScenePanels) do if IsValid(ent) then ent:Remove() end end end
bKeypads_Tutorial_ScenePanels = nil

function bKeypads.Tutorial:ClearScene()
	if sceneFrameObjects then
		for _, ent in ipairs(sceneFrameObjects) do
			if IsValid(ent) then
				ent:Remove()
			end
			if ent.Particles and ent.Particles:IsValid() then
				ent.Particles:StopEmissionAndDestroyImmediately()
			end
		end
	end
	if sceneFramePanels then
		for _, pnl in ipairs(sceneFramePanels) do
			if IsValid(pnl) then
				pnl:Remove()
			end
		end
	end
end

function bKeypads.Tutorial:SetupScene(scene)
	if not scene.Frames or not scene.Frames[1] then return end

	if initSceneRT then
		initSceneRT()
		initSceneRT = nil
	end

	activeScene = scene
	activeFrame = scene.Frames[1]
	sceneStart = CurTime()
	sceneTransitioning = nil
	sceneFrameStart = nil
	sceneFramePrevFrameTimestamp = CurTime()
	sceneFrame = 1
	sceneCenter, sceneMins, sceneMaxs = Vector(), Vector(), Vector()
	sceneFrameMasterSequence = nil
	sceneAdvanceFrame = nil
	sceneFrameCaptionOverride = nil
	circleCamLastFrame = nil
	circleCamLag = 0
	sceneX, sceneY = nil, nil

	bKeypads.Tutorial:SetupFrame(activeFrame)
end

function bKeypads.Tutorial:StopScene()
	bKeypads.Tutorial:ClearScene()

	bKeypads.Tutorial.Menu.Scene.ActiveScene = nil
	bKeypads.Tutorial.Menu.Scene.m_tTVAnimation = nil

	activeScene = nil
	activeFrame = nil
	sceneStart = nil
	sceneTransitioning = nil
	sceneFrameStart = nil
	sceneFrame = nil
	sceneCenter, sceneMins, sceneMaxs = nil, nil, nil
	sceneFrameMasterSequence = nil
	sceneFrameTimeDelta = nil
	sceneFramePrevFrameTimestamp = nil
	sceneAdvanceFrame = nil
	sceneFrameObjects = nil
	sceneFramePanels = nil
	sceneFrameCaptionOverride = nil
	bKeypads_Tutorial_SceneObjects = nil
	bKeypads_Tutorial_ScenePanels = nil
	circleCamLastFrame = nil
	circleCamLag = nil
	sceneX, sceneY = nil, nil

	EyePos = bKeypads_Tutorial_EyePos
	EyeAngles = bKeypads_Tutorial_EyeAngles
end

function bKeypads.Tutorial:SetupFrame(frame)
	bKeypads.Tutorial:ClearScene()

	sceneCenter, sceneMins, sceneMaxs = Vector(), Vector(), Vector()

	sceneFrameMasterSequence = nil

	sceneFrameCaptionOverride = nil

	sceneFrameObjects = {}
	bKeypads_Tutorial_SceneObjects = sceneFrameObjects

	sceneFramePanels = {}
	bKeypads_Tutorial_ScenePanels = sceneFramePanels

	if frame.Panels then
		for _, pnlObj in ipairs(frame.Panels) do
			local pnl
			if isstring(pnlObj[1]) then
				pnl = vgui.Create(pnlObj[1], bKeypads.Tutorial.Menu.Scene)
			elseif isfunction(pnlObj[1]) then
				pnl = pnlObj[1](bKeypads.Tutorial.Menu.Scene)
			end

			if not IsValid(pnl) or not ispanel(pnl) then
				ErrorNoHalt("Failed to create panel \"" .. tostring(pnlObj[1]) .. "\"!\n")
				continue
			end

			table.insert(sceneFramePanels, pnl)

			if not pnlObj.SuppressFade then
				pnl:SetAlpha(0)
				pnl.bKeypads_FadeAlpha = true
			end

			if isfunction(pnlObj[2]) then pnlObj[2](pnl, bKeypads.Tutorial.Menu.Scene:GetWide(), bKeypads.Tutorial.Menu.Scene:GetTall()) end
		end
	end

	if frame.Objects then
		for _, obj in ipairs(frame.Objects) do
			local ent
			local isClientsideSENT
			if obj.Class == "Player" then

				ent = ClientsideModel(playerModels[math.random(1, #playerModels)], RENDERGROUP_OPAQUE)
				ent:UseClientSideAnimation()
				ent:ResetSequenceInfo()

				if developer:GetInt() >= 2 then
					for id, sequence in SortedPairsByValue(ent:GetSequenceList()) do
						print(id, sequence)
					end
					print(ent:GetModel())
				end

				if obj.Weapon then
					ent.m_sWeapon = obj.Weapon

					ent.Weapon = ClientsideModel(obj.Weapon, RENDERGROUP_OPAQUE)
					ent.Weapon:SetMoveType(MOVETYPE_NONE)
					ent.Weapon:SetParent(ent, ent:LookupAttachment("anim_attachment_RH"))
					ent.Weapon:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
					ent.Weapon:SetNoDraw(true)
					ent.Weapon:SetOwner(ent)
					ent.Weapon:SetSolid(SOLID_NONE)
					ent.Weapon:Spawn()
					ent.Weapon:Activate()

					if obj.HoldType then
						ent.HoldType = obj.HoldType
					end

					table.insert(sceneFrameObjects, ent.Weapon)
				end

			elseif obj.Class == "prop_physics" then
				ent = ents.CreateClientProp(obj.Model, RENDERGROUP_OPAQUE)
			else
				ent = ents.CreateClientside(obj.Class)
				isClientsideSENT = true
			end

			if not IsValid(ent) then
				ErrorNoHalt("Failed to create \"" .. obj.Class .. "\" (" .. tostring(ent) .. ") clientside!\n")
				continue
			end

			ent.bKeypads_Tutorial = true

			ent.FrameObject = obj

			ent:SetPredictable(false)
			ent:SetLOD(0)
			ent:SetNoDraw(true)

			if obj.Sequence then
				ent.Sequence = obj.Sequence
				if obj.MasterSequence then
					ent.MasterSequence = true
					sceneFrameMasterSequence = {
						ent = ent,
						Sequence = ent.MasterSequence
					}
				end
			end

			if ent.MasterSequence then
				table.insert(sceneFrameObjects, 1, ent)
			else
				table.insert(sceneFrameObjects, ent)
			end
			if obj.ID then
				sceneFrameObjects[obj.ID] = ent
			end

			if obj.Class ~= "prop_physics" and obj.Model then
				ent:SetModel(obj.Model)
			end

			if obj.Material then
				ent:SetMaterial(obj.Material)
			end

			if obj.Class ~= "Player" then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
				ent:SetMoveType(MOVETYPE_NONE)
			end

			ent.OriginPos = ent:GetPos()

			ent:Spawn()

			local mins, maxs
			for i = 1, 3 do
				if i == 1 then
					mins, maxs = ent:GetModelBounds()
				elseif i == 2 then
					mins, maxs = ent:GetCollisionBounds()
				elseif i == 3 then
					mins, maxs = ent:GetRenderBounds()
				end
				if mins and maxs then break end
			end
			if mins and maxs then
				if obj.Class == "Player" then mins.z = 0 end

				local center = (maxs + mins) / 2
				center.z = mins.z
				ent:SetPos(ent:GetPos() - ent:LocalToWorld(center))
			end

			if obj.Translate then
				ent:SetPos(ent:GetPos() + obj.Translate)
			end
			if obj.Angle then
				ent:SetAngles(obj.Angle)
			end

			if obj.Class == "Player" then
				if ent.HoldType then
					ent:ResetSequence("walk_" .. ent.HoldType)
				else
					local seq = ent:SelectWeightedSequence(ACT_WALK)
					ent:ResetSequence(seq ~= -1 and seq or "walk_all")
				end
			end

			if isClientsideSENT then
				ent.Start3D2D = cam_Start3D2D
				ent.End3D2D = cam_End3D2D
				ent.Scissor2D = clip_Scissor2D
				ent.m_ForceSupressEngineLighting = true
				if ent.TutorialInitialize then
					ent:TutorialInitialize()
				end

				if obj.NetworkVars then
					for key, val in pairs(obj.NetworkVars) do
						assert(isfunction(ent["Set" .. key]), "NetworkVar setter \"" .. tostring(key) .. "\" does not exist!")
						ent["Set" .. key](ent, val)
					end
				end
			end
		end
	end
end

local circleVec = Vector()
function bKeypads.Tutorial:RenderScene(x, y, w, h, paused)
	if not bKeypads or not bKeypads.Tutorial or not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then return end

	local activeScene = bKeypads.Tutorial.Menu.Scene.ActiveScene
	if not activeScene or not activeScene.Frames then return end

	sceneX, sceneY = x, y

	local activeFrame = bKeypads.Tutorial.Menu.Scene.ActiveScene.Frames[sceneFrame]
	if not activeFrame then bKeypads.Tutorial:StopScene() return end

	sceneFrameTimeDelta = (CurTime() - sceneFramePrevFrameTimestamp)
	sceneFramePrevFrameTimestamp = CurTime()

	if paused or not sceneFrameStart then
		sceneFrameStart = CurTime()
	end

	local FOV = activeFrame.FOV or 110
	local CameraFocus = sceneCenter
	if activeFrame.CameraFocus and IsValid(sceneFrameObjects[activeFrame.CameraFocus]) then
		CameraFocus = sceneFrameObjects[activeFrame.CameraFocus]:WorldSpaceCenter()
	end

	local frameDelta = CurTime() - (sceneFrameStart or CurTime())
	local sceneDelta = CurTime() - (sceneStart or CurTime())

	local circleCamDelta
	if activeFrame.CircularCam == false or activeScene.CircularCam == false or not activeFrame.Objects or #activeFrame.Objects == 0 then
		circleCamLag = circleCamLag + (CurTime() - (circleCamLastFrame or CurTime()))
		if activeFrame.CameraFocus and IsValid(sceneFrameObjects[activeFrame.CameraFocus]) then
			circleCamDelta = 0
		else
			circleCamDelta = activeFrame.CircularCamFactor or 0
		end
	else
		circleCamDelta = (CurTime() - (sceneStart or CurTime())) - circleCamLag
	end
	circleCamLastFrame = CurTime()

	local timeStep = ((circleCamDelta / 8) % 2) * math.pi
	circleVec.x = math.sin(timeStep)
	circleVec.y = math.cos(timeStep)

	local sceneSizeX, sceneSizeY, sceneSizeZ = sceneMaxs.x - sceneMins.x, sceneMaxs.y - sceneMins.y, sceneMaxs.z - sceneMins.z

	local sceneTranslation = activeFrame.SceneTranslate or activeScene.SceneTranslate
	if sceneTranslation then sceneSizeX, sceneSizeY, sceneSizeZ = sceneSizeX + sceneTranslation.x, sceneSizeY + sceneTranslation.y, sceneSizeZ + sceneTranslation.z end

	local camDist = (math.max(sceneSizeX, sceneSizeY, sceneSizeZ)) * (1 + (1 / math.tan(math.rad(FOV / 2))))

	local camFocalPoint = Vector(CameraFocus)
	camFocalPoint:Sub(camDist * circleVec)
	camFocalPoint.z = sceneCenter.z

	local camTranslate = activeFrame.CameraTranslate or activeScene.CameraTranslate
	if camTranslate then
		camFocalPoint:Add(camTranslate)
	end

	local lookAt = Vector(CameraFocus)
	lookAt.z = sceneCenter.z

	local camPos = Vector(camFocalPoint)
	if not activeScene.CameraCenterZ then
		camPos.z = camPos.z * 1.1
		lookAt.z = lookAt.z * 0.9
	end

	local shootPos
	local shootVec

	local RTWidth, RTHeight = sceneRT:Width(), sceneRT:Height()
	local RTViewportX, RTViewportY = (RTWidth - w) / 2, (RTHeight - h) / 2

	cam.Start3D = bKeypads_cam_Start3D
	cam.End3D = bKeypads_cam_End3D

	render.PushRenderTarget(sceneRT)

	render.SetWriteDepthToDestAlpha(false)
	render.OverrideAlphaWriteEnable(true, true)
	render.OverrideDepthEnable(true, true)

	-- TODO faceid for keypad owner PIN for everyone else

	render.Clear(bKeypads.COLOR.GMODBLUE.r, bKeypads.COLOR.GMODBLUE.g, bKeypads.COLOR.GMODBLUE.b, 255, true, false)

	local _ScrW, _ScrH = ScrW(), ScrH()
	render.SetViewPort(RTViewportX, RTViewportY, w, h)

	cam.Start2D()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(GRADIENT_LIGHT_LARGE)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		render.ClearDepth()
	cam.End2D()

	render.OverrideAlphaWriteEnable(false)
	render.OverrideDepthEnable(false)

	if activeScene.CameraPos or activeFrame.CameraPos then
		camPos = activeScene.CameraPos or activeFrame.CameraPos
	end

	if activeScene.CameraAngle or activeFrame.CameraAngle then
		camAng = activeScene.CameraAngle or activeFrame.CameraAngle
	else
		camAng = (lookAt - camFocalPoint):Angle()
	end

	EyePos = EyePos_Hack
	EyeAngles = EyeAngles_Hack

	cam.Start3D(camPos, camAng, FOV, 0, 0, RTWidth, RTHeight, 1, 99999999999)

	--render.SetColorMaterialIgnoreZ()
	--render.DrawBox(vector_origin, angle_zero, sceneMins, sceneMaxs, Color(255,0,0), false)

		render.SuppressEngineLighting(true)
		render.SetLightingOrigin(vector_origin)
		render.ResetModelLighting(1, 1, 1)
		render.SetColorModulation(1, 1, 1)
		render.SetAmbientLight(1, 1, 1)

			local rayEnts
			local rayEntsDict
			if activeFrame.Raycast and IsValid(sceneFrameObjects["PLAYER"]) then
				local ply = sceneFrameObjects["PLAYER"]
				local eyes = ply:LookupAttachment("eyes")
				if eyes ~= -1 then
					local aim_pitch, aim_yaw = ply:LookupPoseParameter("aim_pitch"), ply:LookupPoseParameter("aim_yaw")
					if aim_pitch ~= -1 and aim_yaw ~= -1 then
						local pMins, pMaxs = ply:GetPoseParameterRange(aim_pitch)
						local aim_pitch = math.Remap(ply:GetPoseParameter("aim_pitch"), 0, 1, pMins, pMaxs)

						local yMins, yMaxs = ply:GetPoseParameterRange(aim_yaw)
						local aim_yaw = math.Remap(ply:GetPoseParameter("aim_yaw"), 0, 1, yMins, yMaxs)

						local eyeAngles = Angle(aim_pitch, aim_yaw, 0)

						shootPos = ply:GetAttachment(eyes).Pos
						shootVec = eyeAngles:Forward()

						rayEnts, rayEntsDict = {}, {}
						for _, ent in ipairs(ents.FindAlongRay(shootPos, shootPos + (shootVec * (sceneFrameObjects.RaycastDist or 256)), vector_origin, vector_origin)) do
							if ent.bKeypads_Tutorial and ent ~= ply and ent:GetParent() ~= ply then
								table.insert(rayEnts, ent)
								rayEntsDict[ent] = true
							end
						end
					end
				end
			end

			local shootToolgunAt
			local shootToolgunFrom

			local halos, linkingBeams

			local masterSequenceAdvance
			for _, ent in ipairs(sceneFrameObjects) do
				if ent.bKeypad then ent.ClipX, ent.ClipY, ent.ClipZ = sceneX, sceneY, 1 end

				ent.SingularRef = { ent }

				if ent.Sequence then
					if not ent.m_iCurrentSequence then
						ent.m_iCurrentSequence = 1
					end

					local curSequence = ent.Sequence[ent.m_iCurrentSequence]
					if curSequence then
						if curSequence.Halo then
							halos = halos or {}
							curSequence.Halo.Ents = ent.SingularRef
							table.insert(halos, curSequence.Halo)
						end
						if curSequence.DrawLinkingBeam then
							linkingBeams = linkingBeams or {}
							table.insert(linkingBeams, curSequence.DrawLinkingBeam)
						end
					end

					if paused then goto drawEnt end

					if masterSequenceAdvance or (ent.m_iSequenceEnd and CurTime() >= ent.m_iSequenceEnd) then
						ent.m_iSequenceEnd = nil
						ent.m_iCurrentSequence = ent.m_iCurrentSequence + 1
						ent.m_bSequencePlaying = false
						if ent.MasterSequence then
							masterSequenceAdvance = true
						end

						curSequence = ent.Sequence[ent.m_iCurrentSequence]
					end

					if curSequence then
						if curSequence.Caption then
							sceneFrameCaptionOverride = curSequence.Caption
						elseif curSequence.Caption == false then
							sceneFrameCaptionOverride = nil
						end

						local seq = -1
						--local layeredSeq = -1
						if isstring(curSequence[1]) then
							local startPos, endPos = curSequence[1]:find("%%HOLDTYPE%%")
							if startPos and endPos then
								seq = ent:LookupSequence(curSequence[1]:sub(1, startPos - 1) .. (ent.HoldType or "all") .. curSequence[1]:sub(endPos + 1))
							else
								seq = ent:LookupSequence(curSequence[1])
							end
						end

						if not ent.m_bSequencePlaying then
							ent.OriginPos = ent:GetPos()
							ent.m_bSequencePlaying = true
							ent.m_iSequenceStart = CurTime()
							ent.m_aLookAng = nil
							ent.m_fAimPitch = nil
							ent.m_fAimYaw = nil
							ent.m_fHeadPitch = nil
							ent.m_fHeadYaw = nil

							if seq ~= -1 then
								ent:SetSequence(seq)
								ent:SetCycle(0)
							end

							if curSequence.WalkTo then ent:SetCycle(0) end
							--if layeredSeq ~= -1 then
							--	ent:SetLayerSequence(0, layeredSeq)
							--	ent:SetLayerPlaybackRate(0, 1)
							--	ent:SetLayerCycle(0, 0)
							--	ent:SetLayerWeight(0, 1)
							--end

							if curSequence.Duration then
								ent.m_iSequenceEnd = CurTime() + curSequence.Duration
							end

							if isfunction(curSequence[1]) then
								curSequence[1](ent)
							end

							if curSequence.ShootToolgun and IsValid(ent.Weapon) then
								local shootAt = sceneFrameObjects[curSequence.ShootToolgun]
								if IsValid(shootAt) then
									surface.PlaySound("weapons/airboat/airboat_gun_lastshot1.wav")
								end
							end

							if curSequence.Weapon == false then
								surface.PlaySound("npc/combine_soldier/gear5.wav")
								if IsValid(ent.Weapon) then
									table.RemoveByValue(sceneFrameObjects, ent.Weapon)
									ent.Weapon:Remove()
								end
								ent.HoldType = nil
								if seq == -1 then
									local seq = ent:SelectWeightedSequence(ACT_WALK)
									ent:ResetSequence(seq ~= -1 and seq or "walk_all")
								end
							end
						end

						if curSequence.ShootToolgun then
							--layeredSeq = ent:SelectWeightedSequence(ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER)

							local shootAt = sceneFrameObjects[curSequence.ShootToolgun]
							if IsValid(shootAt) and (not ent.Weapon.m_iToolgunTracerLife or ent.Weapon.m_iToolgunTracerLife < 1) then
								shootToolgunFrom = ent.Weapon
								shootToolgunAt = shootAt
							end
						elseif IsValid(ent.Weapon) then
							ent.Weapon.m_iToolgunTracerLife = nil
						end

						if curSequence.WalkTo then
							local walkDir = (curSequence.WalkTo - ent:GetPos())
							local walkLength = walkDir:Length()

							if not curSequence.WalkLength then curSequence.WalkLength = (curSequence.WalkTo - ent.OriginPos):Length() end
							local progress = walkLength / curSequence.WalkLength

							if progress - 0.01 <= 0 then
								ent.m_iCurrentSequence = ent.m_iCurrentSequence + 1
								ent.m_bSequencePlaying = false

								if ent.MasterSequence then
									masterSequenceAdvance = true
								end
							else
								walkDir:Normalize()

								local walkSpeed = walkDir * walkEase(progress)
								ent:SetPoseParameter("move_x", walkSpeed.x)
								ent:SetPoseParameter("move_y", walkSpeed.y)
								ent:InvalidateBoneCache()

								walkDir:Mul(ent:GetSequenceGroundSpeed(ent:GetSequence()) * sceneFrameTimeDelta)
								walkDir:Add(ent:GetPos())
								ent:SetPos(walkDir)
							end
						else
							local from, to = ent:GetPoseParameterRange(ent:LookupPoseParameter("move_x"))
							if from and to then ent:SetPoseParameter("move_x", math.Remap(ent:GetPoseParameter("move_x"), 0, 1, from, to) * .95) end
							local from, to = ent:GetPoseParameterRange(ent:LookupPoseParameter("move_y"))
							if from and to then ent:SetPoseParameter("move_y", math.Remap(ent:GetPoseParameter("move_y"), 0, 1, from, to) * .95) end
							ent:InvalidateBoneCache()
						end

						if curSequence.LookAt then
							local eyes = ent:LookupAttachment("eyes")
							if eyes ~= -1 then
								local shootPos = ent:GetAttachment(eyes).Pos

								local lookEnt = sceneFrameObjects[curSequence.LookAt]
								if IsValid(lookEnt) then
									local lookFrac = curSequence.Duration and bKeypads.ease.InOutCubic(math.TimeFraction(ent.m_iSequenceStart, ent.m_iSequenceStart + curSequence.Duration, CurTime())) or 1

									if not ent.m_aLookAng then
										ent.m_aLookAng = ent:GetAngles()
									end

									local lookAng = (lookEnt:GetPos() - shootPos):Angle()
									lookAng:Normalize()

									local aim_pitch, aim_yaw = lookAng.p, lookAng.y
									lookAng.r = 0
									lookAng.p = 0

									if not ent.m_fAimPitch then
										local aim_pitch = ent:LookupPoseParameter("aim_pitch")
										if aim_pitch ~= -1 then
											local pMins, pMaxs = ent:GetPoseParameterRange(aim_pitch)
											ent.m_fAimPitch = math.Remap(ent:GetPoseParameter("aim_pitch"), 0, 1, pMins, pMaxs)
										end
									end
									if ent.m_fAimPitch then ent:SetPoseParameter("aim_pitch", Lerp(lookFrac, ent.m_fAimPitch, aim_pitch)) end

									if not ent.m_fAimYaw then
										local aim_yaw = ent:LookupPoseParameter("aim_yaw")
										if aim_yaw ~= -1 then
											local yMins, yMaxs = ent:GetPoseParameterRange(aim_yaw)
											ent.m_fAimYaw = math.Remap(ent:GetPoseParameter("aim_yaw"), 0, 1, yMins, yMaxs)
										end
									end
									if ent.m_fAimYaw then ent:SetPoseParameter("aim_yaw", Lerp(lookFrac, ent.m_fAimYaw, aim_yaw)) end

									local head_pitch = ent:LookupPoseParameter("head_pitch")
									if head_pitch ~= -1 then
										local pMins, pMaxs = ent:GetPoseParameterRange(head_pitch)
										if not ent.m_fHeadPitch then
											ent.m_fHeadPitch = math.Remap(ent:GetPoseParameter("head_pitch"), 0, 1, pMins, pMaxs)
										end
										ent:SetPoseParameter("head_pitch", Lerp(lookFrac, ent.m_fHeadPitch, math.Clamp(aim_pitch, pMins, pMaxs)))
									end

									local head_yaw = ent:LookupPoseParameter("head_yaw")
									if head_yaw ~= -1 then
										local yMins, yMaxs = ent:GetPoseParameterRange(head_yaw)
										if not ent.m_fHeadYaw then
											ent.m_fHeadYaw = math.Remap(ent:GetPoseParameter("head_yaw"), 0, 1, yMins, yMaxs)
										end
										ent:SetPoseParameter("head_yaw", Lerp(lookFrac, ent.m_fHeadYaw, math.Clamp(aim_yaw, yMins, yMaxs)))
									end

									ent:InvalidateBoneCache()
								end
							end
						end

					elseif (sceneFrameMasterSequence == nil or ent.MasterSequence) and ent.m_iCurrentSequence >= #ent.Sequence then
						sceneAdvanceFrame = true
					end
				end

				::drawEnt::
				if not ent.AutomaticFrameAdvance then
					ent:FrameAdvance()
				end

				DrawModel(ent)

				if IsValid(ent.Weapon) then
					DrawModel(ent.Weapon)
				end

				if ent.Particles and ent.Particles:IsValid() then
					ent.Particles:Render()
				end

				if (not ent.m_iCurrentSequence or ent.m_iCurrentSequence == 1) and ent.FrameObject and not ent.FrameObject.OutOfFrame then
					local mins, maxs = ent:GetRotatedAABB(ent:GetModelBounds())
					mins, maxs = ent:LocalToWorld(mins), ent:LocalToWorld(maxs)

					if sceneMins:IsZero() then
						sceneMins = mins
					else
						sceneMins:SetUnpacked(
							math.min(sceneMins.x, mins.x),
							math.min(sceneMins.y, mins.y),
							math.min(sceneMins.z, mins.z)
						)
					end

					if sceneMaxs:IsZero() then
						sceneMaxs = maxs
					else
						sceneMaxs:SetUnpacked(
							math.max(sceneMaxs.x, maxs.x),
							math.max(sceneMaxs.y, maxs.y),
							math.max(sceneMaxs.z, maxs.z)
						)
					end

					local mins, maxs = ent:GetModelBounds()
					mins, maxs = ent:LocalToWorld(mins), ent:LocalToWorld(maxs)

					sceneMins:SetUnpacked(
						math.min(sceneMins.x, mins.x),
						math.min(sceneMins.y, mins.y),
						math.min(sceneMins.z, mins.z)
					)

					sceneMaxs:SetUnpacked(
						math.max(sceneMaxs.x, maxs.x),
						math.max(sceneMaxs.y, maxs.y),
						math.max(sceneMaxs.z, maxs.z)
					)
				end
			end

			if sceneMaxs and sceneMins then
				sceneCenter = (sceneMaxs + sceneMins) / 2
			end

			if shootToolgunFrom and shootToolgunAt then
				local muzzle = shootToolgunFrom:LookupAttachment("muzzle")
				shootToolgunFrom.m_iToolgunTracerLife = DrawToolgunTracer(shootToolgunFrom.m_iToolgunTracerLife or 0, shootToolgunFrom:GetAttachment(muzzle).Pos, shootToolgunAt:WorldSpaceCenter())
			end

		render.SuppressEngineLighting(false)

		if halos then
			cam.Start3D = noop
			cam.End3D = noop
				for _, entry in ipairs(halos) do
					if IsValid(entry.Ents[1]) and (not entry.Raycast or not rayEntsDict or rayEntsDict[entry.Ents[1]]) then
						halo.Render(entry)
					end
				end
			cam.Start3D = bKeypads_cam_Start3D
			cam.End3D = bKeypads_cam_End3D
		end

		if linkingBeams then
			bKeypads.ESP.AnimateDataBeam()
			for _, linkingBeam in ipairs(linkingBeams) do
				local ent1

				if istable(linkingBeam[1]) then
					local ent = sceneFrameObjects[linkingBeam[1][1]]
					if IsValid(ent) then
						if not shootPos or not rayEntsDict or rayEntsDict[ent] then
							ent1 = ent
						else
							ent1 = shootPos + (shootVec * (linkingBeam.MaxDist or 64))
						end
					end
				elseif isstring(linkingBeam[1]) then
					local ent = sceneFrameObjects[linkingBeam[1]]
					if IsValid(ent) then
						ent1 = ent
					end
				else
					ent1 = linkingBeam[1]
				end

				local ent2
				if istable(linkingBeam[2]) then
					local ent = sceneFrameObjects[linkingBeam[2][1]]
					if IsValid(ent) then
						if not shootPos or not rayEntsDict or rayEntsDict[ent] then
							ent2 = ent
						else
							ent2 = shootPos + (shootVec * (linkingBeam.MaxDist or 64))
						end
					end
				elseif isstring(linkingBeam[2]) then
					if IsValid(sceneFrameObjects[linkingBeam[2]]) then
						ent2 = sceneFrameObjects[linkingBeam[2]]
					end
				else
					ent2 = linkingBeam[2]
				end

				if ent1 and ent2 then
					local ignoreZ = bKeypads.ESP.IgnoreZ
					bKeypads.ESP.IgnoreZ = linkingBeam[5] ~= true
					cam.IgnoreZ(bKeypads.ESP.IgnoreZ)
						bKeypads.ESP.DrawDataBeam(ent1, ent2, linkingBeam[3], linkingBeam[4], linkingBeam[5])
					cam.IgnoreZ(false)
					bKeypads.ESP.IgnoreZ = ignoreZ
				end
			end
		end
	cam.End3D()

	EyePos = bKeypads_Tutorial_EyePos
	EyeAngles = bKeypads_Tutorial_EyeAngles

	local caption = sceneFrameCaptionOverride or activeFrame.Caption
	if caption then
		cam.Start2D()
			gmod_language = gmod_language or GetConVar("gmod_language")

			local marginX, marginY = 30, 30
			local txtWidth = ScrW() - (marginX * 2)
			local txtY = ScrH() - marginY

			local captionStr = InterpolateLanguageStrings(caption)
			if not activeFrame.MarkupObj or activeFrame.MarkupObj.str ~= captionStr or activeFrame.MarkupObj.w ~= w or activeFrame.MarkupObj.h ~= h or activeFrame.MarkupObj.lang ~= gmod_language:GetString() then
				activeFrame.MarkupObj = {
					bKeypads.markup.Parse("<font=bKeypads.Tutorial.Caption><color=255,255,255>" .. captionStr .. "</color></font>", txtWidth),
					w = w,
					h = h,
					lang = gmod_language:GetString(),
					str = captionStr
				}
			end

			activeFrame.MarkupObj[1]:Draw((ScrW() - txtWidth) / 2, txtY, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 255, TEXT_ALIGN_CENTER)
		cam.End2D()
	end

	render.OverrideAlphaWriteEnable(false)
	render.OverrideDepthEnable(false)
	render.SetViewPort(0, 0, _ScrW, _ScrH)
	render.PopRenderTarget()
end

local function ScenePaint(self, w, h)
	if not IsValid(bKeypads.Tutorial.Menu) then return end
	local x, y = self:LocalToScreen(0, 0)

	bKeypads.Tutorial:RenderScene(x, y, w, h, self.m_bTVAnimation == true or sceneTransitioning)

	local RTWidth, RTHeight = sceneRTTransition:Width(), sceneRTTransition:Height()

	if sceneTransitioning then

		bKeypads:TVAnimation(self, .5, w, h, true, x, y, bKeypads.ease.InOutSine)

			local frac = math.Clamp(math.TimeFraction(self.m_tTVAnimation.Start, self.m_tTVAnimation.Start + .5, CurTime()), 0, 1)
			if frac == 1 then sceneTransitioning = false end

			surface.SetAlphaMultiplier(1 - frac)

			local dc = DisableClipping(false)
				surface.SetDrawColor(255, 255, 255, 255)
				bKeypads:DrawSubpixelClippedMaterial(sceneRTTransitionMat, (w - RTWidth) / 2, (h - RTHeight) / 2, RTWidth, RTHeight)
			DisableClipping(dc)

			surface.SetAlphaMultiplier(1)

		bKeypads:TVAnimation(self)
	end

	bKeypads:TVAnimation(self, .5, w, h, self.ActiveScene == nil, x, y, bKeypads.ease.InOutSine)

		local frac = math.Clamp(math.TimeFraction(self.m_tTVAnimation.Start, self.m_tTVAnimation.Start + .5, CurTime()), 0, 1)
		if self.ActiveScene == nil then
			if frac == 1 then
				bKeypads:TVAnimation(self)
				self:SetVisible(false)
				return
			else
				frac = 1 - frac
			end
		end

		if sceneFramePanels then
			local fadeFrac = bKeypads.ease.OutSine(math.Clamp(math.TimeFraction(self.m_tTVAnimation.Start + .5, self.m_tTVAnimation.Start + .5 + .25, CurTime()), 0, 1))
			for _, pnl in ipairs(sceneFramePanels) do
				if pnl.bKeypads_FadeAlpha then
					pnl:SetAlpha(255 * fadeFrac)
				end
			end
		end

		surface.SetAlphaMultiplier(frac)

		local dc = DisableClipping(false)
			surface.SetDrawColor(255, 255, 255, 255)
			bKeypads:DrawSubpixelClippedMaterial(sceneRTMat, (w - RTWidth) / 2, (h - RTHeight) / 2, RTWidth, RTHeight)
		DisableClipping(dc)

		surface.SetAlphaMultiplier(1)

	bKeypads:TVAnimation(self)
end

local function SceneThink(self)
	if activeFrame and sceneFrame and (sceneAdvanceFrame or (activeFrame.Duration and sceneFrameStart and CurTime() - sceneFrameStart > activeFrame.Duration)) then
		sceneAdvanceFrame = nil
		sceneFrame = sceneFrame + 1
		if sceneFrame > #bKeypads.Tutorial.Menu.Scene.ActiveScene.Frames then
			surface.PlaySound("bkeypads/cracker/success.mp3")
			bKeypads.Tutorial:StopScene()
		else
			bKeypads.Tutorial.Menu.Scene.m_tTVAnimation = nil
			sceneTransitioning = true
			render.CopyTexture(sceneRT, sceneRTTransition)

			surface.PlaySound("npc/turret_floor/click1.wav")
			activeFrame = bKeypads.Tutorial.Menu.Scene.ActiveScene.Frames[sceneFrame]
			bKeypads.Tutorial:SetupFrame(activeFrame)
		end
	end
end

--## MENU ##--

local LOGO = Material("bkeypads/logo_wide_white.png", "smooth")

local function MenuPaint(self, w, h)
	surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
	surface.DrawRect(0, 0, w, 24)

	surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
	surface.DrawRect(0, 24 - 2, w, h - 24 + 2)

	surface.SetMaterial(GRADIENT_LIGHT_LARGE)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRectRotated(w / 2, ((24 + 2) + h) / 2, w, h - 24 + 2, 180)

	surface.SetDrawColor(bKeypads.COLOR.SLATE)
	surface.DrawRect(2, 24, w - 4, h - 24 - 2)

	local logo_w = (230 / 900) * w
	local logo_h = (128 / 335) * logo_w
	surface.SetMaterial(LOGO)
	surface.SetDrawColor(255, 255, 255, 100)
	surface.DrawTexturedRect(self.Categories:GetWide() + ((w - 4 - self.Categories:GetWide() - logo_w) / 2), 24 + ((h - 24 - 2) - logo_h) / 2, logo_w, logo_h)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(GRADIENT_LIGHT)
	surface.DrawTexturedRect(0, 0, w, 24)

	surface.SetDrawColor(255, 255, 255, 200)
	surface.SetMaterial(GRADIENT)
	surface.DrawTexturedRectRotated(self.Categories:GetWide() + (7 / 2), (h + (24 + 2)) / 2, h - 24 - 2, 7, -90)
end

local function SceneClicked(self)
	if not IsValid(bKeypads.Tutorial.Menu) then return end

	if self.Scene.Function or self.Scene.Setting then
		surface.PlaySound("bkeypads/cracker/success.mp3")
	end

	if self.Scene.Function then
		self.Scene.Function(self.Scene)
	end

	if self.Scene.Setting then
		if not IsValid(g_SpawnMenu) or not g_SpawnMenu:IsVisible() then
			RunConsoleCommand("+menu")
		end
		bKeypads:OpenSettings()

		local setting = self.Scene.Setting
		if setting ~= "" then
			timer.Simple(0, function() timer.Simple(0, function()
				if not bKeypads or not bKeypads.Settings or not IsValid(bKeypads.Settings.CPanel) or not bKeypads.Settings.CPanel:IsVisible() then return end

				local settingPnl = bKeypads.Settings.CPanel.SettingPanels[setting]
				if not IsValid(settingPnl) then return end

				bKeypads.Settings.CPanel.SmoothScroll:InvalidateLayout(true)

				local y = select(2, bKeypads.Settings.CPanel.SmoothScroll.pnlCanvas:ScreenToLocal(settingPnl:LocalToScreen(settingPnl:GetWide() / 2, settingPnl:GetTall() / 2)))
				y = y - (bKeypads.Settings.CPanel.SmoothScroll:GetTall())
				y = -y

				-- FIXME

				bKeypads.Settings.CPanel.SmoothScroll.pnlCanvas.TargetOffset = y
				bKeypads.Settings.CPanel.SmoothScroll.pnlCanvas.CurrentOffset = y
				print(y)

				local VBar = bKeypads.Settings.CPanel.SmoothScroll:GetVBar()
				VBar.TargetY = y
				VBar.CurrentY = y
				VBar:InvalidateLayout(true)

				timer.Simple(0, function()
					if not IsValid(settingPnl) or not settingPnl:IsVisible() then return end
					input.SetCursorPos(settingPnl:LocalToScreen(settingPnl:GetWide() / 2, settingPnl:GetTall() / 2))
				end)
			end) end)
		end

		timer.Simple(0, function()
			if not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then return end
			bKeypads.Tutorial.Menu:MakePopup()
			bKeypads.Tutorial.Menu:MoveToFront()
		end)
	end

	if not self.Scene.Frames then
		bKeypads.Tutorial.Menu.Scene.ActiveScene = nil
		bKeypads.Tutorial.Menu.Scene.m_tTVAnimation = nil
		return
	end

	bKeypads.Tutorial:StopScene()
	bKeypads.Tutorial:SetupScene(self.Scene)

	if not bKeypads.Tutorial.Menu.Scene:IsVisible() then
		bKeypads.Tutorial.Menu.Scene.m_tTVAnimation = nil
		bKeypads.Tutorial.Menu.Scene:SetVisible(true)
		surface.PlaySound("bkeypads/cracker/whirr.mp3")
	elseif bKeypads.Tutorial.Menu.Scene.ActiveScene ~= self.Scene then
		surface.PlaySound("bkeypads/cracker/success.mp3")
	else
		surface.PlaySound("bkeypads/cracker/hello.mp3")
	end

	bKeypads.Tutorial.Menu.Scene.ActiveScene = self.Scene
end

local function MenuOnClose()
	surface.PlaySound("garrysmod/balloon_pop_cute.wav")
	bKeypads.Tutorial:StopScene()
end

local function CategoriesPaint(self, w, h)
	surface.SetDrawColor(20, 20, 20)
	surface.DrawRect(0, 0, w, h)
end

function bKeypads.Tutorial:OpenMenu()
	if IsValid(bKeypads.Tutorial.Menu) then
		bKeypads.Tutorial.Menu:Close()
	else
		surface.PlaySound("garrysmod/content_downloaded.wav")
	end

	local L = bKeypads.L
	local I = InterpolateLanguageStrings

	local h = (600 / 1080) * ScrH()
	local w = (900 / 600) * h

	--## MAIN WINDOW ##--

	local menu = vgui.Create("DFrame") bKeypads.Tutorial.Menu = menu
	menu:SetIcon("icon16/emoticon_grin.png")
	menu:SetTitle("Billy's Keypads - " .. L"Tutorial")
	menu:SetSize(w, h)
	menu:DockPadding(2, 24, 2, 2)
	menu:SetSizable(true)
	menu:MakePopup()
	menu.Paint = MenuPaint
	menu.OnClose = MenuOnClose

	menu.lblTitle:SetTextColor(bKeypads.COLOR.WHITE)
	menu.lblTitle:SetFont("bKeypads.TutorialFont")

	menu:SetPos((ScrW() - menu:GetWide()) / 2, ScrH())
	local y = (ScrH() + menu:GetTall()) / 2
	menu:NewAnimation(1, 0, .25).Think = function(_, pnl, f)
		local f = bKeypads.ease.OutSine(f)

		local x = pnl:GetPos()
		pnl:SetPos(x, ScrH() - (y * f))

		pnl:SetAlpha(f * 255)
	end

	--## CATEGORIES ##--

	menu.Divider = vgui.Create("DHorizontalDivider", menu)
	menu.Divider:Dock(FILL)
	menu.Divider:SetDividerWidth(2)

	menu.Categories = vgui.Create("bKeypads.SmoothScroll.CategoryList", menu)
	menu.Categories.Paint = CategoriesPaint
	menu.Divider:SetLeft(menu.Categories)

	menu.Content = vgui.Create("DPanel", menu)
	menu.Content.Paint = nil
	menu.Divider:SetRight(menu.Content)

	menu.Divider:SetLeftWidth(w * .25)

	for _, category in ipairs(bKeypads.Tutorial.Categories) do
		local categoryPnl = menu.Categories:Add(I(category.Name))
		categoryPnl.Category = category

		if category.Scenes then for _, scene in ipairs(category.Scenes) do
			if isstring(scene) then
				scene = bKeypads.Tutorial.Shortcuts[scene]
				if not scene then continue end
			end
			local scenePnl = categoryPnl:Add(I(scene.Name))
			scenePnl.Category = category
			scenePnl.Scene = scene
			scenePnl.DoClick = SceneClicked
			if scene.Tooltip then
				bKeypads:RecursiveTooltip(I(scene.Tooltip), scenePnl)
			end
		end end
	end

	--## SCENE ##--

	menu.Scene = vgui.Create("DPanel", menu.Content)
	menu.Scene:Dock(FILL)
	menu.Scene:SetVisible(false)
	menu.Scene.Paint = ScenePaint
	menu.Scene.Think = SceneThink

	hook.Run("bKeypads.BuildCPanel", menu)
end

include("bkeypads/cl_tutorial_scenes.lua")

hook.Add("bKeypads.TutorialScenes", "bKeypads.TutorialScenes.RefreshMenu", function()
	if bKeypads and bKeypads.Tutorial and IsValid(bKeypads.Tutorial.Menu) then
		bKeypads.Tutorial:OpenMenu() bKeypads.Tutorial:OpenMenu()
	end
end)