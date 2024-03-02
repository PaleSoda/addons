---------------------------------------------------------------------------
//// Don't change anything here if you don't know what you are doing ////
---------------------------------------------------------------------------

escore = escore or {}
escore.loader = escore.loader or {}
local loader = escore.loader



--WORKSHOP CONTENT
if ( SERVER ) then
	resource.AddWorkshop( "2500137654" ) -- https://steamcommunity.com/sharedfiles/filedetails/?id=2500137654
end



if (SERVER) then
print([[ 
 _____ _____                    _                         _ 
|  ___/  ___|                  | |                       | |
| |__ \ `--.  ___ ___  _ __ ___| |__   ___   __ _ _ __ __| |
|  __| `--. \/ __/ _ \| '__/ _ \ '_ \ / _ \ / _` | '__/ _` |
| |___/\__/ / (_| (_) | | |  __/ |_) | (_) | (_| | | | (_| |
\____/\____/ \___\___/|_|  \___|_.__/ \___/ \__,_|_|  \__,_|
]])
print("____________________________\n")
end



--Default folder
local epath = "escoreboard/"

--CLIENT
function loader:IncludeClient(path)
	if (CLIENT) then
		include(epath .. path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile(epath .. path .. ".lua")
		print("• ".. epath .. path .. ".lua")
	end
end

--SERVER
function loader:IncludeServer(path)
	if (SERVER) then
		include(epath .. path .. ".lua")
		print("• ".. epath .. path .. ".lua")
	end
end

--SHARED
function loader:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
	if (SERVER) then print("• ".. epath .. path .. ".lua") end
end

--RESOURCE (Font OR Materials)
function loader:ResourceAddFile(path)
	if (SERVER) then
		resource.AddFile(path)
		print("• Resource added: ".. path)
	end
end

function loader:ResourceAddFolder(name, recurse)
    local files, folders = file.Find(name .."/*", "GAME")

    for _, fname in ipairs(files) do
        self:ResourceAddFile(name .."/".. fname)
    end

    if recurse then
        for _, fname in ipairs(folders) do
            emenu.loader:AddFolder(name .."/".. fname, recurse)
        end
    end
end

function loader:ClAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeClient(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ClAddFolder(name .."/".. fname, recurse)
        end
    end
end

function loader:SvAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeServer(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:SvAddFolder(name .."/".. fname, recurse)
        end
    end
end

function loader:ShAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeShared(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ShAddFolder(name .."/".. fname, recurse)
        end
    end
end

--Main load function
function loader:Load()
	print("[ESCOREBOARD] "..(SERVER and "Loading server files..." or "Loading client files..."))

	--CONFIGS
	self:IncludeClient("config/escore_config")
	self:IncludeClient("config/escore_langs")
	self:IncludeClient("config/escore_commands")

	--OTHER
	self:IncludeShared("core/escore_fonts")
	self:IncludeShared("core/escore_utils")

	--VGUI
	self:IncludeClient("vgui/e_avatar")
	self:IncludeClient("vgui/e_background")
	self:IncludeClient("vgui/e_frame")
	self:IncludeClient("vgui/e_contextmenu")
	self:IncludeClient("vgui/e_slider")

	--MAIN FILES
	self:IncludeServer("core/escore_server")
	self:IncludeClient("core/escoreboard")
	self:IncludeClient("core/escore_buttons")

	print("+------------------------------+")
	print("| ESCOREBOARD LOADING FINISHED |")
	print("+------------------------------+")

	self.finished = true
end

escore.loader:Load()