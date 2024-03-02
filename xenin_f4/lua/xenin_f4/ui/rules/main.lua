local cfg = F4Menu.CFG

F4Menu.Config.Rules = {}

cfg:AddRule({
  name = "General",
  level = 1,
  jobs = {},
  usergroups = {},
  text = "<b>D</b>amn boi"
})

cfg:AddRule({
  name = "Building",
  level = 2,
  jobs = {},
  usergroups = {}
})

cfg:AddRule({
  name = "Bases",
  level = 3,
  jobs = {},
  usergroups = {}
})

cfg:AddRule({
  name = "Public areas",
  level = 3,
  jobs = {},
  usergroups = {}
})

cfg:AddRule({
  name = "Police",
  level = 3,
  jobs = {},
  usergroups = {}
})

local PANEL = {}

for i = 1, 8 do
  XeninUI:CreateFont("F4MenuDLC.Sidebar.Level." .. i, 24 - (i * 2), nil, {
  italic = i >= 3
  })
  XeninUI:CreateFont("F4MenuDLC.Header." .. i, 28 - (i * 2), nil, {
  italic = i >= 3
  })
end

for i = 6, 120 do
  XeninUI:CreateFont("F4MenuDLC.Content." .. i, i)
end

function PANEL:Init()
  self.Sidebar = self:Add("Panel")
  self.Sidebar:Dock(LEFT)
  self.Sidebar.Paint = function(pnl, w, h)
    surface.SetDrawColor(XeninUI.Theme.Navbar)
    surface.DrawRect(0, 0, w, h)
  end

  self.Sidebar.Scroll = self.Sidebar:Add("XeninUI.ScrollPanel")
  self.Sidebar.Scroll:Dock(FILL)
  self.Sidebar.Scroll:GetCanvas():DockPadding(16, 16, 16, 16)
  self.Sidebar.Scroll.VBar:SetWide(0)

  self.Search = self.Sidebar.Scroll:Add("XeninUI.TextEntry")
  self.Search:Dock(TOP)
  self.Search:DockMargin(0, 0, 0, 16)
  self.Search:SetTall(38)
  self.Search:SetBackgroundColor(XeninUI.Theme.Primary)
  self.Search:SetPlaceholder("Search")
  self.Search:SetIcon(XeninUI.Materials.Search, true)
  self.Search.textentry:SetUpdateOnType(true)
  self.Search.textentry.OnValueChange = function(pnl, text) end

  self.Divider = self.Sidebar.Scroll:Add("DPanel")
  self.Divider.Paint = function(pnl, w, h)
    surface.SetDrawColor(XeninUI.Theme.Primary)
    surface.DrawRect(0, h - 1, w, 1)
  end

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)
  self.Scroll:DockPadding(16, 16, 16, 16)
  self.Scroll:GetCanvas():DockPadding(16, 16, 16, 16)

  self.Outline = {}
  for i, v in ipairs(F4Menu.Config.Rules) do
    self:AddContent(v.name, v.level, v.text)
  end
end

function PANEL:AddContent(name, level, text)
  if level == nil then level = 1
  end
  local panel = self.Sidebar.Scroll:Add("DButton")
  panel:Dock(TOP)
  panel:SetContentAlignment(7)
  panel:SetText(name)
  panel:SetTextInset(level * 8, 8)
  panel:SetFont("F4MenuDLC.Sidebar.Level." .. level)
  local col = 255 - ((level - 1) * 30)
  panel:SetTextColor(Color(col, col, col))
  panel.BackgroundAlpha = 0
  panel.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Primary, pnl.BackgroundAlpha))
  end
  panel.OnCursorEntered = function(pnl)
    pnl:Lerp("BackgroundAlpha", 200)
  end
  panel.OnCursorExited = function(pnl)
    pnl:Lerp("BackgroundAlpha", 0)
  end
  panel:SizeToContentsY(16)

  local header = self.Scroll:Add("DLabel")
  header:Dock(TOP)
  header:DockMargin(0, 0, 0, text and 0 or 5)
  header:SetText(name)
  header:SetFont("F4MenuDLC.Header." .. level)
  local col = 255 - ((level - 1) * 30)
  header:SetTextColor(Color(col, col, col))
  header:SizeToContents()

  if text then
    local content = self.Scroll:Add("DLabel")
    content:Dock(TOP)
    content:DockMargin(0, 0, 0, 5)
    content:SetText(text)
    content:SetFont("F4MenuDLC.Content")
    content:SizeToContents()
  end

  table.insert(self.Outline, panel)
end

function PANEL:PerformLayout(w, h)
  self.Sidebar:SetWide(200)

  self.Divider:SetTall(8)
  self.Divider:SetWide(self.Sidebar:GetWide())
  self.Divider:SetPos(0, 16 + self.Search:GetTall() + 4)
end

function PANEL:BuildTop()
  self.Top = self:Add("DPanel")
  self.Top:Dock(TOP)
  self.Top:DockPadding(8, 8, 8, 8)
  self.Top:SetTall(52)
  self.Top.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)
  end

  self.Top.Search = self.Top:Add("XeninUI.TextEntry")
  self.Top.Search:Dock(LEFT)
  self.Top.Search:SetPlaceholder("Search")
  self.Top.Search:SetIcon(XeninUI.Materials.Search, true)
  self.Top.Search.textentry:SetUpdateOnType(true)
  self.Top.Search.textentry.OnValueChange = function(pnl, text) end

  self.Top.Favourite = self.Top:Add("XeninUI.CheckboxV2")
  self.Top.Favourite:Dock(RIGHT)
  self.Top.Favourite:DockMargin(8, 8, 8, 8)
  self.Top.Favourite.TextColor = Color(225, 225, 225)
  self.Top.Favourite.Text = F4Menu:GetPhrase("items.top.showFavourite")
  self.Top.Favourite:SetState(true, true)
  self.Top.Favourite.OnStateChanged = function()
    self:Build()end

  self.Top.Sort = self.Top:Add("DButton")
  self.Top.Sort:Dock(LEFT)
  self.Top.Sort:DockMargin(8, 0, 0, 0)
  self.Top.Sort:SetText(F4Menu:GetPhrase("items.top.sort.default"))
  self.Top.Sort:SetFont("F4Menu.Sort")
  self.Top.Sort:SetTextColor(Color(190, 190, 190))
  self.Top.Sort:SetContentAlignment(5)
  self.Top.Sort.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
  end
  self.Top.Sort.SortChanged = function(pnl, text)
    pnl:SetText(text)
    self:Build()
    self.Top:InvalidateLayout()
  end
  self.Top.Sort.DoClick = function(pnl)
    local func = function(btn)
      pnl:SortChanged(btn:GetText())
    end
    local hoverColor = Color(75, 75, 75)

    local panel = XeninUI:DropdownPopup(pnl:LocalToScreen(-12, -12 + pnl:GetTall()))
    panel:SetBackgroundColor(XeninUI.Theme.Navbar)
    panel:SetTextColor(Color(185, 185, 185))
    panel:AddChoice(F4Menu:GetPhrase("items.top.sort.default"), func, nil, hoverColor)
    panel:AddChoice(F4Menu:GetPhrase("items.top.sort.alphabetically"), func, nil, hoverColor)
    panel:AddChoice(F4Menu:GetPhrase("items.top.sort.highestPrice"), func, nil, hoverColor)
    panel:AddChoice(F4Menu:GetPhrase("items.top.sort.lowestPrice"), func, nil, hoverColor)
  end

  self.Top.PerformLayout = function(pnl, w, h)
    pnl.Search:SetWide(200)
    pnl.Favourite:SizeToContentsX()
    pnl.Sort:SizeToContentsX(24)
  end
end

vgui.Register("F4Menu.Rules", PANEL)
