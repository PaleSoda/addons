do
	util.AddNetworkString("bKeypads.KeypadModelFallback")

	local downloaded = {}

	local fake_keypad

	local vtxstruct, physstruct
	local extracted = false

	net.Receive("bKeypads.KeypadModelFallback", function(l, ply)
		local keypad = net.ReadEntity()
		if not IsValid(keypad) or not keypad.bKeypad then return end

		if not extracted then
			local mdl = keypad:GetModel()
			if mdl == "models/error.mdl" or not util.IsValidModel(mdl) then
				bKeypads:print("The keypad model file was not found on the server! Please reinstall the addon.", bKeypads.PRINT_TYPE_BAD, "ERROR")
				return
			end

			if not IsValid(fake_keypad) then
				fake_keypad = ents.Create("prop_physics")
				fake_keypad:SetNoDraw(true)
				fake_keypad:SetModel(bKeypads.MODEL.KEYPAD)
				fake_keypad:Spawn()
			end

			local phys = fake_keypad:GetPhysicsObject()
			if not IsValid(phys) then return end

			vtxstruct = phys:GetMesh()
			physstruct = phys:GetMeshConvexes()

			fake_keypad:Remove()

			extracted = true
		end

		if downloaded[ply] then return end
		downloaded[ply] = true

		net.Start("bKeypads.KeypadModelFallback")
			net.WriteEntity(keypad)

			net.WriteUInt(#vtxstruct, 16)
			for _, vert in ipairs(vtxstruct) do
				net.WriteVector(vert.pos)
			end

			for _, convex in ipairs(physstruct) do
				net.WriteBool(true)
				net.WriteUInt(#convex, 16)
				for _, vert in ipairs(convex) do
					net.WriteVector(vert.pos)
				end
			end
			net.WriteBool(false)
		net.Send(ply)
	end)
end

do
	util.AddNetworkString("bKeypads.KeypadData.Fetch")
	util.AddNetworkString("bKeypads.KeypadData.Push")

	local newToken = 0
	local tokens = {}
	function bKeypads:FetchAccessMatrix(ply, keypad, mirrorKeypad)
		tokens[newToken] = {ply, keypad, mirrorKeypad}

		net.Start("bKeypads.KeypadData.Fetch")
			net.WriteUInt(newToken, 16)
		net.Send(ply)

		newToken = newToken + 1
	end

	net.Receive("bKeypads.KeypadData.Push", function(l, ply)
		local tokenID = net.ReadUInt(16)
		local token = tokens[tokenID]
		if token and token[1] == ply and IsValid(token[2]) then
			local am = bKeypads.KeypadData.Net:Deserialize()
			token[2]:SetAccessMatrix(am)
			if IsValid(token[3]) then
				token[3]:SetAccessMatrix(table.Copy(am))
			end
		end
		tokens[tokenID] = nil
	end)
end

--[[
do
	bKeypads_numpad_OnUp = bKeypads_numpad_OnUp or numpad.OnUp
	bKeypads_numpad_OnDown = bKeypads_numpad_OnDown or numpad.OnDown
	bKeypads_numpad_Remove = bKeypads_numpad_Remove or numpad.Remove

	bKeypads_FadingDoorKeyRegistry = bKeypads_FadingDoorKeyRegistry or {}
	bKeypads_FadingDoorImpulses = bKeypads_FadingDoorImpulses or {}

	local bKeypads_numpad_OnUp = bKeypads_numpad_OnUp
	local bKeypads_numpad_OnDown = bKeypads_numpad_OnDown
	local bKeypads_numpad_Remove = bKeypads_numpad_Remove

	local bKeypads_FadingDoorKeyRegistry = bKeypads_FadingDoorKeyRegistry
	local bKeypads_FadingDoorImpulses = bKeypads_FadingDoorImpulses

	-- TODO show keys on keyboard simulating links

	function numpad.OnUp(ply, key, name, ent, ...)
		local impulse = bKeypads_numpad_OnUp(ply, key, name, ent, ...)

		if name:lower():find("fading%s*door") then
			bKeypads_FadingDoorKeyRegistry[ply] = bKeypads_FadingDoorKeyRegistry[ply] or {}

			bKeypads_FadingDoorKeyRegistry[ply][key] = bKeypads_FadingDoorKeyRegistry[ply][key] or {}
			bKeypads_FadingDoorKeyRegistry[ply][key][ent] = true

			bKeypads_FadingDoorImpulses[ent] = bKeypads_FadingDoorImpulses[ent] or {}
			bKeypads_FadingDoorImpulses[ent][impulse] = {
				key = key,
				ply = ply
			}
			bKeypads_FadingDoorImpulses[impulse] = ent
		end

		return impulse
	end

	function numpad.OnDown(ply, key, name, ent, ...)
		local impulse = bKeypads_numpad_OnDown(ply, key, name, ent, ...)

		if name:lower():find("fading%s*door") then
			bKeypads_FadingDoorKeyRegistry[ply] = bKeypads_FadingDoorKeyRegistry[ply] or {}

			bKeypads_FadingDoorKeyRegistry[ply][key] = bKeypads_FadingDoorKeyRegistry[ply][key] or {}
			bKeypads_FadingDoorKeyRegistry[ply][key][ent] = true

			bKeypads_FadingDoorImpulses[ent] = bKeypads_FadingDoorImpulses[ent] or {}
			bKeypads_FadingDoorImpulses[ent][impulse] = {
				key = key,
				ply = ply
			}
			bKeypads_FadingDoorImpulses[impulse] = ent
		end

		return impulse
	end

	function numpad.Remove(impulse, ...)
		local ent = bKeypads_FadingDoorImpulses[impulse]
		if ent then
			local metadata = bKeypads_FadingDoorImpulses[ent][impulse]
			if metadata then
				local ply, key = metadata.ply, metadata.key
				if IsValid(ply) and bKeypads_FadingDoorKeyRegistry[ply] then
					if bKeypads_FadingDoorKeyRegistry[ply][key] then
						bKeypads_FadingDoorKeyRegistry[ply][key][ent] = nil
						if table.IsEmpty(bKeypads_FadingDoorKeyRegistry[ply][key]) then
							bKeypads_FadingDoorKeyRegistry[ply][key] = nil
						end
					end
					if table.IsEmpty(bKeypads_FadingDoorKeyRegistry[ply]) then
						bKeypads_FadingDoorKeyRegistry[ply] = nil
					end
				end
			end

			bKeypads_FadingDoorImpulses[ent][impulse] = nil
			if table.IsEmpty(bKeypads_FadingDoorImpulses[ent]) then
				bKeypads_FadingDoorImpulses[ent] = nil
			end

			bKeypads_FadingDoorImpulses[impulse] = nil
		end

		return bKeypads_numpad_Remove(impulse, ...)
	end
end
--]]