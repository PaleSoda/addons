AddCSLuaFile()
--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]
MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading Localization Module\n" )


AWarn.Localization = {}
AWarn.Localization.Languages = {}
AWarn.Localization.LangCodes = {}

function AWarn.Localization:RegisterLanguage( langCode, langName )
	AWarn.Localization.Languages[ langCode ] = {}
	AWarn.Localization.LangCodes[ langCode ] = langName
end

function AWarn.Localization:AddDefinition( langCode, defID, text )
	AWarn.Localization.Languages[ langCode ][ defID ] = text
end

function AWarn.Localization:LookupDefinition( langCode, defID )
	local defString = "NOT SET"
	
	if AWarn.Localization.Languages[ langCode ] then
		if AWarn.Localization.Languages[ langCode ][ defID ] then
			defString = AWarn.Localization.Languages[ langCode ][ defID ]
		else 
			defString = self:LookupFallbackDefinition( defID )
		end
	else
		defString = self:LookupFallbackDefinition( defID )
	end
	return defString
end

function AWarn.Localization:LookupFallbackDefinition( defID )
	local defString = "NOT SET"
	if AWarn.Localization.Languages[ "EN-US" ] then
		if AWarn.Localization.Languages[ "EN-US" ][ defID ] then
			defString = AWarn.Localization.Languages[ "EN-US" ][ defID ]
		end
	end
	return defString	
end

function AWarn.Localization:GetTranslation( defID )
	local langCode = "EN-US"
	if SERVER then
		langCode = AWarn:GetOption( "awarn_server_language" )
	else
		langCode = AWarn.SelectedLanguage or "EN-US"
	end
	return AWarn.Localization:LookupDefinition( langCode, defID )
end

function AWarn.Localization:LoadLanguages()
	local foundFiles, foundDirs = file.Find( "localizations/*.lua", "LUA" )
	for k, v in pairs( foundFiles ) do
		include( "localizations/".. v )
		if SERVER then
			AddCSLuaFile( "localizations/".. v )
		end
	end
end
AWarn.Localization:LoadLanguages()



