local Network
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "Network",
    __base = XeninUI.Network.__base,
    sendEconomySnapshot = function(self, ply)
      local __laux_type = (istable(ply) and ply.__type and ply:__type()) or type(ply)
      assert(__laux_type == "Player" or __laux_type == "table", "Expected parameter `ply` to be type `Player|table` instead of `" .. __laux_type .. "`")
      local result = F4Menu.EconomySnapshot or {}
      local entries = #result

      self:send("EconomySnapshots", ply, function(self)
        net.WriteUInt(entries, 9)
        for i = 1, entries do
          net.WriteFloat(result[i].money)
        end
      end)
    end,
    sendTotalMoney = function(self, target)
      if target == nil then target = player.GetAll()
      end
      self:send("TotalMoney", target, function(self)
        net.WriteString(tostring(F4Menu.PlayersMoney) or "")
      end)
    end,
    sendRichestPlayer = function(self, target)
      if target == nil then target = player.GetAll()
      end
      local result = F4Menu.RichestPlayer
      self:send("RichestPlayer", target, function(self)
        net.WriteString(result.rpname or "Unknown name")
        net.WriteString(tostring(result.uid) or "")
        net.WriteString(tostring(result.wallet) or "0")
      end)
    end,
    sendFavourites = function(self, ply, tbl)
      local __laux_type = (istable(ply) and ply.__type and ply:__type()) or type(ply)
      assert(__laux_type == "Player", "Expected parameter `ply` to be type `Player` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(tbl) and tbl.__type and tbl:__type()) or type(tbl)
      assert(__laux_type == "table", "Expected parameter `tbl` to be type `table` instead of `" .. __laux_type .. "`")
      self:send("SendFavourites", ply, function(self)
        net.WriteUInt(table.Count(tbl), 6)
        for i, v in pairs(tbl) do

          net.WriteString(i)
          local size = #v
          net.WriteUInt(size, 16)
          for j = 1, size do

            net.WriteString(v[j])
          end
        end
      end)
    end,
    receiveEconomySnapshotsRequest = function(self, ply)
      local lastRequested = ply.__economySnapshotRequested or 0
      if (lastRequested > CurTime()) then return end
      ply.__economySnapshotRequested = CurTime() + 30

      self:sendEconomySnapshot(ply)
    end,
    receiveRichestPlayerRequest = function(self, ply)
      local requested = ply.__hasRequestedRichestPlayer
      if requested then return end
      ply.__hasRequestedRichestPlayer = true

      self:sendRichestPlayer(ply)
    end,
    receiveTotalMoneyRequest = function(self, ply)
      local requested = ply.__hasRequestedMoney
      if requested then return end
      ply.__hasRequestedMoney = true

      self:sendTotalMoney(ply)
    end,
    receiveSaveFavourite = function(self, ply)
      local type = net.ReadString()
      local name = net.ReadString()

      F4Menu.Database:SaveFavourite(ply, type, name)
    end,
    receiveRemoveFavourite = function(self, ply)
      local type = net.ReadString()
      local name = net.ReadString()

      F4Menu.Database:RemoveFavourite(ply, type, name)
    end,
    __type = function(self)
      return "F4Menu.Network"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self, ...)
      Network.__parent.__init(self, ...)

      self:setPrefix("F4Menu.")
      self:prepare({
        "TotalMoney",
        "EconomySnapshots",
        "RichestPlayer",
        "SendFavourites",
        "SaveFavourite",
        "RemoveFavourite"
      })

      self:receiver("EconomySnapshots", self.receiveEconomySnapshotsRequest)
      self:receiver("RichestPlayer", self.receiveRichestPlayerRequest)
      self:receiver("TotalMoney", self.receiveTotalMoneyRequest)
      self:receiver("SaveFavourite", self.receiveSaveFavourite)
      self:receiver("RemoveFavourite", self.receiveRemoveFavourite)
    end,
    __base = _base_0,
    __parent = _parent_0
  }, {
    __index = function(cls, parent)
      local val = rawget(_base_0, parent)
      if val == nil then local _parent = rawget(cls, "__parent")
        if _parent then return _parent[parent]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  if _parent_0.__inherited then _parent_0.__inherited(_parent_0, _class_0)
  end
  Network = _class_0
end

F4Menu.Network = Network()
