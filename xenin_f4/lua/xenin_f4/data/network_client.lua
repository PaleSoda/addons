local Network
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "Network",
    __base = XeninUI.Network.__base,
    receiveTotalMoney = function(self)
      local money = tonumber(net.ReadString())

      F4Menu.PlayersMoney = money
    end,
    receiveRichestPlayer = function(self)
      local name = net.ReadString()
      local sid64 = net.ReadString()
      local money = tonumber(net.ReadString())

      F4Menu.RichestPlayer = {
        sid64 = sid64,
        money = money,
        name = name
      }

      hook.Run("F4Menu.RichestPlayer", F4Menu.RichestPlayer)
    end,
    receiveEconomySnapshots = function(self)
      local entries = net.ReadUInt(9)
      local tbl = {}
      for i = 1, entries do
        tbl[#tbl + 1] = net.ReadFloat()
      end

      F4Menu.EconomySnapshots = tbl

      hook.Run("F4Menu.EconomySnapshots")
    end,
    receiveFavourites = function(self)
      local typeSize = net.ReadUInt(6)
      local tbl = {}
      for i = 1, typeSize do
        local typeName = net.ReadString()
        tbl[typeName] = {}
        local size = net.ReadUInt(16)
        for j = 1, size do
          tbl[typeName][j] = net.ReadString()
        end
      end

      F4Menu:SetFavourites(tbl)
    end,
    sendRemoveFavourite = function(self, type, name)
      self:send("RemoveFavourite", function(self)
        net.WriteString(type)
        net.WriteString(name)
      end)
    end,
    sendSaveFavourite = function(self, type, name)
      self:send("SaveFavourite", function(self)
        net.WriteString(type)
        net.WriteString(name)
      end)
    end,
    sendRequestRichestPlayer = function(self)
      self:send("RichestPlayer", function(self) end)
    end,
    sendRequestTotalMoney = function(self)
      self:send("TotalMoney", function(self) end)
    end,
    sendRequestEconomySnapshots = function(self)
      self:send("EconomySnapshots", function(self) end)
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

      self:receiver("TotalMoney", self.receiveTotalMoney)
      self:receiver("RichestPlayer", self.receiveRichestPlayer)
      self:receiver("EconomySnapshots", self.receiveEconomySnapshots)
      self:receiver("SendFavourites", self.receiveFavourites)
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
