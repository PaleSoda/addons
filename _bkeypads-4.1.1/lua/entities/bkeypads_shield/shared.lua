AddCSLuaFile()

ENT.Base = "bkeypads_dmg_consumable"
DEFINE_BASECLASS(ENT.Base)

ENT.PrintName = "#bKeypads_KeypadShieldBattery"
ENT.Category = "Billy's Keypads"
ENT.Spawnable = true

function ENT:Initialize()
	self:SetModel("models/items/battery.mdl")
	self:SetColor(bKeypads.COLOR.GMODBLUE)
	self:SetBaseModelScale(.75, 0.0001)

	BaseClass.Initialize(self)
end

if SERVER then
	function ENT:Consume(keypad)
		if bKeypads.Config.KeypadDestruction.MaxShield ~= 0 and keypad:GetShield() >= bKeypads.Config.KeypadDestruction.MaxShield * keypad:GetMaxHealth() then return end

		keypad:StopSound("npc/scanner/scanner_siren2.wav")
		keypad:EmitSound("items/battery_pickup.wav", 75)

		local shield = math.max(keypad:GetShield(), 0) + math.ceil(keypad:GetMaxHealth() * bKeypads.Config.KeypadDestruction.ShieldBatteryCharge)
		if bKeypads.Config.KeypadDestruction.MaxShield == 0 then
			keypad:SetShield(shield)
		else
			keypad:SetShield(math.min(shield, math.ceil(keypad:GetMaxHealth() * bKeypads.Config.KeypadDestruction.MaxShield)))
		end

		return true
	end
else
	function ENT:DrawHUDLabel()
		draw.SimpleTextOutlined(bKeypads.L"KeypadShield", "bKeypads.KeypadLabelFont", 0, 0, bKeypads.COLOR.GMODBLUE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, bKeypads.COLOR.BLACK)
	end

	function ENT:DrawConsumedLabel()
		draw.SimpleTextOutlined(bKeypads.L("ShieldAdded"):format(math.ceil(self:GetConsumedBy():GetMaxHealth() * bKeypads.Config.KeypadDestruction.ShieldBatteryCharge)), "bKeypads.KeypadLabelFont", 0, 0, bKeypads.COLOR.GMODBLUE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, bKeypads.COLOR.BLACK)
	end
end

bKeypads_Initialize_Fix(ENT)