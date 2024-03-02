local function L(phrase)
	return GAS:Phrase(phrase, "adminsits")
end

if (CLIENT) then
	GAS:ContextProperty("gas_adminsits", {
		MenuLabel = L"module_name",
		MenuIcon = "icon16/user_red.png",
		MenuOpen = function(self, option, ply, tr)
			if (GAS.AdminSits:IsInSit(ply)) then
				if (GAS.AdminSits:IsInSitWith(ply, LocalPlayer())) then
					option:AddOption(L"RemoveFromSit", function()
						RunConsoleCommand("say", "!sit " .. ply:SteamID())
					end):SetIcon("icon16/user_delete.png")
				end
			else
				option:AddOption(L"AdminSit", function()
					RunConsoleCommand("say", "!sit " .. ply:SteamID())
				end):SetIcon("icon16/shield.png")
			end
		end,
		Filter = function(self, ent, ply)
			return ent:IsPlayer() and not ent:IsBot() and OpenPermissions:HasPermission(ply, "gmodadminsuite_adminsits/create_sits") and not GAS.AdminSits:IsStaff(ent)
		end
	})
end