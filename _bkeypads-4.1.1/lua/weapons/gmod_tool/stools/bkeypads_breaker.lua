TOOL.Category = "Billy's Keypads"
TOOL.Name = "#tool.bkeypads_breaker.name"
TOOL.AddToMenu = false

TOOL.ClientConVar["slant"] = 1

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "break_keypad", icon = "gui/lmb.png", op = 0 },
		{ name = "repair_keypad", icon = "gui/rmb.png", op = 0 }
	}
end

-- TODO show keypad owner in logs

function TOOL:LeftClick(tr)
	if not IsValid(self:GetOwner()) or not bKeypads.Permissions:Check(self:GetOwner(), "tools/keypad_breaker") then return false end

	if IsValid(tr.Entity) and tr.Entity.bKeypad and not tr.Entity:GetBroken() and not tr.Entity:GetHacked() then
		if SERVER then
			tr.Entity:SetHealth(0)
			tr.Entity:Break(tobool(self:GetClientNumber("slant")))
		elseif CLIENT and IsFirstTimePredicted() then
			notification.AddLegacy(bKeypads.L"KeypadBroken", NOTIFY_UNDO, 2)
		end
		return true
	end

	return false
end

function TOOL:RightClick(tr)
	if not IsValid(self:GetOwner()) or not bKeypads.Permissions:Check(self:GetOwner(), "tools/keypad_breaker") then return false end

	if IsValid(tr.Entity) and tr.Entity.bKeypad and tr.Entity:GetBroken() and not tr.Entity:GetHacked() then
		if SERVER then
			tr.Entity:SetHealth(tr.Entity:GetMaxHealth())
			tr.Entity:Repair()
		elseif CLIENT and IsFirstTimePredicted() then
			notification.AddLegacy(bKeypads.L"KeypadRepaired", NOTIFY_GENERIC, 2)
		end
		return true
	end

	return false
end

function TOOL:Reload(tr)
	return false
end

function TOOL.BuildCPanel(CPanel)
	local L = bKeypads.L

	bKeypads:InjectSmoothScroll(CPanel)
	bKeypads:STOOLMatrix(CPanel)

	local Video = vgui.Create("bKeypads.DockedImage", CPanel)
	Video:SetMaterial(Material("bkeypads/keypad_breaker"))
	Video:SetAspectRatio(416 / 736)
	CPanel:AddItem(Video)

	local Help = vgui.Create("DForm", CPanel)
		Help:SetExpanded(true)
		Help:SetLabel(L"Help")
		local label = Help:Help("#tool.bkeypads_breaker.help")
		label:GetParent():DockMargin(0, 0, 0, 8)
		label:DockMargin(0, 0, 0, 0)
	CPanel:AddItem(Help)

	local Config = vgui.Create("DForm", CPanel)
		Config:SetExpanded(true)
		Config:SetLabel(L"Configuration")

		Config:CheckBox(L"Slant", "bkeypads_breaker_slant")
		Config:Help(L"SlantTip"):DockMargin(0, 0, 0, 0)

	CPanel:AddItem(Config)

	hook.Run("bKeypads.BuildCPanel", CPanel)
end
bKeypads_KeypadBreaker_BuildCPanel = TOOL.BuildCPanel

function TOOL:Deploy()
	self.m_Deployed = true
	if CLIENT then bKeypads.ESP:Activate() end

	self:SetStage(0)
	self:SetOperation(0)
end

function TOOL:Holster()
	self.m_Deployed = nil
	if CLIENT then bKeypads.ESP:Deactivate() end

	self:SetStage(0)
	self:SetOperation(0)
end

if CLIENT then
	function TOOL:Deployed()
		self:Deploy()
	end
	function TOOL:Holstered()
		self:Holster()
	end
end
bKeypads_Prediction(TOOL)

if CLIENT then
	local matKeypadBreaker = CreateMaterial("bkeypads_breaker", "UnlitGeneric", {
		["$basetexture"] = "bkeypads/face_id_sad",
		["$vertexcolor"] = 1,
		["$translucent"] = 1,
		["$ignorez"] = 1
	})

	function TOOL:DrawToolScreen(w,h)
		surface.SetDrawColor(bKeypads.Config.Appearance.ScreenColors.Hacked)
		surface.DrawRect(0,0,w,h)

		if not self.Matrix then
			self.Matrix = bKeypads_Matrix("STOOL_Screen", w, h)
		end
		self.Matrix:Draw(w,h)

		surface.SetDrawColor(bKeypads:DarkenForeground(bKeypads.Config.Appearance.ScreenColors.Hacked) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE)
		surface.SetMaterial(matKeypadBreaker)
		surface.DrawTexturedRect((w - (w * .75)) / 2, (h - (h * .75)) / 2, w * .75, h * .75)

		if not bKeypads.Permissions:Cached(LocalPlayer(), "tools/keypad_breaker") then
			bKeypads:ToolScreenNoPermission(w,h)
		end
	end
end