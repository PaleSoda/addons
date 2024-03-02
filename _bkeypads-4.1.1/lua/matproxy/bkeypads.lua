local IsValid = IsValid
local vec_black = Vector(0, 0, 0)

matproxy.Add({
	name = "KeycardColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if IsValid(ent) and (ent.bKeypad or ent.bKeycard) then
			if ent.KeycardColor then
				mat:SetVector(self.ResultTo, ent.KeycardColor:ToVector())
			elseif ent.GetKeycardColor and ent:GetKeycardColor() then
				mat:SetVector(self.ResultTo, ent:GetKeycardColor():ToVector())
			end
		end
	end
})

matproxy.Add({
	name = "LEDColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if IsValid(ent) and ent.bKeypad then
			if ent.GetLEDColor and ent:GetLEDColor() then
				mat:SetVector(self.ResultTo, ent:GetLEDColor():ToVector())
			else
				mat:SetVector(self.ResultTo, vec_black)
			end
		end
	end
})

matproxy.Add({
	name = "ScreenColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if IsValid(ent) and (ent.bKeypad or ent.bKeypadOff) then
			if ent.GetScreenColor and ent:GetScreenColor() and not ent.m_bTVAnimation then
				mat:SetVector(self.ResultTo, ent:GetScreenColor():ToVector())
			else
				mat:SetVector(self.ResultTo, vec_black)
			end
		end
	end
})