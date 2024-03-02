local PANEL = {}

XeninUI:CreateFont("F4Menu.Player.Name", 20)
XeninUI:CreateFont("F4Menu.Player.Job", 16)

local matCogHollow = Material("xenin/f4/cog_hollow.png", "smooth")
local matCog = Material("xenin/f4/cog.png", "smooth")

function PANEL:Init()
  self.Avatar = self:Add("XeninUI.Avatar")
  self.Avatar:SetPlayer(LocalPlayer(), 64)
  self.Avatar:SetVertices(30)

  self.Text = self:Add("DPanel")
  self.Text:SetMouseInputEnabled(false)
  self.Text.TextHeight = 0
  local ply = LocalPlayer()
  self.Text.Rows = {
    {
      font = "F4Menu.Player.Name",
      text = ply:Nick(),
      color = color_white
    },
    {
      font = "F4Menu.Player.Job",
      text = team.GetName(ply:Team()),
      color = team.GetColor(ply:Team())
    }
  }
  self.Text.Paint = function(pnl, w, h)
    local ply = LocalPlayer()

    pnl.TextHeight = 0
    for i, v in pairs(pnl.Rows) do
      XeninUI:DrawShadowText(v.text, v.font, 0, pnl.TextHeight, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 255)

      pnl.TextHeight = pnl.TextHeight + draw.GetFontHeight(v.font) - 2
    end
  end

  self:AddHook("OnPlayerChangedTeam", "F4Menu.Player", function(pnl, ply, old, new)
    if (ply != LocalPlayer()) then return end
    if (!IsValid(F4Menu.Frame)) then return end

    self.Text.Rows[2].text = team.GetName(new)
    self.Text.Rows[2].color = team.GetColor(new)

    F4Menu.Frame:InvalidateLayout()
  end)

  self:AddTimer("F4Menu.Player", 1, 0, function(pnl)
    if (!IsValid(F4Menu.Frame)) then return end

    self.Text.Rows[1].text = LocalPlayer():Nick()

    F4Menu.Frame:InvalidateLayout()
  end)

  self.Toggle = self:Add("DButton")
  self.Toggle:Dock(RIGHT)
  self.Toggle:SetText("")
  self.Toggle.Overlay = 0
  self.Toggle.Paint = function(pnl, w, h)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(matCogHollow)
    local size = h / 4
    local x = w - size - 12
    local y = h / 2 - size / 2
    surface.DrawTexturedRect(x, y, size, size)

    XeninUI:Mask(function()
      XeninUI:DrawCircle(x + size / 2, y + size / 2, size * pnl.Overlay, 30, color_white)
    end, function()
      surface.SetDrawColor(color_white)
      surface.SetMaterial(matCog)
      surface.DrawTexturedRect(x, y, size, size)
    end)
  end
  self.Toggle.DoClick = function(pnl)
    self.Commands = !self.Commands

    pnl:Lerp("Overlay", self.Commands and 1 or 0)

    if self.Commands then
      self:OpenCommands()
    else
      self:CloseCommands()
    end
  end

  local parent = self:GetParent()
  self.CommandsOverlay = parent:Add("DPanel")
  self.CommandsOverlay:Dock(FILL)
  self.CommandsOverlay.Alpha = 0
  self.CommandsOverlay:SetZPos(2)
  self.CommandsOverlay:SetVisible(false)
  self.CommandsOverlay.Paint = function(pnl, w, h)
    local aX, aY = self:LocalToScreen()

    XeninUI:Mask(function()
      XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, color_white, false, false, true, false)
    end, function()
      draw.SimpleLinearGradient(aX, aY + self:GetTall(), w, h, ColorAlpha(F4Menu.Config.SidebarColors.Commands[1], pnl.Alpha), ColorAlpha(F4Menu.Config.SidebarColors.Commands[2], pnl.Alpha))
    end)
  end
  self.CommandsOverlay:AddHook("OnPlayerChangedTeam", "F4Menu.Commands", function(pnl, ply, old, new)
    timer.Simple(1, function()
      if (!IsValid(self)) then return end
      if (!pnl:IsVisible()) then return end

      self.CommandsPanel:CreateCommands()
    end)
  end)

  self.CommandsPanel = self.CommandsOverlay:Add("F4Menu.Commands")
  self.CommandsPanel:Dock(FILL)
end

function PANEL:OpenCommands()
  if IsValid(self.CommandsOverlay) then
    self.CommandsOverlay:SetVisible(true)
    self.CommandsOverlay:LerpAlpha(255)
    self.CommandsPanel:CreateCommands()

    return
  end
end

function PANEL:CloseCommands()
  self.CommandsOverlay:LerpAlpha(0, nil, function()
    self.CommandsOverlay:SetVisible(false)
  end)
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()
  draw.SimpleLinearGradient(aX, aY, w, h, F4Menu.Config.SidebarColors.Player[1], F4Menu.Config.SidebarColors.Player[2])

  XeninUI:Mask(function()
    XeninUI:DrawRoundedBox((h - 24) / 2, 12, 12, h - 24, h - 24, color_white)
  end, function()
    draw.SimpleLinearGradient(aX + 12, aY + 12, h - 24, h - 24, F4Menu.Config.SidebarColors.PlayerAvatar[1], F4Menu.Config.SidebarColors.PlayerAvatar[2], true)
  end)
end

function PANEL:PerformLayout(w, h)
  self.Avatar:SetPos(14, 14)
  self.Avatar:SetSize(h - 28, h - 28)

  self.Text:MoveRightOf(self.Avatar, 10)
  local textH = 1
  for i, v in pairs(self.Text.Rows) do
    textH = textH + draw.GetFontHeight(v.font)
  end
  self.Text:SetTall(textH)
  self.Text:CenterVertical()
  self.Text:SetWide(w - self.Text.x)
end

vgui.Register("F4Menu.Player", PANEL)
