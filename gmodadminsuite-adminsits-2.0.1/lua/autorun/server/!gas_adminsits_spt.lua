local entMeta = FindMetaTable("Entity")

GAS_AdminSits_SetPreventTransmit = GAS_AdminSits_SetPreventTransmit or entMeta.SetPreventTransmit

function entMeta:SetPreventTransmit(ply, preventTransmit)
	if (hook.Run("GAS.AdminSits.TransmitStateChanged", self, ply, true) ~= false) then
		return GAS_AdminSits_SetPreventTransmit(self, ply, preventTransmit)
	end
end