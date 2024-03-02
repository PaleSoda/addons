escore.commands = escore.commands or {}
escore.commands.user = {}
escore.commands.admin = {}

local userCMD = escore.commands.user
userCMD.OpenProfile = function(cmdPly)
    cmdPly:ShowProfile()
end
userCMD.CopyName = function(cmdPly)
    SetClipboardText(cmdPly:Name())
end
userCMD.CopySteamID = function(cmdPly)
    SetClipboardText(cmdPly:SteamID())
end

local AdminCMD = escore.commands.admin



-----------
/// ULX ///
-----------
AdminCMD["ulx"] = {}
AdminCMD["ulx"].Goto = function(cmdPly)
    RunConsoleCommand("ulx", "goto", cmdPly:Nick())
end

AdminCMD["ulx"].Bring = function(cmdPly)
    RunConsoleCommand("ulx", "bring", cmdPly:Nick())
end

AdminCMD["ulx"].Freeze = function(cmdPly)
    RunConsoleCommand("ulx", "bring", cmdPly:Nick())
    RunConsoleCommand("ulx", "freeze", cmdPly:Nick())
end

AdminCMD["ulx"].Unfreeze = function(cmdPly)
    RunConsoleCommand("ulx", "unfreeze", cmdPly:Nick())
end

AdminCMD["ulx"].Return = function(cmdPly)
    RunConsoleCommand("ulx", "return", cmdPly:Nick())
end

AdminCMD["ulx"].Spectate = function(cmdPly)
    RunConsoleCommand("ulx", "spectate", cmdPly:Nick())
end

AdminCMD["ulx"].Kick = function(cmdPly, reason)
    RunConsoleCommand("ulx", "kick", cmdPly:Nick(), reason)
end



-----------
/// SAM ///
-----------
AdminCMD["sam"] = {}
AdminCMD["sam"].Goto = function(cmdPly)
    RunConsoleCommand("sam", "goto", cmdPly:Nick())
end

AdminCMD["sam"].Bring = function(cmdPly)
    RunConsoleCommand("sam", "bring", cmdPly:Nick())
end

AdminCMD["sam"].Freeze = function(cmdPly)
    RunConsoleCommand("sam", "bring", cmdPly:Nick())
    RunConsoleCommand("sam", "freeze", cmdPly:Nick())
end

AdminCMD["sam"].Unfreeze = function(cmdPly)
    RunConsoleCommand("sam", "unfreeze", cmdPly:Nick())
end

AdminCMD["sam"].Return = function(cmdPly)
    RunConsoleCommand("sam", "return", cmdPly:Nick())
end

AdminCMD["sam"].Spectate = function(cmdPly)
    RunConsoleCommand("sam", "spectate", cmdPly:Nick())
end

AdminCMD["sam"].Kick = function(cmdPly, reason)
    RunConsoleCommand("sam", "kick", cmdPly:Nick(), reason)
end



--------------
/// FADMIN ///
--------------
AdminCMD["fadmin"] = {}
AdminCMD["fadmin"].Goto = function(cmdPly)
    RunConsoleCommand("fadmin", "goto", cmdPly:UserID())
end

AdminCMD["fadmin"].Bring = function(cmdPly)
    RunConsoleCommand("fadmin", "bring", cmdPly:UserID())
end

AdminCMD["fadmin"].Freeze = function(cmdPly)
    RunConsoleCommand("fadmin", "bring", cmdPly:UserID())
    RunConsoleCommand("fadmin", "freeze", cmdPly:UserID())
end

AdminCMD["fadmin"].Unfreeze = function(cmdPly)
    RunConsoleCommand("fadmin", "unfreeze", cmdPly:UserID())
end

AdminCMD["fadmin"].Spectate = function(cmdPly)
    RunConsoleCommand("FSpectate", cmdPly:UserID())
end

AdminCMD["fadmin"].Kick = function(cmdPly, reason)
    RunConsoleCommand("fadmin", "kick", cmdPly:UserID(), reason)
end



-------------------
/// SERVERGUARD ///
-------------------
AdminCMD["serverguard"] = {}
AdminCMD["serverguard"].Goto = function(cmdPly)
    RunConsoleCommand("sg", "goto", cmdPly:Nick())
end

AdminCMD["serverguard"].Bring = function(cmdPly)
    RunConsoleCommand("sg", "bring", cmdPly:Nick())
end

AdminCMD["serverguard"].Freeze = function(cmdPly)
    RunConsoleCommand("sg", "bring", cmdPly:Nick())
    RunConsoleCommand("sg", "freeze", cmdPly:Nick())
end

AdminCMD["serverguard"].Unfreeze = function(cmdPly)
    RunConsoleCommand("sg", "unfreeze", cmdPly:Nick())
end

AdminCMD["serverguard"].Return = function(cmdPly)
    RunConsoleCommand("sg", "return", cmdPly:Nick())
end

AdminCMD["serverguard"].Spectate = function(cmdPly)
    RunConsoleCommand("sg", "spectate", cmdPly:Nick())
end

AdminCMD["serverguard"].Kick = function(cmdPly, reason)
    RunConsoleCommand("sg", "kick", cmdPly:Nick(), reason)
end



------------------
/// XADMIN 2.0 ///
------------------
AdminCMD["xadmin2"] = {}
AdminCMD["xadmin2"].Goto = function(cmdPly)
    RunConsoleCommand("xadmin", "goto", cmdPly:Nick())
end

AdminCMD["xadmin2"].Bring = function(cmdPly)
    RunConsoleCommand("xadmin", "bring", cmdPly:Nick())
end

AdminCMD["xadmin2"].Freeze = function(cmdPly)
    RunConsoleCommand("xadmin", "bring", cmdPly:Nick())
    RunConsoleCommand("xadmin", "freeze", cmdPly:Nick())
end

AdminCMD["xadmin2"].Unfreeze = function(cmdPly)
    RunConsoleCommand("xadmin", "unfreeze", cmdPly:Nick())
end

AdminCMD["xadmin2"].Return = function(cmdPly)
    RunConsoleCommand("xadmin", "return", cmdPly:Nick())
end

AdminCMD["xadmin2"].Spectate = function(cmdPly)
    RunConsoleCommand("xadmin", "spectate", cmdPly:Nick())
end

AdminCMD["xadmin2"].Kick = function(cmdPly, reason)
    RunConsoleCommand("xadmin", "kick", cmdPly:Nick(), reason)
end



------------------
/// XADMIN 1.0 ///
------------------
AdminCMD["xadmin"] = {}
AdminCMD["xadmin"].Goto = function(cmdPly)
    RunConsoleCommand("xadmin_goto", "goto", cmdPly:Nick())
end

AdminCMD["xadmin"].Bring = function(cmdPly)
    RunConsoleCommand("xadmin_bring", "bring", cmdPly:Nick())
end

AdminCMD["xadmin"].Freeze = function(cmdPly)
    RunConsoleCommand("xadmin_bring", "bring", cmdPly:Nick())
    RunConsoleCommand("xadmin_freeze", "freeze", cmdPly:Nick())
end

AdminCMD["xadmin"].Unfreeze = function(cmdPly)
    RunConsoleCommand("xadmin_unfreeze", "unfreeze", cmdPly:Nick())
end

AdminCMD["xadmin"].Return = function(cmdPly)
    RunConsoleCommand("xadmin_return", "return", cmdPly:Nick())
end

AdminCMD["xadmin"].Spectate = function(cmdPly)
    RunConsoleCommand("xadmin_spectate", "spectate", cmdPly:Nick())
end

AdminCMD["xadmin"].Kick = function(cmdPly, reason)
    RunConsoleCommand("xadmin_kick", "kick", cmdPly:Nick(), reason)
end

--------------
/// sAdmin ///
--------------
AdminCMD["sadmin"] = {}
AdminCMD["sadmin"].Goto = function(cmdPly)
    RunConsoleCommand("sa", "goto", cmdPly:Nick())
end

AdminCMD["sadmin"].Bring = function(cmdPly)
    RunConsoleCommand("sa", "bring", cmdPly:Nick())
end

AdminCMD["sadmin"].Freeze = function(cmdPly)
    RunConsoleCommand("sa", "bring", cmdPly:Nick())
    RunConsoleCommand("sa", "freeze", cmdPly:Nick())
end

AdminCMD["sadmin"].Unfreeze = function(cmdPly)
    RunConsoleCommand("sa", "unfreeze", cmdPly:Nick())
end

AdminCMD["sadmin"].Return = function(cmdPly)
    RunConsoleCommand("sa", "return", cmdPly:Nick())
end

AdminCMD["sadmin"].Kick = function(cmdPly, reason)
    RunConsoleCommand("sa", "kick", cmdPly:Nick(), reason)
end