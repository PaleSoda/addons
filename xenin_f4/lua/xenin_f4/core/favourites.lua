function F4Menu:GetRecentJobs()
	return self.RecentJobs or {}
end

function F4Menu:SetRecentJobs(tbl)
	self.RecentJobs = tbl
end

function F4Menu:AddRecentJob(job)
	self.RecentJobs = self.RecentJobs or {}

	for i, v in ipairs(self.RecentJobs) do
		local currJob = RPExtraTeams[v]
		local newJob = RPExtraTeams[job]
		if (!currJob or !newJob) then continue end

		if (currJob.name == newJob.name) then return end
	end

	if (#self.RecentJobs == 4) then
		table.remove(self.RecentJobs, 1)
	end

	table.insert(self.RecentJobs, job)
end

hook.Add("OnPlayerChangedTeam", "F4Menu.RecentJobs", function(ply, old, new)
	F4Menu:AddRecentJob(old)

	hook.Run("F4Menu.RecentChanged", old)
end)

function F4Menu:GetFavouriteJobs()
	return self:GetFavourites("job") or {}
end

function F4Menu:RemoveFavouriteJob(job)
	F4Menu:RemoveFavourite("job", job)
end

function F4Menu:AddFavouriteJob(job)
	F4Menu:SaveFavourite("job", job)
end

function F4Menu:RemoveFavourite(type, name)
	if (!self.favourites[type]) then
		self.favourites[type] = {}
	end

	table.RemoveByValue(self.favourites[type], name)

	F4Menu.Network:sendRemoveFavourite(type, name)
end

function F4Menu:SaveFavourite(type, name)
	if (!self.favourites[type]) then
		self.favourites[type] = {}
	end

	table.insert(self.favourites[type], name)

	F4Menu.Network:sendSaveFavourite(type, name)
end

function F4Menu:SetFavourites(tbl)
	self.favourites = tbl
end

function F4Menu:GetFavourites(type)
	self.favourites = self.favourites || {}

	if type then
		return self.favourites[type] or {}
	end

	return self.favourites
end
