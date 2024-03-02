-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

CreateConVar( "mrs_playermodel", 0, FCVAR_USERINFO )

local d_dist = 200
local ScrW, ScrH = ScrW, ScrH
local rot = Angle(0, 0, 0)

local rank_def = Material("ranks_ui/rank.png", "smooth")
local center_gradient = Material("gui/center_gradient.vtf", "smooth")
local theme = {}
local notification_types = {
	[1] = {Color(0, 153, 241), "mqs/done/3.mp3"},
	[2] = {Color(218, 8, 8), "mqs/fail/1.mp3"},
}

local blur = Material("pp/blurscreen")

function MRS.HudBlur(x, y, w, h)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 4) * 4)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		render.SetScissorRect(x, y, x + w, y + h, true)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function MRS.HudNotification() end

function MRS.GetActiveRankData(ply)
	local group = MRS.GetNWdata(ply, "Group")
	local rank_id = MRS.GetNWdata(ply, "Rank")
	if not group then return nil end
	if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank_id] then return nil end
	if rank_id < 1 then return end
	local rank = MRS.Ranks[group].ranks[rank_id]

	return group, rank, rank_id, MRS.Ranks[group]
end

function MRS.GetRankIcon(icon)
	if not icon or icon == "" then
		return rank_def
	end

	if string.StartWith(icon, "http") then
		return MSD.ImgLib.GetMaterial(icon)
	else
		return icon
	end

end

function MRS.RanksSubmit(rank)
	local cd, bn = MRS.TableCompress(rank)

	net.Start("MRS.RanksSubmit")
		net.WriteUInt(bn, 32)
		net.WriteData(cd, bn)
	net.SendToServer()
end

function MRS.Frame(x, y, w, h, lw, color, otcolor)
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(otcolor)

	if lw then
		surface.DrawLine(x, y, x + lw, y)
		surface.DrawLine(w + x - 1, y, w + x - lw - 1, y)
		surface.DrawLine(x, y + h - 1, x + lw, y + h - 1)
		surface.DrawLine(w + x - 1, y + h - 1, w + x - lw - 1, y + h - 1)
		surface.DrawLine(x, y, x, y + lw)
		surface.DrawLine(w + x - 1, y, w + x - 1, y + lw)
		surface.DrawLine(x, y, x, y + lw)
		surface.DrawLine(w + x - 1, y + h - 1, w + x - 1, y + h - lw - 1)
		surface.DrawLine(x, y + h - 1, x, y + h - lw - 1)
	end
end

theme[1] = function(x, y, w, h, right)
	MSD.DrawTexturedRect(x, y, w, h, right and MSD.Materials.gradient_right or MSD.Materials.gradient, MSD.Theme["d"])
end

theme[2] = function(x, y, w, h)
	draw.RoundedBox(8, x, y, w, h, MSD.Theme["d"])
end

theme[3] = function(x, y, w, h)
	draw.RoundedBox(0, x, y, w, h, MSD.Theme["d"])
end

theme[4] = function(x, y, w, h)
	draw.RoundedBox(0, x, y, w, h, MSD.Theme["d"])
	MRS.Frame(x, y, w, h, 10, MSD.Theme["d"], color_white)
end

theme[5] = function(x, y, w, h)
	alpha = alpha or 1
	if MSD.Config.Blur then
		MRS.HudBlur(x, y, w, h)
		draw.RoundedBox(MSD.Config.Rounded, x, y, w, h, MSD.ColorAlpha(color_black, (250 - MSD.Config.BgrColor.r) * alpha))
	else
		local cl = MSD.Config.BgrColor
		if MSD.Config.BgrColor.r > 70 then
			cl = MSD.ColorAlpha(color_black, 255 - MSD.Config.BgrColor.r)
		end
		draw.RoundedBox(MSD.Config.Rounded, x, y, w, h, MSD.ColorAlpha(cl, cl.a * alpha))
	end
end

function MRS.DrawRankInfo(ply, x, y, Config)
	local group, rank, _, gtable = MRS.GetActiveRankData(ply)
	if not group then return end
	if rank.hidden then return end
	if not ply.mrsW then ply.mrsW = 0 end

	local w1, w2 = 0, 0
	local is, fs, fss = Config.IconSize, math.Clamp(Config.FontSize, 12, 42), math.Clamp(Config.FontSize - 8, 12, 42)
	local ipos = Config.IconRight
	local mh = math.max(is, fs)

	if theme[Config.Theme] then
		theme[Config.Theme](x, y, ply.mrsW, mh + 10, ipos)
	end

	if not Config.HideName and  Config.ShowGroup then
		w2 = draw.SimpleTextOutlined(group, "MSDFont." .. fss, ipos and 5 + x or x + 10 + is, y + fs / 2 + fss + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	end

	if not Config.HideName then
		local rank_name = gtable.show_sn and rank.srt_name or rank.name
		local grp = w2 > 0 and fs / 2 + 5 or (mh + 10) / 2
		w1 = draw.SimpleTextOutlined(rank_name, "MSDFont." .. fs, ipos and 5 + x or x + 10 + is, y + grp, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	end

	MSD.DrawTexturedRect(ipos and x + ply.mrsW - is - 5 or x + 5, y + 5 + (mh - is), is, is, MRS.GetRankIcon(rank.icon), color_white)
	ply.mrsW = math.max(w1, w2) + is + ( Config.HideName and 10 or 15 )
end

function MRS.DoNotify(text1, text2, type)
	local startt = CurTime()
	local x, y = ScrW(), ScrH()
	local color = notification_types[type][1]
	local anim = 0
	surface.PlaySound(notification_types[type][2])

	MRS.HudNotification = function()
		surface.SetDrawColor(0, 0, 0, anim * 170)
		surface.SetMaterial(center_gradient)
		surface.DrawTexturedRectRotated(x / 2, y / 8, 250, anim * (x + 200), -90)
		local _, h = draw.SimpleTextOutlined(text1, "MSDFont.Biger", x / 2, y / 8 - 50, MSD.ColorAlpha(color, anim * 255), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, anim * 255))
		text2 = MSD.TextWrap(text2, "MSDFont.28", y)
		draw.DrawText(text2, "MSDFont.36", x / 2 + 1, y / 8 + h - 49,  MSD.ColorAlpha(color_black, anim * 255), TEXT_ALIGN_CENTER, 0)
		draw.DrawText(text2, "MSDFont.36", x / 2, y / 8 + h - 50,  MSD.ColorAlpha(color_white, anim * 255), TEXT_ALIGN_CENTER, 0)

		if startt + 8 < CurTime() then
			anim = Lerp(FrameTime() * 3, anim, 0)
		else
			anim = Lerp(FrameTime() * 5, anim, 1)
		end

		if startt + 10 < CurTime() then
			MRS.HudNotification = function() end
		end
	end
end

function MRS.HudPlayer(ply, Draw3D)
	if not MRS.Config.plyUI.Show then return end

	if ply == LocalPlayer() or ply:InVehicle() then return end
	if ply.FAdmin_GetGlobal and ply:FAdmin_GetGlobal("FAdmin_cloaked") then return end
	if ply:GetMaterial() == "models/effects/vol_light001" then return end
	local group, _, _, gtable = MRS.GetActiveRankData(ply)
	if not group then return end

	if not gtable.cansee and MRS.GetNWdata(LocalPlayer(), "Group") ~= group then return end
	if not ply.mrsW then ply.mrsW = 0 end

	if ply:GetPos():DistToSqr(LocalPlayer():GetPos()) > d_dist ^ 2 then return end

	local pos = ply:GetShootPos()

	if Draw3D then
		pos.z = pos.z + (ply:Crouching() and 15 or 5)

		if MRS.Config.plyUI.Follow then
			local pla = LocalPlayer():GetAngles()
			rot = LerpAngle(FrameTime() * 7, rot, Angle(0, pla.y - 180, 0))
		else
			rot = Angle(0, 0, 0)
		end

		local ang = Angle(0, rot.y, 0)
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)

		cam.Start3D2D(pos, ang, 0.08)
			local distx = 160 * MRS.Config.plyUI.X
			local disty = 400 * MRS.Config.plyUI.Y
			local x = distx
			if MRS.Config.plyUI.AlignX == 1 then
				x = 80 - (distx + ply.mrsW / 2)
			elseif MRS.Config.plyUI.AlignX == 2 then
				x = 0 - (distx + ply.mrsW)
			end
			MRS.DrawRankInfo(ply, x, 200 - disty, MRS.Config.plyUI)
		cam.End3D2D()
		return
	end

	pos.z = pos.z + 15 * MRS.Config.plyUI.Y

	pos = pos:ToScreen()
	local distx = 160 * MRS.Config.plyUI.X
	local x = distx
	if MRS.Config.plyUI.AlignX == 1 then
		x = 80 - (distx + ply.mrsW / 2)
	elseif MRS.Config.plyUI.AlignX == 2 then
		x = 0 - (distx + ply.mrsW)
	end

	MRS.DrawRankInfo(ply, pos.x + x, pos.y, MRS.Config.plyUI)
end

function MRS.HUDPaint()
	MRS.HudNotification()

	if not MRS.Config.Is2d3d then
		for id, ent in ipairs( ents.FindInCone( LocalPlayer():EyePos(), LocalPlayer():GetAimVector(), 100, math.cos( math.rad( 45 ) ) ) ) do
			if not IsValid(ent) or not ent:IsPlayer() then continue end
			MRS.HudPlayer(ent)
		end
	end

	if not MRS.Config.HUD.Show then return end
	local scrw, scrh = ScrW(), ScrH()
	local ply = LocalPlayer()
	local x, y = scrw * MRS.Config.HUD.X, scrh * MRS.Config.HUD.Y
	local mh = math.max(MRS.Config.HUD.IconSize, math.Clamp(MRS.Config.HUD.FontSize, 12, 42)) + 10
	if not ply.mrsW then ply.mrsW = 0 end

	if MRS.Config.HUD.AlignX == 1 then
		x = scrw / 2 - ply.mrsW / 2
	elseif MRS.Config.HUD.AlignX == 2 then
		x = scrw - (scrw * MRS.Config.HUD.X) - ply.mrsW
	end

	if MRS.Config.HUD.AlignY == 1 then
		y = scrh - (scrh * MRS.Config.HUD.Y) - mh
	end

	MRS.DrawRankInfo(ply, x, y, MRS.Config.HUD)
end

hook.Add("HUDPaint", "MRS.HUDPaint", MRS.HUDPaint)

hook.Add("PostPlayerDraw", "MRS.PostPlayerDraw", function(ply)
	if not MRS.Config.Is2d3d then return end
	MRS.HudPlayer(ply, true)
end)

net.Receive("MRS.Notify", function()
	local text1 = net.ReadString()
	local text2 = net.ReadString()
	local type = net.ReadUInt(2)
	MRS.DoNotify(text1, text2, type)
end)