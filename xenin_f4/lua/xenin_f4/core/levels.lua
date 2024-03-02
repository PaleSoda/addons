local Levels
do
  local _class_0
  local _base_0 = {
    __name = "Levels",
    setActiveLevel = function(self, activeLevel)
      self.activeLevel = activeLevel
      return self
    end,
    getActiveLevel = function(self)
      return self.activeLevel
    end,
    getActive = function(self)
      return self.levels[self:getActiveLevel()]
    end,
    get = function(self, id)
      return self.levels[id]
    end,
    register = function(self, id, tbl)
      self.levels[id] = tbl
    end,
    detectInstalled = function(self)
      for i, v in pairs(self.levels) do
        if (!v:isInstalled()) then continue end

        self:setActiveLevel(i)

        return
      end

      self:setActiveLevel("Vrondakis")
    end,
    __type = function(self)
      return "F4Menu.Levels"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.activeLevel = "Vrondakis"
      self.levels = {}
    end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  Levels = _class_0
end

F4Menu.Levels = Levels()
