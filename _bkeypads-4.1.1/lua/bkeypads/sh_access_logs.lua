local L = bKeypads.L

bKeypads.AccessLogs = {}
bKeypads.AccessLogs.Keypads = {}

if CLIENT then
	local accessLogsCallbacks = {}
	local callbackId = 0
	function bKeypads.AccessLogs:GetPage(keypad, fromIndex, callback)
		accessLogsCallbacks[keypad] = callback
		callbackId = callbackId + 1

		net.Start("bKeypads.AccessLogs.GetPage")
			net.WriteEntity(keypad)
			if fromIndex == -1 then
				net.WriteBool(true)
			else
				net.WriteBool(false)
				net.WriteUInt(fromIndex, 16)
			end
			net.WriteUInt(callbackId, 16)
		net.SendToServer()
	end

	net.Receive("bKeypads.AccessLogs.GetPage", function()
		local keypad = net.ReadEntity()
		local _callbackId = net.ReadUInt(16)
		if callbackId ~= _callbackId or not IsValid(keypad) or not accessLogsCallbacks[keypad] then return end

		local totalLogs = net.ReadUInt(32)

		local accessLogs = {}
		while (net.ReadBool()) do
			table.insert(accessLogs, {
				index = net.ReadUInt(32),
				ply = net.ReadString(),
				authMode = net.ReadUInt(2),
				granted = net.ReadBool(),
				charge = net.ReadUInt(32),
				time = net.ReadUInt(32),
				hacked = net.ReadBool()
			})
		end

		accessLogsCallbacks[keypad](totalLogs, accessLogs)
		accessLogsCallbacks[keypad] = nil
	end)
end

if CLIENT then
	local function PaginationPerformLayout(self, w, h)
		self.Left:CenterHorizontal(0.4)
		self.Page:CenterHorizontal(0.5)
		self.Right:CenterHorizontal(0.6)

		self.Left:CenterVertical()
		self.Page:CenterVertical()
		self.Right:CenterVertical()
	end

	local function PageAllowInput(self, c)
		return not c:match("%d")
	end

	local function PageOnChange(self)
		local UI = self:GetParent():GetParent()
		local val = tonumber(self:GetValue())
		if self.Value == -1 then
			bKeypads.AccessLogs:GetPage(UI.Keypad, -1, UI.ReceiveData)
		else
			local index = self.MaxIndex - (val - 1) * 30
			if val and val > 0 and index > 0 and index < (2^32)-1 then
				if self:GetText() ~= tostring(val) then self:SetText(val) end
				self.Value = val
				self:SetText(val)

				self:GetParent().Left:SetDisabled(val <= 1)
				self:GetParent().Right:SetDisabled(index - 30 <= 1)

				UI.List:Clear()
				UI.List:AddLine(L"LoadingEllipsis")
				bKeypads.AccessLogs:GetPage(UI.Keypad, index, UI.ReceiveData)
			else
				self:SetText(self.Value)
			end
		end
	end

	local function PrevPage(self)
		self:GetParent().Page:SetText(self:GetParent().Page.Value - 1)
		PageOnChange(self:GetParent().Page)
	end

	local function NextPage(self)
		self:GetParent().Page:SetText(self:GetParent().Page.Value + 1)
		PageOnChange(self:GetParent().Page)
	end

	local function ListOnRowSelected(self, index, line)
		if line.SteamID64 then
			surface.PlaySound("garrysmod/ui_return.wav")

			local menu = DermaMenu()

			local name, sid64, sid32 = line.plyName, line.SteamID64, util.SteamIDFrom64(line.SteamID64)

			line.DMenuNameOption = menu:AddOption(name, function(self)
				SetClipboardText(self.UpdatedName or (IsValid(line) and line.plyName or name))
				surface.PlaySound("garrysmod/content_downloaded.wav")
				notification.AddLegacy(L"CopiedExclamation", NOTIFY_CLEANUP, 2)
			end)
			line.DMenuNameOption:SetIcon("icon16/box.png")
			line.DMenuNameOption.m_Image.AvatarImage = vgui.Create("AvatarImage", line.DMenuNameOption.m_Image)
			line.DMenuNameOption.m_Image.AvatarImage:Dock(FILL)
			line.DMenuNameOption.m_Image.AvatarImage:SetSteamID(sid64, 32)

			menu:AddOption(sid32, function()
				SetClipboardText(sid32)
				surface.PlaySound("garrysmod/content_downloaded.wav")
				notification.AddLegacy(L"CopiedExclamation", NOTIFY_CLEANUP, 2)
			end):SetIcon("icon16/user.png")

			menu:AddOption(sid64, function()
				SetClipboardText(sid64)
				surface.PlaySound("garrysmod/content_downloaded.wav")
				notification.AddLegacy(L"CopiedExclamation", NOTIFY_CLEANUP, 2)
			end):SetIcon("icon16/user_gray.png")

			menu:Open()
		end
	end

	function bKeypads.AccessLogs:OpenUI(keypad, animate, UI, wep)
		local AuthModeStrs = {
			[bKeypads.AUTH_MODE.PIN] = L"PIN",
			[bKeypads.AUTH_MODE.FACEID] = L"FaceID",
			[bKeypads.AUTH_MODE.KEYCARD] = L"Keycard"
		}

		if not UI then
			UI = UI or vgui.Create("DFrame")
			--UI:SetSkin("bKeypads_Dark")
			UI:SetTitle(L"KeypadAccessLogs")
			UI:SetIcon("icon16/calculator.png")
			UI:SetSize(450, 500)
			UI:MakePopup()
			if wep then
				UI.OnClose = function()
					if IsValid(wep) and LocalPlayer():GetActiveWeapon() == wep then
						net.Start("bKeypads.AccessLogs.Closed")
							net.WriteEntity(keypad)
						net.SendToServer()
					end
				end
			end

			if animate then
				UI:SetPos((ScrW() - UI:GetWide()) / 2, ScrH())

				local y = (ScrH() + UI:GetTall()) / 2
				UI:NewAnimation(1, 0, .5).Think = function(_, pnl, f)
					local f = bKeypads.ease.OutBack(f)

					local x = pnl:GetPos()
					pnl:SetPos(x, ScrH() - (y * f))

					pnl:SetAlpha(f * 255)
				end
			else
				UI:Center()
			end
		end
		UI.Keypad = keypad

		UI.List = vgui.Create("DListView", UI)
		UI.List:SetMultiSelect(false)
		UI.List:Dock(FILL)
		UI.List:AddColumn(L"When")
		UI.List:AddColumn(L"Mode")
		UI.List:AddColumn(L"Who")
		UI.List:AddColumn(L"Access")
		if bKeypads.Economy:HasCashSystem() then UI.List:AddColumn(L"Charge") end
		UI.List:AddLine(L"LoadingEllipsis")
		UI.List.OnRowSelected = ListOnRowSelected

		UI.Pagination = vgui.Create("DPanel", UI)
		UI.Pagination:Dock(TOP)
		UI.Pagination:DockPadding(10, 10, 10, 10)
		UI.Pagination:SetTall(25 + 20)
		UI.Pagination.PerformLayout = PaginationPerformLayout
		UI.Pagination.Paint = nil

		UI.Pagination.Left = vgui.Create("DButton", UI.Pagination)
		UI.Pagination.Left:SetText("<")
		UI.Pagination.Left:SetSize(25, 25)
		UI.Pagination.Left:SetDisabled(true)
		UI.Pagination.Left.DoClick = PrevPage

		UI.Pagination.Page = vgui.Create("DTextEntry", UI.Pagination)
		UI.Pagination.Page:SetText("1")
		UI.Pagination.Page:SetSize(50, 25)
		UI.Pagination.Page:SetDisabled(true)
		UI.Pagination.Page.Value = -1
		UI.Pagination.Page.AllowInput = PageAllowInput
		UI.Pagination.Page.OnEnter = PageOnChange
		UI.Pagination.Page.OnFocusChanged = function(self, focused) if not focused and self:GetText() ~= tostring(self.Value) then PageOnChange(self) end end

		UI.Pagination.Right = vgui.Create("DButton", UI.Pagination)
		UI.Pagination.Right:SetText(">")
		UI.Pagination.Right:SetSize(25, 25)
		UI.Pagination.Right:SetDisabled(true)
		UI.Pagination.Right.DoClick = NextPage

		UI.ReceiveData = function(totalLogs, accessLogs)
			if UI.Pagination.Page.Value == -1 then
				UI.Pagination.Page.Value = 1
				if totalLogs > 30 then
					UI.Pagination.Right:SetDisabled(false)
				end
			end
			UI.Pagination.Page.MaxIndex = totalLogs
			UI.Pagination.Page:SetDisabled(false)

			UI.List:Clear()
			if #accessLogs > 0 then
				for _, log in ipairs(accessLogs) do
					local plyName, steamWorksRequest
					if log.ply ~= "" and log.ply:match("^7656119%d+$") then
						plyName = util.SteamIDFrom64(log.ply)
						local ply = bKeypads.player.GetBySteamID64(log.ply)
						if IsValid(ply) then
							plyName = ply:Nick()
						else
							local steamName = steamworks.GetPlayerName(log.ply)
							if #steamName > 0 then
								plyName = steamName
							else
								steamWorksRequest = log.ply
							end
						end
					else
						plyName = L"Unknown"
					end

					local line = UI.List:AddLine(
						bKeypads:FormatTimeDelta(os.time(), log.time),
						AuthModeStrs[log.authMode] or L"Unknown",
						log.hacked and L"KeypadHackedAdminHidden" or plyName,
						log.granted == true and ((log.hacked or log.ply == "") and "=̨̘͎͖̈̋̋̏́̌̀͜͠=̣̖̦̗̜͌̓͌̆̊̀͋̍͜ͅ=̷̢̱̤̪̘̩̠̆̇̂̎̇͠͝=̴̡̢̟̙̲̙̠̰̟͐̊͂͊͐̍̚͢≠̛̛͎̮̜͚͕̊̽̓̂͊̽͟͜͞=͕̹̻̝̥̤͚͛̋̈̌͆̋͒" or L"Granted") or L"Denied",
						bKeypads.Economy:HasCashSystem() and (log.charge == 0 and "" or bKeypads.Economy:formatMoney(log.charge)) or nil
					)
					line.SteamID64 = log.ply ~= "" and log.ply
					line.plyName = plyName

					if steamWorksRequest then
						steamworks.RequestPlayerInfo(steamWorksRequest, function(name)
							if #name == 0 then return end
							line:SetColumnText(3, name)
							line.plyName = name
							if IsValid(line.DMenuNameOption) then
								line.DMenuNameOption:SetText(name)
								line.DMenuNameOption:InvalidateParent()
							end
						end)
					end
				end
			else
				UI.List:AddLine(L"NoData")
			end
		end

		PageOnChange(UI.Pagination.Page)
	end

	net.Receive("bKeypads.AccessLogs", function()
		bKeypads.AccessLogs:OpenUI(net.ReadEntity(), true, nil, net.ReadEntity())
	end)
end