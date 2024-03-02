bKeypads.ContextMenu = {}

local function recursiveFilterCheck(member, ent, ply)
	for _, child in ipairs(member.Members) do
		if child.Filter and child:Filter(ent, ply) and ((not child.Members or #child.Members == 0) or (recursiveFilterCheck(child, ent, ply) == true)) then
			return true
		end
	end
	return false
end

local net_ids = { incr = 0, registry = {} }
bKeypads.ContextMenu.NetReceivers = {}
if SERVER then
	function bKeypads.ContextMenu:Receive(_, ply)
		local net_id = net.ReadUInt(8)
		if bKeypads.ContextMenu.NetReceivers[net_id] then
			local ent = net.ReadEntity()
			if not bKeypads.ContextMenu.NetReceivers[net_id].Filter or bKeypads.ContextMenu.NetReceivers[net_id]:Filter(ent, ply) == true then
				bKeypads.ContextMenu.NetReceivers[net_id].Callback(bKeypads.ContextMenu.NetReceivers[net_id], ent, ply)
			end
		end
	end
end

local memberMeta = {}
memberMeta.__index = memberMeta

function memberMeta:AddMember(name, icon, filter, callback, net_receiver)
	self.Members = self.Members or {}
	return self.Members[table.insert(self.Members, setmetatable({}, memberMeta)(name, icon, filter, callback, net_receiver))]
end

if CLIENT then
	local function interpolateIcon(member, option, ent)
		if isfunction(member.MenuIcon) then
			return member:MenuIcon(option, ent)
		else
			return member.MenuIcon
		end
	end
	function memberMeta:MenuOpen(submenu, ent, tr)
		if submenu.SetIcon then
			submenu = submenu:AddSubMenu()
		end
		for _, member in ipairs(self.Members) do
			if not member.Filter or member:Filter(ent, LocalPlayer()) == true then
				if not member.Members or #member.Members == 0 then
					local option = submenu:AddOption(member.MenuLabel, function()
						member.NetworkEnt = ent
						member:Callback(ent, LocalPlayer(), tr)
					end)
					option:SetIcon(interpolateIcon(member, option, ent))
				elseif recursiveFilterCheck(member, ent, LocalPlayer()) then
					local submenu, _ = submenu:AddSubMenu(member.MenuLabel)
					_:SetIcon(interpolateIcon(member, _, ent))
					member:MenuOpen(submenu, ent, LocalPlayer(), tr)
				end
			end
		end
	end
end

function memberMeta:__call(name, icon, filter, callback, net_receiver)
	self.MenuLabel = name
	self.MenuIcon = icon
	self.Filter = filter
	self.Callback = callback

	if net_receiver then
		local net_id = net_ids.registry[name]
		if not net_id then
			net_ids.incr = net_ids.incr + 1
			net_id, net_ids.registry[name] = net_ids.incr, net_ids.incr
		end
		self.NetID = net_id
		bKeypads.ContextMenu.NetReceivers[net_id] = self
	end

	return self
end

function memberMeta:Network()
	if not self.m_bNetworking then
		self.m_bNetworking = true

		bKeypads.ContextMenu:MsgStart()
		net.WriteUInt(self.NetID, 8)
		net.WriteEntity(self.NetworkEnt)
	else
		self.m_bNetworking = nil

		bKeypads.ContextMenu:MsgEnd()
	end
end

local function mergemetatables(dest, source)
	for k, v in pairs(source) do
		if k == "__index" then continue end
		if istable(v) and istable(dest[k]) then
			table.Merge(dest[k], v)
		else
			dest[k] = v
		end
	end

	return dest
end
properties.Add("bkeypads", bKeypads.ContextMenu)

setmetatable(bKeypads.ContextMenu, mergemetatables(table.Copy(getmetatable(bKeypads.ContextMenu)), memberMeta))("Billy's Keypads", "icon16/calculator.png", function(self, ent, ply)
	return recursiveFilterCheck(self, ent, ply)
end)

bKeypads.ContextMenu:AddMember(
	"#bKeypads_OwnedBy",

	-- Icon/Text
	function(self, option, ent)
		local owner = ent:GetKeypadOwner()
		self.m_Clipboard = owner:SteamID()

		option:SetText(owner:Nick())

		option:SetIcon("icon16/user.png")
		option.m_Image.AvatarImage = vgui.Create("AvatarImage", option.m_Image)
		option.m_Image.AvatarImage:SetSteamID(owner:SteamID64(), 32)
		option.m_Image.AvatarImage:Dock(FILL)

		return "icon16/user.png"
	end,

	-- Filter
	function(self, ent, ply)
		return ent.bKeypad and IsValid(ent:GetKeypadOwner())
	end,

	-- Callback
	function(self, ent, ply)
		if self.m_Clipboard then
			SetClipboardText(self.m_Clipboard)
			surface.PlaySound("garrysmod/content_downloaded.wav")
			notification.AddLegacy(bKeypads.L"CopiedExclamation", NOTIFY_CLEANUP, 2)
		end
	end
)