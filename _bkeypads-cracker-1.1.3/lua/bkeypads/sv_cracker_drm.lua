bKeypads:print("Loading DRM payloads...", bKeypads.PRINT_TYPE_NEUTRAL, "CRACKER")

--[[#####################################################################################################################]]--

local function http_ready()
	local function load()
		XEON:Init("7502", "Billy's Keypad Cracker", bKeypads.Cracker.License.SV_Version, "bkeypads/sv_cracker_drm.lua", bKeypads.Cracker.License.License)
	end
	if XEON and XEON.Init then
		load()
	else
		hook.Add("XEON.Ready", "bKeypadCracker", load)
	end
end
if #player.GetHumans() > 0 then
	http_ready()
else
	timer.Simple(0, http_ready)
end