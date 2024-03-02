if (not GAS_JobWhitelist_DarkRPReady) then
	if (ezJobs) then
		GAS:print("[JobWhitelist] Waiting for ezJobs...")
		GAS:hook("ezJobsLoaded","jobwhitelist:ezJobs",function()
			GAS:print("[JobWhitelist] ezJobs Ready", GAS_PRINT_COLOR_GOOD)
			GAS_JobWhitelist_DarkRPReady = true
			hook.Run("gmodadminsuite:jobwhitelist:DarkRPReady")
		end)
	elseif (DConfig) then
		GAS:print("[JobWhitelist] Waiting for DConfig...")
		GAS:hook("DConfigDataLoaded","jobwhitelist:DConfig",function()
			GAS:print("[JobWhitelist] DConfig Ready", GAS_PRINT_COLOR_GOOD)
			GAS_JobWhitelist_DarkRPReady = true
			hook.Run("gmodadminsuite:jobwhitelist:DarkRPReady")
		end)
	else
		GAS:print("[JobWhitelist] Waiting for DarkRP...")
		GAS:hook("loadCustomDarkRPItems","jobwhitelist:loadCustomDarkRPItems",function()
			GAS:print("[JobWhitelist] DarkRP Ready", GAS_PRINT_COLOR_GOOD)
			GAS_JobWhitelist_DarkRPReady = true
			hook.Run("gmodadminsuite:jobwhitelist:DarkRPReady")
		end)
	end
end