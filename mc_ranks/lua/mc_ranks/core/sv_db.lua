MRS.DB.Driver = {}
MRS.DB.Driver.Name = "SQLite"

function MRS.DB.Init()
	MsgC(Color(0, 255, 0), "[MRS] SQLite: Initializing...\n")

	MRS.DB.Query("CREATE TABLE IF NOT EXISTS mrs_player(id TEXT, value TEXT)")
	MRS.DB.Query("CREATE TABLE IF NOT EXISTS mrs_ranks(id TEXT, value TEXT)")

	MRS.DB.Query("SELECT * FROM mrs_ranks", function(result)
		if result ~= nil and #result > 0 then
			for _,data in ipairs(result) do
				MRS.Ranks[data.id] = util.JSONToTable(data.value)
			end
		end
	end)
end

function MRS.DB.Query(query, callback, errorcb)

	local result = sql.Query(query)

	if result == false then
		if errorcb ~= nil then
			errorcb(sql.LastError)
		else
			local sqlerror = sql.LastError()
			MsgC(Color(255, 0, 0), "[MRS] SQL Error: " .. sqlerror .. "\n")
		end
	else
		if callback ~= nil then
			callback(result)
		end
	end
end

function MRS.DB.Escape(str, nqts)
	return sql.SQLStr(str, nqts)
end

hook.Add("Initialize", "MRS.DB.Init", function()
	MRS.DB.Init()
end)

function MRS.SaveRanksData(id, data)
	id = MRS.DB.Escape(id)

	local json = MRS.DB.Escape(util.TableToJSON(data), true)

	MRS.DB.Query("DELETE FROM mrs_ranks WHERE id=" .. id, function()
		MRS.DB.Query("INSERT INTO mrs_ranks VALUES(" .. id .. ", '" .. json .. "')")
		MsgC(Color(0, 255, 0), "[MRS] SQLite: Rank group " .. id .. " updated\n")
	end)
end

function MRS.RemoveRanksData(id)
	id = MRS.DB.Escape(id)

	MRS.DB.Query("DELETE FROM mrs_ranks WHERE id=" .. id, function()
		MsgC(Color(0, 255, 0), "[MRS] SQLite: Rank group " .. id .. " removed\n")
	end)
end

function MRS.DB.GetPlayerData(sid)
	if not sid then return end
	sid = MRS.DB.Escape(sid)
	local data
	MRS.DB.Query("SELECT * FROM mrs_player WHERE id=" .. sid, function(result)
		if result ~= nil and #result > 0 then
			local tbl = util.JSONToTable(result[1].value)
			if tbl and istable(tbl) then
				data = tbl
			end
		end
	end)
	return data
end