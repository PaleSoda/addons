F4Menu.Levels:register("Vrondakis", {
  isInstalled = function(self)
    return istable(LevelSystemConfiguration)
  end,
  getLevel = function(self, ply)
    if ply == nil then ply = LocalPlayer()
    end
    return ply:getDarkRPVar("level") or 0
  end
})
