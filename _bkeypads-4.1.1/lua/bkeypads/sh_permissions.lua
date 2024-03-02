bKeypads.Permissions = {}

bKeypads.Permissions.Registry = {
	{
		Label = "Create Keypads",
		Value = "create_keypads",
		Icon = "icon16/wand.png",
		Default = true
	},

	{
		Label = "Create Mirrored Keypads",
		Value = "mirror_keypads",
		Icon = "icon16/page_white_copy.png",
		Default = true
	},

	{
		Label = "Administration",
		Value = "administration",
		Icon = "icon16/shield.png",

		{
			{
				Label = "Keypad Logos/Images",
				Value = "custom_img",
				Icon = "icon16/picture.png",

				{
					{
						Label = "Ban/Unban Players from Feature",
						Value = "ban",
						Icon = "icon16/group_key.png",
						Tip = "Allow this group to ban/unban players from uploading custom keypad images to their keypads?"
					},

					{
						Label = "Remove Keypad Images",
						Value = "remove",
						Icon = "icon16/delete.png",
						Tip = "Allow this group to remove keypad images from keypads?"
					},
				}
			}
		}
	},

	{
		Label = "Notifications",
		Value = "notifications",
		Icon = "icon16/error.png",

		{
			{
				Label   = "Access Granted",
				Value   = "access_granted",
				Icon    = "icon16/flag_green.png",
				Tip     = "Allow this group to receive \"Access Granted\" notifications?",
				Default = true
			},

			{
				Label   = "Access Denied",
				Value   = "access_denied",
				Icon    = "icon16/flag_red.png",
				Tip     = "Allow this group to receive \"Access Denied\" notifications?",
				Default = true
			},
		}
	},

	{
		Label = "Tools",
		Value = "tools",
		Icon = "icon16/wrench.png",

		{
			{
				Label = "Use Admin Tool",
				Value = "admin_tool",
				Icon = "icon16/wand.png",
				Tip = "Allow the use of the admin tool (access logs, door link checker, fading door link checker, keypad link checker, etc.)?"
			},

			{
				Label = "Use Keypad Breaker Tool",
				Value = "keypad_breaker",
				Icon = "icon16/bomb.png",
				Tip = "Allow the use of the keypad breaker tool?"
			},
		}
	},

	{
		Label = "Keypad Settings",
		Value = "keypads",
		Icon = "icon16/calculator.png",

		{
			{
				Label = "Bypass \"Keypads Only On Fading Doors\"",
				Value = "bypass_keypad_only_fading_doors",
				Icon = "icon16/map.png",
				Tip = "Allow this group to bypass the \"Keypads Only On Fading Doors\" setting?",
			},

			{
				Label = "Use Custom Lua Functions",
				Value = "custom_lua_functions",
				Icon = "icon16/script_code.png",
				Tip = "Allow this group to whitelist/blacklist access via custom Lua functions (that you defined in bkeypads_custom_access.lua) on their keypads?",
				Default = true
			},

			{
				Label = "Create Uncrackable Keypads",
				Value = "uncrackable_keypads",
				Icon = "icon16/shield.png",
				Tip = "Allow this group to create keypads that can't be cracked by a keypad cracker?"
			},

			{
				Label = "Keypad Payments",
				Value = "payments",
				Icon = "icon16/money.png",
				Tip = "Allow this group to create keypads which charge money for use?",
				Default = true
			},

			{
				Label = "Wiremod",
				Value = "wiremod",
				Icon = "icon16/wrench_orange.png",
				Tip = "Allow this group to create keypads which have Wiremod outputs?",
				Default = true
			},

			{
				Label = "Keyboard Button Simulation",
				Value = "keyboard_button_simulation",
				Icon = "icon16/keyboard.png",
				Tip = "Allow this group to create keypads which simulate pressing keys on their keyboard?"
			},

			{
				Label = "Create Unfrozen Keypads",
				Value = "unfrozen_keypads",
				Icon = "icon16/weather_snow.png",
				Tip = "Allow this group to unfreeze their keypads?",
				Default = true
			},

			{
				Label = "Create Unwelded Keypads",
				Value = "unwelded_keypads",
				Icon = "icon16/link_break.png",
				Tip = "Allow this group to unweld their keypads? If not, any keypads they create will be welded.",
				Default = true,
			},

			{
				Label = "Create Collidable Keypads",
				Value = "collidable_keypads",
				Icon = "icon16/collision_on.png",
				Tip = "Allow this group to create collidable keypads? If not, any keypads they create will be no-collided.",
				Default = true,
			},

			{
				Label = "Keypad Appearance",
				Value = "appearance",
				Icon = "icon16/palette.png",

				{
					{
						Label = "Use custom image/logo",
						Value = "custom_img",
						Icon = "icon16/picture.png",
						Tip = "Allow this group to use a custom image on their keypads?",
						Default = true
					},

					{
						Label = "Change background color",
						Value = "bg_color",
						Icon = "icon16/color_wheel.png",
						Tip = "Allow this group to change the background color of their keypads?",
						Default = true
					},

					{
						Label = "RAINBOW BACKGROUND COLOR",
						Value = "rainbows",
						Icon = "icon16/rainbow.png",
						Tip = "RAINBOWS HELL YEAH"
					},
				}
			},
		}
	},

	{
		Label = "Persistence",
		Value = "persistence",
		Icon = "icon16/world.png",

		{
			{
				Label = "Manage persistent keycards",
				Value = "manage_persistent_keycards",
				Tip = "Create, modify and destroy persistent keycards",
				Icon = "icon16/vcard.png",
			},

			{
				Label = "Manage persistent keypads",
				Value = "manage_persistent_keypads",
				Tip = "Create, modify and destroy persistent keypads",
				Icon = "icon16/star.png",
			},

			{
				Label = "Switch keypad persistence profile",
				Value = "switch_profile",
				Tip = "Switch between other keypad layouts & configurations (profiles) for the map on the fly",
				Icon = "icon16/disk.png",
			},

			{
				Label = "Manage persistent keypad profiles",
				Value = "manage_profiles",
				Tip = "Create or delete keypad persistence profiles",
				Icon = "icon16/wand.png",
			},
		}
	},

	{
		Label = "Linking",
		Value = "linking",
		Icon = "icon16/link.png",

		{
			{
				Label = "Link keypads",
				Value = "link_keypads",
				Icon = "icon16/calculator.png",
				Tip = "Allow this group to link their keypads together?",
				Default = true
			},

			{
				Label = "Link to doors",
				Value = "doors",
				Icon = "icon16/door_in.png",
				Tip = "Allow this group to link their keypads to map doors?"
			},

			{
				Label = "[DarkRP] Link to owned doors",
				Value = "darkrp_doors",
				Icon = "icon16/door_in.png",
				Tip = "Allow this group to link their keypads to OWNED map doors?",
				Default = true
			},

			{
				Label = "[DarkRP] Prevent Lockpick links",
				Value = "darkrp_prevent_lockpick",
				Icon = "icon16/lock_break.png",
				Tip = "Allow this group to prevent lockpicking on linked map doors?",
			},

			{
				Label = "Link to buttons",
				Value = "buttons",
				Icon = "icon16/control_eject.png",
				Tip = "Allow this group to link their keypads to map buttons?",
			},

			{
				Label = "Link to Gmod Sandbox buttons",
				Value = "gmod_button",
				Icon = "icon16/control_eject_blue.png",
				Tip = "Allow this group to link their keypads to Sandbox's buttons (spawned with the Button tool)?",
				Default = true
			},

			{
				Label = "Pseudolinking",
				Value = "pseudolink",
				Icon = "icon16/script_code.png",
				Tip = "Allow this group to create pseudolinks?"
			},

			{
				Label = "Disable Map Objects",
				Value = "disable_map_objects",
				Icon = "icon16/cross.png",
				Tip = "Allow this group to disable map objects? (Disabling buttons, keeping doors locked, etc.)"
			},

			{
				Label = "Redirect +use",
				Value = "redirect_use",
				Icon = "icon16/arrow_undo.png",
				Tip = "Allow this group to redirect +use on map links?"
			},

			{
				Label = "Hide Map Object",
				Value = "hide_map_object",
				Icon = "icon16/lightbulb_off.png",
				Tip = "Allow this group to hide map objects to prevent them from rendering?",
			},

			{
				Label = "Bypass Maximum Linking Distance",
				Value = "max_distance",
				Icon = "icon16/chart_curve.png",
				Tip = "Allow this group to bypass the maximum linking distance set in the config?",
			},
		}
	},

	{
		Label = "Access Methods",
		Icon = "icon16/shield_go.png",
		Value = "access_methods",

		{
			{
				Label = "PIN",
				Value = "pin",
				Icon = "icon16/calculator.png",
				Tip = "Allow this group to create keypads which require a PIN code for access?",
				Default = true
			},

			{
				Label = "Face Scanning (FaceID)",
				Value = "faceid",
				Icon = "icon16/camera.png",
				Tip = "Allow this group to create keypads which require a facial scan for access?",
				Default = true
			},

			{
				Label = "Keycard",
				Value = "keycard",
				Icon = "icon16/vcard.png",
				Tip = "Allow this group to create keypads which require a keycard for access?",
				Default = true
			},
		}
	},

	{
		Label = "Fading Doors",
		Value = "fading_doors",
		Icon = "icon16/door_open.png",

		{
			{
				Label = "Create Fading Doors",
				Value = "create",
				Icon = "icon16/door.png",
				Tip = "Allow this group to create fading doors?",
				Default = true
			},

			{
				Label = "Fading Door Sounds",
				Value = "sounds",
				Icon = "icon16/sound.png",
				Tip = "Allow this group to create fading doors which emit sounds?",
				Default = true
			},

			{
				Label = "Freeze to Cancel Fade",
				Value = "freeze_cancel",
				Icon = "icon16/door_out.png",
				Tip = "Allow this group to cancel a fading door's fade when picked up & frozen using their physgun?",
				Default = true
			},

			{
				Label = "Open with Keyboard",
				Value = "keyboard",
				Icon = "icon16/keyboard.png",
				Tip = "Allow this group to open their fading doors via keyboard buttons? (This can be disabled completely in the config)",
				Default = true
			},
		}
	},

	{
		Label = "Keycards",
		Value = "keycards",
		Icon = "icon16/vcard.png",

		{
			{
				Label = "Drop Keycards",
				Value = "drop",
				Icon = "icon16/arrow_down.png",
				Tip = "Allow this group to drop keycards they've picked up?",
				Default = true
			},

			{
				Label = "Drop Loadout Keycard",
				Value = "drop_spawned",
				Icon = "icon16/box.png",
				Tip = "Allow this group to drop the keycard their team/job spawns with?",
				Default = true
			},
		}
	},

	{
		Label = "Destruction",
		Value = "destruction",
		Icon = "icon16/bomb.png",

		{
			{
				Label = "Create Indestructible Keypads",
				Value = "indestructible",
				Icon = "icon16/shield.png",
				Tip = "When keypad destruction is ENABLED, can this group create indestructible keypads?"
			},

			{
				Label = "Create Destructible Keypads",
				Value = "destructible",
				Icon = "icon16/bomb.png",
				Tip = "When keypad destruction is DISABLED, can this group create destructible keypads?"
			},

			{
				Label = "Override Destruction Config",
				Value = "override_config",
				Icon = "icon16/cog_edit.png",
				Tip = "Can this group override the health and shield of keypads they spawn?"
			},
		}
	}
}

--## Build Tree ##--

bKeypads.Permissions.Tree = {}
do
	local function step(id, registry)
		for _, permission in ipairs(registry) do
			local id = (id and (id .. "/") or "") .. permission.Value
			bKeypads.Permissions.Tree[id] = permission
			if permission[1] then
				step(id, permission[1])
			end
		end
	end
	step(nil, bKeypads.Permissions.Registry, bKeypads.Permissions.Tree)
end

--## Interface ##--

do
	local permissionsCache = {}

	function bKeypads.Permissions:Cached(ply, permission_id)
		assert(bKeypads.Permissions.Tree[permission_id] ~= nil, "Permission \"" .. permission_id .. "\" does not exist!")
		if OpenPermissions and OpenPermissions.HasPermission then
			if not permissionsCache[ply] or not permissionsCache[ply][permission_id] or SysTime() >= permissionsCache[ply][permission_id].Expires then
				return bKeypads.Permissions:Check(ply, permission_id)
			end
			return permissionsCache[ply][permission_id].Result
		else
			return bKeypads.Permissions:Check(ply, permission_id)
		end
	end

	function bKeypads.Permissions:Check(ply, permission_id)
		assert(bKeypads.Permissions.Tree[permission_id] ~= nil, "Permission \"" .. permission_id .. "\" does not exist!")
		if OpenPermissions and OpenPermissions.HasPermission then
			if not permissionsCache[ply] then permissionsCache[ply] = {} end

			local cache = {
				Expires = SysTime() + 1,
				Result  = OpenPermissions:HasPermission(ply, "bkeypads/" .. permission_id)
			}
			permissionsCache[ply][permission_id] = cache

			return cache.Result
		else
			return ply:IsSuperAdmin() or bKeypads.Permissions.Tree[permission_id].Default == true
		end
	end
end

--## OpenPermissions Support ##--

if SERVER then
	local function bKeypads_Init()
		bKeypads.OpenPermissions = OpenPermissions:RegisterAddon("bkeypads", {
			Name  = "Billy's Keypads",
			Color = Color(0,150,255),
			Icon  = "icon16/calculator.png",
			Logo = {
				Path = "bkeypads/logo_wide_white.png",
				Width = 335,
				Height = 128
			}
		})

		local function step(tree, registry)
			for _, permission in ipairs(registry) do
				local branch = tree:AddToTree({
					Value = permission.Value,
					Label = permission.Label,
					Icon = permission.Icon,
					Tip = permission.Tip,
					Default = (permission.Default == true and OpenPermissions.CHECKBOX.TICKED) or (permission.Default == false and OpenPermissions.CHECKBOX.CROSSED) or nil,
				})
				if permission[1] then
					step(branch, permission[1])
				end
			end
		end
		step(bKeypads.OpenPermissions, bKeypads.Permissions.Registry)
	end

	local function OpenPermissions_Init()
		hook.Remove("OpenPermissions:Ready", "bKeypads.OpenPermissions")
		if bKeypads_Ready == true then
			bKeypads_Init()
		else
			hook.Add("bKeypads.Ready", "bKeypads.OpenPermissions", bKeypads_Init)
		end
	end
	if OpenPermissions_Ready == true then
		OpenPermissions_Init()
	else
		hook.Add("OpenPermissions:Ready", "bKeypads.OpenPermissions", OpenPermissions_Init)
	end
end

--## CanTool ##--

local checkFunc = SERVER and bKeypads.Permissions.Check or bKeypads.Permissions.Cached

function bKeypads.CanTool(ply, tr, tool)
	if IsValid(tr.Entity) and tr.Entity.bKeypad then
		if tool == "bkeypads_breaker" then
			return checkFunc(bKeypads.Permissions, ply, "tools/keypad_breaker")
		elseif tool == "bkeypads_admin_tool" then
			return checkFunc(bKeypads.Permissions, ply, "tools/admin_tool")
		elseif tool == "bkeypads_persistence" then
			return checkFunc(bKeypads.Permissions, ply, "persistence/manage_persistent_keypads") or checkFunc(bKeypads.Permissions, ply, "persistence/manage_persistent_keycards")
		end
	elseif tool == "bkeypads_linker" then
		local toolObj = ply:GetTool(tool)
		if not toolObj then return end
		if toolObj.MapLinking and IsValid(toolObj.TargetEnt) then
			if bKeypads.MapLinking:IsDoor(toolObj.TargetEnt) then
				if checkFunc(bKeypads.Permissions, ply, "linking/doors") or (DarkRP and toolObj.TargetEnt.isKeysOwnedBy and checkFunc(bKeypads.Permissions, ply, "linking/darkrp_doors") and toolObj.TargetEnt:isKeysOwnedBy(ply)) then
					return true
				end
			elseif bKeypads.MapLinking:IsMapButton(toolObj.TargetEnt) then
				return checkFunc(bKeypads.Permissions, ply, "linking/buttons")
			end
		end
	end
end

bKeypads_gamemode_Call = bKeypads_gamemode_Call or gamemode.Call
gamemode.Call = function(event, ...)
	if event == "CanTool" then
		local r = bKeypads.CanTool(...)
		if r ~= nil then return r end
	end
	return bKeypads_gamemode_Call(event, ...)
end