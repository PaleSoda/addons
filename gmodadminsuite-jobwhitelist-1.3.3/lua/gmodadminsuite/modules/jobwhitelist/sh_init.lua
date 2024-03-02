if (SERVER) then
	AddCSLuaFile("sh_jobwhitelist.lua")
	AddCSLuaFile("sh_permissions.lua")
	AddCSLuaFile("sh_contextmenu.lua")
	AddCSLuaFile("cl_menu.lua")
	AddCSLuaFile("sh_factions.lua")
end

GAS:hook("gmodadminsuite:LoadModule:jobwhitelist", "LoadModule:jobwhitelist", function(module_info)
	if (SERVER) then
		include("autorun/server/gas_jobwhitelist_darkrp_load.lua")
	end
	
	GAS:GMInitialize(function()
		if (not DarkRP) then
			GAS:print("[JobWhitelist] DarkRP is not running, aborting", GAS_PRINT_COLOR_BAD, GAS_PRINT_TYPE_ERROR)
			return
		end

		include("gmodadminsuite/modules/jobwhitelist/sh_jobwhitelist.lua")

		if (SERVER) then
			GAS.XEON:PostLoad(function()
				XEON:Init("6017", "[GAS] Billy's Whitelist", "1.3", "gmodadminsuite/modules/jobwhitelist/sv_drm.lua", include("gmodadminsuite/modules/jobwhitelist/license.lua"))
			end)
		end
	end)
end)