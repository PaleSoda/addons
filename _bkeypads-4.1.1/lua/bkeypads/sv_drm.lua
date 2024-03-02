bKeypads:print("Loading DRM payloads...")

--[[#####################################################################################################################]]--

local function http_ready()
	local function load()
		XEON:Init("7466", "Billy's Keypads", bKeypads.License.SV_Version, "bkeypads/sv_drm.lua", bKeypads.License.License)
	end
	if XEON and XEON.Init then
		load()
	else
		hook.Add("XEON.Ready", "bKeypads", load)
	end
end
if #player.GetHumans() > 0 then
	http_ready()
else
	timer.Simple(0, http_ready)
end