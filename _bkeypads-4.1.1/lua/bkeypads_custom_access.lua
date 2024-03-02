bKeypads.CustomAccess:Reset() --[[ Don't delete this line

                  ___          _                      ___
                 / __\   _ ___| |_ ___  _ __ ___     / _ \_ __ ___  _   _ _ __  ___
                / / | | | / __| __/ _ \| '_ ` _ \   / /_\/ '__/ _ \| | | | '_ \/ __|
               / /__| |_| \__ \ || (_) | | | | | | / /_\\| | | (_) | |_| | |_) \__ \
               \____/\__,_|___/\__\___/|_| |_| |_| \____/|_|  \___/ \__,_| .__/|___/
                                                                         |_|

In this file you can define custom groups of teams and custom Lua functions which players can use
to authorize people on their keypads.

Some basic knowledge of Lua syntax is required.

By the way, in case you didn't know, DarkRP jobs are the same thing as teams.

====================================================================================================

                             __                           _
                            /__\_  ____ _ _ __ ___  _ __ | | ___  ___
                           /_\ \ \/ / _` | '_ ` _ \| '_ \| |/ _ \/ __|
                          //__  >  < (_| | | | | | | |_) | |  __/\__ \
                          \__/ /_/\_\__,_|_| |_| |_| .__/|_|\___||___/
                                                   |_|

Example 1
=========
This example defines a TEAM GROUP which represents all law enforcement teams.

bKeypads:AddTeamGroup("Law Enforcement", {
	TEAM_POLICE,
	TEAM_CHIEF,
	TEAM_MAYOR,
})

Example 2
=========
This example defines a TEAM GROUP which represents all hospital workers.

bKeypads:AddTeamGroup("Hospital Staff", {
	TEAM_PARAMEDIC,
	TEAM_DOCTOR,
	TEAM_NURSE,
	TEAM_COLONOSCOPIST,
})

Example 3
=========
This example defines a LUA FUNCTION which returns whether the player has law enforcement
permissions on DarkRP.

This is basically Example 1, but using a Lua function instead.

bKeypads:AddCustomGroup("Police", function(keypad, ply, keycard)
	-- Note: keycard only exists if the keypad is scanning one
	return ply:isCP()
end)

Example 4
=========
This example defines a TEAM GROUP which represents all Class B personnel on SCP-RP.

bKeypads:AddTeamGroup("Class B", {
	TEAM_RESEARCHER,
	TEAM_SECURITY,
	TEAM_MTF,
	TEAM_MTF_COMMANDER,
	TEAM_O5,
	TEAM_FIELD_AGENT,
})

Yes I'm aware that I've probably spectacularly fucked up the lore there, but it's just an example :D

Example 5
=========
This example defines a LUA FUNCTION which returns whether a player has an SCP keycard whose level falls in a certain range.

This example would obviously only work if you've written a custom SCP keycard system for your server or are using a Workshop addon
or similar which exposes some custom Lua functions. PLAYER:GetSCPKeycardLevel() is a completely arbritrary example.

bKeypads:AddCustomGroup("Level 3", function(keypad, ply, keycard)
	-- Note: keycard only exists if the keypad is scanning one
	return ply:GetSCPKeycardLevel() >= 3
end)

====================================================================================================
                                      WRITE CODE BELOW THESE LINES
====================================================================================================]]

