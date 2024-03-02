-- You can add your own buttons if you know what you are doing
local UserCMD = escore.commands.user
local AdminCMD = escore.commands.admin[escore.config.adminmod]
-------------------------------
/// BUTTONS IN CONTEXT MENU ///
-------------------------------
function eboard:ReloadContextButtons()
	self.contextbuttons = {}
	local list = self.contextbuttons

	--HEADER COMMON
	table.insert(list,{
		Type = "Header",
		Text = escore.text["common"],
	})
	table.insert(list,{ 
		Type = "Button",
		Text = escore.text["openprof"],
		Func = UserCMD.OpenProfile
	})
	table.insert(list,{
		Type = "Button",
		Text = escore.text["copynick"],
		Func = UserCMD.CopyName
	})
	table.insert(list,{
		Type = "Button",
		Text = escore.text["copysteamid"],
		Func = UserCMD.CopySteamID
	})

	--ADMIN
	local groupsets = escore.config.usergroups[LocalPlayer():GetUserGroup()]
	if groupsets then
		if groupsets["AdminButtons"] then

			table.insert(list,{
				Type = "Header",
				Text = escore.text["admin"],
			})
			for name,func in pairs(AdminCMD) do
				table.insert(list,{
					Type = "Button",
					Text = name,
					Func = func
				})
			end

		end
	end
	--TYPES: Button / Header / Separator
	--table.insert(list.common,{Type = "Separator"}) --Separator example
end

----------------------
/// BOTTOM BUTTONS ///
----------------------
local cv = CreateClientConVar("escore_effect", "1", true, false, "escore effect on / off", 0, 1)

function eboard:ReloadBottomButtons()
	self.botbuttons = {}
	local list = self.botbuttons

	--EFFECT ON/OFF
	if escore.config.effect then
		table.insert(list,{ 
			Icon = self.Materials["effect"],
			Name = "Effect",
			HoverText = escore.text["effect"],
			DoClick = function(ply)
				local bg = eboard.panel
				if IsValid(bg) then
					if IsValid(bg.context) then bg.context:Close(true) return end

		        	local context = vgui.Create("escore.contextmenu",bg)
	        		local posx,posy = input.GetCursorPos()
	        		context:SetWide(100)
	        		context:SetPly(ply)
	        		context:SetNotify(false)
	        		context.origin = bg
	        		function context:Think()
	        			if not IsValid(self.origin) or not IsValid(self:GetPly()) then
	        				self:Remove()
	        			end
	        		end
	        		context:AddHeader(escore.text["effect"])

	        		--On / off button
	        		local button = context:AddButton(bg:GetEffectEnabled() and escore.text["off"] or escore.text["on"], function()
	        			cv:SetBool(not cv:GetBool())
						if bg:IsValid() then
							bg:SetEffectEnabled(cv:GetBool()) 
						end 
	        		end)
	        		button:SetTextColor(cv:GetBool() and escore.colors.default.red or escore.colors.default.green)

	        		--EFFECT BUTTONS
	        		for name,func in pairs(escore.EffectManager:GetAllEffects()) do
	        			if bg:GetEffect() ~= name then
		        			local button = context:AddButton(escore.text.capitalize(name), function() end)
		        			function button:DoClick()
		        				context:Close()
		        				bg:SetEffect(name)

		        				if not cv:GetBool() then
			        				cv:SetBool(not cv:GetBool())
									if bg:IsValid() then
										bg:SetEffectEnabled(cv:GetBool()) 
									end
								end
		        			end
		        			function button:DoRightClick() self:DoClick() end
		        		end
	        		end

	        		context:SetPosClamped(posx+30,posy+5)
		        	bg.context = context
	        	end
			end,
			DoRightClick = function(ply)
				local bg = eboard.panel
				cv:SetBool(not cv:GetBool())
				if bg:IsValid() then
					bg:SetEffectEnabled(cv:GetBool()) 
				end 
			end
		})

		if #escore.config.links ~= 0 then
			table.insert(list,{
				Type="separator",
			})

			for _,v in ipairs(escore.config.links) do
				table.insert(list,{
					Name = v["Name"],
					HoverText = v["HoverText"],
					Icon = v["Icon"],
					IconLink = v["IconLink"],
					DisplayText = v["DisplayText"],
					Color = v["Color"],
					DoClick = function()
						gui.OpenURL(v["Link"])
					end
				})
			end
		end




	end
end

---------------------------
/// BUTTONS IN PROFILER ///
---------------------------
function eboard:ReloadButtons()
	self.buttons = {}
	local actbuttons = self.buttons

	-- --Open Steam Profile (EXAMPLE)
	-- table.insert( actbuttons, { 
	-- 	Text = escore.text["openprof"],
	-- 	Icon = self.Materials["steam"], 
	-- 	Func = UserCMD.OpenProfile } 
	-- ) 

	-- Сheck for admin
	local groupsets = escore.config.usergroups[LocalPlayer():GetUserGroup()]
	if groupsets then
		if groupsets["AdminButtons"] then

			table.insert( actbuttons, { 
				Text = escore.text["tp"], 
				Icon = self.Materials["tp"] , 
				Func = AdminCMD.Goto 
			}) 
			table.insert( actbuttons, { 
				Text = escore.text["bring"], 
				Icon = self.Materials["bring"], 
				Func = AdminCMD.Bring 
			})
			table.insert( actbuttons, { 
				Text = escore.text["freeze"], 
				Icon = self.Materials["freeze"], 
				Func = AdminCMD.Freeze, 
			})
			table.insert( actbuttons, { 
				Text = escore.text["unfreeze"], 
				Icon = self.Materials["freeze"], 
				Func = AdminCMD.Unfreeze, 
			})

		end
	end
end

-------------------
/// INFOBUTTONS ///
-------------------
function eboard:ReloadInfoButtons()
	self.infobuttons = {}
	local list = self.infobuttons
	local ply = LocalPlayer()

	-- --NICKNAME (example)
	-- table.insert(list,{ 
	-- 	Icon = self.Materials["id"], 				-- Icon material
	-- 	Info = function(ply) return ply:Name() end, -- if DisplayInfo is not nil, the script will copy this parameter
	-- 	DisplayInfo = nil 							-- if nil then the Info parameter is used
	-- })

	--STEAMID
	table.insert(list,{ 
		Icon = self.Materials["steam"],
		Info = function(ply) return ply:SteamID() end,
		DisplayInfo = nil
	})

	--USERGROUP
	table.insert(list,{ 
		Icon = self.Materials["tag"],
		Info = function(ply) return ply:GetUserGroup() end,
		DisplayInfo = nil
	})

	if DarkRP and not escore.config.hide_all_jobs then
		--JOB
		table.insert(list,{ 
			Icon = self.Materials["job"],
			Info = function(ply) return ply:getDarkRPVar("job") end,
			DisplayInfo = nil,
			Color = function(ply) return team.GetColor(ply:Team()) end
		})
	end

	local groupsets = escore.config.usergroups[LocalPlayer():GetUserGroup()]
	if groupsets then
		if groupsets["AdminInfo"] then

			if DarkRP then
				--MONEY
				table.insert(list,{ 
					Icon = self.Materials["dollar"],
					Info = function(ply) return ply:getDarkRPVar("money") end,
					DisplayInfo = function(info) return DarkRP.formatMoney(info) end,
					Color = escore.colors.default.green
				})
			end

			--PROPS
			if ply.GetCount then
				table.insert(list,{ 
					Icon = self.Materials["prop"], 
					Info = function(ply)
						if ply.GetCount then
							return ply:GetCount("props") or 0 
						end
						return 0
					end,
					DisplayInfo = function(info) return info.." "..escore.text["props"] end 
				})
			end
		end
	end

	--KILLS
	table.insert(list,{ 
		Icon = self.Materials["kill"], 
		Info = function(ply) return ply:Frags() end,
		DisplayInfo = function(info) return info.." "..escore.text["kills"] end 
	})

	--DEATHS
	table.insert(list,{ 
		Icon = self.Materials["death"], 
		Info = function(ply) return ply:Deaths() end,
		DisplayInfo = function(info) return info.." "..escore.text["deaths"] end 
	})

	--KD
	table.insert(list,{ 
		Icon = self.Materials["kill"], 
		Info = function(ply)
			local d = ply:Deaths()
			if d == 0 then return 0 end
			x = ply:Frags() / d
			return 0.01*math.floor(100*x)
		end,
		DisplayInfo = function(info) return info.." ".."KD" end 
	})
end