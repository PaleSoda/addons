F4Menu.Database = {}
F4Menu.RichestPlayer = F4Menu.RichestPlayer or {}

function F4Menu.Database:GetConnection()
  return MySQLite
end

function F4Menu.Database:Tables()
  local conn = self:GetConnection()

  return XeninUI.Promises.all({
    XeninUI:InvokeSQL(conn, [[
      CREATE TABLE IF NOT EXISTS xenin_f4menu_activeplayers (
        sid BIGINT,
        lastLoggedIn BIGINT NOT NULL,
        PRIMARY KEY (sid)
      )
    ]], "F4Menu.ActivePlayers"),

    XeninUI:InvokeSQL(conn, [[
      CREATE TABLE IF NOT EXISTS xenin_f4menu_economysnapshots (
        time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        money VARCHAR(35) NOT NULL,
        PRIMARY KEY (time)
      )
    ]], "F4Menu.EconomySnapshots"),

    XeninUI:InvokeSQL(conn, [[
      CREATE TABLE IF NOT EXISTS xenin_f4menu_favourites (
        sid64 CHAR(21),
        type VARCHAR(32),
        key_name VARCHAR(127),
        PRIMARY KEY (sid64, key_name, type)
      )
    ]], "F4Menu.Favourites")
  })
end

function F4Menu.Database:SaveEconomySnapshot(money)
  local conn = self:GetConnection()
  local query = [[
    INSERT INTO xenin_f4menu_economysnapshots (money)
    VALUES (':money:')
  ]]
  query = query:Replace(":money:", money)

  return XeninUI:InvokeSQL(conn, query, "F4Menu.SaveEconomySnapshot." .. money)
end

function F4Menu.Database:GetEconomySnapshots(days)
  days = days or 7
  local conn = self:GetConnection()
  local isMySQL = conn.isMySQL()
  local offset = isMySQL and "INTERVAL " .. days .. " DAY" or (86400 * days)
  local time = isMySQL and "UNIX_TIMESTAMP(time)" or "strftime('%s', time)"
  local now = isMySQL and "now()" or "strftime('%s', 'now')"
  local query = [[
    SELECT money AS money, :time: AS time FROM xenin_f4menu_economysnapshots
    WHERE time >= :now: - :offset:
    ORDER BY time DESC
    LIMIT ]] .. days * 24
  query = query:Replace(":offset:", offset)
  query = query:Replace(":time:", time)
  query = query:Replace(":now:", now)

  local p = XeninUI:InvokeSQL(conn, query, "F4Menu.GetEconomySnapshots." .. days)
  p:next(function(result)
    F4Menu.EconomySnapshot = result
    F4Menu.Network:sendEconomySnapshot(player.GetAll())
  end)

  return p
end

function F4Menu.Database:GetRichestPlayer()
  local conn = self:GetConnection()
  local cfg = F4Menu.Config.TotalMoney
  local days = cfg.DaysSinceLastLogin

  local power = conn.isMySQL() and "POWER(2, 32)" or "4294967296"
  local query = [[
    SELECT CAST(d.uid AS CHAR) AS uid, d.rpname, d.wallet + :atm: AS wallet
    FROM darkrp_player AS d
    :join:
    WHERE d.uid >= :power:
      :and:
    ORDER BY wallet DESC
    LIMIT 1
  ]]
  query = query:Replace(":power:", power)

  local gbType = GlorifiedBanking and GlorifiedBanking.SQL.GetType()
  if (conn.isMySQL() and BATM and BATM.Config and BATM.Config.UseMySQL and cfg.IncludeBATM) then
    query = query:Replace(":atm:", [[
      IFNULL((
        SELECT SUBSTRING(accountinfo, 42, LENGTH(SUBSTRING_INDEX(accountinfo, ",", 2)) - 41) AS balance
        FROM batm_personal_accounts
        WHERE steamid = uid
        LIMIT 1
      ), 0)
    ]])
  elseif (SlownLS and SlownLS.ATM and SlownLS.ATM.SQL.useMysql == conn.isMySQL() and cfg.IncludeBATM) then
    query = query:Replace(":atm:", [[
      (
        IFNULL(
          (
            SELECT SUM(balance) AS balance 
            FROM slownls_atm_accounts
            WHERE steamid = uid
          )
        , 0)
        +
        IFNULL(
          (
            SELECT SUM(balance) AS balance
            FROM slownls_atm_groups
            WHERE members LIKE :concat: OR steamid = uid
          )
        , 0)
      )
    ]])
    query = query:Replace(":concat:", conn.isMySQL() and "CONCAT('%', uid, '%')" or "'%' || uid || '%'")
  elseif (gbType and ((gbType == "sqlite" and !conn.isMySQL()) or (gbType != "sqlite" and conn.isMySQL()))) then
    query = query:Replace(":atm:", [[
      IFNULL((
        SELECT Balance AS balance
        FROM gb_players
        WHERE SteamID = uid
        LIMIT 1
      ), 0)
    ]])
  else
    query = query:Replace(":atm:", "0")
  end

  if (days and days > 0) then
    local currentTime = os.time()
    local goBack = 60 * 60 * 24 * days
    local time = currentTime - goBack

    query = query:Replace(":and:", "AND a.lastLoggedIn >= " .. time)
    query = query:Replace(":join:", "INNER JOIN xenin_f4menu_activeplayers AS a ON d.uid = a.sid")
  else
    query = query:Replace(":join:", "")
    query = query:Replace(":and:", "")
  end

  return XeninUI:InvokeSQL(conn, query, "F4Menu.GetRichestPlayer"):next(function(result)
    result = result[1] or {}

    F4Menu.RichestPlayer = result
  end)
end
-- 76561198196929675
function F4Menu.Database:CachePlayersMoney()
  local conn = self:GetConnection()
  local cfg = F4Menu.Config.TotalMoney
  local days = cfg.DaysSinceLastLogin
  local query = [[
    SELECT SUM(d.wallet) + :atm: AS money
    FROM darkrp_player AS d
    :join:
  ]]
  local gbType = GlorifiedBanking and GlorifiedBanking.SQL.GetType()
  if (conn.isMySQL() and BATM and BATM.Config and BATM.Config.UseMySQL) then
    query = query:Replace(":atm:", [[
      IFNULL((
        SELECT SUM(SUBSTRING(accountinfo, 42, LENGTH(SUBSTRING_INDEX(accountinfo, ",", 2)) - 41)) AS balance
        FROM batm_personal_accounts
      ), 0)
    ]])
  elseif (SlownLS and SlownLS.ATM and SlownLS.ATM.SQL.useMysql == conn.isMySQL()) then
    query = query:Replace(":atm:", [[
      (
        IFNULL(
          (
            SELECT SUM(balance) AS balance 
            FROM slownls_atm_accounts
          )
        , 0)
        +
        IFNULL(
          (
            SELECT SUM(balance) AS balance
            FROM slownls_atm_groups
          )
        , 0)
      )
    ]])
  elseif (cfg.IncludeBATM and gbType and ((gbType == "sqlite" and !conn.isMySQL()) or (gbType != "sqlite" and conn.isMySQL()))) then
    query = query:Replace(":atm:", [[
      IFNULL((
        SELECT SUM(Balance) AS balance
        FROM gb_players
      ), 0)
    ]])
  else
    query = query:Replace(":atm:", "0")
  end

  if (days and days > 0) then
    local currentTime = os.time()
    local goBack = 60 * 60 * 24 * days
    local time = currentTime - goBack

    query = query .. [[
      AND a.lastLoggedIn >= :time:
    ]]
    query = query:Replace(":join:", "INNER JOIN xenin_f4menu_activeplayers AS a ON d.uid = a.sid")
    query = query:Replace(":time:", time)
  else
    query = query:Replace(":join:", "")
  end

  return XeninUI:InvokeSQL(conn, query, "F4Menu.CachePlayersMoney"):next(function(result)
    F4Menu.PlayersMoney = result[1] and result[1].money or 0
    F4Menu.Network:sendTotalMoney()
    XeninUI:Debounce("F4Menu.Cache", cfg.CacheInterval, function()
      self:CachePlayersMoney(days)
    end)
  end)
end

function F4Menu.Database:UpdateActivePlayer(ply)
  local conn = self:GetConnection()
  local sid64 = ply:SteamID64()
  local time = os.time()

  if conn.isMySQL() then
    local query = [[
      INSERT INTO xenin_f4menu_activeplayers (sid, lastLoggedIn)
      VALUES (':sid64:', :time:)
      ON DUPLICATE KEY
        UPDATE
          lastLoggedIn = :time:
    ]]
    query = query:Replace(":sid64:", sid64)
    query = query:Replace(":time:", time)

    return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
  else
    local query = [[
      SELECT * FROM xenin_f4menu_activeplayers
      WHERE sid = ':sid64:'
    ]]
    query = query:Replace(":sid64:", sid64)

    local p = XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer.Select." .. sid64)
    p:next(function(result)
      if (istable(result) and #result > 0) then
        local query = [[
          UPDATE xenin_f4menu_activeplayers
          SET lastLoggedIn = :time:
          WHERE sid = ':sid64:'
        ]]
        query = query:Replace(":sid64:", sid64)
        query = query:Replace(":time:", time)

        return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
      else
        local query = [[
          INSERT INTO xenin_f4menu_activeplayers (sid, lastLoggedIn)
          VALUES (':sid64:', :time:)
        ]]
        query = query:Replace(":sid64:", sid64)
        query = query:Replace(":time:", time)

        return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
      end
    end)

    return p
  end
end

function F4Menu.Database:GetBATMPersonalAccount(sid64)
  local p = XeninUI.Promises.new()
  if (!CBLib or !BATM or !BATM.Config or !F4Menu.Config.TotalMoney.IncludeBATM) then
    return p:resolve(0)
  end

  local module = CBLib.Modules["batm/bm_accounts.lua"]

  module.GetCachedPersonalAccount(sid64, function(result)
    p:resolve(result.balance or 0)
  end)

  return p
end

function F4Menu.Database:CreateGraphSnapshot()
  F4Menu.Database:CachePlayersMoney():next(function()
    local money = tonumber(F4Menu.PlayersMoney)

    F4Menu.Database:SaveEconomySnapshot(money)
  end)
end

function F4Menu.Database:CacheRichestPlayer()
  F4Menu.Database:GetRichestPlayer():next(function()
    local result = F4Menu.RichestPlayer

    F4Menu.Network:sendRichestPlayer()
  end)
end

function F4Menu.Database:GetFavourites(ply)
  local conn = self:GetConnection()
  local sid64 = ply:SteamID64()
  local query = [[
    SELECT * FROM xenin_f4menu_favourites
    WHERE sid64 = ':sid64:'
  ]]
  query = query:Replace(":sid64:", sid64)

  return XeninUI:InvokeSQL(conn, query, "F4Menu.GetFavourites." .. sid64)
end

function F4Menu.Database:SaveFavourite(ply, type, name)
  local conn = self:GetConnection()
  local sid64 = ply:SteamID64()
  local query = [[
    :ignore xenin_f4menu_favourites (sid64, type, key_name)
    VALUES (':sid64:', :type:, :key_name:)
  ]]
  query = query:Replace(":ignore", conn.isMySQL() and "INSERT IGNORE" or "INSERT OR IGNORE")
  query = query:Replace(":sid64:", sid64)
  query = query:Replace(":type:", conn.SQLStr(type))
  query = query:Replace(":key_name:", conn.SQLStr(name))

  return XeninUI:InvokeSQL(conn, query, "F4Menu.SaveFavourite." .. sid64 .. " [" .. type .. " - " .. name .. "]")
end

function F4Menu.Database:RemoveFavourite(ply, type, name)
  local conn = self:GetConnection()
  local sid64 = ply:SteamID64()
  local query = [[
    DELETE FROM xenin_f4menu_favourites
    WHERE sid64 = ':sid64:'
      AND type = :type:
      AND key_name = :key_name:
  ]]
  query = query:Replace(":sid64:", sid64)
  query = query:Replace(":type:", conn.SQLStr(type))
  query = query:Replace(":key_name:", conn.SQLStr(name))

  return XeninUI:InvokeSQL(conn, query, "F4Menu.RemoveFavourite." .. sid64 .. " [" .. type .. " - " .. name .. "]")
end

hook.Add("DarkRPDBInitialized", "F4Menu.Caching", function()
  F4Menu.Database:Tables():next(function()
    F4Menu.Database:CachePlayersMoney()
    F4Menu.Database:GetEconomySnapshots()
    F4Menu.Database:CacheRichestPlayer()
  end):next(function()
    timer.Create("F4Menu.MoneyGraphData", 3600, 0, function()
      F4Menu.Database:CreateGraphSnapshot()
    end)
    timer.Create("F4Menu.RichestPlayerCache", F4Menu.Config.RichestPlayer.CacheInterval, 0, function()
      F4Menu.Database:CacheRichestPlayer()
    end)
  end)
end)

hook.Add("PlayerInitialSpawn", "F4Menu.Caching", function(ply)
  if (!IsValid(ply)) then return end

  F4Menu.Database:UpdateActivePlayer(ply):next(function()
    return F4Menu.Database:CachePlayersMoney()
  end):next(function(results)
    return F4Menu.Database:CacheRichestPlayer()
  end):next(function(results)
    if (!IsValid(ply)) then return end

    return F4Menu.Database:GetFavourites(ply)
  end):next(function(results)
    timer.Simple(3, function()
      if (!IsValid(ply)) then return end
      if (!istable(results)) then return end
      if (#results == 0) then return end

      local tbl = {}
      for i, v in ipairs(results) do
        tbl[v.type] = tbl[v.type] or {}

        table.insert(tbl[v.type], v.key_name)
      end
      F4Menu.Network:sendFavourites(ply, tbl)
    end)
  end)
end)
