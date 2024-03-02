escore.EffectManager = {}
local EffectManager = escore.EffectManager
EffectManager.list = {}
function EffectManager:RegisterEffect(Name,Function)
	self.list[Name] = Function
end
function EffectManager:GetEffect(Name) return self.list[Name] end
function EffectManager:GetAllEffects() return self.list end

local blur = Material("pp/blurscreen")
local function DrawBlur(pnl,amount)
	local x, y, w, h = pnl:GetBounds(0, 0)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)
    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, w, h)
    end
end



local PANEL={}
AccessorFunc(PANEL, "effect_phys", "Physics", FORCE_BOOL)

function PANEL:Init()
	self:SetSize(ScrW(),ScrH())
	self.Color = Color(13,13,13,255) --bg color

	--Effects
	self:SetPhysics(true)
	self:PerformEffect()
	self:SetMouseInputEnabled(false)
	self.EffectEnable = true
	self.Speed = 1
	self.Blur = false
	self.BlurAmount = 3

	--Visualizer
	self.VisualizerEnabled = true
	self.bandwidth = 5
	self.gaps = 5
	self.num = (self:GetWide()/(self.bandwidth+self.gaps))
	self.amp = 500 --amplitude
	self.smoothdata = smoothdata or {}
	for i = 1, self.num do
		self.smoothdata[i] = 0
	end
	self.station = nil
	self.startspeed = self.Speed
end

function PANEL:SetSpeed(int)
	self.Speed = int or 1
	self.startspeed = self.Speed
end

function PANEL:PerformEffect()
	if IsValid(self.pEffect) then
		self.pEffect:Remove()
	end

	if self.EffectEnable then
		local pnl
		if EffectManager:GetAllEffects()[self.effect] then
			pnl = EffectManager:GetEffect(self.effect)(self)
		end

		if IsValid(pnl) then
			self.pEffect = pnl
			self.pEffect:SetZPos(-1000)
			return self.effect
		end
	end
end

function PANEL:SetEffect(s_Effect)
	if self.effect ~= s_Effect then
		self.effect = s_Effect
		self:PerformEffect()
	end
end

function PANEL:GetEffect()
	return self.effect
end

function PANEL:SetEffectEnabled(bool)
	if self.EffectEnable ~= bool then
		self.EffectEnable = bool
		self:PerformEffect()
	end
end

function PANEL:GetEffectEnabled(bool)
	return self.EffectEnable
end

function PANEL:SetBlur(bool,amount)
	if not amount then amount = 3 end
	self.Blur = bool
	self.BlurAmount = amount
end

function PANEL:Close()
	self:Remove()
end

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:SetStation(station)
	self.station = station
end

function PANEL:SetVisualizerEnabled(bool)
	self.VisualizerEnabled = bool
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(self.Color)
	surface.DrawRect(0, 0, w, h)

	if self.Blur then
		DrawBlur(self,self.BlurAmount or 1)
	end

	if self.VisualizerEnabled then
		if IsValid(self.station) then
			local bands = {}
			self.station:FFT(bands , FFT_8192)
			local srznach = 0
			local min, max = 1, 30
			for i = 1, self.num do
				if i ~= nil and bands ~= nil and self.bandwidth ~= nil and self.amp ~= nil and bands[i] ~= nil then
					surface.SetDrawColor(escore.colors.radio.visualizer)
					local posx = i*(self.bandwidth+self.gaps)
					local posy = bands[i]*self.amp
					local ct = CurTime()
					surface.DrawLine(posx,0,posx,posy)

					if i >= min and i <= max then
						srznach = srznach + bands[i]*10
						self.Speed = self.startspeed + srznach/max
					end
				end
			end
		else
			if self.Speed ~= self.startspeed then
				self.Speed = self.startspeed
			end
		end
	end
end



---------------
/// EFFECTS ///
---------------
-- Requirements for the effect:
-- 1) New panel must be created
-- 2) Panel must be returned in function
-- Add new effect: escore.EffectManager:RegisterEffect("name",function)
local function ef_snow(bg)
	local pEffect = vgui.Create("DPanel",bg)
		pEffect:SetSize(bg:GetWide(),bg:GetTall())
		pEffect:SetText("")
		pEffect:SetMouseInputEnabled(false)
		pEffect:SetAlpha(200)

	--config
	local particles = {}
	local startspeed = 0.05
	local amount = escore.config.snow_amount
	local size = {min=3,max=8}

	--physics config
	local physics = bg:GetPhysics()
	local gravity = {min=12,max=30}
	local amplitude = {min=-0.3,max=0.3}
	local maxdist = 100 --pixels
	local inertdamper = 0.01
	local inertmodifer = 1

	local function genone(override)
		local randcol = math.random(0,45)
		local tbl = {
			physics   = physics,
			gravity   = math.random(gravity.min, gravity.max),
			amplitude = math.Rand(amplitude.min, amplitude.max),
			size      = math.random(size.min, size.max),
			color     = Color(255-randcol, 255-randcol, 255, 255-math.random(0,200)),
			x = math.random(pEffect:GetWide()),
			y = math.random(pEffect:GetTall()),
			xinert = 0,
			yinert = 0
		}

		if override then
			if type(override) == "table" then
				for k, v in ipairs(override) do
					tbl[k] = v
				end
			end
		end
		return tbl
	end

	--generating
	for i = 1, amount.max do
		table.insert(particles,genone())
	end

	--logic
	local delay = 0
	pEffect.Paint = function(self,w,h)
		local suspension = (RealFrameTime()*100)

		if escore.config.effect_fps_suspension then
			--optimization (near 100 fps)
			if suspension > 1.6 and #particles > amount.min then
				particles[#particles] = nil
			end
			if suspension < 0.6 and #particles <= amount.max then
				table.insert(particles,genone())
			end
		end

		for k, v in ipairs(particles) do
			--draw snow flake
			draw.RoundedBox(16,v.x, v.y, v.size, v.size, v.color)

			--x manipulation
			v.x = v.x + (v.amplitude * (bg.Speed*suspension) or 1)

			--y manipulation
			v.y = v.y + (startspeed*v.gravity*(bg.Speed*suspension) or 1)

			--x out except
			if v.x < 0 then	v.x = w
			elseif v.x > w then v.x = 0 end

			--y out except
			if v.y < 0 then 
				v.y = h-3
				v.x = math.random(10,w-10)
			elseif v.y > h then 
				v.y = 3
				v.x = math.random(10,w-10) 
			end

			--lifetime
			if v.lifetime then
				if not v.life then
					v.life = v.lifetime
				else
					if v.life > 0 then
						v.life = v.life - 0.01
					else
						particles[k] = nil
					end
				end
			end

			if physics and v.physics then
				local mx, my = gui.MouseX(), gui.MouseY()

				--spawning with rmb
				if input.IsMouseDown(MOUSE_RIGHT) then
					if delay < CurTime() then
						table.insert(particles,genone({x=mx,y=my,gravity=math.random(-30,30),amplitude=math.Rand(-1,1),lifetime=3}))
						delay = CurTime() + 0.01
					end
				end

				--
				local dist = math.sqrt( (mx-v.x)^2 + (my-v.y)^2 )
				if dist < maxdist then
					local modifer = inertmodifer * suspension
					--attraction on lmb
					if input.IsMouseDown(MOUSE_LEFT) then
						modifer = -modifer
					end

					--x inertion
					if v.x >= mx then
						v.xinert = v.xinert + (v.x - mx)/(maxdist*10) * modifer
					elseif v.x <= mx then
						v.xinert = v.xinert - (mx - v.x)/(maxdist*10) * modifer
					end

					--y inertion
					if v.y >= my then
						v.yinert = v.yinert + (v.y - my)/(maxdist*10) * modifer
					elseif v.y <= my then
						v.yinert = v.yinert - (my - v.y)/(maxdist*10) * modifer
					end

					local color = table.Copy(v.color)
					color.a = (110-dist)
					surface.SetDrawColor(color)
					surface.DrawLine(mx,my,v.x+v.size*0.5,v.y+v.size*0.5)
				end

				--inertion
				if v.xinert > 0 then
					v.x = v.x + v.xinert
					v.xinert = v.xinert - inertdamper * suspension
				elseif v.xinert < 0 then
					v.x = v.x + v.xinert
					v.xinert = v.xinert + inertdamper * suspension
				end
				if v.yinert > 0 then
					v.y = v.y + v.yinert
					v.yinert = v.yinert - inertdamper * suspension
				elseif v.yinert < 0 then
					v.y = v.y + v.yinert
					v.yinert = v.yinert + inertdamper * suspension
				end

			end --if physics
		end
	end
	return pEffect
end

local function ef_dots(bg)
	--DOTS
	local pEffect = vgui.Create("DPanel",bg)
		pEffect:SetSize(bg:GetWide(),bg:GetTall())
		pEffect:SetText("")
		pEffect:SetMouseInputEnabled(false)
		pEffect:SetAlpha(200)

	--config
	local particles = {}
	local startspeed = 0.05
	local amount = escore.config.dots_amount
	local size = {min=3,max=3}

	--physics config
	local physics = bg:GetPhysics()
	local gravity = {min=-10,max=10}
	local amplitude = {min=-0.3,max=0.3}
	local maxdist = 100 --pixels
	local inertdamper = 0.04
	local inertmodifer = 3

	local function genone(override)
		local randcol = math.random(0,45)
		local tbl = {
			physics   = physics,
			gravity   = math.random(gravity.min, gravity.max),
			amplitude = math.Rand(amplitude.min, amplitude.max),
			size      = math.random(size.min, size.max),
			color     = Color(255,255,255, 255),
			x = math.random(pEffect:GetWide()),
			y = math.random(pEffect:GetTall()),

			xinert = 0,
			yinert = 0
		}

		if override then
			if type(override) == "table" then
				for k, v in pairs(override) do
					tbl[k] = v
				end
			end
		end
		return tbl
	end

	--generating
	for i = 1, amount.max do
		table.insert(particles,genone())
	end

	--logic
	local delay = 0
	pEffect.Paint = function(self,w,h)
		local suspension = (RealFrameTime()*100) -- > 1.4, < 0.7

		--optimization (near 100 fps)
		if escore.config.effect_fps_suspension then
			if suspension > 1.4 and #particles > amount.min then
				particles[#particles] = nil
			end
			if suspension < 0.7 and #particles <= amount.max then
				local x = math.random(pEffect:GetWide())
				local y = {3,pEffect:GetTall()-3}
				table.insert(particles,genone({x=x, y=y[math.random(1,2)]}))
			end
		end
				
		for id, v in ipairs(particles) do
			--draw
			surface.SetDrawColor(v.color)
			surface.DrawRect(v.x, v.y, v.size, v.size) 

			--x manipulation
			v.x = v.x + (v.amplitude * (bg.Speed*suspension) or 1)

			--y manipulation
			v.y = v.y + (startspeed*v.gravity*(bg.Speed*suspension) or 1)

			--x out except
			if v.x < 0 then	
				v.x = w-3
				v.y = math.random(10,h-10)
			elseif v.x > w then 
				v.x = 3
				v.y = math.random(10,h-10)
			end

			--y out except
			if v.y < 0 then 
				v.y = h-3
				v.x = math.random(10,w-10)
			elseif v.y > h then 
				v.y = 3
				v.x = math.random(10,w-10) 
			end

			--lifetime
			if v.lifetime then
				if not v.life then
					v.life = v.lifetime
				else
					if v.life > 0 then
						v.life = v.life - 0.01
					else
						particles[k] = nil
					end
				end
			end

			for id2, p in ipairs(particles) do
				if id ~= id2 then
					local px, py = p.x, p.y
					local dist = math.sqrt( (px-v.x)^2 + (py-v.y)^2 )
					if dist < maxdist then
						local color = table.Copy(v.color)
						color.a = (110-dist)
						surface.SetDrawColor(color)
						surface.DrawLine(v.x+v.size*0.5, v.y+v.size*0.5, px+p.size*0.5, py+p.size*0.5)

						-- --draw
						-- surface.SetDrawColor(v.color.r, v.color.g, v.color.b, color.a)
						-- surface.DrawRect(v.x, v.y, v.size, v.size) 
					end
				end
			end

			if physics and v.physics then
				local mx, my = gui.MouseX(), gui.MouseY()

				local dist = math.sqrt( (mx-v.x)^2 + (my-v.y)^2 )
				if dist < maxdist then
					local modifer = inertmodifer * suspension
					--attraction on lmb
					if input.IsMouseDown(MOUSE_LEFT) then
						modifer = -modifer
					end


					--x inertion
					local xdist = (v.x-mx)
					v.xinert = v.xinert + xdist/(maxdist*10) * modifer

					--y inertion
					local ydist = (v.y - my)
					v.yinert = v.yinert + ydist/(maxdist*10) * modifer

					local color = table.Copy(v.color)
					color.a = (110-dist)
					surface.SetDrawColor(color)
					surface.DrawLine(mx,my,v.x+v.size*0.5,v.y+v.size*0.5)
				end

				--inertion
				if v.xinert > 0 then
					v.x = v.x + v.xinert
					v.xinert = v.xinert - inertdamper * suspension
				elseif v.xinert < 0 then
					v.x = v.x + v.xinert
					v.xinert = v.xinert + inertdamper * suspension
				end
				if v.yinert > 0 then
					v.y = v.y + v.yinert
					v.yinert = v.yinert - inertdamper * suspension
				elseif v.yinert < 0 then
					v.y = v.y + v.yinert
					v.yinert = v.yinert + inertdamper * suspension
				end

			end --if physics
		end
	end
	return pEffect
end

EffectManager:RegisterEffect("snow",ef_snow)
EffectManager:RegisterEffect("dots",ef_dots)


vgui.Register( "escore.background", PANEL, "EditablePanel" )