if CLIENT then

  surface.CreateFont( "Graphite_Roboto_20", {
  	font = "Roboto",
  	extended = false,
  	size = 20,
  	weight = 500,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_15", {
  	font = "Roboto",
  	extended = false,
  	size = 15,
  	weight = 500,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_17", {
  	font = "Roboto",
  	extended = false,
  	size = 17,
  	weight = 1000,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_25", {
  	font = "Roboto",
  	extended = false,
  	size = 25,
  	weight = 500,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_40", {
  	font = "Roboto",
  	extended = false,
  	size = 40,
  	weight = 1000,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_50", {
  	font = "Roboto",
  	extended = false,
  	size = 50,
  	weight = 1000,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_60", {
  	font = "Roboto",
  	extended = false,
  	size = 60,
  	weight = 1000,
  	antialias = true,
  } )

  surface.CreateFont( "Graphite_Roboto_80", {
  	font = "Roboto",
  	extended = false,
  	size = 80,
  	weight = 1000,
  	antialias = true,
  } )


local HungerMaterial = Material("materials/graphite_hud/hunger_32.png")
local IdMaterial = Material("materials/graphite_hud/id_32.png")
local CashMaterial = Material("materials/graphite_hud/cash_32.png")
local JobMaterial = Material("materials/graphite_hud/job_32.png")
local HeartMaterial = Material("materials/graphite_hud/heart_32.png")
local ArmorMaterial = Material("materials/graphite_hud/shield_32.png")
local LicenceMaterial = Material("materials/graphite_hud/gun_32.png")
local WantedMaterial = Material("materials/graphite_hud/star_32.png")

local Job2Material = Material("materials/graphite_hud/job_128.png")
local Id2Material = Material("materials/graphite_hud/id_128.png")
local Heart2Material = Material("materials/graphite_hud/heart_128.png")
local Licence2Material = Material("materials/graphite_hud/licence_128.png")
local Rank2Material = Material("materials/graphite_hud/rank_128.png")
local Hunger2Material = Material("materials/graphite_hud/hunger_64.png")
  
local function Icon()
  if !GraphiteConfig.DisableLeftBottomHud then
    if GraphiteConfig.DisableGraphiteHUD then return end
    if GraphiteConfig.PlayerIconType == "model" then
      local icon = vgui.Create("DModelPanel")
      icon:SetSize(75,75)
      icon:SetPos(20,ScrH() - (120 - 5))
      icon:SetModel(LocalPlayer():GetModel())
      function icon:LayoutEntity(Entity) return end
      function icon.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end
        icon:SetFOV(12)
        icon:SetCamPos(Vector(85,-20,65))
      	icon:SetLookAt(Vector(0,0,62))
      	icon.Entity:SetEyeTarget(Vector(200, 200, 100))
          timer.Create("UpdateIcon",0.5, 0,function()
            if icon:IsValid() and LocalPlayer():GetModel() != icon.Entity:GetModel() then
              icon:SetModel(LocalPlayer():GetModel())
            end
          end)
    else
      local Avatar = vgui.Create("AvatarImage")
      Avatar:SetSize(75,75)
      Avatar:SetPos(20,ScrH() - (120 - 5))
      Avatar:SetPlayer(LocalPlayer(),75)
    end
  end
end

hook.Add("InitPostEntity", "GraphiteIcon", Icon)

function OutlinedBox(x,y,w,h,thickness,clr)
	surface.SetDrawColor(clr)
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect(x + i, y + i,w - i * 2,h - i * 2)
	end
end

if GraphiteConfig.blur_check == nil then GraphiteConfig.blur_check = false end

local blur = Material("pp/blurscreen")
local function DrawBlur(x, y, w, h, layers, density, alpha)
  surface.SetDrawColor(255,255,255, alpha)
	surface.SetMaterial(blur)

  for i = 1, layers do
		blur:SetFloat("$blur", (i/layers) * density)
		blur:Recompute()

    render.UpdateScreenEffectTexture()
    render.SetScissorRect(x,y,x + w,y + h,true)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())
    render.SetScissorRect(0,0,0,0,false)
  end
end

local function BlurLine(r,x,y,l,h,color)
  draw.RoundedBox(r,x,y,l,h,Color(0,0,0))
  draw.RoundedBox(r,x + 1,y + 1,l - 2,h - 2,color)
end


local ply, hp, w, h, l, w, ap, ap2, m, name, s, hungerm, hunger, nw
local hp2, ap2, money, hungerl = 0, 0, 0, 0
local function Base()
  l = 340
  w = 120
  ply = LocalPlayer()
  nw = 25

  if LocalPlayer():getDarkRPVar("Energy") and GraphiteConfig.EnableHunger then
    if !GraphiteConfig.EnableLeftLightColorSquare then
      hungerm = 15
    else
      hungerm = 25
    end
  else
    hungerm = 0
  end

  if GraphiteConfig.DisableGraphiteHUD or !GraphiteConfig.blur_check then return end

  if !GraphiteConfig.DisableLeftBottomHud and GraphiteConfig.blur_check then

  --BASE
  /*if GraphiteConfig.BlurHud then
    draw.RoundedBox(2,5,ScrH() - (w + 5),l + hungerm,w,Color(32,32,32,245))
    DrawBlur(5,ScrH() - (w + 5),l + hungerm,w,3,4,100)
    OutlinedBox(5,ScrH() - (w + 5),l + hungerm,w,1,Color(0,0,0))
  else*/
    BlurLine(2,5,ScrH() - (w + 5),l + hungerm,w,Color(32,32,32))
    if GraphiteConfig.EnableLeftLightColorSquare then
      draw.RoundedBoxEx(2,5 + 1,ScrH() - (w + 5) + 1,l/3.55 + (hungerm + 3) - 2,w - 2,Color(64,64,64,15),true,true,false,false)
    end
  --end

  draw.RoundedBox(2,20,ScrH() - (w - 5),75,75,Color(64,64,64)) --avatar box
  /*if GraphiteConfig.BlurHud then
    draw.RoundedBox(2,5,ScrH() - (w + GraphiteConfig.TopBarPosition),l + hungerm,30,Color(32,32,32,245))
    DrawBlur(5,ScrH() - (w + GraphiteConfig.TopBarPosition),l + hungerm,30,3,4,100)
    OutlinedBox(5,ScrH() - (w + GraphiteConfig.TopBarPosition),l + hungerm,30,1,Color(0,0,0))
  else*/
    BlurLine(2,5,ScrH() - (w + GraphiteConfig.TopBarPosition),l + hungerm,30,Color(32,32,32)) --base top
  --end

  if LocalPlayer():getDarkRPVar("Energy") and GraphiteConfig.EnableHunger and GraphiteConfig.blur_check then

    hunger = (LocalPlayer():getDarkRPVar("Energy") or 0) * 0.85
    hungerl = Lerp(10 * FrameTime(),hungerl,hunger)

    if !GraphiteConfig.EnableLeftLightColorSquare then
      draw.RoundedBox(2,105 - 1,ScrH() - w - 1 + nw,10 + 2,85 + 2,Color(64,64,64))
      draw.RoundedBox(0,105,(ScrH() - w) + (85 - hungerl) + nw,10,85 / (85/hungerl),Color(204,102,0))
    else
      draw.RoundedBox(2,107.5 - 1,ScrH() - w - 1 + nw,10 + 2,85 + 2,Color(64,64,64))
      draw.RoundedBox(0,107.5,(ScrH() - w) + (85 - hungerl) + nw,10,85 / (85/hungerl),Color(204,102,0))
    end

    surface.SetDrawColor(255,255,255)
    surface.SetMaterial(HungerMaterial)
    if !GraphiteConfig.EnableLeftLightColorSquare then
      surface.DrawTexturedRect(95,ScrH() - 125,32,32)
    else
      surface.DrawTexturedRect(100,ScrH() - 125,32,32)
    end
  end

  hp = ply:Health() or 0
  hp2 = Lerp(10 * FrameTime(),hp2,hp)

  draw.RoundedBox(2,110 - 1 + hungerm,ScrH() - (70 + 1),222,22,Color(64,64,64)) --hp bg
  draw.RoundedBox(0,110 + hungerm,ScrH() - 70,math.Clamp(hp2,0,100) * 2.2,20,Color(153,0,0)) --hp

  draw.SimpleText(math.Clamp(hp,0,999999999999999999),"Graphite_Roboto_17",325 + hungerm,ScrH() - 60,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)


  ap = ply:Armor() or 0
  ap2 = Lerp(10 * FrameTime(),ap2,ap)

  draw.RoundedBox(2,110 - 1 + hungerm,ScrH() - (40 + 1),222,22,Color(64,64,64)) --ap bg
  draw.RoundedBox(0,110 + hungerm,ScrH() - 40,math.Clamp(ap2,0,100) * 2.2,20,Color(0,51,102)) --ap
  draw.SimpleText(math.Clamp(ap,0,999999999999999999),"Graphite_Roboto_17",325 + hungerm,ScrH() - 30,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)


  name = LocalPlayer():GetName() or ""
  m = LocalPlayer():getDarkRPVar("money") or 0
  s = LocalPlayer():getDarkRPVar("salary") or 0
  money = Lerp(10 * FrameTime(),money,m)

  if string.len(name) > 30 then name = string.Left(name, 27) .. "..." end

  draw.SimpleText(name,"Graphite_Roboto_20",40,ScrH() - ((80 + GraphiteConfig.TopBarPosition) + 34.5),Color(255,255,255),TEXT_ALIGN_LEFT)
  if GraphiteConfig.DrawSalary then
    draw.SimpleText(DarkRP.formatMoney(math.Round(money)) .. " (" .. DarkRP.formatMoney(math.Round(s)) .. ")","Graphite_Roboto_17",135 + hungerm,ScrH() - 85,Color(76,153,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
  else
    draw.SimpleText(DarkRP.formatMoney(math.Round(money)),"Graphite_Roboto_17",135 + hungerm,ScrH() - 85,Color(76,153,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
  end

  if GraphiteConfig.JobColorIsTeamColor and ply:Team() then
    draw.SimpleText(LocalPlayer():getDarkRPVar("job"),"Graphite_Roboto_17",135 + hungerm,ScrH() - 106,team.GetColor(ply:Team()),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
  else
    draw.SimpleText(LocalPlayer():getDarkRPVar("job"),"Graphite_Roboto_17",135 + hungerm,ScrH() - 106,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
  end

  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(IdMaterial)
  surface.DrawTexturedRect(5,ScrH() - (121 + GraphiteConfig.TopBarPosition),32,32)

  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(CashMaterial)
  surface.DrawTexturedRect(105 + hungerm,ScrH() - 102,32,32)

  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(JobMaterial)
  surface.DrawTexturedRect(105 + hungerm,ScrH() - 123,32,32)

  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(HeartMaterial)
  surface.DrawTexturedRect(105 + hungerm,ScrH() - 76,32,32)

  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(ArmorMaterial)
  surface.DrawTexturedRect(105 + hungerm,ScrH() - 46,32,32)

  if ply:getDarkRPVar("HasGunlicense") then surface.SetDrawColor(255,255,255) else surface.SetDrawColor(64,64,64) end
  surface.SetMaterial(LicenceMaterial)
  surface.DrawTexturedRect(20,ScrH() - 37,32,32)

  if ply:getDarkRPVar("wanted") then surface.SetDrawColor(255,255,255) else surface.SetDrawColor(64,64,64) end
  surface.SetMaterial(WantedMaterial)
  surface.DrawTexturedRect(60,ScrH() - 39,32,32)
end

end

hook.Add("HUDPaint", "GraphiteBase", Base)

local wep, total, clip, nicename
local function Ammo()
  if GraphiteConfig.DisableGraphiteHUD then return end
  if !GraphiteConfig.EnableAmmo then return end
  ply = LocalPlayer()
  if !IsValid(ply:GetActiveWeapon()) then return end
  wep = ply:GetActiveWeapon()
  total = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
  clip = wep:Clip1()
  nicename = wep:GetPrintName()

  if clip < 0 or wep:GetClass() == "weapon_physcannon" then return end

  draw.RoundedBox(2,ScrW() - 210,ScrH() - 96,200,90 - 4,Color(0,0,0))
  draw.RoundedBox(2,ScrW() - (210 - 1),ScrH() - (80 - 1),200 - 2,70 - 2,Color(32,32,32))
  draw.RoundedBox(0,ScrW() - 210 + 100,ScrH() - (80 - 1),2,70 - 2,Color(64,64,64,20))
  draw.SimpleText(clip,"Graphite_Roboto_50",ScrW() - 160,ScrH() - 75,Color(255,255,255),TEXT_ALIGN_CENTER)
  draw.SimpleText(total,"Graphite_Roboto_50",ScrW() - 60,ScrH() - 75,Color(255,255,255),TEXT_ALIGN_CENTER)
  draw.SimpleText("Clip","Graphite_Roboto_20",ScrW() - 160,ScrH() - 32,Color(255,255,255),TEXT_ALIGN_CENTER)
  draw.SimpleText("Reserved","Graphite_Roboto_20",ScrW() - 60,ScrH() - 32,Color(255,255,255),TEXT_ALIGN_CENTER)

  draw.RoundedBoxEx(2,ScrW() - (210 - 1),ScrH() - 95,200 - 2,20,Color(0,51,102),true,true,false,false)
  if string.len(nicename) > 21 then nicename = string.Left(nicename, 19) .. "..." end
  draw.SimpleText(nicename,"Graphite_Roboto_20",ScrW() - 110,ScrH() - 95,Color(255,255,255),TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "GraphiteAmmo", Ammo)

net.Receive("graphite_load", function()
  GraphiteConfig.blur_check = GraphiteConfig.blur_check or true
end)

local agenda, atext, agendatext
local function Agenda()
  if GraphiteConfig.DisableGraphiteHUD then return end
  if !GraphiteConfig.AgendaPanel then return end
  
  ply = LocalPlayer()
  
  if !ply:getAgendaTable() then return end
  
  agenda = ply:getAgendaTable()
  if !agenda then return end

  agendatext = LocalPlayer():getDarkRPVar("agenda") or ""

  if !GraphiteConfig.AgendaPanel or agendatext == "" or agendatext == " " or !GraphiteConfig.blur_check then return end

  atext = DarkRP.textWrap((agendatext),"Graphite_Roboto_17", 395)

  draw.RoundedBox(2,10 - 1,5 - 1,402,123,Color(32,32,32,150))

  draw.RoundedBoxEx(2,10,31,400,95,Color(32,32,32,150),false,false,true,true)
  draw.RoundedBoxEx(2,10,5,400,25,Color(0,51,102),true,true,false,false)

  draw.SimpleText(agenda.Title,"Graphite_Roboto_20",15,17.5,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
  draw.DrawText(atext,"Graphite_Roboto_17",15,35,Color(255,255,255))
end

hook.Add("HUDPaint", "GraphiteAgenda", Agenda)


local dtrace, dent
hook.Add("HUDPaint", "GraphiteDoor", function()
  dtrace = LocalPlayer():GetEyeTrace()
  dent = dtrace.Entity


  if GraphiteConfig.DrawDoorOwnableInfo and IsValid(dent) and dent:isKeysOwnable() and dent:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
    dent:drawOwnableInfo()
  end
end)

end
if SERVER then
  util.AddNetworkString("graphite_load")

  concommand.Add("sv_graphite", function(ply)
  	ply:ChatPrint("76561198311881522 | 1.3.1")
  end)

  hook.Add("PlayerInitialSpawn", "GraphiteLoad", function(ply)
    if GraphiteConfig.Owner and GraphiteConfig.Owner == "76561198311881522" then
      net.Start("graphite_load")
      net.Send(ply)
    end
  end)
end
if CLIENT then

local HungerMaterial = Material("materials/graphite_hud/hunger_32.png")
local IdMaterial = Material("materials/graphite_hud/id_32.png")
local CashMaterial = Material("materials/graphite_hud/cash_32.png")
local JobMaterial = Material("materials/graphite_hud/job_32.png")
local HeartMaterial = Material("materials/graphite_hud/heart_32.png")
local ArmorMaterial = Material("materials/graphite_hud/shield_32.png")
local LicenceMaterial = Material("materials/graphite_hud/gun_32.png")
local WantedMaterial = Material("materials/graphite_hud/star_32.png")

local Job2Material = Material("materials/graphite_hud/job_128.png")
local Id2Material = Material("materials/graphite_hud/id_128.png")
local Heart2Material = Material("materials/graphite_hud/heart_128.png")
local Licence2Material = Material("materials/graphite_hud/licence_128.png")
local Rank2Material = Material("materials/graphite_hud/rank_128.png")
local Hunger2Material = Material("materials/graphite_hud/hunger_64.png")

local level, reqexp, exp, lvlposx, lvlposy, lvlposw, lvlposh, prestige, prestige_color
local xp = 0
local function Level()
  if GraphiteConfig.DisableGraphiteHUD then return end
  if !GraphiteConfig.EnableLevel then return end

  lvlposw, lvlposh = 250, 35
  lvlposx, lvlposy = ScrW() - (lvlposw + 10), 20

  draw.RoundedBox(2,lvlposx - 1, lvlposy - 11 + GraphiteConfig.LevelPos,lvlposw + 2,lvlposh + 22,Color(32,32,32,150))
  draw.RoundedBox(2,lvlposx, lvlposy + 11 + GraphiteConfig.LevelPos,lvlposw,lvlposh,Color(32,32,32,150))
  draw.RoundedBoxEx(2,lvlposx, lvlposy - 10 + GraphiteConfig.LevelPos,lvlposw,20,Color(0,51,102),true,true,false,false)

  if GraphiteConfig.LevelType == 1 then
    level = levelup.getLevel(LocalPlayer()) or 0
    exp = levelup.getExperience(LocalPlayer()) or 0
    reqexp = ((levelup.getLevel(LocalPlayer()) + 1) * levelup.config.expPerLevel) or 0

    if !level or !exp or !reqexp or level == nil or exp == nil or reqexp == nil then return end

    xp = Lerp(10 * FrameTime(),xp,exp/reqexp)

    draw.RoundedBox(0,lvlposx + 1, lvlposy + 13 + GraphiteConfig.LevelPos,math.Clamp(lvlposw * (xp) - 2,0,lvlposw - 2),lvlposh - 4,Color(255,255,255,150))

    draw.SimpleText("Level: " .. level,"Graphite_Roboto_17",ScrW() - (lvlposw + 8), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    draw.SimpleText("Exp: " .. exp .. " / " .. reqexp,"Graphite_Roboto_17",ScrW() - (lvlposw - 235), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

    hook.Remove("HUDPaint", "levelup_hud_drawhud")
    hook.Remove("HUDPaint", "levelup_hud_drawfloatingnotes")
  elseif GraphiteConfig.LevelType == 3 then
    level = LocalPlayer():getDarkRPVar("level") or 0
    exp = LocalPlayer():getDarkRPVar("xp") or 0
    reqexp = ((level*(level+1)*90) + 10)*LevelSystemConfiguration.XPMult or 0

    if !level or !exp or !reqexp or level == nil or exp == nil or reqexp == nil then return end

    xp = Lerp(10 * FrameTime(),xp,exp/reqexp) or 0

    draw.RoundedBox(0,lvlposx + 1, lvlposy + 13 + GraphiteConfig.LevelPos,math.Clamp(lvlposw * (xp) - 2,0,lvlposw - 2),lvlposh - 4,Color(255,255,255,150))

    draw.SimpleText("Level: " .. level,"Graphite_Roboto_17",ScrW() - (lvlposw + 8), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    draw.SimpleText("Exp: " .. exp .. " / " .. reqexp,"Graphite_Roboto_17",ScrW() - (lvlposw - 235), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

    hook.Remove("HUDPaint", "manolis:MVLevels:HUDPaintA") --def lvlposw

    if LocalPlayer():getDarkRPVar("prestige") and  LocalPlayer():getDarkRPVar("prestige") > 0 then
      prestige_color = LevelSystemPrestigeConfiguration.XPColors[(LocalPlayer():getDarkRPVar('prestige') or 0)] or LevelSystemConfiguration.DefaultColor

      draw.RoundedBox(2,ScrW() - 345 - 1,10 - 1 + GraphiteConfig.LevelPos,80 + 2, lvlposh + 22,Color(32,32,32,150))
      draw.RoundedBox(2,ScrW() - 345,31 + GraphiteConfig.LevelPos,80,lvlposh,Color(32,32,32,150))
      draw.RoundedBoxEx(2,ScrW() - 345,10 + GraphiteConfig.LevelPos,80,20,Color(0,51,102),true,true,false,false)
      draw.SimpleText("Prestige","Graphite_Roboto_17",ScrW() - 305, 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
      draw.SimpleText(LocalPlayer():getDarkRPVar("prestige"),"Graphite_Roboto_40",ScrW() - 305, 48 + GraphiteConfig.LevelPos,prestige_color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if LocalPlayer():getDarkRPVar("prestige") then
      hook.Remove("HUDPaint","DarkRP_Mod_HU1312313awdadadada123131DPaint")
    end
  elseif GraphiteConfig.LevelType == 2 then
    level = tonumber(LocalPlayer().DarkRPVars.lvl) or 0
    exp = tonumber(LocalPlayer().DarkRPVars.xp) or 0
    exp = math.floor(exp)
    reqexp = DARKRP_LVL_SYSTEM["XP"][tonumber(level)] or 0

    if !level or !exp or !reqexp or level == nil or exp == nil or reqexp == nil then return end

    xp = Lerp(10 * FrameTime(),xp,exp/reqexp)

    draw.RoundedBox(0,lvlposx + 1, lvlposy + 13 + GraphiteConfig.LevelPos,math.Clamp(lvlposw * (xp) - 2,0,lvlposw - 2),lvlposh - 4,Color(255,255,255,150))

    draw.SimpleText("Level: " .. level,"Graphite_Roboto_17",ScrW() - (lvlposw + 8), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    draw.SimpleText("Exp: " .. exp .. " / " .. reqexp,"Graphite_Roboto_17",ScrW() - (lvlposw - 235), 20 + GraphiteConfig.LevelPos,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

    hook.Remove("HUDPaint", "DrawGetXP")
  end
end

concommand.Add("cl_graphite", function()
  LocalPlayer():ChatPrint("76561198311881522 | 1.3.1")
end)

hook.Add("HUDPaint", "GraphiteLevel", Level)

local ang, pos, offset, alpha, trace, ent, group, group_color, job_min
local Alpha = 255
local function HeadHud(ply)
  if !GraphiteConfig.HeadHud then return end
  if !IsValid(ply) or ply == LocalPlayer() or !ply:Alive() then return end
  if !GraphiteConfig.ForceHeadHud and ply:GetNoDraw() or ply:GetColor().a != 255 then return end

  trace = LocalPlayer():GetEyeTrace()
  ent = trace.Entity

  offset = Vector(0,0,85)
  ang = LocalPlayer():EyeAngles()
  pos = ply:GetPos() + offset + ang:Up()

  dis = LocalPlayer():GetPos():Distance(ply:GetPos())

  ang:RotateAroundAxis(ang:Forward(), 90)
  ang:RotateAroundAxis(ang:Right(), 90)

  if dis > 200 or trace.HitPos:Distance(LocalPlayer():GetShootPos()) > 250 then
    alpha = 0
  else
    alpha = 255
  end

  Alpha = Lerp(2 * FrameTime(), Alpha, alpha)

  cam.Start3D2D(pos,Angle(0,ang.y,90),0.050)
    if GraphiteConfig.DrawJobOnHeadHud then
      job_min = 0
		surface.SetDrawColor(255,255,255,Alpha)
		surface.SetMaterial(Job2Material)
		surface.DrawTexturedRect(210,470,128,128)

		draw.SimpleText(ply:getDarkRPVar("job"),"Graphite_Roboto_60",320,535,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    else
      job_min = 70
    end

    surface.SetDrawColor(255,255,255,Alpha)
    surface.SetMaterial(Id2Material)
    surface.DrawTexturedRect(210,400,128,128)

    surface.SetDrawColor(255,255,255,Alpha)
    surface.SetMaterial(Heart2Material)
    surface.DrawTexturedRect(210,540 - job_min,128,128)

	draw.SimpleText(ply:GetName(),"Graphite_Roboto_60",320,465,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

    draw.SimpleText(ply:Health(),"Graphite_Roboto_60",320,605 - job_min,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

    if GraphiteConfig.DrawLicenceOnHeadHud then
      if ply:getDarkRPVar("HasGunlicense") then
        surface.SetDrawColor(255,255,255,Alpha)
        surface.SetMaterial(Licence2Material)
        surface.DrawTexturedRect(210,620 - job_min,128,128)

        draw.SimpleText("Own Licence","Graphite_Roboto_60",320,685 - job_min,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
      end
    end

    group = ply:GetNWString("usergroup")

    if GraphiteConfig.DrawRankOnHeadHud then
      if GraphiteConfig.DrawLicenceOnHeadHud and ply:getDarkRPVar("HasGunlicense") and !table.HasValue(GraphiteConfig.IgnoredRanks, group) then

        surface.SetDrawColor(255,255,255,Alpha)
        surface.SetMaterial(Rank2Material)
        surface.DrawTexturedRect(210,700 - job_min,128,128)

        draw.SimpleText(string.upper(string.Left(group, 1)) .. string.Right(group, string.len(group) - 1),"Graphite_Roboto_60",320,760 - job_min,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
      else
        if !table.HasValue(GraphiteConfig.IgnoredRanks, group) then
          surface.SetDrawColor(255,255,255,Alpha)
          surface.SetMaterial(Rank2Material)
          surface.DrawTexturedRect(210,620,128,128)

          draw.SimpleText(string.upper(string.Left(group, 1)) .. string.Right(group, string.len(group) - 1),"Graphite_Roboto_60",320,685,Color(255,255,255,Alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end
      end
    end

    if GraphiteConfig.EnableWantedOnHeadHud and ply:isWanted() then
      if GraphiteConfig.EnableWantedReasonOnHeadHud and ply:getDarkRPVar("wantedReason") then
        local wanted_reason = ply:getDarkRPVar("wantedReason")
        if string.len(wanted_reason) > 35 then wanted_reason = string.Left(wanted_reason, 35) .. "..." end

        draw.SimpleText("Wanted","Graphite_Roboto_80",0,150,Color(255,255,255,Alpha),TEXT_ALIGN_CENTER ,TEXT_ALIGN_CENTER)
        draw.SimpleText(wanted_reason,"Graphite_Roboto_60",0,210,Color(255,255,255,Alpha),TEXT_ALIGN_CENTER ,TEXT_ALIGN_CENTER)
      else
        draw.SimpleText("Wanted","Graphite_Roboto_80",0,210,Color(255,255,255,Alpha),TEXT_ALIGN_CENTER ,TEXT_ALIGN_CENTER)
      end
    end
  cam.End3D2D()

end

hook.Add("PostPlayerDraw", "GraphiteHeadHud", HeadHud)

local hunger_alpha
local halp = 0
local function Notifications()
  if GraphiteConfig.DisableGraphiteHUD or !GraphiteConfig.blur_check then return end
  if LocalPlayer():getDarkRPVar("Energy") then

    hunger = LocalPlayer():getDarkRPVar("Energy")

    if GraphiteConfig.EnableHunger and GraphiteConfig.EnableLowHungerNotification and hunger and hunger <= GraphiteConfig.LowHungerValue then
      hunger_alpha = 255
    else
      hunger_alpha = 0
    end

    halp = Lerp(10 * FrameTime(),halp,hunger_alpha)

    if !GraphiteConfig.EnableLeftLightColorSquare then
      draw.RoundedBox(2,365 - 1,ScrH() - 55 - 2,50 + 2,50 + 2,Color(0,0,0,halp))
      draw.RoundedBox(2,365,ScrH() - 55 - 1,50,50,Color(32,32,32,halp))
    else
      draw.RoundedBox(2,375 - 1,ScrH() - 55 - 2,50 + 2,50 + 2,Color(0,0,0,halp))
      draw.RoundedBox(2,375,ScrH() - 55 - 1,50,50,Color(32,32,32,halp))
    end

    surface.SetDrawColor(255,255,255,halp)
    surface.SetMaterial(Hunger2Material)
    if !GraphiteConfig.EnableLeftLightColorSquare then
      surface.DrawTexturedRect(358,ScrH() - 60,64,64)
    else
      surface.DrawTexturedRect(368,ScrH() - 60,64,64)
    end

    if GraphiteConfig.EnableHunger and GraphiteConfig.EnableLowHungerNotification and hunger <= GraphiteConfig.LowHungerValue then
      surface.SetDrawColor(255,0,0,math.sin(CurTime()/1.5) * 230)
      surface.SetMaterial(Hunger2Material)
      if !GraphiteConfig.EnableLeftLightColorSquare then
        surface.DrawTexturedRect(358,ScrH() - 60,64,64)
      else
        surface.DrawTexturedRect(368,ScrH() - 60,64,64)
      end
    end
  end

  if GetGlobalBool("DarkRP_LockDown") and GraphiteConfig.EnableLockdownInfo then
    draw.RoundedBox(4,ScrW()/2 - 200,10,400,55,Color(0,0,0,100))
    draw.RoundedBox(4,ScrW()/2 - 200 + 1,10 + 1,400 - 2,55 - 2,Color(32,32,32,100))
    draw.DrawText(GraphiteConfig.Language.lockdown_first_line,"Graphite_Roboto_25", ScrW() / 2, 15,Color(255,255,255),TEXT_ALIGN_CENTER)
    draw.DrawText(GraphiteConfig.Language.lockdown_second_line,"Graphite_Roboto_20", ScrW() / 2, 40,Color(255,255,255),TEXT_ALIGN_CENTER)
  end
end

hook.Add("HUDPaint", "GraphiteNotifications", Notifications)

  print("Graphite Hud Loaded Correctly")

end -- if client end
