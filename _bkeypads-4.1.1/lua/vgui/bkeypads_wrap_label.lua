-- (\S+?):Help\((.+?)\)
-- bKeypads:AddHelp($1, $2)

local PANEL = {}

function PANEL:Init()
	self:SetContentAlignment(5)
	self.m_bOptimizing = true
end

function PANEL:GenerateMarkupObject(w)
	local w = w or self:GetWide()
	local markupStr = "<color=" .. bKeypads.markup.Color(self:GetTextColor() or self:GetTextStyleColor()) .. "><font=" .. bKeypads.markup.Escape(self:GetFont()) .. ">" .. bKeypads.markup.Escape(self.m_Text or self:GetText()) .. "</font></color>"
	if not self.m_MarkupObj or self.m_MarkupObj:GetMaxWidth() ~= w or markupStr ~= self.m_MarkupStr then
		self.m_MarkupStr = markupStr
		self.m_MarkupObj = bKeypads.markup.Parse(self.m_MarkupStr, w)
	end
end

function PANEL:SetText(text)
	self.m_Text = text
	DLabel.SetText(self, text)
	self:GenerateMarkupObject()
end

function PANEL:PerformLayout(w, h)
	self:GenerateMarkupObject(w)

	if self.m_iWrapCheck ~= nil then
		if self.m_bWrapCheckNextFrame then
			if self.m_iWrapCheck == h then
				self:SetWrap(false)
			end
			self.m_iWrapCheck = nil
			self.m_bWrapCheckNextFrame = nil
		else
			self.m_bWrapCheckNextFrame = true
		end
		self:InvalidateLayout()
	end
end

function PANEL:Paint(w, h)
	if bKeypads.Performance:Optimizing() then
		if not self.m_bOptimizing then
			self:SetWrap(false)
			self:SetAutoStretchVertical(false)
			DLabel.SetText(self, "X")
			self:SizeToContentsY()
			self.m_iWrapCheck = self:GetTall()

			self:SetWrap(true)
			self:SetAutoStretchVertical(true)
			DLabel.SetText(self, self.m_Text or self:GetText())

			self:InvalidateLayout(true)

			self.m_bOptimizing = true
		end
	else
		self.m_iWrapCheck = nil
		self.m_bWrapCheckNextFrame = nil

		if self.m_bOptimizing then
			DLabel.SetText(self, "")
			self:SetWrap(false)
			self:SetAutoStretchVertical(false)

			self:InvalidateLayout()

			self.m_bOptimizing = nil
		end

		if not self.m_MarkupObj then
			self:GenerateMarkupObject()
		end

		self.m_MarkupObj:Draw(0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, self:GetAlpha(), TEXT_ALIGN_CENTER)
		self:SetTall(self.m_MarkupObj:GetHeight())
	end
end

derma.DefineControl("bKeypads.WrapLabel", nil, PANEL, "DLabel")