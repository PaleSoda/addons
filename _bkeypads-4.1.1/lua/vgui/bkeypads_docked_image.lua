local PANEL = {}

function PANEL:SetMaterial(mat)
	self.m_Material = mat
	self.m_Square = nil

	self.m_AspectRatio = self.m_Material:Height() / self.m_Material:Width()

	self._w, self._h = nil
end

function PANEL:SetSquareMaterial(mat)
	self.m_Material = mat
	self.m_Square = true
	self._w, self._h = nil
end

function PANEL:GetMaterial()
	return self.m_Material
end

function PANEL:SetAspectRatio(aspectRatio)
	self.m_AspectRatio = aspectRatio
	self._w, self._h = nil
end

function PANEL:Paint(w,h)
	if self.m_Material then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.m_Material)
		if self.m_Square then
			surface.DrawTexturedRect(0, 0, w, w)
		else
			surface.DrawTexturedRect(0, 0, w, h)
		end

		if self._w ~= w or self._h ~= h then
			self._w, self._h = w, h
			self:SetTall(w * self.m_AspectRatio)
		end
	end
end

derma.DefineControl("bKeypads.DockedImage", nil, PANEL, "DPanel")