bKeypads.Economy = {}

local plyMeta = FindMetaTable("Player")
function bKeypads.Economy:HasCashSystem()
	return bKeypads.Config.Payments.Economy.CustomEconomy or (DarkRP and (CLIENT or plyMeta.addMoney) and plyMeta.canAfford and true) or false
end

function bKeypads.Economy:addMoney(ply, amount)
	assert(IsValid(ply), "Tried to use a NULL player!")
	if bKeypads.Config.Payments.Economy.CustomEconomy then
		return bKeypads.Config.Payments.Economy.addMoney(ply, amount)
	elseif DarkRP and ply.addMoney then
		return ply:addMoney(amount)
	end
end

function bKeypads.Economy:canAfford(ply, amount)
	assert(IsValid(ply), "Tried to use a NULL player!")
	if bKeypads.Config.Payments.Economy.CustomEconomy then
		return bKeypads.Config.Payments.Economy.canAfford(ply, amount)
	elseif DarkRP and ply.canAfford then
		return ply:canAfford(amount)
	end
end

function bKeypads.Economy:formatMoney(amount)
	if bKeypads.Config.Payments.Economy.CustomEconomy then
		return bKeypads.Config.Payments.Economy.formatMoney(amount)
	elseif DarkRP and DarkRP.formatMoney then
		return DarkRP.formatMoney(amount)
	end
end

game.AddParticles("particles/bkeypads_cash.pcf")
PrecacheParticleSystem("bkeypads_cash")
function bKeypads.Economy:CashEffect(keypad)
	ParticleEffect("bkeypads_cash", keypad:LocalToWorld(keypad:OBBCenter()), angle_zero, keypad)
end

if SERVER then
	util.AddNetworkString("bKeypads.Economy.RequiresPayment")

	local requiresPaymentQueue = {}
	local function PlayerTick(ply)
		if requiresPaymentQueue[ply] then
			local EyePos, AimVector = ply:EyePos(), ply:GetAimVector()
			for keypad in pairs(requiresPaymentQueue[ply]) do
				if not IsValid(keypad) then continue end

				local keypadCenter = keypad:WorldSpaceCenter()

				local intersect = util.IntersectRayWithPlane(EyePos, AimVector, keypadCenter, (EyePos - keypadCenter):Angle():Forward())
				if not intersect then return end

				local dist = intersect:Distance(keypadCenter)

				local maxs, mins = keypad:OBBMaxs(), keypad:OBBMins()
				local tolerance = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z) * 2

				if dist > tolerance then continue end

				net.Start("bKeypads.Economy.RequiresPayment")
					net.WriteEntity(keypad)
					net.WriteBool(keypad:PlayerRequiresPayment(ply))
				net.Send(ply)
			end
			requiresPaymentQueue[ply] = nil

			if table.IsEmpty(requiresPaymentQueue) then
				hook.Remove("PlayerTick", "bKeypads.Economy.RequiresPayment")
			end
		end
	end

	local antispam = {}
	net.Receive("bKeypads.Economy.RequiresPayment", function(_, ply)
		local keypad = net.ReadEntity()

		if antispam[ply] and antispam[ply] > SysTime() then return end

		if not IsValid(keypad) or keypad:GetPaymentAmount() == 0 or not keypad:GetChargeUnauthorized() then return end

		antispam[ply] = SysTime() + 1

		requiresPaymentQueue[ply] = requiresPaymentQueue[ply] or {}
		requiresPaymentQueue[ply][keypad] = true

		hook.Add("PlayerTick", "bKeypads.Economy.RequiresPayment", PlayerTick) -- the lengths I go to to oppress skids
	end)
else
	local requiresPayment = {}
	net.Receive("bKeypads.Economy.RequiresPayment", function()
		requiresPayment[net.ReadEntity()] = net.ReadBool()
	end)

	function bKeypads.Economy:RequiresPayment(keypad, transmit)
		if keypad:GetKeypadOwner() == LocalPlayer() then return false end
		if not keypad:GetChargeUnauthorized() then return true end

		if transmit and keypad:GetChargeUnauthorized() then
			net.Start("bKeypads.Economy.RequiresPayment")
				net.WriteEntity(keypad)
			net.SendToServer()
		end

		if IsValid(keypad) and requiresPayment[keypad] ~= nil then
			return requiresPayment[keypad]
		else
			return true
		end
	end
end

-- Linus says: 1 SEK = 0.088 GBP