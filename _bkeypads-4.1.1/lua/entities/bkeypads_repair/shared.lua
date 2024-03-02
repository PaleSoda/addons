AddCSLuaFile()

ENT.Base = "bkeypads_dmg_consumable"
DEFINE_BASECLASS(ENT.Base)

ENT.PrintName = "#bKeypads_KeypadBattery"
ENT.Category = "Billy's Keypads"
ENT.Spawnable = true

function ENT:Initialize()
	self:SetModel("models/items/battery.mdl")
	self:SetColor(bKeypads.COLOR.GREEN)
	self:SetBaseModelScale(.75, 0.0001)

	BaseClass.Initialize(self)
end

if SERVER then
	function ENT:Consume(keypad)
		if keypad:Health() >= keypad:GetMaxHealth() then return end

		keypad:StopSound("npc/scanner/scanner_siren2.wav")
		keypad:EmitSound("items/battery_pickup.wav", 75)
		keypad:SetHealth(math.min(math.max(keypad:Health(), 0) + math.ceil(keypad:GetMaxHealth() * bKeypads.Config.KeypadDestruction.BatteryCharge)), keypad:GetMaxHealth())

		return true
	end
else
	function ENT:DrawHUDLabel()
		draw.SimpleTextOutlined(bKeypads.L"KeypadBattery", "bKeypads.KeypadLabelFont", 0, 0, bKeypads.COLOR.GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, bKeypads.COLOR.BLACK)
	end

	function ENT:DrawConsumedLabel()
		draw.SimpleTextOutlined(bKeypads.L("HealthAdded"):format(math.ceil(self:GetConsumedBy():GetMaxHealth() * bKeypads.Config.KeypadDestruction.BatteryCharge)), "bKeypads.KeypadLabelFont", 0, 0, bKeypads.COLOR.GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, bKeypads.COLOR.BLACK)
	end
end

bKeypads_Initialize_Fix(ENT)