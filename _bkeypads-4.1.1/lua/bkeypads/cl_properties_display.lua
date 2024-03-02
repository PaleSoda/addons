bKeypads.Properties = {}
bKeypads.Properties.Drawing = {}

-- Remove any previous property sheets
for _, keypad in ipairs(bKeypads.Keypads) do
	if not IsValid(keypad) then continue end
	if IsValid(keypad.m_pKeypadProperties) then
		keypad.m_pKeypadProperties:Remove()
	end
	keypad.m_pKeypadProperties = nil
end

local propertiesW = 300

local displayProps = {

	--## Name ##--

	{
		Name = "Name",
		{
			{
				Name = "Name",
				Type = "Generic",
				ConVar = "bkeypads_name",
				SetValue = function(keypad)
					return keypad:GetKeypadName()
				end
			},
		}
	},

	--## Persistence ##--

	{
		Name = "Persistence",
		{
			{
				Name = "Persistent",
				Type = "Boolean",
				SetValue = function(keypad)
					return keypad:GetPersist()
				end
			}
		}
	},

	--## General ##--

	{
		Name = "General",
		{
			{
				Name = "AuthMode",
				Type = "Generic",
				SetValueConVar = function()
					local AuthMode = GetConVar("bkeypads_auth_mode"):GetInt()
					if AuthMode == 1 then
						return bKeypads.L("PIN")
					elseif AuthMode == 2 then
						return bKeypads.L("FaceID")
					elseif AuthMode == 3 then
						return bKeypads.L("Keycard")
					end
					return "ERROR"
				end,
				SetValue = function(keypad)
					local AuthMode = keypad:LinkProxy():GetAuthMode()
					if AuthMode == 1 then
						return bKeypads.L("PIN")
					elseif AuthMode == 2 then
						return bKeypads.L("FaceID")
					elseif AuthMode == 3 then
						return bKeypads.L("Keycard")
					end
					return "ERROR"
				end
			},

			{
				Name = "ScanningStatus",
				Type = "Generic",
				SetValue = function(keypad)
					local ScanningStatus = keypad:GetScanningStatus()
					if ScanningStatus == 0 then
						return bKeypads.L("LoadingEllipsis")
					elseif ScanningStatus == 1 then
						return bKeypads.L("Idle")
					elseif ScanningStatus == 2 then
						return bKeypads.L("Scanning")
					elseif ScanningStatus == 3 then
						return bKeypads.L("AccessGranted")
					elseif ScanningStatus == 4 then
						return bKeypads.L("AccessDenied")
					end
					return "ERROR"
				end
			},

			{
				NameRaw = "Wiremod",
				Type = "Boolean",
				SetValueConVar = function()
					return WireLib ~= nil and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/wiremod") and GetConVar("bkeypads_wiremod"):GetBool()
				end,
				SetValue = function(keypad)
					return keypad:GetWiremodEnabled()
				end
			},

			{
				Name = "Broken",
				Type = "Boolean",
				SetValue = function(keypad)
					return keypad:GetBroken()
				end
			},

			{
				Name = "Hacked",
				Type = "Boolean",
				SetValue = function(keypad)
					return keypad:GetHacked()
				end
			},

			{
				Name = "Uncrackable",
				Type = "Boolean",
				SetValueConVar = function()
					return bKeypads.Permissions:Cached(LocalPlayer(), "keypads/uncrackable_keypads") and not GetConVar("bkeypads_uncrackable"):GetBool()
				end,
				SetValue = function(keypad)
					return keypad:GetUncrackable()
				end
			},

			{
				Name = "Freeze",
				Type = "Boolean",
				ConVar = "bkeypads_freeze",
				SetValue = function(keypad)
					local phys = keypad:GetPhysicsObject()
					return not IsValid(phys) or not phys:IsMotionEnabled()
				end
			},

			{
				Name = "Weld",
				Type = "Boolean",
				ConVar = "bkeypads_weld",
				SetValue = function(keypad)
					return keypad:GetWelded()
				end,
			}
		}
	},

	--## Access Granted ##--

	{
		Name = "AccessGranted",
		{
			{
				Name = "Key",
				Type = "Generic",
				SetValueConVar = function()
					local key = GetConVar("bkeypads_granted_key"):GetInt()
					return key == 0 and "" or language.GetPhrase(input.GetKeyName(key))
				end,
				SetValue = function(keypad)
					return keypad:GetGrantedKey() == 0 and "" or language.GetPhrase(input.GetKeyName(keypad:GetGrantedKey()))
				end
			},

			{
				Name = "Time",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(
						GetConVar("bkeypads_granted_hold_time"):GetInt(),
						bKeypads.Config.Scanning.AccessGranted.MinimumTime,
						bKeypads.Config.Scanning.AccessGranted.MaximumTime == 0 and ((2^31)-1) or bKeypads.Config.Scanning.AccessGranted.MaximumTime
					)
				end,
				SetValue = function(keypad)
					return keypad:GetGrantedTime()
				end
			},

			{
				Name = "Delay",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_granted_initial_delay"):GetInt(), 0, (2^31)-1)
				end,
				SetValue = function(keypad)
					return keypad:GetGrantedDelay()
				end
			},

			{
				Name = "Repeats",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_granted_repeats"):GetInt(), 0, bKeypads.Config.Scanning.AccessGranted.MaximumRepeats)
				end,
				SetValue = function(keypad)
					return keypad:GetGrantedRepeats()
				end
			},

			{
				Name = "RepeatDelay",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_granted_repeat_delay"):GetInt(), bKeypads.Config.Scanning.AccessGranted.MinimumRepeatDelay, (2^31)-1)
				end,
				SetValue = function(keypad)
					return keypad:GetGrantedRepeatDelay()
				end
			},
		}
	},

	--## Access Denied ##--

	{
		Name = "AccessDenied",
		{
			{
				Name = "Key",
				Type = "Generic",
				SetValueConVar = function()
					local key = GetConVar("bkeypads_denied_key"):GetInt()
					return key == 0 and "" or language.GetPhrase(input.GetKeyName(key))
				end,
				SetValue = function(keypad)
					return keypad:GetDeniedKey() == 0 and "" or language.GetPhrase(input.GetKeyName(keypad:GetDeniedKey()))
				end
			},

			{
				Name = "Time",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(
						GetConVar("bkeypads_denied_hold_time"):GetInt(),
						bKeypads.Config.Scanning.AccessDenied.MinimumTime,
						bKeypads.Config.Scanning.AccessDenied.MaximumTime == 0 and ((2^31)-1) or bKeypads.Config.Scanning.AccessDenied.MaximumTime
					)
				end,
				SetValue = function(keypad)
					return keypad:GetDeniedTime()
				end
			},

			{
				Name = "Delay",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_denied_initial_delay"):GetInt(), 0, (2^31)-1)
				end,
				SetValue = function(keypad)
					return keypad:GetDeniedDelay()
				end
			},

			{
				Name = "Repeats",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_denied_repeats"):GetInt(), 0, bKeypads.Config.Scanning.AccessDenied.MaximumRepeats)
				end,
				SetValue = function(keypad)
					return keypad:GetDeniedRepeats()
				end
			},

			{
				Name = "RepeatDelay",
				Type = "Int",
				SetValueConVar = function()
					return math.Clamp(GetConVar("bkeypads_denied_repeat_delay"):GetInt(), bKeypads.Config.Scanning.AccessDenied.MinimumRepeatDelay, (2^31)-1)
				end,
				SetValue = function(keypad)
					return keypad:GetDeniedRepeatDelay()
				end
			},
		}
	},

	--## Appearance ##--

	{
		Name = "Appearance",
		{
			{
				Name = "BackgroundColor",
				Type = "VectorColor",
				SetValueConVar = function()
					return bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/bg_color") and bKeypads:IntToColor(GetConVar("bkeypads_background_color"):GetInt()) or bKeypads.COLOR.GMODBLUE
				end,
				SetValue = function(keypad)
					return keypad.CustomBackgroundColor or keypad.TargetBackgroundColor or bKeypads.COLOR.GMODBLUE
				end
			},

			{
				Name = "ImageURL",
				Type = "Generic",
				SetValueConVar = function()
					if not bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/custom_img") then return "" end

					local image_url = GetConVar("bkeypads_image_url"):GetString()
					if #image_url > 0 and bKeypads.KeypadImages:VerifyURL(image_url, true) then
						return image_url
					end

					return ""
				end,
				SetValue = function(keypad)
					return keypad:GetImageURL()
				end
			},

			{
				Name = "Slanted",
				Type = "Boolean",
				SetValue = function(keypad)
					return keypad:GetSlanted()
				end
			},
		}
	},

	--## Notifications ##--

	{
		Name = "Notifications",
		{
			{
				Name = "AccessGranted",
				Type = "Boolean",
				ConVar = "bkeypads_granted_notification",
				SetValue = function(keypad)
					return keypad:GetGrantedNotifications()
				end
			},

			{
				Name = "AccessDenied",
				Type = "Boolean",
				ConVar = "bkeypads_denied_notification",
				SetValue = function(keypad)
					return keypad:GetDeniedNotifications()
				end
			},
		}
	},
}

local function KeypadPropertiesPerformLayout(self, w, h)
	DProperties.PerformLayout(self, w, h)

	if self:GetCanvas():GetVBar():IsVisible() then
		self:GetCanvas():SizeToChildren(false, true)
		self:SizeToChildren(false, true)
	end
end

if IsValid(bKeypads_ConVarProperties) then
	bKeypads_ConVarProperties:Remove()
	bKeypads_ConVarProperties = nil
end
local function ConVarPropertiesThink(self)
	for _, category in ipairs(displayProps) do
		for _, prop in ipairs(category[1]) do
			if not prop.SetValueConVar and not prop.ConVar then continue end
			local row = self.Props[category.NameRaw or category.Name][prop.NameRaw or prop.Name]
			if prop.SetValueConVar then
				row:SetValue(prop.SetValueConVar())
			else
				local ConVar = GetConVar(prop.ConVar)
				local ConVarValue
				if prop.Type == "Generic" then
					ConVarValue = ConVar:GetString()
				elseif prop.Type == "Boolean" then
					ConVarValue = ConVar:GetBool()
				elseif prop.Type == "Int" then
					ConVarValue = ConVar:GetInt()
				elseif prop.Type == "Float" then
					ConVarValue = ConVar:GetFloat()
				end
				row:SetValue(ConVarValue)
			end
		end
	end
end

function bKeypads.Properties:Update(keypad, use_convars)
	local KeypadProperties = bKeypads.Properties:CreatePropertiesPanel(keypad, use_convars)

	local isInWorldSpace = KeypadProperties:GetParent() == vgui.GetWorldPanel()

	if not use_convars then
		for _, category in ipairs(displayProps) do
			for _, prop in ipairs(category[1]) do
				local row = KeypadProperties.Props[category.NameRaw or category.Name][prop.NameRaw or prop.Name]
				row:SetValue(prop.SetValue(keypad))
			end
		end
	end

	if isInWorldSpace and not KeypadProperties.m_b3D2D then
		KeypadProperties.m_b3D2D = true

		KeypadProperties:SetMouseInputEnabled(false)
		KeypadProperties:SetKeyboardInputEnabled(false)
		KeypadProperties:SetPaintedManually(true)

		KeypadProperties:SetWide(propertiesW)
		KeypadProperties.PerformLayout = KeypadPropertiesPerformLayout
	end

	return KeypadProperties
end

function bKeypads.Properties:CreatePropertiesPanel(keypad, use_convars)
	if use_convars then
		if IsValid(bKeypads_ConVarProperties) then return bKeypads_ConVarProperties end
	else
		if IsValid(keypad.m_pKeypadProperties) then return keypad.m_pKeypadProperties end
	end

	local KeypadProperties = vgui.Create("DProperties")

	if use_convars then
		bKeypads_ConVarProperties = KeypadProperties
		KeypadProperties.Think = ConVarPropertiesThink
	else
		keypad.m_pKeypadProperties = KeypadProperties
	end

	KeypadProperties:SetMouseInputEnabled(false)
	KeypadProperties:SetKeyboardInputEnabled(false)
	KeypadProperties:SetPaintedManually(true)

	KeypadProperties:SetWide(propertiesW)
	KeypadProperties.PerformLayout = KeypadPropertiesPerformLayout

	KeypadProperties.Props = {}
	for _, category in ipairs(displayProps) do
		KeypadProperties.Props[category.Name] = {}
		for _, prop in ipairs(category[1]) do
			if use_convars and (not prop.SetValueConVar and not prop.ConVar) then continue end

			local options

			if prop.Type == "Float" or prop.Type == "Int" then
				options = {
					min = -math.huge,
					max = math.huge
				}
			end

			local row = KeypadProperties:CreateRow(category.NameRaw or bKeypads.L(category.Name), prop.NameRaw or (bKeypads.L(prop.Name):gsub(":", "")))
			row:Setup(prop.Type, options)

			if prop.Type == "Generic" then
				local function blockChange(self)
					local actualVal
					if use_convars then
						if prop.SetValueConVar then
							actualVal = prop.SetValueConVar()
						else
							actualVal = GetConVar(prop.ConVar):GetString()
						end
					elseif IsValid(keypad) then
						actualVal = prop.SetValue(keypad)
					else
						return
					end
					if self:GetText() ~= actualVal then
						self:SetText(actualVal)
					end
				end

				local DTextEntry = row:Find("DTextEntry")
				DTextEntry:SetUpdateOnType(true)
				DTextEntry.OnValueChange = blockChange
				DTextEntry.OnChange = blockChange
				DTextEntry.OnTextChanged = blockChange
				DTextEntry.OnEnter = blockChange
				DTextEntry.OnFocusChanged = blockChange
				DTextEntry.OnKeyCode = blockChange
				DTextEntry.AllowInput = function() return true end
			elseif prop.Type == "Boolean" then
				row:Find("DCheckBox"):SetMouseInputEnabled(false)
			elseif prop.Type == "VectorColor" then
				row:Find("DButton"):SetMouseInputEnabled(false)
			elseif prop.Type == "Int" then
				local DNumSlider = row:Find("DNumSlider")
				DNumSlider.Slider:SetVisible(false)
				DNumSlider.Scratch:SetMouseInputEnabled(false)
				DNumSlider:SetMouseInputEnabled(false)
				row.Inner.Paint = nil
			end

			KeypadProperties.Props[category.NameRaw or category.Name][prop.NameRaw or prop.Name] = row
		end
	end

	return KeypadProperties
end

function bKeypads.Properties:TrashPropertiesPanel(keypad)
	if IsValid(keypad) and IsValid(keypad.m_pKeypadProperties) then
		keypad.m_pKeypadProperties:Remove()
		keypad.m_pKeypadProperties = nil
	end
end