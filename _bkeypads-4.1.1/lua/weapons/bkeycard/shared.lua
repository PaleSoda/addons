SWEP.Base = "weapon_base"

SWEP.Category = "Billy's Keypads"
SWEP.PrintName = "#bKeypads_Keycard"
SWEP.Instructions = "#bKeypads_KeycardInstructions"
SWEP.Purpose = nil
SWEP.Contact = nil
SWEP.Slot = 0
SWEP.SlotPos = 128
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/bkeypads/c_keycard.mdl"
SWEP.WorldModel = "models/bkeypads/keycard.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.DisableDuplicator = true

SWEP.CanDrop = false
SWEP.Droppable = false

SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT

function SWEP:ShouldDropOnDie() return false end
function SWEP:PrimaryAttack() return true end
function SWEP:SecondaryAttack() return true end
function SWEP:Reload() return true end
function SWEP:Holster() return true end
function SWEP:Deploy() return true end

function SWEP:Initialize()
	self.bKeycard = true
	self.CachedKeycardLevels = { [1] = true }
	self.CachedKeycardLevel = 1

	self:SetHoldType(self.HoldType)

	if CLIENT then
		self.ClientWorldModel = ClientsideModel(self.WorldModel, RENDERGROUP_OPAQUE)
		self.ClientWorldModel:SetParent(self)
		self.ClientWorldModel:SetNoDraw(true)
		self.ClientWorldModel.bKeycard = true
		self.ClientWorldModel.GetKeycardColor = function()
			if not IsValid(self) then
				return color_white
			else
				return self:GetKeycardColor()
			end
		end

		self.ClientViewModel = ClientsideModel(self.WorldModel, RENDERGROUP_VIEWMODEL)
		self.ClientViewModel:SetParent(self)
		self.ClientViewModel:SetNoDraw(true)
		self.ClientViewModel.bKeycard = true
		self.ClientViewModel.GetKeycardColor = function()
			if not IsValid(self) then
				return color_white
			else
				return self:GetKeycardColor()
			end
		end

		self.Identification = { Over = {}, Under = {} }
	else
		self:PhysicsInit(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "SelectedKeycard")

	self:NetworkVar("Bool", 0, "WasPickedUp")
	self:NetworkVar("Bool", 1, "BeingScanned")
	self:NetworkVar("Bool", 2, "Identifying")

	if CLIENT then
		self:NetworkVarNotify("Identifying", self.IdentifyingStatusChanged)
	end

	self:NetworkVarNotify("SelectedKeycard", self.SelectedKeycardChanged)
end

function SWEP:GetKeycardMetadata()
	return bKeypads.Keycards.Levels[self:GetPrimaryLevel()] or bKeypads.Keycards.Levels[1]
end

function SWEP:SelectedKeycardChanged(_, prev, selectedKeycard)
	self.m_iSelectedKeycardID = selectedKeycard

	if prev ~= selectedKeycard then
		self:EmitSound("weapons/smg1/switch_burst.wav", 55, 100, 1, CHAN_WEAPON)
	end
end

function SWEP:GetPlayerKeycardData()
	if IsValid(self:GetOwner()) then
		if not self.m_PlayerKeycardData_NextUpdate or (not self:GetOwner():IsDormant() and SysTime() >= self.m_PlayerKeycardData_NextUpdate) then
			self.m_PlayerKeycardData_NextUpdate = SysTime() + 2
			self.m_PlayerKeycardData = bKeypads.Keycards:GetKeycardData(self:GetOwner())
		end

		return self.m_PlayerKeycardData
	end
end

local defaultKeycardData = {
	PrimaryLevel = 1,
	Levels = {},
	LevelsDict = {}
}
function SWEP:GetSelectedKeycardData()
	self.m_iSelectedKeycardID = self.m_iSelectedKeycardID or self:GetSelectedKeycard()

	if self.m_iSelectedKeycardID ~= 0 then
		local keycardData = bKeypads.Keycards:GetByID(self.m_iSelectedKeycardID)
		if keycardData then
			return keycardData
		end
	end

	return self:GetPlayerKeycardData() or defaultKeycardData
end

function SWEP:GetLevels()
	return self:GetSelectedKeycardData().Levels
end

function SWEP:GetLevelsDictionary()
	return self:GetSelectedKeycardData().LevelsDict
end

function SWEP:GetPrimaryLevel()
	return self:GetSelectedKeycardData().PrimaryLevel
end

function SWEP:GetKeycardColor()
	return self:GetKeycardMetadata().Color
end

function SWEP:GetKeycardName()
	return self:GetKeycardMetadata().Name or (bKeypads.L"KeycardLevel"):format(self:GetKeycardLevel())
end

function SWEP:GetSteamID()
	return self:GetSelectedKeycardData().SteamID or ""
end

function SWEP:GetTeam()
	return self:GetSelectedKeycardData().Team or ""
end

function SWEP:GetPlayerModel()
	return self:GetSelectedKeycardData().PlayerModel or ""
end

function SWEP:GetHash()
	return util.CRC(self:GetSteamID() .. self:GetPlayerModel() .. (table.concat(self:GetLevels(), ",")) .. (IsValid(self:GetOwner()) and DarkRP and bKeypads.Config.Keycards.ShowCustomJobName and self:GetOwner().getDarkRPVar and self:GetOwner():getDarkRPVar("job") or (self:GetTeam() ~= 0 and self:GetTeam() or "")))
end