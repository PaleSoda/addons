local authModes
local function AuthModeToStr(keypad)
	if not authModes then
		authModes = {
			[bKeypads.AUTH_MODE.PIN] = "PIN",
			[bKeypads.AUTH_MODE.FACEID] = "FaceID",
			[bKeypads.AUTH_MODE.KEYCARD] = "Keycard",
		}
	end
	return authModes[keypad:LinkProxy():GetAuthMode()]
end

local function KeycardName(keycard, index)
	return "<color=" .. bKeypads.markup.Color(keycard:GetKeycardColor()) .. ">" .. index .. "</color>"
end

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keypad Creation"
MODULE.Colour   = Color(0,150,255)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keypad.Spawned", "bKeypads.Keypad.Spawned", function(ply, keypad)
		if keypad:GetKeypadName() ~= "" then
			MODULE:Log("{1} spawned a {2} keypad called \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
		else
			MODULE:Log("{1} spawned a {2} keypad ({3})", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:FormatEntity(keypad))
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keypad Cracks"
MODULE.Colour   = Color(0,150,255)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keypad.Cracked", "bKeypads.Keypad.Cracked", function(keypad, ply)
		if keypad:GetKeypadName() ~= "" then
			if IsValid(ply) then
				MODULE:Log("\"{1}\" / {2} was cracked by {3}", GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatPlayer(ply))
			else
				MODULE:Log("\"{1}\" / {2} was cracked", GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			end
		else
			if IsValid(ply) then
				MODULE:Log("{1} was cracked by {2}", GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatPlayer(ply))
			else
				MODULE:Log("{1} was cracked", GAS.Logging:FormatEntity(keypad))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Access Granted"
MODULE.Colour   = Color(0,255,0)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keypad.AccessGranted", "bKeypads.Keypad.AccessGranted", function(keypad, ply)
		if not IsValid(ply) then return end
		local keycard = keypad:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD and ply:GetWeapon("bkeycard") or nil
		if keypad:GetKeypadName() ~= "" then
			if IsValid(keycard) then
				MODULE:Log("{1} was GRANTED access scanning their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] to \"{5}\" / {6}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetSelectedKeycard()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} was GRANTED access via {2} to \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			end
		else
			if IsValid(keycard) then
				MODULE:Log("{1} was GRANTED access scanning their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] to {6}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetSelectedKeycard()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} was GRANTED access via {2} to {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:FormatEntity(keypad))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Access Denied"
MODULE.Colour   = Color(255,0,0)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keypad.AccessDenied", "bKeypads.Keypad.AccessDenied", function(keypad, ply)
		if not IsValid(ply) then return end
		local keycard = keypad:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD and ply:GetWeapon("bkeycard") or nil
		if keypad:GetKeypadName() ~= "" then
			if IsValid(keycard) then
				MODULE:Log("{1} was DENIED access scanning their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] from \"{5}\" / {6}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetSelectedKeycard()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} was DENIED access via {2} from \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			end
		else
			if IsValid(keycard) then
				MODULE:Log("{1} was DENIED access scanning their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] from {6}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetSelectedKeycard()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} was DENIED access via {2} from {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(AuthModeToStr(keypad)), GAS.Logging:FormatEntity(keypad))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Payments"
MODULE.Colour   = Color(70,200,30)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Payment", "bKeypads.Payment", function(ply, beneficiary, amount, keypad)
		if keypad:GetKeypadName() ~= "" then
			if IsValid(beneficiary) then
				MODULE:Log("{1} paid {2} {3} for access to \"{4}\" / {5}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatPlayer(beneficiary), GAS.Logging:FormatMoney(amount), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} paid {2} for access to \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatMoney(amount), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
			end
		else
			if IsValid(beneficiary) then
				MODULE:Log("{1} paid {2} {3} for access to {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatPlayer(beneficiary), GAS.Logging:FormatMoney(amount), GAS.Logging:FormatEntity(keypad))
			else
				MODULE:Log("{1} paid {2} for access to {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatMoney(amount), GAS.Logging:FormatEntity(keypad))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keycard Pickups"
MODULE.Colour   = Color(255,255,0)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keycard.PickedUp", "bKeypads.Keycard.PickedUp", function(ply, keycard, quantity)
		if keycard.m_DroppedBy then
			if quantity then
				MODULE:Log("{1} picked up a " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] (dropped by {5}), there are now {6} of these keycard(s) left to pickup", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetID()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:FormatPlayer(keycard.m_DroppedBy), GAS.Logging:Highlight(quantity))
			else
				MODULE:Log("{1} picked up a " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}] (dropped by {5})", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetID()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:FormatPlayer(keycard.m_DroppedBy))
			end
		else
			if quantity then
				MODULE:Log("{1} picked up a " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}], there are now {5} of these keycard(s) left to pickup", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetID()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")), GAS.Logging:Highlight(quantity))
			else
				MODULE:Log("{1} picked up a " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}]", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetID()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keycard Drops"
MODULE.Colour   = Color(150,0,255)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keycard.Dropped", "bKeypads.Keycard.Dropped", function(ply, keycard)
		MODULE:Log("{1} dropped their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}]", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetID()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")))
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keycard Identifications"
MODULE.Colour   = Color(255,150,0)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keycard.Identified", "bKeypads.Keycard.Identified", function(ply, keycard)
		MODULE:Log("{1} presents their " .. KeycardName(keycard, "{2}") .. " keycard and identifies themselves as {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:FormatTeam(ply:Team()))
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keycard Switches"
MODULE.Colour   = Color(100,0,200)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.Keycard.Selected", "bKeypads.Keycard.Selected", function(ply, keycardID, keycard)
		MODULE:Log("{1} switched to their " .. KeycardName(keycard, "{2}") .. " keycard [ID: #{3} Levels: {4}]", GAS.Logging:FormatPlayer(ply), GAS.Logging:Escape(keycard:GetKeycardName()), GAS.Logging:Highlight(keycard:GetSelectedKeycard()), GAS.Logging:Escape(table.concat(keycard:GetLevels(), ",")))
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Access Logs Checker"
MODULE.Colour   = Color(0,0,255)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.AccessLogs.Checked", "bKeypads.AccessLogs.Checked", function(ply, keypad)
		if keypad:GetKeypadName() ~= "" then
			MODULE:Log("{1} viewed the access logs of \"{2}\" / {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
		else
			MODULE:Log("{1} viewed the access logs of {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(keypad))
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Linking"
MODULE.Colour   = Color(0,0,255)

MODULE:Setup(function()
	local LINK_TYPE_BUTTON = 0
	local LINK_TYPE_DOOR = 1
	local LINK_TYPE_MAP = 2
	local LINK_TYPE_FADING_DOOR = 3
	local linkTypes
	local function link(linked, linkType, ply, keypad, ent, access_granted)
		if not linkTypes then
			linkTypes = {
				[LINK_TYPE_BUTTON] = "<color=255,0,255>BUTTON</color>",
				[LINK_TYPE_DOOR] = "<color=255,0,0>DOOR</color>",
				[LINK_TYPE_MAP] = "<color=255,150,0>MAP OBJECT</color>",
				[LINK_TYPE_FADING_DOOR] = "<color=0,255,0>FADING DOOR</color>",
			}
		end
		if keypad:GetKeypadName() ~= "" then
			MODULE:Log("{1} " .. (linked and "<color=0,255,0>LINKED</color>" or "<color=255,0,0>UNLINKED</color>") .. " (on access " .. (access_granted and "<color=0,255,0>granted</color>" or "<color=255,0,0>denied</color>") .. ") a " .. linkTypes[linkType] .. " ({2}) " .. (linked and "to" or "from") .. " \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(ent), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad))
		else
			MODULE:Log("{1} " .. (linked and "<color=0,255,0>LINKED</color>" or "<color=255,0,0>UNLINKED</color>") .. " (on access " .. (access_granted and "<color=0,255,0>granted</color>" or "<color=255,0,0>denied</color>") .. ") a " .. linkTypes[linkType] .. " ({2}) " .. (linked and "to" or "from") .. " {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(ent), GAS.Logging:FormatEntity(keypad))
		end
	end

	MODULE:Hook("bKeypads.Link.Button", "bKeypads.Link.Button", function(...) link(true, LINK_TYPE_BUTTON, ...) end)
	MODULE:Hook("bKeypads.Unlink.Button", "bKeypads.Unlink.Button", function(...) link(false, LINK_TYPE_BUTTON, ...) end)

	MODULE:Hook("bKeypads.Link.Door", "bKeypads.Link.Door", function(...) link(true, LINK_TYPE_DOOR, ...) end)
	MODULE:Hook("bKeypads.Unlink.Door", "bKeypads.Unlink.Door", function(...) link(false, LINK_TYPE_DOOR, ...) end)

	MODULE:Hook("bKeypads.Link.Map", "bKeypads.Link.Map", function(...) link(true, LINK_TYPE_MAP, ...) end)
	MODULE:Hook("bKeypads.Unlink.Map", "bKeypads.Unlink.Map", function(...) link(false, LINK_TYPE_MAP, ...) end)

	MODULE:Hook("bKeypads.Link.FadingDoor", "bKeypads.Link.FadingDoor", function(...) link(true, LINK_TYPE_FADING_DOOR, ...) end)
	MODULE:Hook("bKeypads.Unlink.FadingDoor", "bKeypads.Unlink.FadingDoor", function(...) link(false, LINK_TYPE_FADING_DOOR, ...) end)

	MODULE:Hook("bKeypads.Link.Keypad", "bKeypads.Link.Keypad", function(ply, keypad, keypad2)
		if keypad:GetKeypadName() ~= "" then
			if keypad2:GetKeypadName() ~= "" then
				MODULE:Log("{1} linked keypad \"{2}\" / {3} -> \"{4}\" / {5}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad), GAS.Logging:Highlight(keypad2:GetKeypadName()), GAS.Logging:FormatEntity(keypad2))
			else
				MODULE:Log("{1} linked keypad \"{2}\" / {3} -> {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatEntity(keypad2))
			end
		else
			if keypad2:GetKeypadName() ~= "" then
				MODULE:Log("{1} linked {2} -> \"{3}\" / {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(keypad), GAS.Logging:Highlight(keypad2:GetKeypadName()), GAS.Logging:FormatEntity(keypad2))
			else
				MODULE:Log("{1} linked {2} -> {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatEntity(keypad2))
			end
		end
	end)
end)

GAS.Logging:AddModule(MODULE)

-----------------------------------------------------------------

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Billy's Keypads"
MODULE.Name     = "Keypad Image Moderation"
MODULE.Colour   = Color(150,0,255)

MODULE:Setup(function()
	MODULE:Hook("bKeypads.KeypadImages.Ban", "bKeypads.KeypadImages.Ban", function(ply, admin)
		MODULE:Log("{1} <color=255,0,0>banned</color> {2} from using keypad images", GAS.Logging:FormatPlayer(admin), GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("bKeypads.KeypadImages.Unban", "bKeypads.KeypadImages.Unban", function(ply, admin)
		MODULE:Log("{1} <color=0,255,0>unbanned</color> {2} from using keypad images", GAS.Logging:FormatPlayer(admin), GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("bKeypads.KeypadImages.Removed", "bKeypads.KeypadImages.Removed", function(ply, admin, keypad)
		if keypad:GetKeypadName() ~= "" then
			MODULE:Log("{1} removed the keypad image of \"{2}\" / {3} (owned by {4})", GAS.Logging:FormatPlayer(admin), GAS.Logging:Highlight(keypad:GetKeypadName()), GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatPlayer(ply))
		else
			MODULE:Log("{1} removed the keypad image of {2} (owned by {3})", GAS.Logging:FormatPlayer(admin), GAS.Logging:FormatEntity(keypad), GAS.Logging:FormatPlayer(ply))
		end
	end)
end)

GAS.Logging:AddModule(MODULE)
