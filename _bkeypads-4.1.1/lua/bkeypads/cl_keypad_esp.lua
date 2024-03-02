bKeypads.ESP = {}
-- This is not a cheat, it is part of the addon

bKeypads.ESP.IgnoreZ = false

hook.Remove("PreDrawHalos", "bKeypads.ESP.PreDrawHalos")
hook.Remove("PostDrawTranslucentRenderables", "bKeypads.ESP.Draw")

bKeypads.ESP.Active = false
function bKeypads.ESP:Activate()
	if bKeypads.ESP.Active then return end

	bKeypads.ESP.Active = true

	bKeypads.ESP.Halos:Reset()
	bKeypads.ESP.DataLinks = {}
	bKeypads.ESP.KeypadNetworks = {}

	bKeypads.ESP.ActiveTrace = {
		Color = {
			Red = false,
			Green = false
		},
		SnapTo = {
			FadingDoors = false,
			Keypads = false,
			MapLinkables = false
		},
		Keypad = NULL,
	}

	hook.Add("PreDrawHalos", "bKeypads.ESP.PreDrawHalos", bKeypads.ESP.PreDrawHalos)
	hook.Add("PostDrawTranslucentRenderables", "bKeypads.ESP.Draw", bKeypads.ESP.PostDrawTranslucentRenderables)
	hook.Add("PreDrawViewModel", "bKeypads.ESP.PreDrawViewModel", bKeypads.ESP.PreDrawViewModel)
	hook.Add("PostDrawViewModel", "bKeypads.ESP.PostDrawViewModel", bKeypads.ESP.PostDrawViewModel)
	hook.Add("PreDrawPlayerHands", "bKeypads.ESP.PreDrawPlayerHands", bKeypads.ESP.PreDrawViewModel)
	hook.Add("PostDrawPlayerHands", "bKeypads.ESP.PostDrawPlayerHands", bKeypads.ESP.PostDrawViewModel)

	bKeypads.ESP:Refresh()
end
function bKeypads.ESP:Deactivate()
	if not bKeypads.ESP.Active then return end

	bKeypads.ESP.Active = false
	bKeypads.ESP.IgnoreZ = false

	bKeypads.ESP.Halos:Reset()
	bKeypads.ESP.DataLinks = {}
	bKeypads.ESP.KeypadNetworks = {}

	hook.Remove("PreDrawHalos", "bKeypads.ESP.PreDrawHalos")
	hook.Remove("PostDrawTranslucentRenderables", "bKeypads.ESP.Draw")
	hook.Remove("PreDrawViewModel", "bKeypads.ESP.PreDrawViewModel")
	hook.Remove("PostDrawViewModel", "bKeypads.ESP.PostDrawViewModel")
	hook.Remove("PreDrawPlayerHands", "bKeypads.ESP.PreDrawPlayerHands")
	hook.Remove("PostDrawPlayerHands", "bKeypads.ESP.PostDrawPlayerHands")
end
function bKeypads.ESP:Refresh()
	if not bKeypads.ESP.Active then return end
	bKeypads.ESP.Update = true
end

--## Halos ##--

bKeypads.ESP.Halos = {}

function bKeypads.ESP.Halos:Reset()
	bKeypads.ESP.Halos.Dictionary = {
		[bKeypads.COLOR.GREEN] = {},
		[bKeypads.COLOR.RED] = {},
		[bKeypads.COLOR.PINK] = {},
		[bKeypads.COLOR.WHITE] = {}
	}
	bKeypads.ESP.Halos.List = {
		[bKeypads.COLOR.GREEN] = {},
		[bKeypads.COLOR.RED] = {},
		[bKeypads.COLOR.PINK] = {},
		[bKeypads.COLOR.WHITE] = {}
	}
end
bKeypads.ESP.Halos:Reset()

function bKeypads.ESP.Halos:Add(ent, color)
	if bKeypads.ESP.Halos.Dictionary[color][ent] == nil then
		bKeypads.ESP.Halos.Dictionary[color][ent] = table.insert(bKeypads.ESP.Halos.List[color], ent)
	end
end

bKeypads.ESP.PreDrawHalos = function()
	halo.Add(bKeypads.ESP.Halos.List[bKeypads.COLOR.GREEN], bKeypads.COLOR.GREEN, 1, 1, 1, true, bKeypads.ESP.IgnoreZ)
	halo.Add(bKeypads.ESP.Halos.List[bKeypads.COLOR.RED], bKeypads.COLOR.RED, 1, 1, 1, true, bKeypads.ESP.IgnoreZ)
	halo.Add(bKeypads.ESP.Halos.List[bKeypads.COLOR.PINK], bKeypads.COLOR.PINK, 1, 1, 1, true, bKeypads.ESP.IgnoreZ)
	halo.Add(bKeypads.ESP.Halos.List[bKeypads.COLOR.WHITE], bKeypads.COLOR.WHITE, 1, 1, 1, true, bKeypads.ESP.IgnoreZ)
end

bKeypads.ESP.PreDrawViewModel = function()
	render.DepthRange(0, 0)
end

bKeypads.ESP.PostDrawViewModel = function()
	render.DepthRange(0, 1)
end

--## Data Beams ##--

do
	local DataBeamMat = Material("cable/chain")

	local DataBeamPseudoMat = CreateMaterial("bKeypads.DataBeamPseudoMat", "UnlitGeneric", {
		["$basetexture"] = "sprites/physbeam_active_white",
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	function bKeypads.ESP.DrawDataBeam(ent1, ent2, color, pseudolink, solid)
		if (not isvector(ent1) and not IsValid(ent1)) or (not isvector(ent2) and not IsValid(ent2)) then return end

		local pos1 = isvector(ent1) and ent1 or ent1:LocalToWorld(ent1:OBBCenter())
		local pos2 = isvector(ent2) and ent2 or ent2:LocalToWorld(ent2:OBBCenter())

		local dist = pos1:Distance(pos2)
		local clamp = math.max(math.floor(dist / 10), 4)

		if pseudolink then
			render.SetMaterial(DataBeamPseudoMat)
			render.DrawBeam(pos1, pos2, 4, SysTime() + clamp, SysTime(), bKeypads.COLOR.PINK)
		else
			if solid then
				if bKeypads.ESP.IgnoreZ then
					render.SetColorMaterialIgnoreZ()
				else
					render.SetColorMaterial()
				end
			else
				render.SetMaterial(DataBeamMat)
			end
			render.DrawBeam(pos1, pos2, 2, SysTime() + clamp, SysTime(), color or bKeypads.COLOR.WHITE)
		end
	end

	function bKeypads.ESP.AnimateDataBeam()
		DataBeamMat:SetInt("$frame", ((SysTime() * 2) % 3) + 1)
	end

	bKeypads.ESP.PostDrawTranslucentRenderables = function(bDrawingDepth, bDrawingSkybox)
		if bDrawingSkybox then return end
		if render.GetRenderTarget() ~= nil then return end

		bKeypads.cam.IgnoreZ(bKeypads.ESP.IgnoreZ)

		bKeypads.ESP.AnimateDataBeam()

		for _, data_link in ipairs(bKeypads.ESP.DataLinks) do
			bKeypads.ESP.DrawDataBeam(data_link[1], data_link[2], data_link[3], data_link[4], data_link[5])
		end

		bKeypads.cam.IgnoreZ(false)
	end
end

--## Think Logic ##--

local bKeypadsTools = {
	bkeypads_linker = true,
	bkeypads_admin_tool = true,
	bkeypads_fading_door = true,
	bkeypads_breaker = true,
}

local showLinkTools = {
	bkeypads_admin_tool = true,
	bkeypads_linker = true
}

local access_mode_iter = {
	[true] = bKeypads.COLOR.GREEN,
	[false] = bKeypads.COLOR.RED,
}

function bKeypads.ESP:DrawKeypadNetwork(keypad, keypadNoDraw)
	local parent = keypad:IsParentKeypad() and keypad or keypad:GetParentKeypad()
	if IsValid(parent) then
		if parent ~= keypad and parent ~= keypadNoDraw and not bKeypads.ESP.Halos.Dictionary[bKeypads.COLOR.GREEN][parent] and not bKeypads.ESP.Halos.Dictionary[bKeypads.COLOR.RED][parent] then
			bKeypads.ESP.Halos:Add(parent, bKeypads.COLOR.PINK)
		end

		for keypad in pairs(parent:GetChildKeypads()) do
			if keypad == keypadNoDraw then continue end
			if not bKeypads.ESP.Halos.Dictionary[bKeypads.COLOR.GREEN][keypad] and not bKeypads.ESP.Halos.Dictionary[bKeypads.COLOR.RED][keypad] then
				bKeypads.ESP.Halos:Add(keypad, bKeypads.COLOR.PINK)
			end
			table.insert(bKeypads.ESP.DataLinks, { parent, keypad, bKeypads.COLOR.PINK } )
		end
	end
end

local _origin, _angles, _fov, _znear, _zfar
bKeypads.ESP.Watch = function(ply, origin, angles, fov, znear, zfar)
	if bKeypads.ESP.Update or bKeypads.ESP.Tick or (_origin ~= origin or _angles ~= angles or _fov ~= fov or _znear ~= znear or _zfar ~= zfar) then
		bKeypads.ESP.Update = false
		_origin, _angles, _fov, _znear, _zfar = origin, angles, fov, znear, zfar

		-- Force an ESP update to actually occur after a new frame
		if not bKeypads.ESP.Tick then
			bKeypads.ESP.Tick = true
			return
		else
			bKeypads.ESP.Tick = false
		end
	else
		return
	end

	bKeypads.ESP.Halos:Reset()
	bKeypads.ESP.DataLinks = {}
	bKeypads.ESP.KeypadNetworks = {}

	if not IsValid(ply) then return end

	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	local tool = ply:GetTool()

	if tool and wep:GetClass() == "gmod_tool" and bKeypadsTools[tool.Mode] then
		local tr = ply:GetEyeTrace()
		if not tr.Hit then return end

		if tool.Mode == "bkeypads_breaker" then
			if bKeypads.Permissions:Cached(LocalPlayer(), "tools/keypad_breaker") then
				bKeypads.ESP.IgnoreZ = true

				for _, ent in ipairs(ents.GetAll()) do
					if ent.bKeypad then
						bKeypads.ESP.Halos:Add(ent, ent:GetBroken() and bKeypads.COLOR.RED or bKeypads.COLOR.GREEN)
					end
				end
			end
		else
			bKeypads.ESP.IgnoreZ = tool.Mode ~= "bkeypads_fading_door"

			if tool.Mode == "bkeypads_admin_tool" then
				if bKeypads.Permissions:Cached(LocalPlayer(), "tools/admin_tool") then
					if IsValid(tool.LinkingKeypad) then
						local fadingDoorLinks = bKeypads.FadingDoors:GetLinks(tool.LinkingKeypad)
						if fadingDoorLinks then
							for ent, linkData in pairs(fadingDoorLinks) do
								local access_mode, link = next(linkData)
								if not IsValid(link) then continue end

								local espColor = access_mode_iter[access_mode]

								bKeypads.ESP.Halos:Add(ent, espColor)
								table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, ent, espColor, nil, true } )

								if tool.TargetEnt == ent or not isLinking then
									bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)
								end
							end
						end

						local mapLinks = bKeypads.MapLinking:GetLinks(tool.LinkingKeypad)
						if mapLinks then
							for ent, linkData in pairs(mapLinks) do
								local access_mode, link = next(linkData)
								if not IsValid(link) then continue end

								local espColor = access_mode_iter[access_mode]

								bKeypads.ESP.Halos:Add(ent, espColor)
								table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, ent, espColor, link:HasGeneralFlag(bKeypads.MapLinking.F_PSEUDOLINK) or nil, true } )

								if tool.TargetEnt == ent then
									bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)
								end
							end
						end
					end

					if IsValid(tr.Entity) and not tr.Entity:IsWorld() then
						if bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then
							local fadingDoorLinks = bKeypads.FadingDoors:GetLinks(tr.Entity)
							if fadingDoorLinks then
								for keypad, linkData in pairs(fadingDoorLinks) do
									local access_mode, link = next(linkData)
									if not IsValid(link) then continue end

									local espColor = access_mode_iter[access_mode]

									bKeypads.ESP.Halos:Add(keypad, espColor)
									bKeypads.ESP.Halos:Add(tr.Entity, espColor)
									table.insert(bKeypads.ESP.DataLinks, { keypad, tr.Entity, espColor, nil, true } )
								end
							end
						elseif bKeypads.MapLinking:IsLinkEntity(tr.Entity) then
							local mapLinks = bKeypads.MapLinking:GetLinks(tr.Entity)
							if mapLinks then
								for keypad, linkData in pairs(mapLinks) do
									local access_mode, link = next(linkData)
									if not IsValid(link) then continue end

									local espColor = access_mode_iter[access_mode]

									bKeypads.ESP.Halos:Add(keypad, espColor)
									bKeypads.ESP.Halos:Add(tr.Entity, espColor)
									table.insert(bKeypads.ESP.DataLinks, { keypad, tr.Entity, espColor, link:HasGeneralFlag(bKeypads.MapLinking.F_PSEUDOLINK) or nil, true } )
								end
							end
						end
					end

					if IsValid(tool.LinkingKeypad) then
						bKeypads.ESP:DrawKeypadNetwork(tool.LinkingKeypad)
					end
				end
			else
				local showLinks = showLinkTools[tool.Mode] and IsValid(tool.LinkingKeypad)
				local isLinking = showLinks and tool.Mode == "bkeypads_linker"

				if tool.Mode == "bkeypads_fading_door" and IsValid(tr.Entity) and not tr.Entity:IsWorld() then
					if bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then
						bKeypads.ESP.Halos:Add(tr.Entity, bKeypads.COLOR.PINK)

						-- Draw links to this fading door
						local fadingDoorLinks = bKeypads.FadingDoors:GetLinks(tr.Entity)
						if fadingDoorLinks then
							for keypad, linkData in pairs(fadingDoorLinks) do
								local access_mode, link = next(linkData)
								if not IsValid(link) then continue end

								local espColor = access_mode_iter[access_mode]

								bKeypads.ESP.Halos:Add(keypad, espColor)
								table.insert(bKeypads.ESP.DataLinks, { keypad, tr.Entity, espColor, nil, true } )

								-- Draw keypad networks
								bKeypads.ESP:DrawKeypadNetwork(keypad)
							end
						end
					elseif bKeypads.FadingDoors:CanFadingDoor(tr.Entity) then
						bKeypads.ESP.Halos:Add(tr.Entity, bKeypads.COLOR.WHITE)
					end
				end

				if showLinks then
					local fadingDoorLinks = bKeypads.FadingDoors:GetLinks(tool.LinkingKeypad)
					if fadingDoorLinks then
						for ent, linkData in pairs(fadingDoorLinks) do
							local access_mode, link = next(linkData)
							if not IsValid(link) then continue end

							local espColor = access_mode_iter[access_mode]

							bKeypads.ESP.Halos:Add(ent, espColor)
							table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, ent, espColor, nil, true } )

							if tool.TargetEnt == ent or not isLinking then
								bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)
							end
						end
					end

					local mapLinks = bKeypads.MapLinking:GetLinks(tool.LinkingKeypad)
					if mapLinks then
						for ent, linkData in pairs(mapLinks) do
							local access_mode, link = next(linkData)
							if not IsValid(link) then continue end

							local espColor = access_mode_iter[access_mode]

							bKeypads.ESP.Halos:Add(ent, espColor)
							table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, ent, espColor, link:HasGeneralFlag(bKeypads.MapLinking.F_PSEUDOLINK) or nil, true } )

							if tool.TargetEnt == ent then
								bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)
							end
						end
					end

					if isLinking and not tool.DisableTargetESP then
						local canLink, keypadLinkSource, keypadLinkTarget
						if IsValid(tool.TargetEnt) and tool.TargetEnt.bKeypad then
							canLink, keypadLinkSource, keypadLinkTarget = bKeypads.KeypadLinking:TranslatePair(tool.LinkingKeypad, tool.TargetEnt)
						end

						if canLink then
							local espColor = keypadLinkSource == keypadLinkTarget:LinkProxy() and bKeypads.COLOR.RED or bKeypads.COLOR.PINK
							bKeypads.ESP.Halos:Add(keypadLinkSource, espColor)
							bKeypads.ESP.Halos:Add(keypadLinkTarget, espColor)

							table.insert(bKeypads.ESP.DataLinks, { keypadLinkSource, keypadLinkTarget, espColor } )

							bKeypads.ESP:DrawKeypadNetwork(keypadLinkSource, keypadLinkTarget)
							return
						else
							local espColor = (tool.TargetAccessMode ~= nil and (tool.TargetAccessMode and bKeypads.COLOR.GREEN or bKeypads.COLOR.RED)) or (tool.AccessMode and bKeypads.COLOR.GREEN or bKeypads.COLOR.RED)

							if canLink == false then
								table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, tr.HitPos, espColor } )
								bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)
							else
								local espColor = (tool.TargetAccessMode ~= nil and (tool.TargetAccessMode and bKeypads.COLOR.GREEN or bKeypads.COLOR.RED)) or (tool.AccessMode and bKeypads.COLOR.GREEN or bKeypads.COLOR.RED)
								table.insert(bKeypads.ESP.DataLinks, { tool.LinkingKeypad, (tool.SnapToEnt and IsValid(tool.TargetEnt) and tool.TargetEnt) or tr.HitPos, espColor, tool.MapLinking and tobool(tool:GetClientNumber("map_pseudolink")) } )

								bKeypads.ESP.Halos:Add(tool.LinkingKeypad, espColor)

								if IsValid(tool.TargetEnt) then
									bKeypads.ESP.Halos:Add(tool.TargetEnt, espColor)
								end
							end
						end
					end

					if IsValid(tool.LinkingKeypad) then
						bKeypads.ESP:DrawKeypadNetwork(tool.LinkingKeypad)
					end
				end
			end
		end
	end
end
hook.Add("CalcView", "bKeypads.ESP.Watch", bKeypads.ESP.Watch)