--------------------------
/// ESCORE CONFIG FILE ///
--------------------------
escore.config = {} --dont change this
local config = escore.config --and this

-------------
/* CONFIG  */
-------------
-- MAIN SETTINGS
config.adminmod     = "sam" 			-- ulx / sam / fadmin / serverguard / xadmin2 / xadmin / sadmin
config.language     = "english" 		-- english / german / russian / spanish / turkish / french / chinese current available
config.ServerName   = "Host name here" 	-- Text on top
config.ProfilerName = "Profiler.exe" 	-- Player window
--
config.logoanim 	= true 				-- Animation when first opening a scoreboard DEFAULT: true
config.ProfilerQuickButtons = true      -- DEFAULT: true
config.ShowCollapsibleCategories = true -- DEFAULT: true
config.ShowGroups   = true              -- Show user groups? DEFAULT: true
config.JobsCategories = true              -- Use job categories

--
config.animtime     = 0.1 				-- All animations speed DEFAULT:0.1
config.logoanimtime = 0.3               -- DEFAULT:0.3
config.blurStrength = 0					-- 0 for disable DEFAULT: 0
config.playerwide   = 0.7  				-- The higher the number, the larger the panel DEFAULT:0.7 | clamp(0.1,1)
config.playertall   = 40   				-- Player panel height DEFAULT:40
config.gap = 0 			 				-- Gap between players DEFAULT:0
config.categorytall = 22				-- Panel height DEFAULT:20

-- EFFECT SETTINGS
config.effect        = "dots" 			-- "dots" or "snow" or false if you want to off effects by default
config.effectPhysics = true 			-- DEFAULT:true ( eats ~10 fps )
config.effect_speed  = 1 				-- DEFAULT: 1

-- FPS SUSPENSION. 
-- With a small number of fps, it will decrease the number of particles, and with a large number, it will increase
config.effect_fps_suspension = true     -- DEFAULT: true
config.dots_amount = {min = 20, max = 150} --DEFAULT: min = 20, max = 150
config.snow_amount = {min = 40, max = 200} --DEFAULT: min = 40, max = 200

------------------
/// HIDED JOBS ///
------------------
config.hide_all_jobs = false
config.hidejobs = {
	--["Gun Dealer"] = true,
	--["Citizen"] = true,
}

------------------
/// USERGROUPS ///
------------------
--Colorpicker: https://colorpicker.me
--DONT FORGET ABOUT ","
--CASE SENSITIVE !!!!!!
config.usergroups = {

	["user"] = {
		Ignore = true, -- Usergroup will not show up in the list
	},

	["moderator"] = {
		Text = "Moderator", 	  -- Text replace
		Color = Color(255,255,0), -- Color
		AdminButtons = true, 	  -- Access to admin buttons like: tp / bring ...
		AdminInfo = true, 		  -- Access to viewing props, money and other RP information in the profiler
	},

	["admin"] = {
		Text = "Administrator",
		Color = Color(30, 215, 96),
		AdminButtons = true,
		AdminInfo = true,
	},

	["superadmin"] = {
		Text = "Owner",
		Color = Color(252, 29, 59),
		AdminButtons = true,
		AdminInfo = true,
	},

}



-------------
/// LINKS ///
-------------
--You can add your own link, which will be displayed at the bottom of the tab
config.links = {
	-- --EXAMPLE WITH ICON
	-- {
	-- 	Name = "Discord",				 -- ID
	-- 	HoverText = "Our Steam group", 	 -- Text that appears when you hover over a button
	-- 	IconLink = "https://cdn.iconscout.com/icon/free/png-512/discord-3-569463.png", -- If specified, then the displaytext and color fields are not used.
	-- 	Link = "https://www.google.com/" -- Link to open
	-- },

	-- --WITHOUT
	-- {
	-- 	Name = "Discord",				 -- ID
	-- 	HoverText = "Our Discord", 	     -- Text that appears when you hover over a button
	-- 	DisplayText = "DS",				 -- Replacing an icon. If not assigned, then the first letter of the name. 1-3 letters are fine
	-- 	Color = Color(30, 145, 206), 	 -- Button color
	-- 	Link = "https://www.google.com/" -- Link to open
	-- },
}


--------------
/// COLORS ///
--------------
escore.colors = {}
local clr = escore.colors

--Default colors that shouldn't change
clr.default = {
	white = Color(255,255,255),
	black = Color(13,13,13),
	red   = Color(255, 100, 100),
	green = Color(30, 215, 96),
}

--Texts
clr.text = {
	main   = Color(235,235,255),
	main2  = Color(155,155,175), --hover
	shadow = Color(0,0,0),
}

--Main colors
clr.scoreboard = {
	bg    = Color(17,17,27,200),
	main  = Color(28,28,30),
	main2 = Color(38,38,40),
	hover = Color(38,38,40),

	icon = Color(235,235,235),
	iconhover = clr.default.green,
	separator = Color(189, 195, 199),

	badping  = Color(252, 29, 59),
	averping = Color(243, 156, 18),
	goodping = Color(30, 215, 96),
}

clr.search = {
	bg = Color(31, 31, 35, 250),
	text = Color(244,244,255),
	highlight = Color(52, 52, 68),
}

--Category button
clr.category = {
	main = Color(45, 45, 58, 252),
	hover = Color(55, 55, 68, 252),
	texthover = Color(255,255,255),
}

--User button
clr.user = {
	main   = Color(20, 20, 22, 240),
	hover  = Color(35, 33, 40, 240),
	active = Color(34, 35, 38, 240),
	activehover = Color(38, 39, 44, 240),
}

--Profiler
clr.playerpanel = {
	bg = Color(24, 25, 28),
	topbar = Color(28, 29, 32),

	icons = Color(58,58,68),
	iconshover = Color(78,78,88),

	text = Color(155,155,155),
	texthover = Color(245,245,255),
}

--Notify
clr.notify = {
	bg = Color(28, 28, 30, 254),
	text = Color(255,255,255),
	progressbar = Color(30, 215, 96),

	--Hover info 
	hoverbg = Color(31, 31, 35),
	hoverbg2 = Color(46,46,50), --Outline
}

--Context menu
clr.context = {
	bg = Color(28, 28, 30),
	separator = Color(58,58,70),

	header = Color(38,38,42),
	headertext = Color(245,245,255),

	button = Color(24, 25, 28),
	buttonhover = Color(48,48,50),

	text = Color(155,155,155),
	texthover = Color(245,245,255),
}

--Radio panel
clr.radio = {
	visualizer = Color(235,235,235),
	text = clr.text.main,

	sliderbg = Color( 166, 166, 166 ),
	sliderhover = Color( 30, 215, 96 ),
	slider = Color( 255, 255, 255 ),
	knob = Color(235,235,255),
	knobhover = Color(200,255,200)
}



----------------------
/// RADIO SETTINGS ///
----------------------
-- If some radio stations take a long time to load or do not load at all,
-- then this is a problem in the stations themselves and not in the addon! Just remove them.
-- So you need exactly the DIRECT link to the radio station

config.radio = {}
config.radio.enable = true
config.radio.visualizer = true --music visualizer
config.radio.stations = {
	-- --EXAMPLE
	-- {
	-- 	name = "Here name",
	-- 	logo = "link to logo",
	-- 	url = "link to radio stream" --the link MUST be DIRECT to the audio stream!
	-- },
	-- you can find everything on the Internet

	--ENGLISH
	{
		name = "HITS Radio",
		logo = "https://i.imgur.com/X9c3RKz.png",
		url = "https://16803.live.streamtheworld.com/977_JAMZ.mp3"
	},
	{
		name = "100hitz",
		logo = "http://a1840.phobos.apple.com/us/r30/Purple3/v4/d3/d0/55/d3d055a4-f2c2-c977-ac58-64b04795c291/mzl.dnozsugp.png",
		url = "http://69.4.234.186:9070/"
	},
	{
		name = "Classic Rock",
		logo = "https://image2014.s3.amazonaws.com/61171az.jpg",
		url = "http://167.114.64.181:8352/"
	},
	{
		name = "Smooth Jazz",
		logo = "https://avatars.yandex.net/get-music-content/49707/cda572bb.a.3270219-1/m1000x1000?webp=false",
		url = "http://east-mp3-128.streamthejazzgroove.com/stream"
	},
	{
		name = "80s 90s Hits Radio",
		logo = "https://avatars.yandex.net/get-music-content/34131/6e868145.a.2532210-1/m1000x1000?webp=false",
		url = "https://n03.radiojar.com/f67zveayx7zuv?rj-ttl=5&rj-tok=AAABeXCKThUAyO24aX_0b0KCNw"
	},
	--RUSSIAN
	{
		name = "Dorojnoe Radio",
		logo = "https://dorognoe.ru/assets/default/multiplayer/img/logo_dr.svg",
		url = "http://dorognoe.hostingradio.ru:8000/dorognoe"
	},
	{
		name = "Anime radio",
		logo = "https://anison.fm/images/logo_h.png",
		url = "http://pool.anison.fm:9000/AniSonFM(320)?nocache=0.98.."
	},
	{
		name = "Radio shanson",
		logo = "https://radioshanson.ru/assets/2a380c6a/img/logo-09-09-2019.png",
		url = "https://chanson.hostingradio.ru:8041/chanson256.mp3"
	}
}