escore.util = escore.util or {}
local eutil = escore.util


if (CLIENT) then

--TEXT
function eutil.GetTextSize(txt,font)
	surface.SetFont(font)
	local x, y = surface.GetTextSize(txt)
	return {w = x, h = y}
end

function eutil.TextColMustDark(bgCol)
	if ((bgCol.r + bgCol.g + bgCol.b) / 3 >= 127) then 
		return true
	else
		return false
	end
end

--DRAW
function eutil.DrawCircle( x, y, r )
	local circle = {}

	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.DrawPoly(circle)
end


--PANEL META EDIT
local Panel = FindMetaTable("Panel")

--returns center of the panel from pos
function Panel:EGetCenterX()
	local posx = self:GetPos()
	posx = posx+self:GetWide()*0.5
	return posx
end

function Panel:EGetCenterY()
	local _,posy = self:GetPos()
	posy = posy+self:GetTall()*0.5
	return posy
end

function Panel:EGetCenter()
	local posx,posy = self:GetPos()
	posx,posy = posx+self:GetWide()*0.5, posy+self:GetTall()*0.5
	return posx,posy
end


function Panel:EGetPosX()
	local posx,_ = self:GetPos()
	return posx
end

function Panel:EGetPosY()
	local _,posy = self:GetPos()
	return posy
end

function Panel:ESetPosX(x)
	local _,posy = self:GetPos()
	self:SetPos(x,posy)
end

function Panel:ESetPosY(y)
	local posx,_ = self:GetPos()
	self:SetPos(posx,y)
end

end -- if ( CLIENT )