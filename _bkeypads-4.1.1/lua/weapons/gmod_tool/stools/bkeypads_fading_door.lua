TOOL.Category = "Billy's Keypads"
TOOL.Name = "#bKeypads_FadingDoor"

TOOL.ClientConVar["toggle"] = 0
TOOL.ClientConVar["reversed"] = 0
TOOL.ClientConVar["mat"] = "sprites/heatwave"
TOOL.ClientConVar["opensound"] = ""
TOOL.ClientConVar["activesound"] = ""
TOOL.ClientConVar["closesound"] = ""
TOOL.ClientConVar["key"] = 0

local function ListMerge(dict, listName, mergeTbl)
	for _, v in ipairs(mergeTbl) do
		if not dict[v] then
			list.Add(listName, v)
		end
	end
end
local function InitLists()
	table.Empty(list.GetForEdit("bKeypads_FDoorMaterials"))
	table.Empty(list.GetForEdit("bKeypads_FDoorSounds"))
	table.Empty(list.GetForEdit("bKeypads_FDoorLoopSounds"))

	local dict = {}
	for _, mat in ipairs(bKeypads.Config.FadingDoors.Materials) do
		list.Add("bKeypads_FDoorMaterials", mat)
		dict[mat] = true
	end
	ListMerge(dict, "bKeypads_FDoorMaterials", list.Get("FDoorMaterials"))

	local dict = {}
	for _, snd in ipairs(bKeypads.Config.FadingDoors.Sounds) do
		if file.Exists("sound/" .. snd, "GAME") then
			util.PrecacheSound(snd)
			list.Add("bKeypads_FDoorSounds", snd)
			dict[snd] = true
		end
	end
	ListMerge(dict, "bKeypads_FDoorSounds", list.Get("FDoorSounds"))

	local dict = {}
	for _, snd in ipairs(bKeypads.Config.FadingDoors.LoopSounds) do
		if file.Exists("sound/" .. snd, "GAME") then
			util.PrecacheSound(snd)
			list.Add("bKeypads_FDoorLoopSounds", snd)
			dict[snd] = true
		end
	end
	ListMerge(dict, "bKeypads_FDoorLoopSounds", list.Get("FDoorLoopSounds"))
end
if bKeypads and bKeypads.Config then
	InitLists()
else
	hook.Add("bKeypads.Config", "bKeypads.FadingDoors.InitLists", InitLists)
end

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "info1", icon = "gui/info"},
		{ name = "info2", icon = "gui/info" },
		{ name = "info3", icon = "gui/info" },

		{ name = "door", icon = "gui/lmb.png"},
		{ name = "copy", icon = "gui/rmb.png" },
		{ name = "remove", icon = "gui/r.png" },
	}
end

function TOOL:LeftClick(tr)
	return bKeypads.FadingDoors.STOOL.LeftClick(self, tr)
end

function TOOL:RightClick(tr)
	return bKeypads.FadingDoors.STOOL.RightClick(self, tr)
end

function TOOL:Reload(tr)
	return bKeypads.FadingDoors.STOOL.Reload(self, tr)
end

function TOOL:Deployed()
	if CLIENT then bKeypads.ESP:Activate() end
	bKeypads.FadingDoors.STOOL.Reset(self)
end
function TOOL:Holstered()
	if CLIENT then bKeypads.ESP:Deactivate() end
	bKeypads.FadingDoors.STOOL.Reset(self)
end
bKeypads_Prediction(TOOL)

if CLIENT then
	function TOOL.BuildCPanel(CPanel)
		return bKeypads.FadingDoors.STOOL.BuildCPanel(CPanel)
	end

	local matFadingDoorTool = Material("bkeypads/fading_door")
	function TOOL:DrawToolScreen(w,h)
		surface.SetDrawColor(0,150,255)
		surface.DrawRect(0,0,w,h)

		if not self.Matrix then
			self.Matrix = bKeypads_Matrix("STOOL_Screen", w, h)
		end
		self.Matrix:Draw(w,h)

		surface.SetMaterial(matFadingDoorTool)
		surface.DrawTexturedRect(0, 0, w, h)

		if not bKeypads.Permissions:Cached(LocalPlayer(), "fading_doors/create") then
			bKeypads:ToolScreenNoPermission(w,h)
		elseif not bKeypads.STOOL:CheckLimit(LocalPlayer(), bKeypads.STOOL.LIMIT_FADING_DOORS) then
			bKeypads:ToolScreenWarning(bKeypads.L("SBoxLimit__bkeypads_fading_doors"), w, h)
		end
	end
end