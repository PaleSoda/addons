if (SERVER) then

	csitsystem = {}

	function csitsystem.HandOver(admin, ply, target)
		if (not IsValid(admin)) then
			return false, "Invalid admin!"
		elseif (not OpenPermissions:HasPermission(admin, "gmodadminsuite_adminsits/create_sits")) then
			return false, "You do not have permission to create sits!"
		elseif (not IsValid(ply)) then
			return false, "Invalid player!"
		elseif (GAS.AdminSits:IsInSit(admin)) then
			return false, "You are already in a sit!"
		elseif (GAS.AdminSits:IsInSit(ply)) then
			return false, ply:Nick() .. " is already in a sit!"
		elseif (IsValid(target) and GAS.AdminSits:IsInSit(target)) then
			return false, target:Nick() .. " is already in a sit!"
		end

		local sitPlayers = { admin }
		if not GAS.AdminSits:IsStaff(ply) and ply ~= admin then
			table.insert(sitPlayers, ply)
		end
		if IsValid(target) and not GAS.AdminSits:IsStaff(target) and target ~= admin then
			table.insert(sitPlayers, target)
		end

		local sit = GAS.AdminSits:CreateSit(admin, sitPlayers)
		if (admin ~= ply and GAS.AdminSits:IsStaff(ply)) then
			GAS.AdminSits:InviteStaffToSit(ply, sit, admin)
		end
		if (IsValid(target) and admin ~= target and GAS.AdminSits:IsStaff(target)) then
			GAS.AdminSits:InviteStaffToSit(target, sit, admin)
		end
		return sit
	end

	function csitsystem.EndSit(id)
		GAS.AdminSits:EndSit(id)
	end

else

	sitsys = true

end