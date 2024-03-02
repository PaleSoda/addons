function bKeypads:CreateKeypad(Pos, Angles, keypadData)
	local keypad = ents.Create("bkeypad")

	keypad:SetPos(Pos)
	keypad:SetAngles(Angles)

	if IsValid(keypadData.Creator) then
		keypad:SetCreator(keypadData.Creator)
	end

	keypad:Spawn()

	keypad:SetCreationData(keypadData)

	if IsValid(keypadData.Creator) then
		hook.Run("bKeypads.Keypad.Spawned", keypadData.Creator, keypad)
	end

	return keypad
end

do
	local ScanningRegistry = {}
	function bKeypads:ScanPlayer(keypad, ply)
		assert(IsValid(keypad), "Keypad was a NULL entity")
		assert(ply == nil or IsValid(ply), "Player was a NULL entity")

		if ply ~= nil then
			assert(keypad:GetScanningStatus() == bKeypads.SCANNING_STATUS.IDLE, "Keypad is busy!")
			assert(not keypad:GetBroken(), "Hacked keypads cannot scan")
			ScanningRegistry[ply] = ScanningRegistry[ply] or {}
			ScanningRegistry[ply][keypad] = true
			keypad:SetScanningInternal(ply)
		else
			local ply = keypad:GetScanningPlayer()
			if IsValid(ply) and ScanningRegistry[ply] then
				ScanningRegistry[ply][keypad] = nil
				if table.IsEmpty(ScanningRegistry[ply]) then
					ScanningRegistry[ply] = nil
				end
			end
			keypad:SetScanningInternal(nil)
		end
	end
	local function ScanPlayerDisconnect(ply)
		if ScanningRegistry[ply] and #ScanningRegistry > 0 then
			for keypad in pairs(ScanningRegistry[ply]) do
				keypad:Reset()
			end
			ScanningRegistry[ply] = nil
		end
	end
	hook.Add("PlayerDisconnected", "bKeypads.ScanPlayer.Disconnect", ScanPlayerDisconnect)

	function bKeypads:CancelScan(keypad)
		return bKeypads:ScanPlayer(keypad)
	end
end

function bKeypads:TestAccess(keypad, ply)
	return keypad:TestAccess(ply)
end

do
	bKeypads.KeyPressing = {}
	bKeypads_KeyPressing_Locks = bKeypads_KeyPressing_Locks or {}

	local function ForceKey(ply, lock)
		if not lock then
			return false
		end
		if not IsValid(lock.keypad) then
			bKeypads.KeyPressing:Unlock(ply, lock.keypad, lock.key)
			return false
		end

		if not numpad.FromButton() then
			if lock.activate then
				numpad.Activate(ply, lock.key, true)
			else
				numpad.Deactivate(ply, lock.key, true)
			end
		end
	end
	numpad.Register("bKeypads.ForceActivateKey", ForceKey)

	function bKeypads.KeyPressing:Lock(ply, keypad, key)
		if key <= 0 or not IsValid(ply) or not IsValid(keypad) then return end

		local lockId = ply:SteamID64() .. keypad:GetCreationID() .. key

		if not bKeypads_KeyPressing_Locks[lockId] then
			local lock = {
				activate = false,
				keypad = keypad,
				key = key,
				OnDown = -1,
				OnUp = -1
			}

			bKeypads_KeyPressing_Locks[lockId] = lock

			lock.OnDown = numpad.OnDown(ply, key, "bKeypads.ForceActivateKey", bKeypads_KeyPressing_Locks[lockId])
			lock.OnUp = numpad.OnUp(ply, key, "bKeypads.ForceActivateKey", bKeypads_KeyPressing_Locks[lockId])
		end
	end
	function bKeypads.KeyPressing:Unlock(ply, keypad, key)
		if key <= 0 or not IsValid(ply) or not IsValid(keypad) then return end

		local lockId = ply:SteamID64() .. keypad:GetCreationID() .. key
		local lock = bKeypads_KeyPressing_Locks[lockId]

		if lock then
			numpad.Remove(lock.OnDown)
			numpad.Remove(lock.OnUp)
			if lock.activate then
				numpad.Deactivate(ply, key, true)
			end
		end

		bKeypads_KeyPressing_Locks[lockId] = nil
	end
	function bKeypads.KeyPressing:IsLocked(ply, keypad, key)
		return bKeypads_KeyPressing_Locks[ply:SteamID64() .. keypad:GetCreationID() .. key] ~= nil
	end

	function bKeypads.KeyPressing:Force(ply, keypad, key, down)
		if key <= 0 or not IsValid(ply) or not IsValid(keypad) then return end

		local lockId = ply:SteamID64() .. keypad:GetCreationID() .. key
		local lock = bKeypads_KeyPressing_Locks[lockId]
		assert(lock ~= nil, "Key press not locked")

		if lock.activate ~= down then
			lock.activate = down

			if down then
				numpad.Activate(ply, key, true)
			else
				numpad.Deactivate(ply, key, true)
			end
		end
	end
end

hook.Add("PlayerInitialSpawn", "bKeypads.ReuniteKeypads", function(ply)
	if ply:IsBot() then return end

	local sid64 = ply:SteamID64()
	for _, keypad in ipairs(bKeypads.Keypads) do
		if keypad.m_PlayerCreatorSteamID64 == sid64 then
			keypad:SetKeypadOwner(ply)
		end
	end
end)

hook.Add("CanPlayerUnfreeze", "bKeypads.CanPlayerUnfreeze", function(ply, ent)
	if IsValid(ent) and ent.bKeypad and (not bKeypads.Permissions:Check(ply, "keypads/unfrozen_keypads") or (IsValid(ent:GetKeypadOwner()) and ent:GetKeypadOwner() ~= ply and not bKeypads.Permissions:Check(ent:GetKeypadOwner(), "keypads/unfrozen_keypads"))) then
		return false
	end
end)
hook.Add("PhysgunDrop", "bKeypads.PhysgunDrop.CanPlayerUnfreeze", function(ply, ent)
	if IsValid(ent) and ent.bKeypad and IsValid(ent:GetPhysicsObject()) and (not bKeypads.Permissions:Check(ply, "keypads/unfrozen_keypads") or (IsValid(ent:GetKeypadOwner()) and ent:GetKeypadOwner() ~= ply and not bKeypads.Permissions:Check(ent:GetKeypadOwner(), "keypads/unfrozen_keypads"))) then
		ent:GetPhysicsObject():EnableMotion(false)
	end
end)