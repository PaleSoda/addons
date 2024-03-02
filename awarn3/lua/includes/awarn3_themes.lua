AddCSLuaFile()
local themes = {}

local function RegisterTheme( theme )
	themes[theme.name] = theme
end

local THEME = {}
THEME.name = "Dark"
THEME.colors = {
	COLOR_SELECTED = Color( 255, 136, 0, 100 ),
	COLOR_BUTTON_SELECTED = Color( 180, 120, 20, 40 ),
	COLOR_BUTTON = Color( 80, 80, 80, 0 ),
	COLOR_BUTTON_2 = Color( 80, 80, 80, 255 ),
	COLOR_BUTTON_2_HOVERED = Color( 80, 80, 80, 60 ),
	COLOR_BUTTON_HOVERED = Color( 92, 92, 92, 220 ),
	COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
	COLOR_BUTTON_TEXT = Color( 255, 255, 255, 255 ),
	COLOR_LABEL_TEXT = Color( 255, 255, 255, 255 ),
	COLOR_LABEL_VALUE_TEXT = Color( 180, 180, 180, 255 ),
	COLOR_THEME_PRIMARY = Color( 40, 40, 40, 255 ),
	COLOR_THEME_PRIMARY_SHADOW = Color( 35, 35, 35, 255 ),
	COLOR_THEME_SECONDARY = Color( 50, 50, 50, 255 ),
	COLOR_RED_BUTTON = Color(200,40,40,200),
	COLOR_RED_BUTTON_HOVERED = Color(200,40,40,100),
}
RegisterTheme( THEME )

local THEME = {}
THEME.name = "Light"
THEME.colors = {
	COLOR_SELECTED = Color( 255, 136, 0, 200 ),
	COLOR_BUTTON_SELECTED = Color( 120, 120, 120, 140 ),
	COLOR_BUTTON = Color( 80, 80, 80, 0 ),
	COLOR_BUTTON_2 = Color( 200, 80, 60, 120 ),
	COLOR_BUTTON_2_HOVERED = Color( 200, 80, 60, 60 ),
	COLOR_BUTTON_HOVERED = Color( 80, 80, 80, 60 ),
	COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
	COLOR_BUTTON_TEXT = Color( 20, 20, 20, 240 ),
	COLOR_LABEL_TEXT = Color( 60, 10, 10, 210 ),
	COLOR_LABEL_VALUE_TEXT = Color( 40, 30, 30, 240 ),
	COLOR_THEME_PRIMARY = Color( 230, 230, 235, 250 ),
	COLOR_THEME_SECONDARY = Color( 206, 206, 206, 255 ),
	COLOR_THEME_PRIMARY_SHADOW = Color( 189, 189, 189, 250 ),
	COLOR_RED_BUTTON = Color(255,0,0,200),
	COLOR_RED_BUTTON_HOVERED = Color(255,0,0,200),
}
RegisterTheme( THEME )

local THEME = {}
THEME.name = "Rose"
THEME.colors = {
	COLOR_SELECTED = Color( 255, 0, 200, 160 ),
	COLOR_BUTTON_SELECTED = Color( 180, 40, 40, 40 ),
	COLOR_BUTTON = Color( 80, 80, 80, 0 ),
	COLOR_BUTTON_2 = Color( 180, 80, 80, 120 ),
	COLOR_BUTTON_2_HOVERED = Color( 180, 80, 80, 180 ),
	COLOR_BUTTON_HOVERED = Color( 80, 80, 80, 30 ),
	COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
	COLOR_BUTTON_TEXT = Color( 20, 20, 20, 180 ),
	COLOR_LABEL_TEXT = Color( 180, 80, 160, 255 ),
	COLOR_LABEL_VALUE_TEXT = Color( 220, 80, 220, 220 ),
	COLOR_THEME_PRIMARY = Color( 255, 230, 255, 250 ),
	COLOR_THEME_SECONDARY = Color( 255, 210, 255, 255 ),
	COLOR_THEME_PRIMARY_SHADOW = Color( 235, 216, 234, 250 ),
	COLOR_RED_BUTTON = Color(255,80,80,200),
	COLOR_RED_BUTTON_HOVERED = Color(255,80,80,255),
}
RegisterTheme( THEME )

local THEME = {}
THEME.name = "Burgandy"
THEME.colors = {
	COLOR_SELECTED = Color( 200, 110, 20, 200 ),
	COLOR_BUTTON_SELECTED = Color( 180, 50, 80, 80 ),
	COLOR_BUTTON = Color( 80, 80, 80, 0 ),
	COLOR_BUTTON_2 = Color( 180, 50, 80, 120 ),
	COLOR_BUTTON_2_HOVERED = Color( 180, 50, 80, 180 ),
	COLOR_BUTTON_HOVERED = Color( 80, 80, 80, 30 ),
	COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
	COLOR_BUTTON_TEXT = Color( 240, 240, 240, 150 ),
	COLOR_LABEL_TEXT = Color( 250, 250, 250, 200 ),
	COLOR_LABEL_VALUE_TEXT = Color( 255, 200, 200, 180 ),
	COLOR_THEME_PRIMARY = Color( 80, 0, 20, 250 ),
	COLOR_THEME_SECONDARY = Color( 100, 0, 40, 255 ),
	COLOR_THEME_PRIMARY_SHADOW = Color( 60, 0, 10, 250 ),
	COLOR_RED_BUTTON = Color(255,0,0,200),
	COLOR_RED_BUTTON_HOVERED = Color(255,0,0,200),
}
RegisterTheme( THEME )

function AWarn:ReturnThemes()
	return themes
end

function AWarn:SetTheme( theme )
	AWarn.Colors = themes[theme].colors
end