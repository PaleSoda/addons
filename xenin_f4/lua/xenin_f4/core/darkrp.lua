function F4Menu:CanBuyentities(item)
    local ply = LocalPlayer()

    if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
    if item.customCheck and not item.customCheck(ply) then return false, true end

    local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, item)
    local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price

    if canbuy == false then
        return false, suppress, message, cost
    end

    return true, nil, message, cost
end


function F4Menu:CanBuyweapons(ship)
    local ply = LocalPlayer()

    if GAMEMODE.Config.restrictbuypistol and not table.HasValue(ship.allowed, ply:Team()) then return false, true end
    if ship.customCheck and not ship.customCheck(ply) then return false, true end

    local canbuy, suppress, message, price = hook.Call("canBuyPistol", nil, ply, ship)
    local cost = price or ship.getPrice and ship.getPrice(ply, ship.pricesep) or ship.pricesep

    if canbuy == false then
        return false, suppress, message, cost
    end

    return true, nil, message, cost
end


function F4Menu:CanBuyshipments(ship)
    local ply = LocalPlayer()

    if not table.HasValue(ship.allowed, ply:Team()) then return false, true end
    if ship.customCheck and not ship.customCheck(ply) then return false, true end

    local canbuy, suppress, message, price = hook.Call("canBuyShipment", nil, ply, ship)
    local cost = price or ship.getPrice and ship.getPrice(ply, ship.price) or ship.price

    if canbuy == false then
        return false, suppress, message, cost
    end

    return true, nil, message, cost
end


function F4Menu:CanBuyammo(item)
    local ply = LocalPlayer()

    if item.customCheck and not item.customCheck(ply) then return false, true end

    local canbuy, suppress, message, price = hook.Call("canBuyAmmo", nil, ply, item)
    local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price

    if canbuy == false then
        return false, suppress, message, price
    end

    return true, nil, message, price
end


function F4Menu:CanBuyfood(food)
    local ply = LocalPlayer()

    if (food.requiresCook == nil or food.requiresCook == true) and not ply:isCook() then return false, true end
    if food.customCheck and not food.customCheck(LocalPlayer()) then return false, false end

    return true
end


function F4Menu:CanBuyvehicles(item)
    local ply = LocalPlayer()
    local cost = item.getPrice and item.getPrice(ply, item.price) or item.price

    if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
    if item.customCheck and not item.customCheck(ply) then return false, true end

    local canbuy, suppress, message, price = hook.Call("canBuyVehicle", nil, ply, item)
    cost = price or cost

    if canbuy == false then
        return false, suppress, message, cost
    end

    return true, nil, message, cost
end


function F4Menu:isItemHidden(cantBuy, important)
    return cantBuy and (GAMEMODE.Config.hideNonBuyable or (important and GAMEMODE.Config.hideTeamUnbuyable))
end

function F4Menu:FindJobIndexByName(name)
    if (!self.JobNameLookup) then
        self.JobNameLookup = {}
        for i, v in pairs(RPExtraTeams or {}) do
            if (!istable(v)) then continue end

            self.JobNameLookup[v.name] = i
        end
    end

    return self.JobNameLookup[name]
end

hook.Add("F4Menu.Jobs.Rebuild", "F4Menu.Cache", function()
    F4Menu.JobNameLookup = nil
end)
