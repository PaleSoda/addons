local PANEL = {}

function PANEL:Init()
  self:DockMargin(24, 16, 16, 24)
end

function PANEL:SetRanks(ranks)
  self.Content = self:Add("DLabel")
  self.Content:Dock(TOP)
  self.Content:SetFont("F4Menu.Jobs.Slideout.Desc")
  self.Content:SetTextColor(Color(212, 212, 212))
  self.Content:SetWrap(true)
  self.Content:SetAutoStretchVertical(true)
  self.Content:SetText(F4Menu:GetPhrase("jobs.slideout.ranks.title") or "Ranks that can access this job")

  local tbl = {}
  for i, v in pairs(ranks) do
    table.insert(tbl, i)
  end
  table.sort(tbl, function(a, b)
    return a > b end)
  local str = ""
  for i, v in ipairs(tbl) do
    str = str .. "• " .. tostring(v) .. "\n"
  end

  self.Ranks = self:Add("DLabel")
  self.Ranks:Dock(TOP)
  self.Ranks:DockMargin(8, 2, 0, 0)
  self.Ranks:SetFont("F4Menu.Jobs.Slideout.Desc")
  self.Ranks:SetTextColor(color_white)
  self.Ranks:SetWrap(true)
  self.Ranks:SetAutoStretchVertical(true)
  self.Ranks:SetText(str)
end

function PANEL:PerformLayout(w, h)
  self.Content:SetSize(w, h)
end

vgui.Register("F4Menu.Jobs.Slideout.Ranks", PANEL, "Panel")
