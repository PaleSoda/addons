if (SERVER) then
	AddCSLuaFile("gmodadminsuite/modules/adminphysgun/cl_adminphysgun.lua")
	AddCSLuaFile("gmodadminsuite/modules/adminphysgun/sh_adminphysgun.lua")
end

GAS:hook("gmodadminsuite:LoadModule:adminphysgun", "LoadModule:adminphysgun", function(module_info)
	if (SERVER) then
		GAS.XEON:PostLoad(function()
			XEON:Init("6007", "[GAS] Admin Physgun", "2.0.0", "gmodadminsuite/modules/adminphysgun/sv_drm.lua", include("gmodadminsuite/modules/adminphysgun/license.lua"))
		end)
	else
		include("gmodadminsuite/modules/adminphysgun/cl_adminphysgun.lua")
		include("gmodadminsuite/modules/adminphysgun/sh_adminphysgun.lua")
	end
end)