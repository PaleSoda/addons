--######## Detect picking up/dropping player ########--

GAS.AdminPhysgun.PickedUpPlayers = {}
GAS.AdminPhysgun.PickedUpPlayersIndexed = {}
GAS:hook("OnPhysgunPickup", "adminphysgun:PhysgunPickup", function(ply, ent)
	if (not IsValid(ent) or not ent:IsPlayer()) then return	end
	if (IsValid(GAS.AdminPhysgun.PickedUpPlayersIndexed[ent])) then return end

	local pickupEvent = table.IsEmpty(GAS.AdminPhysgun.PickedUpPlayersIndexed)

	GAS.AdminPhysgun.PickedUpPlayers[ply] = ent
	GAS.AdminPhysgun.PickedUpPlayersIndexed[ent] = ply
	ent:SetMoveType(MOVETYPE_NONE)
	hook.Run("GAS:PhysgunPickupPlayer", ply, ent)

	if pickupEvent then
		hook.Run("GAS:PhysgunPickupStarted")
	end
end)
GAS:hook("PhysgunDrop", "adminphysgun:PhysgunDrop", function(ply, ent)
	local wasEmpty = table.IsEmpty(GAS.AdminPhysgun.PickedUpPlayersIndexed)

	GAS.AdminPhysgun.PickedUpPlayers[ply] = nil
	GAS.AdminPhysgun.PickedUpPlayersIndexed[ent] = nil
	if (IsValid(ent) and ent:IsPlayer()) then
		hook.Run("GAS:PhysgunDropPlayer", ply, ent)
		ent:SetMoveType(MOVETYPE_WALK)
	end

	if not wasEmpty and table.IsEmpty(GAS.AdminPhysgun.PickedUpPlayersIndexed) then
		hook.Run("GAS:PhysgunPickupEnded")
	end
end)
GAS:hook("PlayerDisconnected", "adminphysgun:DropOnDisconnect", function(ply)
	GAS.AdminPhysgun.PickedUpPlayers[ply] = nil
	GAS.AdminPhysgun.PickedUpPlayersIndexed[ply] = nil
end)

--######## Frozen player collisions ########--

GAS:hook("ShouldCollide", "adminphysgun:Freeze_Collisions", function(ent1, ent2)
	if (not IsValid(ent1) or not IsValid(ent2) or (ent1:IsPlayer() and ent2:IsPlayer())) then return end
	local ply
	if (ent1:IsPlayer()) then
		ply = ent1
	else
		ply = ent2
	end
	if (ply:GetNWBool("GAS_Frozen", false)) then
		return false
	end
end)

--######## Prevent spawning of anything while picked up #######--

local spawn_hooks = {"PlayerSpawnedVehicle","PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnObject","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","CanTool"}
for _,sh in ipairs(spawn_hooks) do
	GAS:hook(sh, "adminphysgun:PickupDisable:" .. sh, function(ply)
		if (IsValid(ply) and IsValid(GAS.AdminPhysgun.PickedUpPlayersIndexed[ply])) then
			return false
		end
	end)
end