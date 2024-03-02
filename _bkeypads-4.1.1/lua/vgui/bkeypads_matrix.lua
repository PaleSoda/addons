local MatrixChars = {"█","░","▓","▒","男","甸","甹","町","画","甼","甽","甾","甿","畀","畁","畂","畃","畄","畅","畆","畇","畈","畉","畊","畋","界","畍","畎","畏","畐","畑"}

local function bKeypads_Matrix_Instance_SetSize(self, w, h)
	local recompute = self.w ~= w or self.h ~= h
	self.w = w
	self.h = h
	if recompute then
		self:Recompute()
	end
end
local function bKeypads_Matrix_Instance_SetRainSize(self, CharSize)
	self.CharSize = CharSize
	self:Recompute()
end
local function bKeypads_Matrix_Instance_Recompute(self)
	self.ResolutionW = math.ceil(self.w / self.CharSize)
	self.ResolutionH = math.ceil(self.h / self.CharSize)

	self.ColumnHeights = {}
	self.Drops = {}
	self.RainStep = 0
	for i=1,self.ResolutionW do
		self.ColumnHeights[i] = math.random(0, self.ResolutionH * 2)
		self.Drops[i] = {}
		for j=1,math.min(self.ColumnHeights[i], self.ResolutionH) do
			self.Drops[i][j] = MatrixChars[math.random(1,#MatrixChars)]
		end
	end

	surface.CreateFont("bKeypadsMatrix_" .. self.CharSize, {
		size = self.CharSize,
		font = "Roboto",
		extended = true
	})
end
local function bKeypads_Matrix_Instance_SetRainColor(self, col)
	self.RainColor = col
end
local function bKeypads_Matrix_Instance_ContrastRainColor(self, col)
	local luminance = bKeypads:GetLuminance(col)
	if luminance > .35 then
		bKeypads_Matrix_Instance_SetRainColor(self, bKeypads.COLOR.BLACK)
	else
		self.ContrastRainWhite = self.ContrastRainWhite or Color(255,255,255)
		self.ContrastRainWhite.a = ((255 - 25) * luminance) + 25
		bKeypads_Matrix_Instance_SetRainColor(self, self.ContrastRainWhite)
	end
end
local function bKeypads_Matrix_Instance_SetBGColor(self, col)
	self.BGColor = col
end
local function bKeypads_Matrix_Instance_Draw(self, w, h)
	self:SetSize(w,h)

	if self.BGColor then
		surface.SetDrawColor(self.BGColor)
		surface.DrawRect(0,0,w,h)
	end

	if not bKeypads.Performance:Optimizing() then
		local step = SysTime() >= self.RainStep
		if step then self.RainStep = SysTime() + .033 end

		local alpha = surface.GetAlphaMultiplier()

		local font = "bKeypadsMatrix_" .. self.CharSize

		for i=1,self.ResolutionW do
			if step then
				self.ColumnHeights[i] = self.ColumnHeights[i] + 1
				if self.ColumnHeights[i] > self.ResolutionH * 2 then
					self.ColumnHeights[i] = math.random(-self.ResolutionH, 0)
				end
			end
			if self.ColumnHeights[i] > 0 then
				self.Drops[i][self.ColumnHeights[i]] = MatrixChars[math.random(1,#MatrixChars)]
				for j=1,math.min(self.ColumnHeights[i], self.ResolutionH) do
					surface.SetAlphaMultiplier(alpha * ((j / self.ColumnHeights[i]) * (1 - (math.max(0, self.ColumnHeights[i] - self.ResolutionH) / self.ResolutionH))))
					draw.SimpleText(self.Drops[i][j], font, (i - 1) * self.CharSize, (j - 1) * self.CharSize, self.RainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
			end
		end

		surface.SetAlphaMultiplier(alpha)
	end
end

local bKeypads_Matrix_Instance = {
	RainColor = Color(0,0,0),
	CharSize = 12,
	SetSize = bKeypads_Matrix_Instance_SetSize,
	SetRainSize = bKeypads_Matrix_Instance_SetRainSize,
	SetRainColor = bKeypads_Matrix_Instance_SetRainColor,
	SetBGColor = bKeypads_Matrix_Instance_SetBGColor,
	Recompute = bKeypads_Matrix_Instance_Recompute,
	Draw = bKeypads_Matrix_Instance_Draw,
	ContrastRainColor = bKeypads_Matrix_Instance_ContrastRainColor
}

local function bKeypads_Matrix__construct(self, id, w, h, RainColor)
	if not self.Instances[id] then
		self.Instances[id] = table.Copy(bKeypads_Matrix_Instance)
		self.Instances[id].ID = id
		self.Instances[id]:SetSize(w,h)
		self.Instances[id].RainColor = RainColor or self.Instances[id].RainColor
	end
	return self.Instances[id]
end

bKeypads_Matrix = {
	Instances = {},
	__construct = bKeypads_Matrix__construct
}

setmetatable(bKeypads_Matrix, {__call = bKeypads_Matrix.__construct})

--#########################################--

local PANEL = {}

function PANEL:SetMatrixID(id)
	if self.Instance == nil or self.Instance.ID ~= id then
		self.Instance = bKeypads_Matrix(id, self:GetWide(), self:GetTall())
	end
end

function PANEL:SetRainColor(col)
	self.Instance:SetRainColor(col)
end

function PANEL:SetRainSize(size)
	self.Instance:SetRainSize(size)
end

function PANEL:SetBGColor(col)
	self.Instance.BGColor = col
end

function PANEL:PerformLayout(w,h)
	self.Instance:SetSize(w,h)
end

local drawnMatrices, frame = 0
function PANEL:Paint(w,h)
	if not self.Instance then
		error("attempt to index field 'Instance' (a nil value)")
		self:Remove()
		return
	end
	if render.GetRenderTarget() ~= nil then return end
	if frame ~= FrameNumber() then
		drawnMatrices = 1
	else
		drawnMatrices = drawnMatrices + 1
	end
	if drawnMatrices >= 3 then return end
	self.Instance:Draw(w,h)
end

hook.Add("PostRender", "bKeypads.Matrix.Optimizations", function() drawnMatrices = 0 end)

derma.DefineControl("bKeypads.Matrix", nil, PANEL, "DPanel")