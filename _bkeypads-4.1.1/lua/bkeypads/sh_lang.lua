if SERVER then
	for _, f in ipairs((file.Find("bkeypads/lang/*.lua", "LUA"))) do
		AddCSLuaFile("bkeypads/lang/" .. f)
	end
else
	local raw = CreateClientConVar("bkeypads_lang_raw", "0", false, false, "Disables language string translations, only showing raw phrases.", 0, 1):GetBool()
	local dump_strings = CreateClientConVar("bkeypads_lang_debug", "0", false, false, "Prints language strings to console as they are interpolated.", 0, 1):GetBool()
	local dump_traces = CreateClientConVar("bkeypads_lang_traces", "0", false, false, "Prints stack traces to console when language strings are interpolated.", 0, 1):GetBool()

	local function InjectGmodLangPhrases()
		for key, _val in pairs(bKeypads.LANG.English.Phrases) do
			local val = bKeypads.LANG.Phrases[key] or _val
			if key:StartWith("tool.") then
				language.Add(key, raw and key or val)
			elseif key:StartWith("Undo_") or key:StartWith("Undone_") then
				language.Add(key, raw and key or val)
			else
				language.Add("bKeypads_" .. key, raw and key or val)
			end
		end
	end

	cvars.AddChangeCallback("bkeypads_lang_raw", function(_, __, val)
		raw = tobool(val)
		InjectGmodLangPhrases()
	end)
	cvars.AddChangeCallback("bkeypads_lang_debug", function(_, __, val)
		dump_strings = tobool(val)
	end)
	cvars.AddChangeCallback("bkeypads_lang_traces", function(_, __, val)
		dump_traces = tobool(val)
	end)

	bKeypads.LANG = {}
	bKeypads.LANG.English = include("bkeypads/lang/english.lua")
	bKeypads.LANG.Metadata = bKeypads.LANG.English

	local warned_untranslated = {}
	local function warn_untranslated(phrase, return_val)
		if not warned_untranslated[phrase] then
			warned_untranslated[phrase] = true
			bKeypads:print("[" .. bKeypads.LANG.Metadata.Name .. "] WARNING: Untranslated string \"" .. phrase .. "\"!", bKeypads.PRINT_TYPE_BAD, "LANG")
			--debug.Trace()
		end
		return return_val
	end

	function bKeypads.L(phrase)
		if raw then
			return phrase
		else
			local interpolated = bKeypads.LANG.Phrases[phrase] or warn_untranslated(phrase, bKeypads.LANG.English.Phrases[phrase] or phrase)
			if dump_strings or dump_traces then
				bKeypads:print(phrase, bKeypads.PRINT_TYPE_NEUTRAL, "LANG")
				if dump_strings then
					bKeypads:print((interpolated:gsub("\n", "\\n")) .. (dump_traces and "" or "\n"), bKeypads.PRINT_TYPE_NEUTRAL, "LANG")
				end
				if dump_traces then
					debug.Trace()
				end
			end
			return interpolated
		end
	end

	function bKeypads._L(phrase)
		if raw then
			return phrase
		else
			if not bKeypads.LANG.Phrases[phrase] and not bKeypads.LANG.English.Phrases[phrase] and not warned_untranslated[phrase] then
				warned_untranslated[phrase] = true
				bKeypads:print("[" .. bKeypads.LANG.Metadata.Name .. "] WARNING: Untranslated string \"" .. phrase .. "\"!", bKeypads.PRINT_TYPE_BAD, "LANG")
				debug.Trace()
			elseif dump_strings or dump_traces then
				bKeypads.L(phrase)
			end
			return "#bKeypads_" .. phrase
		end
	end

	local gmod_lang_mapping = include("bkeypads/lang/_gmod_langs.lua")
	local function SelectLanguage(gmod_language)
		bKeypads.LANG.Metadata = nil
		bKeypads.LANG.Phrases = nil

		local active_language = gmod_lang_mapping[GetConVar("gmod_language"):GetString()] or gmod_lang_mapping["en"]
		if active_language ~= "english" and file.Exists("bkeypads/lang/" .. active_language .. ".lua", "LUA") then
			local success, metadata = pcall(include, "bkeypads/lang/" .. active_language .. ".lua")
			if success then
				bKeypads.LANG.Metadata = metadata or bKeypads.LANG.English
				bKeypads.LANG.Phrases = (metadata or {}).Phrases or bKeypads.LANG.English.Phrases
			else
				ErrorNoHalt("Error in Billy's Keypads language file: bkeypads/lang/" .. active_language .. ".lua\n")
				ErrorNoHalt(metadata .. "\n")
				debug.Trace()
			end
		end

		if not bKeypads.LANG.Metadata or not bKeypads.LANG.Phrases then
			bKeypads.LANG.Metadata = bKeypads.LANG.English
			bKeypads.LANG.Phrases = bKeypads.LANG.English.Phrases
		end

		InjectGmodLangPhrases()

		hook.Run("bKeypads.LanguageChanged")
	end

	cvars.AddChangeCallback("gmod_language", function(_,__,lang)
		SelectLanguage(lang)
	end, "bKeypads_gmod_language")

	SelectLanguage(GetConVar("gmod_language"):GetString() or "en")

	--## Language Functions ##--

	function bKeypads:FormatTimeDelta(time, unix)
		local delta = time - unix
		if delta < 60 then
			return bKeypads.L(delta == 1 and "s_second" or "s_seconds"):format(delta)
		elseif delta < 3600 then
			local min = math.Round(delta / 60)
			return bKeypads.L(min == 1 and "s_minute" or "s_minutes"):format(min)
		elseif delta < 86400 then
			local hour = math.Round(delta / 60 / 60)
			return bKeypads.L(hour == 1 and "s_hour" or "s_hours"):format(hour)
		else
			return os.date("%x %X", unix)
		end
	end
end