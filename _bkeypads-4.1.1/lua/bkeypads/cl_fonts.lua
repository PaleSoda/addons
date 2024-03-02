local FONT_CIRCULAR = "Circular Std Medium"
local FONT_RUBIK = "Rubik"
local FONT_ROBOTO = "Roboto"

local FONT_16 = 16

local dyslexia = bKeypads.Settings:Get("dyslexia")
local dyslexia_weight
if dyslexia then
	FONT_CIRCULAR = "Comic Sans MS"
	FONT_RUBIK = "Comic Sans MS"
	FONT_ROBOTO = "Comic Sans MS"

	FONT_16 = 19

	dyslexia_weight = 700
end

surface.CreateFont("bKeypads.DermaDefaultDyslexia", {
	font = "Comic Sans MS",
	size = 19,
	weight = 700
})

surface.CreateFont("bKeypads.Tutorial.Caption", {
	font = FONT_CIRCULAR,
	size = 32,
	weight = dyslexia_weight,
	shadow = true
})

surface.CreateFont("bKeypads.Keycards.3D2D.Level", {
	font = "Consolas",
	weight = 700,
	shadow = true,
	size = 64
})

surface.CreateFont("bKeypads.Keycards.3D2D.Team", {
	font = "Consolas",
	shadow = true,
	size = 32
})

local levelBoxSize = 43
local levelBoxFontSize1 = levelBoxSize * (38 / 45)
local levelBoxFontSize2 = levelBoxFontSize1 * (28 / 38)
surface.CreateFont("bKeypads.Keycards.3D2D.Levels.1", {
	font = "Consolas",
	shadow = true,
	size = levelBoxFontSize1
})
surface.CreateFont("bKeypads.Keycards.3D2D.Levels.2", {
	font = "Consolas",
	shadow = true,
	size = levelBoxFontSize2
})

surface.CreateFont("bKeypads.ToolScreenNoPermission", {
	font = "Verdana",
	shadow = true,
	size = 24
})

surface.CreateFont("bKeypads.PicURLFont", {
	font = "Roboto Mono",
	size = 14
})

surface.CreateFont("bKeypads.LevelSelect.Shadow", {
	font = "Roboto Mono",
	size = 14,
	weight = 700,
	shadow = true
})

surface.CreateFont("bKeypads.LevelSelect", {
	font = "Roboto Mono",
	size = 14,
	weight = 700
})

surface.CreateFont("bKeypads.PINBtn", {
	size = 64,
	font = "Roboto Mono",
	weight = 700
})

surface.CreateFont("bKeypads.PINAsterisk", {
	size = 28,
	font = "Roboto Mono"
})

surface.CreateFont("bKeypads.PaymentFont", {
	size = 56,
	font = FONT_ROBOTO,
	weight = dyslexia_weight,
})

surface.CreateFont("bKeypads.SlideTextFont", {
	size = 255,
	font = "Uni Sans Heavy CAPS"
})

surface.CreateFont("bKeypads.OwnedByFont.1", {
	font = FONT_RUBIK,
	weight = 700,
	shadow = true,
	size = FONT_16
})

surface.CreateFont("bKeypads.OwnedByFont.2", {
	font = FONT_RUBIK,
	weight = 700,
	shadow = true,
	size = FONT_16
})

surface.CreateFont("bKeypads.KeypadLabelFont", {
	font = FONT_CIRCULAR,
	size = 50,
	weight = dyslexia_weight
})

surface.CreateFont("bKeypads.TutorialFont", {
	font = FONT_CIRCULAR,
	size = FONT_16,
	weight = dyslexia_weight
})

if bKeypads.CreateTooltipFont then
	bKeypads:CreateTooltipFont()
end