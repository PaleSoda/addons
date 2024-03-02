-- Prevents cheats from figuring out keypad codes from player view angles

local CMD_BTN_MASK = bit.bor(IN_ATTACK, IN_ATTACK2, IN_RELOAD, IN_WEAPON1, IN_WEAPON2)

local function IsGun(wep)
	return wep:GetPrimaryAmmoType() ~= -1 or wep:GetSecondaryAmmoType() ~= -1
end

bKeypads.FakeAngles = {
	UnmutatedTraceStruct = {},

	GetEyeData = function()
		if bKeypads.FakeAngles.Keypad and bKeypads.FakeAngles.Unmutated and bKeypads.FakeAngles.CalcViewStruct then
			return bKeypads.FakeAngles.CalcViewStruct.origin, bKeypads.FakeAngles.Unmutated:Forward()
		else
			local ply = LocalPlayer()
			return ply:EyePos(), ply:GetAimVector()
		end
	end,

	CalcView = function(ply, origin, angles, fov, znear, zfar)
		if ply ~= LocalPlayer() then return end
		if bKeypads.FakeAngles.Keypad and bKeypads.FakeAngles.Unmutated then
			bKeypads.FakeAngles.CalcViewStruct = bKeypads.FakeAngles.CalcViewStruct or {}

			bKeypads.FakeAngles.CalcViewStruct.origin = origin
			bKeypads.FakeAngles.CalcViewStruct.fov = fov
			bKeypads.FakeAngles.CalcViewStruct.znear = znear
			bKeypads.FakeAngles.CalcViewStruct.zfar = zfar

			bKeypads.FakeAngles.CalcViewStruct.angles = bKeypads.FakeAngles.Unmutated or angles

			if bKeypads.FakeAngles.Unmutated then
				bKeypads.FakeAngles.UnmutatedTraceStruct.start = origin
				bKeypads.FakeAngles.UnmutatedTraceStruct.endpos = origin + (bKeypads.FakeAngles.Unmutated:Forward() * 1024)
				bKeypads.FakeAngles.UnmutatedTraceStruct.filter = ply

				local UnmutatedTrace = util.TraceLine(bKeypads.FakeAngles.UnmutatedTraceStruct)
				if UnmutatedTrace.Entity ~= bKeypads.FakeAngles.Keypad then
					bKeypads.FakeAngles.Unlock = bKeypads.FakeAngles.Unmutated
				end
			end

			return bKeypads.FakeAngles.CalcViewStruct
		end
	end,

	CalcViewModelView = function(Weapon, ViewModel, OldEyePos, OldEyeAng)
		if not IsValid(Weapon) then return end
		if bKeypads.FakeAngles.Keypad and bKeypads.FakeAngles.Unmutated and bKeypads.FakeAngles.CalcViewStruct then
			local EyePos, EyeAng = bKeypads.FakeAngles.CalcViewStruct.origin, bKeypads.FakeAngles.CalcViewStruct.angles

			local vm_origin, vm_angles = EyePos, EyeAng

			local func = Weapon.GetViewModelPosition
			if func then
				local pos, ang = func(Weapon, EyePos*1, EyeAng*1)
				vm_origin = pos or vm_origin
				vm_angles = ang or vm_angles
			end

			func = Weapon.CalcViewModelView
			if func then
				local pos, ang = func(Weapon, ViewModel, OldEyePos*1, OldEyeAng*1, EyePos*1, EyeAng*1)
				vm_origin = pos or vm_origin
				vm_angles = ang or vm_angles
			end

			return vm_origin, vm_angles
		end
	end,

	CreateMove = function(cmd)
		if bKeypads.FakeAngles.Unlock then
			cmd:SetViewAngles(bKeypads.FakeAngles.Unlock)

			bKeypads.FakeAngles.Unlock = nil
			bKeypads.FakeAngles.Unmutated = nil
			bKeypads.FakeAngles.Keypad = nil

			return
		end

		if bKeypads.Settings:Get("pin_input_mode") == "look" then
			local ply = LocalPlayer()
			local wep = ply:GetActiveWeapon()
			local tr = ply:GetEyeTrace()
			if
				tr.Hit and IsValid(tr.Entity) and tr.Entity.bKeypad and ply:GetUseEntity() == tr.Entity and tr.Entity:GetAuthMode() == bKeypads.AUTH_MODE.PIN and
				bit.band(cmd:GetButtons(), CMD_BTN_MASK) == 0 and
				ply:GetViewEntity() == ply and
				(not IsValid(wep) or (wep:GetClass() ~= "gmod_tool" and not IsGun(wep))) and
				cmd:GetForwardMove() == 0 and cmd:GetSideMove() == 0 and cmd:GetUpMove() == 0 and
				ply:GetVelocity():IsZero() and
				tr.Entity:GetVelocity():IsZero()
			then
				bKeypads.FakeAngles.Keypad = tr.Entity

				local MutatedAngles = (tr.Entity:LocalToWorld(tr.Entity:OBBCenter()) - ply:EyePos()):Angle()

				if not bKeypads.FakeAngles.Unmutated then
					bKeypads.FakeAngles.Unmutated = cmd:GetViewAngles()
				else
					bKeypads.FakeAngles.Unmutated = bKeypads.FakeAngles.Unmutated + (cmd:GetViewAngles() - MutatedAngles)
				end

				bKeypads.FakeAngles.Unmutated:Normalize()

				cmd:SetViewAngles(MutatedAngles)

				return
			end
		end

		if bKeypads.FakeAngles.Unmutated then
			cmd:SetViewAngles(bKeypads.FakeAngles.Unmutated)
		end
		bKeypads.FakeAngles.Unmutated = nil
		bKeypads.FakeAngles.Keypad = nil
	end
}

local function loadFakeAngles()
	hook.Add("CalcView", "bKeypads.Anticheat.CalcView", bKeypads.FakeAngles.CalcView)
	hook.Add("CalcViewModelView", "bKeypads.Anticheat.CalcViewModelView", bKeypads.FakeAngles.CalcViewModelView)
	hook.Add("CreateMove", "bKeypads.Anticheat.CreateMove", bKeypads.FakeAngles.CreateMove)
end

local function unloadFakeAngles()
	hook.Remove("CalcView", "bKeypads.Anticheat.CalcView")
	hook.Remove("CalcViewModelView", "bKeypads.Anticheat.CalcViewModelView")
	hook.Remove("CreateMove", "bKeypads.Anticheat.CreateMove")
end

local function initFakeAngles()
	if bKeypads.Config.DisablePINKeypadFakeAngles then
		unloadFakeAngles()
	else
		loadFakeAngles()
	end
end

hook.Add("bKeypads.ConfigUpdated", "bKeypads.Anticheat", initFakeAngles)
initFakeAngles()