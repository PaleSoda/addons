bKeypads.CustomAccess = {}

function bKeypads.CustomAccess:Reset()
	bKeypads.CustomAccess.UserConfig = {}
	bKeypads.CustomAccess.UserConfig.Enabled = false
	bKeypads.CustomAccess.UserConfig.TeamGroups = {}
	bKeypads.CustomAccess.UserConfig.LuaFunctions = {}
end
bKeypads.CustomAccess:Reset()

function bKeypads:AddTeamGroup(name, teamGroup)
	if not isstring(name) then
		error("Tried to create a custom access team group with an invalid name: (" .. tostring(name) .. ") Name must be a string, but you put a " .. type(name) .. "!")
		return
	end

	local unenumeratedName = name
	local i = 2
	while bKeypads.CustomAccess.UserConfig.TeamGroups[name] do
		name = unenumeratedName .. " (" .. i .. ")"
		i = i + 1
	end

	if isnumber(teamGroup) then
		bKeypads.CustomAccess.UserConfig.TeamGroups[name] = { [teamGroup] = true }
	elseif istable(teamGroup) then
		for _, teamIndex in pairs(teamGroup) do
			bKeypads.CustomAccess.UserConfig.TeamGroups[name] = bKeypads.CustomAccess.UserConfig.TeamGroups[name] or {}
			bKeypads.CustomAccess.UserConfig.TeamGroups[name][teamIndex] = true
		end
	else
		error("Invalid custom access team group: (" .. tostring(teamGroup) .. ") You did not supply a table, TEAM_NAME or team index.")
		return
	end

	bKeypads.CustomAccess.UserConfig.Enabled = true
end

function bKeypads:AddCustomGroup(name, func)
	if not isstring(name) then
		error("Tried to create a custom access Lua function with an invalid name: (" .. tostring(name) .. ") Name must be a string, but you put a " .. type(name) .. "!")
		return
	elseif not isfunction(func) then
		error("Tried to create a custom access Lua function with an invalid function: (" .. tostring(func) .. ") How did you even manage that? The second argument must be a function, but you put a " .. type(func) .. "!")
		return
	end

	local unenumeratedName = name
	local i = 2
	while bKeypads.CustomAccess.UserConfig.LuaFunctions[name] do
		name = unenumeratedName .. " (" .. i .. ")"
		i = i + 1
	end

	bKeypads.CustomAccess.UserConfig.LuaFunctions[name] = func

	bKeypads.CustomAccess.UserConfig.Enabled = true
end

local function LoadConfig()
	if SERVER and bKeypads.simplerr then
		local succ, err = bKeypads.simplerr.runFile("bkeypads_custom_access.lua")
		if not succ then
			MsgC("\n")
			ErrorNoHalt(err or "[ERROR] UNKNOWN error in \"bkeypads_custom_access.lua\"")
		end
	else
		include("bkeypads_custom_access.lua")
	end
end
hook.Add("bKeypads.ConfigUpdated", "bKeypads.CustomAccess", LoadConfig)
LoadConfig()

--## Addons ##--

bKeypads.CustomAccess.Addons = {}
bKeypads.CustomAccess.Addons.Enabled = false
bKeypads.CustomAccess.Addons.Registry = {}
bKeypads.CustomAccess.Addons.KeyTable = {}

function bKeypads.CustomAccess.Addons:IsValid(path)
	return bKeypads.CustomAccess.AddonFunctions[path] ~= nil
end

function bKeypads.CustomAccess.Addons:Test(path, ply, keypad)
	return bKeypads.CustomAccess.Addons.KeyTable[path] ~= nil and bKeypads.CustomAccess.Addons.KeyTable[path].Function ~= nil and bKeypads.CustomAccess.Addons.KeyTable[path].Function(
		ply, keypad,
		keypad:GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD and (IsValid(ply:GetWeapon("bkeycard")) and ply:GetWeapon("bkeycard")) or nil
	) or false
end

local function ID(str)
	return (str:lower():gsub("[^a-z0-9]", "-"))
end

local customAccessMeta = {}
customAccessMeta.__index = customAccessMeta
function customAccessMeta:__call(parent, icon, name, id, func)
	assert(icon ~= nil, "Missing icon")
	assert(name ~= nil, "Missing name")
	assert(id == nil or isstring(id), "ID should be a string or nil")
	assert(func == nil or isfunction(func), "Member function should be a function or nil")

	self.ID = (parent and (parent.ID .. "/") or "") .. ID(id or name)
	self.Name = name
	self.Icon = icon

	if func then
		self.Function = func
	else
		self.Members = {}
	end

	if parent then
		self.Parent = parent
		self.Addon = self.Parent.Addon or self.Parent
	else
		bKeypads.CustomAccess.Addons.Registry[self.ID] = self
	end

	bKeypads.CustomAccess.Addons.KeyTable[self.ID] = self

	return self
end
function customAccessMeta:AddCategory(icon, name, id)
	assert(self.Members ~= nil, "You can't add a category to a member, use :AddCategory() instead")
	return self.Members[table.insert(self.Members, setmetatable({}, customAccessMeta)(self, icon, name, id))]
end
function customAccessMeta:AddMember(icon, name, func, id)
	return self.Members[table.insert(self.Members, setmetatable({}, customAccessMeta)(self, icon, name, id, func))]
end

function bKeypads.CustomAccess:AddAddon(icon, name, id)
	bKeypads.CustomAccess.Addons.Enabled = true
	return setmetatable({}, customAccessMeta)(nil, icon, name, id)
end

for _, f in ipairs((file.Find("bkeypads/custom/*.lua", "LUA"))) do
	if SERVER then
		AddCSLuaFile("bkeypads/custom/" .. f)
	end
	include("bkeypads/custom/" .. f)
end