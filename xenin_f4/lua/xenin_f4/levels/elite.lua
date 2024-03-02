F4Menu.Levels:register("Elite", {
  isInstalled = function(self)
    return istable(EliteXP)
  end,
  getLevel = function(self, ply)
    if ply == nil then ply = LocalPlayer()
    end
    return EliteXP.GetLevel(ply) or 0
  end
})
