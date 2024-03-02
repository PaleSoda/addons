SWEP.PrintName    = "#bKeypads_KeypadAccessLogs"
SWEP.Category     = "Billy's Keypads"
SWEP.Author       = "Billy"
SWEP.Purpose      = "View the access logs of a keypad"
SWEP.Instructions = "Left click a keypad"

SWEP.Slot           = 5
SWEP.SlotPos        = 2
SWEP.DrawAmmo       = false
SWEP.DrawCrosshair  = true
SWEP.Weight         = 5
SWEP.AutoSwitchTo   = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModel  = "models/weapons/v_emptool.mdl"
SWEP.WorldModel = "models/weapons/w_emptool.mdl"
SWEP.Spawnable  = true
SWEP.AdminOnly  = true

SWEP.ShowViewModel  = true
SWEP.ShowWorldModel = false

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.HolsterSound       = Sound("npc/turret_floor/retract.wav")
SWEP.DeploySound        = Sound("npc/turret_floor/deploy.wav")
SWEP.ErrorSound         = Sound("npc/roller/code2.wav")
SWEP.ViewLogsSound      = Sound("AlyxEMP.Discharge")

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("bkeypads/access_logs_selection")
	SWEP.BounceWeaponIcon = true
end

function SWEP:SecondaryAttack() return false end

function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "ScanningKeypad")
end

local warranted = {}
local function isWarranted(ply)
	if SERVER then
		return ply.warranted == true
	else
		return warranted[ply] or false
	end
end
function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTrace()
	if tr.Hit and tr.StartPos:DistToSqr(tr.HitPos) <= 2025 and IsValid(tr.Entity) and tr.Entity.bKeypad then
		if DarkRP and bKeypads.Config.AccessLogs.PoliceNeedWarrant and self:GetOwner():isCP() then
			local ply = (CLIENT and tr.Entity:GetKeypadOwner()) or (SERVER and tr.Entity:GetCreator()) or nil
			if IsValid(ply) and ply ~= self:GetOwner() and not isWarranted(ply) and not ply:isWanted() and not ply:isArrested() then
				if CLIENT and IsFirstTimePredicted() then
					self:EmitSound("npc/roller/mine/rmine_predetonate.wav", 75, 100, 1, CHAN_WEAPON)
					notification.AddLegacy(bKeypads.L"AccessLogsWarrant", NOTIFY_ERROR, 3)
				end
				return false
			end
		end

		self:SendWeaponAnim(ACT_VM_FIDGET)
		self:EmitSound(self.ViewLogsSound, 75, 100, 1, CHAN_WEAPON)

		if SERVER then
			if self:GetScanningKeypad() ~= tr.Entity then
				self:SetScanningKeypad(tr.Entity)
				hook.Run("bKeypads.AccessLogs.Checked", self:GetOwner(), tr.Entity)
			end
			bKeypads.AccessLogs:OpenUI(self:GetOwner(), tr.Entity, self)
		end

		return true
	end

	if CLIENT and IsFirstTimePredicted() then
		self:EmitSound("npc/roller/code2.wav", 75, 100, 1, CHAN_WEAPON)
	end

	return false
end

-- retarded networking because darkrp does not have a shared function to check warrants for some reason
if SERVER then
	bKeypads:GMInitialize(function()
		if not DarkRP then return end

		util.AddNetworkString("bKeypads.Warrant")

		hook.Add("playerWarranted", "bKeypads.AccessLogs", function(ply)
			if not bKeypads.Config.AccessLogs.PoliceNeedWarrant then return end
			net.Start("bKeypads.Warrant")
				net.WriteEntity(ply)
				net.WriteBool(true)
			net.Broadcast()
		end)

		hook.Add("playerUnWarranted", "bKeypads.AccessLogs", function(ply)
			if not bKeypads.Config.AccessLogs.PoliceNeedWarrant then return end
			net.Start("bKeypads.Warrant")
				net.WriteEntity(ply)
				net.WriteBool(false)
			net.Broadcast()
		end)
	end)
else
	net.Receive("bKeypads.Warrant", function()
		warranted[net.ReadEntity()] = net.ReadBool() or nil
	end)
end

function SWEP:Deploy()
	self:SetScanningKeypad(NULL)

	self:SetHoldType("slam")
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:EmitSound(self.DeploySound, 75, 100, 1, CHAN_WEAPON)
end

function SWEP:Holster()
	self:SetScanningKeypad(NULL)

	self:EmitSound(self.HolsterSound, 75, 100, 1, CHAN_WEAPON)

	return true
end

function SWEP:Think()
	local scanningKeypad = self:GetScanningKeypad()
	if IsValid(scanningKeypad) then
		local tr = self:GetOwner():GetEyeTrace()
		if not tr.Hit or not IsValid(tr.Entity) or not tr.Entity.bKeypad or tr.StartPos:DistToSqr(tr.HitPos) > 2025 then
			if SERVER then
				self:SetScanningKeypad(NULL)
			end
		else
			self:SetHoldType("pistol")
			return
		end
	end

	self:SetHoldType("slam")
end

if SERVER then
	util.AddNetworkString("bKeypads.AccessLogs.Closed")
	net.Receive("bKeypads.AccessLogs.Closed", function(_, ply)
		local scanningKeypad = net.ReadEntity()
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "bkeypads_access_logs" and wep:GetScanningKeypad() == scanningKeypad then
			wep:SetScanningKeypad(NULL)
		end
	end)
else
	SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT

	local renderKeypadOutlines = {}
	function SWEP:DrawKeypadOutline(keypad)
		renderKeypadOutlines[keypad] = true
	end

	local keypadOutlineModelsGarbage = {}
	local keypadOutlineModels

	bKeypads_AccessLogs_Garbage = bKeypads_AccessLogs_Garbage or {}
	for garbage in pairs(bKeypads_AccessLogs_Garbage) do garbage:Remove() end

	local keypadOutlineMat = Material("models/props_combine/portalball001_sheet")
	hook.Add("PreDrawEffects", "bKeypads.AccessLogs.Effect", function()
		local context3D = false
		for keypad in pairs(renderKeypadOutlines) do
			if not context3D then
				context3D = true
				cam.Start3D()
			end

			if not keypadOutlineModels then
				keypadOutlineModels = {}
			end

			if keypadOutlineModelsGarbage and IsValid(keypadOutlineModelsGarbage[keypad]) then
				keypadOutlineModels[keypad] = keypadOutlineModelsGarbage[keypad]
				keypadOutlineModelsGarbage[keypad] = nil
			elseif not IsValid(keypadOutlineModels[keypad]) then
				keypadOutlineModels[keypad] = ClientsideModel(keypad:GetModel(), RENDERGROUP_TRANSLUCENT)
				keypadOutlineModels[keypad]:SetNoDraw(true)
				keypadOutlineModels[keypad]:SetPos(keypad:GetPos())
				keypadOutlineModels[keypad]:SetAngles(keypad:GetAngles())
				keypadOutlineModels[keypad]:SetParent(keypad)
				keypadOutlineModels[keypad]:SetModelScale(1.05)

				bKeypads_AccessLogs_Garbage[keypadOutlineModels[keypad]] = true
			end

			render.ModelMaterialOverride(keypadOutlineMat)
				keypadOutlineModels[keypad]:DrawModel()
			render.ModelMaterialOverride(nil)

			renderKeypadOutlines[keypad] = nil
		end
		if context3D then cam.End3D() end
	end)
	hook.Add("PostRender", "bKeypads.AccessLogs.CollectGarbage", function()
		if keypadOutlineModelsGarbage then
			for _, ent in pairs(keypadOutlineModelsGarbage) do ent:Remove() end
		end
		keypadOutlineModelsGarbage = keypadOutlineModels
		keypadOutlineModels = nil
	end)

	local scanningBeamMat = Material("cable/physbeam")
	function SWEP:DrawBeam(origin, target)
		local dist = origin:Distance(target)
		local clamp = math.max(math.floor(dist / 10), 4)

		render.SetMaterial(scanningBeamMat)
		render.DrawBeam(target, origin, 3, SysTime() + clamp, SysTime(), bKeypads.COLOR.WHITE)
	end

	local EMP_TOOL_MUZZLE = Vector(-3.335912, -2.608896, -0.468449)
	function SWEP:DrawWorldModelTranslucent(flags)
		local scanningKeypad = self:GetScanningKeypad()
		if IsValid(scanningKeypad) then
			local target = scanningKeypad:_LocalToWorld(scanningKeypad:OBBCenter())

			self:DrawKeypadOutline(scanningKeypad)

			local worldEnt = self.WElements["scanner"].modelEnt
			if IsValid(worldEnt) then
				self:DrawBeam(worldEnt:LocalToWorld(EMP_TOOL_MUZZLE), target)
			end
		end

		self:DrawWorldModel(flags)
	end

	local EMP_TOOL_BONE_POS = Vector(18.193024, -4.947582, -8.859428)
	local EMP_TOOL_MUZZLE = Vector(21.075607, -4.780647, -4.641513)
	local EMP_TOOL_MUZZLE_BONE = EMP_TOOL_MUZZLE - EMP_TOOL_BONE_POS
	local bone = "EMP_TOOL.base"
	function SWEP:PreDrawViewModel(vm)
		local scanningKeypad = self:GetScanningKeypad()
		if not IsValid(scanningKeypad) then return end

		local boneID = vm:LookupBone(bone)

		local origin
		if boneID then
			origin = vm:LocalToWorld(vm:WorldToLocal(vm:GetBonePosition(boneID)) + EMP_TOOL_MUZZLE_BONE)
		else
			origin = vm:LocalToWorld(EMP_TOOL_MUZZLE)
		end

		local target = bKeypads:TranslateViewModelPosition(self.ViewModelFOV or 62, scanningKeypad:_LocalToWorld(scanningKeypad:OBBCenter()))
		self:DrawKeypadOutline(scanningKeypad)
		self:DrawBeam(origin, target)
	end

	function SWEP:Initialize()
		self:CreateModels(self.WElements)
	end
end

if SERVER then
	function SWEP:OnDrop()
		if not bKeypads.Config.AccessLogs.CanDrop then
			self:Remove()
		end
	end

	hook.Add("canDropWeapon", "bKeypads.AccessLogs.canDropWeapon", function(ply, wep)
		if not bKeypads.Config.AccessLogs.CanDrop and IsValid(wep) and wep:GetClass() == "bkeypads_access_logs" then
			return false
		end
	end)
end

if CLIENT then
	SWEP.WElements = {
		["scanner"] = {
			type = "Model",
			model = "models/weapons/w_emptool.mdl",
			bone = "ValveBiped.Anim_Attachment_RH",
			rel = "",
			pos = Vector(-1, -1.636, 5.752),
			angle = Angle(38.57, -180, 12.857),
			size = Vector(1, 1, 1),
			color = Color(255, 255, 255, 255),
			material = "",
			skin = 0,
			bodygroup = {}
		}
	}

	-- CREDIT: SWEP Construction Kit
	-- https://github.com/Clavus/SWEP_Construction_Kit

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		if not IsValid(self:GetOwner()) or self.ShowWorldModel == nil or self.ShowWorldModel then
			self:DrawModel()
			return
		end

		if self.GetBoneOrientation == nil then return end

		if not self.wRenderOrder then
			self.wRenderOrder = {}
			for k, v in pairs(self.WElements) do
				if v.type == "Model" then
					table.insert(self.wRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		if IsValid(self:GetOwner()) then
			bone_ent = self:GetOwner()
		else
			bone_ent = self
		end

		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]
			if not v then
				self.wRenderOrder = nil
				break
			end
			if v.hide then continue end

			local pos, ang

			if v.bone then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end

			if not pos then continue end

			local model = v.modelEnt

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			model:SetAngles(ang)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if v.material == "" then
				model:SetMaterial("")
			elseif model:GetMaterial() ~= v.material then
				model:SetMaterial(v.material)
			end

			if v.skin and v.skin ~= model:GetSkin() then
				model:SetSkin(v.skin)
			end

			if v.bodygroup then
				for k, v in pairs(v.bodygroup) do
					if model:GetBodygroup(k) ~= v then
						model:SetBodygroup(k, v)
					end
				end
			end

			render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
			render.SetBlend(v.color.a / 255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
		end
	end

	function SWEP:CreateModels(tab)
		for k, v in pairs(tab) do
			if
				(v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and
					string.find(v.model, ".mdl") and
					file.Exists(v.model, "GAME"))
			 then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if IsValid(v.modelEnt) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif
				(v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and
					file.Exists("materials/" .. v.sprite .. ".vmt", "GAME"))
			 then
				local name = v.sprite .. "-"
				local params = {["$basetexture"] = v.sprite}
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}
				for i, j in pairs(tocheck) do
					if v[j] then
						params["$" .. j] = 1
						name = name .. "1"
					else
						name = name .. "0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
			end
		end
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if tab.rel and tab.rel ~= "" then

			local v = basetab[tab.rel]

			if not v then return end

			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if not pos then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)
			if not bone then return end

			pos, ang = vector_origin, angle_zero
			local m = ent:GetBoneMatrix(bone)
			if m then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

		end

		return pos, ang
	end
end
