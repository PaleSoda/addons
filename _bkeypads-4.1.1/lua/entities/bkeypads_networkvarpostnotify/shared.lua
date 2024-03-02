AddCSLuaFile()

ENT.Base = "base_gmodentity"

ENT.Spawnable = false

local function NetworkVarNotifyCallback(self, name, oldVal, newVal)
	if newVal == nil then
		bKeypads:print("NetworkVar " .. tostring(name) .. " tried to set itself to nil...? Please let Billy know", bKeypads.PRINT_TYPE_WARN, "WARNING")
		debug.Trace()
		return
	end
	self.dt[name] = newVal
	self._dt_callbacks[name](self, name, oldVal, newVal)
end
function ENT:NetworkVarPostNotify(name, func)
	self._dt_callbacks = self._dt_callbacks or {}
	self._dt_callbacks[name] = func

	self:NetworkVarNotify(name, NetworkVarNotifyCallback)
end