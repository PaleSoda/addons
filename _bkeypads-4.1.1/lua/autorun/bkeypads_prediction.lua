local Prediction_Deploy, Prediction_Holster
function bKeypads_Prediction(tbl)
	if SERVER then
		tbl.m_fbKeypadsDeploy = tbl.m_fbKeypadsDeploy or tbl.Deploy
		tbl.m_fbKeypadsHolster = tbl.m_fbKeypadsHolster or tbl.Holster

		tbl.Deploy = Prediction_Deploy
		tbl.Holster = Prediction_Holster
	end
end

if SERVER then
	util.AddNetworkString("bKeypads.PredictionWorkaround")

	function Prediction_Deploy(self)
		local returnVal
		if self.m_fbKeypadsDeploy then
			returnVal = self.m_fbKeypadsDeploy(self)
			if returnVal == false then return false end
		end

		if self.m_fbKeypadsDeployed == true then return returnVal end
		self.m_fbKeypadsDeployed = true
		self.m_fbKeypadsHolstered = nil

		if self.Deployed then self:Deployed() end

		if not IsValid(self:GetOwner()) then return returnVal end

		net.Start("bKeypads.PredictionWorkaround")
			net.WriteBool(self.Mode ~= nil)
			if self.Mode ~= nil then
				net.WriteString(self.Mode)
			else
				net.WriteEntity(self)
				net.WriteString(self:GetClass())
			end
			net.WriteBool(true)
		net.Send(self:GetOwner())

		return returnVal
	end

	function Prediction_Holster(self)
		local returnVal
		if self.m_fbKeypadsHolster then
			returnVal = self.m_fbKeypadsHolster(self)
			if returnVal == false then return false end
		end

		if self.m_fbKeypadsHolstered == true then return returnVal end
		self.m_fbKeypadsHolstered = true
		self.m_fbKeypadsDeployed = nil

		if self.Holstered then self:Holstered() end

		if not IsValid(self:GetOwner()) then return returnVal end

		net.Start("bKeypads.PredictionWorkaround")
			net.WriteBool(self.Mode ~= nil)
			if self.Mode ~= nil then
				net.WriteString(self.Mode)
			else
				net.WriteEntity(self)
				net.WriteString(self:GetClass())
			end
			net.WriteBool(false)
		net.Send(self:GetOwner())

		return returnVal
	end
else
	net.Receive("bKeypads.PredictionWorkaround", function()
		local interface
		if net.ReadBool() then
			-- STOOL

			interface = LocalPlayer():GetTool(net.ReadString())
			if not interface then return end
		else
			-- SWEP
			local SWEP = net.ReadEntity()
			local fallbackClass = net.ReadString()
			if not IsValid(SWEP) then
				local func = net.ReadBool() and "Deployed" or "Holstered"
				bKeypads:nextTick(function()
					local interface = LocalPlayer():GetWeapon(fallbackClass)
					if IsValid(interface) and isfunction(interface[func]) then
						interface[func](interface)
					end
				end)
				return
			end

			interface = SWEP
		end

		local func = interface[net.ReadBool() and "Deployed" or "Holstered"]
		if func then func(interface) end
	end)
end

if CLIENT then
	local function Initialize(self)
		-- Store initialized state
		self.m_bInitialized = true

		local initFunc = self._Initialize
		self._Initialize = nil

		-- Check if it has an Initialize function and call it
		if initFunc then
			initFunc(self)
		end

		-- Uninject Initialize fix
		self.Initialize = initFunc
	end
	local function Think(self)
		-- Check if Initialize function is our fixed one
		if not self.m_bInitialized and self.Initialize == Initialize then
			-- Initialize the entity, clearly gmod failed to call this for whatever reason
			self:Initialize()
		end

		-- Check if it has a Think function and call it
		if self._Think then
			self:_Think()
		end

		if self.m_bInitialized then
			-- Uninject Initialize fix
			self.Think = self._Think
			self._Think = nil
		end
	end
	function bKeypads_Initialize_Fix(ENT)
		if ENT.Initialize == Initialize or ENT.Think == Think or ENT._Initialize ~= nil or ENT._Think ~= nil then return end

		ENT._Initialize = ENT.Initialize
		ENT._Think = ENT.Think

		ENT.Initialize = Initialize
		ENT.Think = Think
	end
else
	bKeypads_Initialize_Fix = function() end
end