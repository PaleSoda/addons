ArcCW.Grenade = {}

hook.Add("StartCommand", "ArcCW_Grenade_ArcSlow", function(ply, ucmd)
    if (ply.ArcSlowEnd or 0) > CurTime() then
        ucmd:SetButtons(bit.band(ucmd:GetButtons(), bit.bnot(IN_SPEED)))
    end
end)

hook.Add("SetupMove", "ArcCW_Grenade_ArcSlow", function(ply, mv, ucmd)
    if (ply.ArcSlowEnd or 0) > CurTime() then
        mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.5)
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.5)
    end
end)

if SERVER then
    util.AddNetworkString("arccw_grenade_autoreload")
    util.AddNetworkString("arccw_grenade_hit")
    util.AddNetworkString("arccw_grenade_arcslow")
    util.AddNetworkString("arccw_grenade_loader")

    -- Since all move hooks are run client and server, we need to network it
    function ArcCW.Grenade.ArcSlow(ply, dur)
        net.Start("arccw_grenade_arcslow")
            net.WriteFloat(dur + CurTime())
        net.Send(ply)
        ply.ArcSlowEnd = dur + CurTime()
    end

    net.Receive("arccw_grenade_arcslow", function()
        LocalPlayer().ArcSlowEnd = net.ReadFloat()
    end)

    hook.Add("RenderScreenspaceEffects", "ArcCW_Grenade_ArcSlow", function()
        if (LocalPlayer().ArcSlowEnd or 0) > CurTime() then
            local delta = math.Clamp((LocalPlayer().ArcSlowEnd - CurTime()) / 2, 0, 1) ^ 0.75

            DrawMaterialOverlay("effects/water_warp01", delta * 0.5)
            DrawMotionBlur(0.5 * delta, 0.75, 0.01)
            DrawColorModify({
                [ "$pp_colour_addr" ] = 0,
                [ "$pp_colour_addg" ] = 0,
                [ "$pp_colour_addb" ] = 0,
                [ "$pp_colour_brightness" ] = 0.35 * delta,
                [ "$pp_colour_contrast" ] = 1 - delta * 0.5,
                [ "$pp_colour_colour" ] = 1 - delta,
                [ "$pp_colour_mulr" ] = 0,
                [ "$pp_colour_mulg" ] = 0,
                [ "$pp_colour_mulb" ] = 0,
            })
        end
    end )

    hook.Add("HUDShouldDraw", "ArcCW_Grenade_ArcSlow", function(ele)
        if (LocalPlayer().ArcSlowEnd or 0) > CurTime() and ele ~= "CHudWeaponSelection" then
            return false
        end
    end)

end