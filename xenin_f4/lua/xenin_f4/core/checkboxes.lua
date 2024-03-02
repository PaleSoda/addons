function F4Menu:GetCheckboxState(id)
  if (!F4Menu.Config.SaveCheckboxStates) then
    return F4Menu.Config.CheckboxStates[id]
  end

  return tobool(LocalPlayer():GetPData("xenin.f4menu.checkbox." .. id, F4Menu.Config.CheckboxStates[id]))
end

function F4Menu:SetCheckboxState(id, state)
  if (!F4Menu.Config.SaveCheckboxStates) then return end

  LocalPlayer():SetPData("xenin.f4menu.checkbox." .. id, tostring(state))
end
