--LUA REFRESH
if eboard then
	if eboard:IsValid() then eboard:Remove() end
end

eboard = eboard or {}
-- local txt = escore.text

-----------------
/// MATERIALS ///
-----------------
eboard.Materials = {
	--icons
	["tag"]    = Material( "materials/icons/escoretag.png",   "smooth" ),
	["prop"]   = Material( "materials/icons/escoreprop.png",  "smooth" ),
	["dollar"] = Material( "materials/icons/escoredollar.png","smooth" ),
	["steam"]  = Material( "materials/icons/escoresteam.png", "smooth" ),
	["job"]    = Material( "materials/icons/escorejob.png",   "smooth" ),
	["kill"]   = Material( "materials/icons/escoreknife.png", "smooth" ),
	["death"]  = Material( "materials/icons/escoreskull.png", "smooth" ),
	["find"]   = Material( "materials/icons/escorefind.png",  "smooth" ),
	["radio"]  = Material( "materials/icons/escoreradio.png", "smooth" ),
	["mute"]   = Material( "materials/icons/escoremute.png",  "smooth" ),
	["unmute"] = Material( "materials/icons/escoreunmute.png","smooth" ),
	["effect"] = Material( "materials/icons/escoreeffect.png","smooth" ),
	--radio
	["play"]   = Material( "materials/icons/escoreplay.png",  "smooth" ),
	["skip"]   = Material( "materials/icons/escoreskip.png",  "smooth" ),
	["stop"]   = Material( "materials/icons/escorestop.png",  "smooth" ),
	["next"]   = Material( "materials/icons/escorenext.png",  "smooth" ),
	["prev"]   = Material( "materials/icons/escoreprev.png",  "smooth" ),
	["wait"]   = Material( "materials/icons/escorewait.png",  "smooth" ),
	--commands
	["tp"]     = Material( "materials/icons/escoregoto.png",  "smooth" ),
	["bring"]  = Material( "materials/icons/escorebring.png", "smooth" ),
	["freeze"] = Material( "materials/icons/escorefreeze.png","smooth" )
}



------------
/// MAIN ///
------------
--Mouse pos saving
local mousepos = {x=ScrW()*0.5,y=ScrH()*0.5}
function eboard:Build()
	local prevposx, prevposy -- panel pos save
	self.createdtime = CurTime()
	local scrw, scrh = ScrW(), ScrH()
	self.xcoef = 1920 / scrw
	self.ixcoef = scrw / 1920
	self.ycoef = 1080 / scrh
	self.iycoef = scrh / 1920

    ------------------
	/// BACKGROUND ///
	------------------
	local bg = vgui.Create("escore.background",bg)
	bg:SetSize(scrw,scrh)
	bg:SetZPos(-1001)
	bg:SetColor(escore.colors.scoreboard.bg)
	bg:MakePopup()
	bg:SetAlpha(1)
	bg:AlphaTo(255, escore.config.animtime)
	self.panel = bg

	--EFFECTS
	bg:SetKeyboardInputEnabled(false)
	bg:SetPhysics(escore.config.effectPhysics)
	bg:SetSpeed(escore.config.effect_speed)
	bg:SetEffectEnabled(GetConVar("escore_effect"):GetBool())
	bg:SetEffect(escore.config.effect)
	bg:SetVisualizerEnabled(escore.config.radio.visualizer)
	--Blur effect
	local blur = math.Clamp(escore.config.blurStrength,0,1000)
	if blur ~= 0 then
		bg:SetBlur(true, escore.config.blurStrength)
	end

	--------------------
	/// SERVER TITLE ///
	--------------------
	local wide = bg:GetWide()*math.Clamp(escore.config.playerwide, 0.1, 1)
	local logo = vgui.Create("DPanel",bg)
	logo:SetSize(wide,bg:GetTall()*0.1)
	local toposx, toposy = bg:GetWide()*0.5-logo:GetWide()*0.5, 0
	if escore.config.logoanim then logo.online = false
	else logo.online = true end
	function logo:Paint(w,h)
		draw.SimpleText(escore.config.ServerName,"escore_60_500",w/2,h/3,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		if self.online then
			draw.SimpleText(escore.text["online"]..": "..eboard.online.."/"..game.MaxPlayers(),"escore_20_500",w/2,h*0.8,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
	if escore.config.logoanim then
		logo:SetPos(toposx,bg:GetTall()*0.5-logo:GetTall()*0.5)
		timer.Simple(0.5,function()
			logo:MoveTo(toposx,toposy,escore.config.logoanimtime,0,-1,function()
				logo.online = true
				local pnl = eboard.panel.content
				pnl:SetVisible(true)
				pnl:SetAlpha(0)
				pnl:AlphaTo(255,escore.config.animtime)
			end)
		end)
	else
		logo:SetPos(toposx, toposy)
	end

	------------------
	/// MAIN PANEL ///
	------------------
	local gap = 5
	local _, posy = logo:LocalToScreen(0,logo:GetTall())
	local panel = vgui.Create("DPanel",bg)
	panel:SetSize(wide,bg:GetTall() - logo:GetTall() - gap*2 - (bg:GetTall()*0.05*self.ycoef))
	panel:SetPos(bg:GetWide()*0.5-panel:GetWide()*0.5, posy+gap)
	panel.Paint = function(self,w,h)
	end
	if escore.config.logoanim then
		panel:SetVisible(false)
	end
	self.panel.content = panel

	local nickpos = panel:GetWide()*0.05*self.xcoef
	local jobpos = panel:GetWide()*0.5
	local grouppos = panel:GetWide()*0.75
	local pingpos = panel:GetWide()*0.94

	--TOP INFO (like job, time, etc)
	local dopinfo = vgui.Create( "DPanel", panel)
	dopinfo:SetTall( 30 )
	dopinfo:SetWide( panel:GetWide() )
	local font = "escore_20_500"
	function dopinfo:Paint(w,h)
		--NICKNAME
		draw.SimpleText(escore.text["nickname"], font,nickpos+escore.util.GetTextSize(escore.text["nickname"],font).w*0.5,h*0.5,escore.colors.text.main,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		--JOB
		if DarkRP and not escore.config.hide_all_jobs then
			draw.SimpleText(escore.text["job"], font,jobpos,h*0.5,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		--USERGROUP
		if escore.config.ShowGroups then
			draw.SimpleText(escore.text["privilege"], font,grouppos,h*0.5,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		--PING
		draw.SimpleText(escore.text["ping"], font,pingpos,h*0.5,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	--------------------
	/// BOTTOM PANEL ///
	--------------------
	self:ReloadBottomButtons()
	local elements = 2 + #self.botbuttons
	local size = 50
	local botlist = vgui.Create("DIconLayout",bg)
	botlist:SetSpaceX(3)
	botlist:SetSize(size*elements + botlist:GetSpaceX()*elements,size)
	botlist:CenterHorizontal()
	local posx,_ = botlist:GetPos()
	local posy = bg:GetTall()-botlist:GetTall()-5
	botlist:SetPos(posx,bg:GetTall())
	botlist:MoveTo(posx,posy,escore.config.animtime*2)

	--------------
	/// SEARCH ///
	--------------
	local psearch = vgui.Create("DButton",botlist)
	psearch:SetSize(size,size)
	psearch:SetText("")
	local posx1,_ = botlist:GetPos()
	function psearch:Paint(w,h)
		local hovered = self:IsHovered()
		surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or escore.colors.scoreboard.icon )
		surface.SetMaterial( eboard.Materials["find"] )
		surface.DrawTexturedRect( 5, 5, h-10, h-10 )
	end
	local hint = self:AddHelpText(psearch,escore.text["search"],nil,5,"top")

	local txte
	local tex
	function psearch:DoClick()
		local tall = self:GetTall()*0.80
		local _,posy = self:GetPos()
		if IsValid(txte) then
			txte:Close()
			self.opened = false
			return
		end
		local posx,posy = self:LocalToScreen(self:GetWide(), 0)
		local offset = 100

		txte = vgui.Create("DTextEntry",bg)
		bg.ready2close = false
		txte:SetSize(1,tall)
		txte:SetPos(offset, posy)
		txte:MakePopup()
		txte:SizeTo(posx1-offset*2,tall,escore.config.animtime)
		txte:SetFont("escore_20_500")
		self.opened = true
		function txte:Paint(w,h)
			draw.RoundedBox(16,0,0,w,h,escore.colors.search.bg)

			draw.SimpleText("Enter / Tab",self:GetFont(),w-20,h*0.5,escore.colors.text.main,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
			self:DrawTextEntryText( escore.colors.search.text, escore.colors.search.highlight, escore.colors.search.text )
		end
		function txte:OnValueChange(val)
			eboard:SearchPlayer(val)
		end
		function txte:Close() 
			self:SizeTo(1,tall,escore.config.animtime,0,-1,function()
				self:Remove()
				eboard:RefreshPlayers(true)
				bg.ready2close = true
			end)
		end
		local prevstate = 0
		function txte:OnKeyCodeReleased( key )
			if key ~= prevstate then
				if (key ==  KEY_TAB) or (key == KEY_ESCAPE) then
					psearch:DoClick()
					prevstate = 0
					return
				end
			else
				prevstate = key
			end
		end
	end

	-------------------
	/// RADIO PANEL ///
	-------------------
	if escore.config.radio.enable then
		local radiopos
		local pradio = vgui.Create("DButton",botlist)
		pradio:SetSize(size,size)
		pradio:SetText("")

		function pradio:Paint(w,h)
			local hovered = self:IsHovered()
			surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or escore.colors.scoreboard.icon )
			surface.SetMaterial( eboard.Materials["radio"] )
			surface.DrawTexturedRect( 5, 5, h-10, h-10 )
		end

		function pradio:DoClick()
			if IsValid(self.panel) then
				local posx,posy = self.panel:GetPos()
				radiopos = {x=posx,y=posy}
				self.panel:Close()
				return
			end

			self.panel = vgui.Create("escore.window",bg)
			local station = eboard.radio:GetStation()
			local panel = self.panel
			local wide,height = bg:GetSize()
			panel:SetSize(wide*0.20*eboard.xcoef,height*0.14*eboard.ycoef)
			panel:SetTitle(escore.text["radio"],nil,"escore_24_1000",TEXT_ALIGN_CENTER)
			if radiopos then
				panel:SetPos(-panel:GetWide(), radiopos.y)
				panel:MoveTo(radiopos.x,radiopos.y,escore.config.animtime)
			else
				panel:SetPos(-panel:GetWide(), height-panel:GetTall()-10)
				local _,posy = panel:GetPos()
				panel:MoveTo(10,posy,escore.config.animtime)
			end
			plcont = panel:GetContent()

			function panel:Close() 
				local _,posy = self:GetPos()
				self:MoveTo(-self:GetWide(),posy,escore.config.animtime,0,-1,function()
					self:Remove()
				end)
			end

			local dLogo = vgui.Create( "HTML", plcont )
			local logo = station.logo
			local size = plcont:GetTall() * 0.7
			dLogo:SetSize(size,size)
			dLogo:SetMouseInputEnabled( false )
			dLogo.frequence = eboard.radio.id
			dLogo:SetHTML( string.format( "<img src='%s' width ='%s' height='%s' style='overflow:hidden;' >", logo , dLogo:GetWide()-20, dLogo:GetTall()-20 ) )
			function dLogo:Think()
				local freq = eboard.radio.id
				if self.frequence ~= freq then
					self:SetHTML( string.format( "<img src='%s' width ='%s' height='%s' style='overflow:hidden;' >", eboard.radio:GetStation().logo , dLogo:GetWide()-20, dLogo:GetTall()-20 ) )
					self.frequence = freq
				end
			end

			function plcont:Paint(w,h)
				local station = (eboard.radio:GetStation(eboard.radio.playing_id or eboard.radio.id))
				draw.SimpleText(escore.text["current"]..": "..station.name,"escore_20_500",size+5,5,escore.colors.radio.text)

				draw.SimpleText(eboard.radio:GetStation().name,"escore_26_500",size+5,30,escore.colors.radio.text)
			end

			local blist = vgui.Create("DIconLayout",plcont)
			local bsize = 16
			local bsize2 = 12
			blist:SetSize(plcont:GetWide(),plcont:GetTall()*0.3)
			blist:SetSpaceX(3)
			blist:Dock(BOTTOM)
			blist:InvalidateParent(true)

			local prev = vgui.Create("DButton",blist)
			prev:SetSize(blist:GetWide()/6, blist:GetTall())
			prev:SetText("")
			function prev:Paint(w,h)
				local hovered = self:IsHovered()
				local posx, posy = w*0.5 - bsize2*0.5,  h*0.5 - bsize2*0.5
				surface.SetMaterial( eboard.Materials["prev"] )
				surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or escore.colors.scoreboard.icon )
				surface.DrawTexturedRect( posx, posy, bsize2, bsize2 )
			end
			function prev:DoClick()
				eboard.radio:Prev()
			end

			local play = vgui.Create("DButton",blist)
			play:SetSize(blist:GetWide()/6, blist:GetTall())
			play:SetText("")
			function play:Paint(w,h)
				local hovered = self:IsHovered()
				local valid = eboard.radio:Valid()

				draw.NoTexture()
				if eboard.radio:GetState() == "loading" then
					surface.SetMaterial( eboard.Materials["wait"] )
				else
					if valid then
						if eboard.radio.id ~= eboard.radio.playing_id then
							surface.SetMaterial( eboard.Materials["skip"] )
						else
							surface.SetMaterial( eboard.Materials["stop"] )
						end
					else
						surface.SetMaterial( eboard.Materials["play"] ) 
					end
				end
				surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or escore.colors.scoreboard.icon )
				local posx, posy = w*0.5 - bsize*0.5,  h*0.5 - bsize*0.5
				surface.DrawTexturedRect( posx, posy, bsize, bsize )
			end

			function play:DoClick()
				eboard.radio:Switch()
			end

			local bnext = vgui.Create("DButton",blist)
			bnext:SetSize(blist:GetWide()/6, blist:GetTall())
			bnext:SetText("")
			function bnext:Paint(w,h)
				local hovered = self:IsHovered()
				local posx, posy = w*0.5 - bsize2*0.5,  h*0.5 - bsize2*0.5
				surface.SetMaterial( eboard.Materials["next"] )
				surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or escore.colors.scoreboard.icon )
				surface.DrawTexturedRect( posx, posy, bsize2, bsize2 )
			end
			function bnext:DoClick()
				eboard.radio:Next()
			end

			local cv = GetConVar( "eradio_volume" )
			local volume = vgui.Create("escore.slider",blist)
			volume:SetSize(blist:GetWide()*0.5 - blist:GetSpaceX() * 3 , blist:GetTall())
			volume:SetValue(cv:GetFloat())
			volume:SetConVar("eradio_volume")
			volume.OnValueChanged = function(self,val)
				eboard.radio:SetVolume(val)
			end
		end

		local hint = self:AddHelpText(pradio,escore.text["radio"],nil,5,"top")
	end

	----------------------------
	/// OTHER BOTTOM BUTTONS ///						
	----------------------------
	for _,v in ipairs(self.botbuttons) do
		if not v.Type or v.Type == "button" then
			local button = vgui.Create("DButton",botlist)
			button:SetSize(size,size)
			button:SetText("")

			function button:Paint(w,h)
				local hovered = self:IsHovered()
				local col = escore.colors.scoreboard.icon
				if v.Color then
					col = v.Color
				end
				if v.Icon then
					surface.SetDrawColor( hovered and escore.colors.scoreboard.iconhover or col )
					surface.SetMaterial( v.Icon )
					surface.DrawTexturedRect( 5, 5, h-10, h-10 )
				else
					local text = string.sub(v.Name or "Null", 1, 1)
					if v.DisplayText then text = v.DisplayText end
					draw.SimpleText(text,"escore_36_1000",w*0.5,h*0.5,hovered and escore.colors.scoreboard.iconhover or col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
			end
			function button:DoClick()
				v.DoClick(LocalPlayer())
			end
			if v.DoRightClick then
				function button:DoRightClick()
					v.DoRightClick(LocalPlayer())
				end
			end

			if v.IconLink then
				button.Paint = nil
				local icon = button:Add("HTML")
				icon:SetMouseInputEnabled(false)
				icon:SetSize(button:GetWide(),button:GetTall())
				icon:SetHTML(string.format( [[ <body style="overflow: hidden; display:block; margin:auto;"><img src="%s" width ="%s" height="%s"></body> ]], v.IconLink , icon:GetWide()-5, icon:GetTall()-5))
			end

			self:AddHelpText(button,v.HoverText,nil,5,"top")
		else
			if v.Type == "separator" then
				local sep = vgui.Create("DPanel",botlist)
				sep:SetSize(2,size)
				function sep:Paint(w,h)
					surface.SetDrawColor(escore.colors.scoreboard.separator:Unpack())
					surface.DrawRect(0,10,w,h-20)
				end
			end
		end
	end

	------------------
	/// PLAYERLIST ///
	------------------
	local Scroll = vgui.Create( "DScrollPanel", self.panel.content )
	Scroll:SetSize(self.panel.content:GetWide(),self.panel.content:GetTall()-dopinfo:GetTall())
	Scroll:SetPos(0,dopinfo:GetTall())
	Scroll:GetVBar():SetHideButtons(true)
	self.Scroll = Scroll
	Scroll.VBar.Paint = function(self, w, h) end
	Scroll.VBar.btnUp.Paint = function( s, w, h ) end
    Scroll.VBar.btnDown.Paint = function( s, w, h ) end
    Scroll.VBar.btnGrip.Paint = function( s, w, h ) draw.RoundedBox( 0, 4, 0, w/2, h, escore.colors.scoreboard.main) end

    local activelist = {}
    function eboard:BuildPlayers()
		self.plist = vgui.Create("DIconLayout",self.Scroll)
		self.plist:SetAlpha(1)
		self.plist:AlphaTo(255,escore.config.animtime)
		self.plist:SetSize(self.panel.content:GetWide()-Scroll.VBar:GetWide(),self.panel.content:GetTall())
		self.plist:SetSpaceY(escore.config.gap)

		local new_cats = {}

		if DarkRP and escore.config.JobsCategories then
			local cats = table.Copy(DarkRP.getCategories()["jobs"])
			for k,v in ipairs(cats) do
				if v.canSee then 
					if not v.canSee(LocalPlayer()) then
						continue
					end
				end
				new_cats[v.name] = v.color or Color(255,255,255)
			end

			new_cats["Unknown"] = {
				color = Color(255,255,255),
			}
		end
				        


		for category,plist in pairs(self.playerlist) do
			if escore.config.hidejobs[category] then
				continue
			end

			if (category ~= "All") and (escore.config.ShowCollapsibleCategories and not escore.config.hide_all_jobs) then
				if #plist > 0 then
					local cat = vgui.Create( "DButton", self.plist)
			        cat:SetTall( escore.config.categorytall )
			        cat:SetWide( self.plist:GetWide() )
			        cat:SetText("")
			        local categcolor = escore.colors.default.white

			        if escore.config.JobsCategories then
			        	if new_cats[category] then
			        		categcolor = new_cats[category]
			        	end
			        else
			        	local ply = plist[1]
			        	if ply and IsValid(ply) then
			        		clr = ply:getJobTable().color
			        		if clr then categcolor = clr end
			        	end
			       	end


			        function cat:Paint(w,h)
			        	local hover = self:IsHovered()
			        	local active = activelist[category] or false
			        	if not hover then
							surface.SetDrawColor(escore.colors.category.main)
							surface.DrawRect(0, 0, w, h)
						else
							surface.SetDrawColor(escore.colors.category.hover)
							surface.DrawRect(0, 0, w, h)
						end

						draw.SimpleText(category.." - "..#plist,"escore_20_500",10,h*0.5,hover and escore.colors.category.texthover or categcolor,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
						draw.SimpleText(active and "<" or "˅","escore_20_500",w-10,h*0.4,escore.colors.text.main,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
						surface.SetDrawColor(categcolor)
						surface.DrawRect(0, 0, 3, h)
			        end
			        function cat:DoClick()
			        	if activelist[category] then 
			        		activelist[category] = nil 
			        	else
				        	activelist[category] = true
				        end

			        	eboard:RefreshPlayers(true)
			        end
			    end
			end

			if table.IsEmpty(plist) then
				local pnl = vgui.Create( "DButton", self.plist)
			        pnl:SetTall( escore.config.playertall )
			        pnl:SetWide( self.plist:GetWide() )	
			        pnl:SetText("")

			    function pnl:Paint(w,h)
			    	surface.SetDrawColor(escore.colors.user.main)
					surface.DrawRect(0, 0, w, h)

			    	draw.SimpleText(escore.text["nofound"],"escore_20_500",w*0.5,h*0.5,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			    end
			end

			if not activelist[category] then
			for id, ply in pairs(plist) do
				if IsValid(ply) then
				local jobcolor = escore.colors.default.white

				if not escore.config.hide_all_jobs then
					jobcolor = team.GetColor(ply:Team()) or escore.colors.default.white
				end

				if type(jobcolor) ~= "table" then jobcolor = escore.colors.default.white end
															
				--main player panel
				local pnl = vgui.Create( "DButton", self.plist)
			        pnl:SetTall( escore.config.playertall )
			        pnl:SetWide( self.plist:GetWide() )	
			        pnl:SetText("")

				local Avatar = vgui.Create( "AvatarImage", pnl )
					Avatar:SetSize(pnl:GetTall()-2, pnl:GetTall()-2)
					Avatar:SetPos(12,pnl:GetTall()*0.5-Avatar:GetTall()*0.5)
					Avatar:SetPlayer( ply, 64 )
					Avatar:SetMouseInputEnabled( false )

				--MUTE
				local mutebutton = vgui.Create("DButton",pnl)
					local size = 24
					mutebutton:SetSize(size,pnl:GetTall())
					mutebutton:SetPos(pnl:GetWide()-mutebutton:GetWide()-5)
					mutebutton:CenterVertical()
					mutebutton:SetText("")
					function mutebutton:Paint(w,h)
						if IsValid(ply) then
							local muted = ply:IsMuted()
							surface.SetDrawColor( self:IsHovered() and escore.colors.playerpanel.iconshover or escore.colors.playerpanel.icons )
							surface.SetMaterial(muted and eboard.Materials["mute"] or eboard.Materials["unmute"] )
							surface.DrawTexturedRect( w*0.5 - size*0.5, h*0.5 - size*0.5, size, size )
						end
					end
					function mutebutton:DoClick()
						ply:SetMuted( not ply:IsMuted() )
					end


				pnl.w, pnl.h = pnl:GetSize()
				function pnl:Paint()
					if not IsValid(ply) then 
						self.playerlist[id] = nil
						return
					end
					local drawbg = true
					local hover = self:IsHovered()
					if IsValid(eboard.playerpanel) then
						if eboard.playerpanel.player == ply then
							if not hover then
								surface.SetDrawColor(escore.colors.user.active)
								surface.DrawRect(0, 0, self.w, self.h)
							else
								surface.SetDrawColor(escore.colors.user.activehover)
								surface.DrawRect(0, 0, self.w, self.h)
							end
							drawbg = false
						end
					end

					if drawbg then
						if not hover then
							surface.SetDrawColor(escore.colors.user.main)
							surface.DrawRect(0, 0, self.w, self.h)
						else
							surface.SetDrawColor(escore.colors.user.hover)
							surface.DrawRect(0, 0, self.w,self. h)
						end
					end

					if not escore.config.hide_all_jobs then
						surface.SetDrawColor(jobcolor)
						surface.DrawRect(0, 0, 3, self.h)
					end

					--nickname
					local addstr = ((LocalPlayer() == ply and " ( "..escore.text["you"].." )") or (ply:GetFriendStatus() == "friend" and " ( "..escore.text["friend"].." )" or "")) or ""
					draw.SimpleText(ply:Name()..addstr,"escore_20_500",nickpos,self.h*0.5,escore.colors.text.main,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

					--job
					if DarkRP and not escore.config.hide_all_jobs then
						draw.SimpleText(ply:getDarkRPVar("job") or "Undefined","escore_20_500",jobpos,self.h*0.5,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end

					--usergroup
					if escore.config.ShowGroups then
						local ug = ply:GetUserGroup() or "Undefined"

						local groupsets = escore.config.usergroups[ug] or nil
						if groupsets then
							if not groupsets["Ignore"] then
								local col = groupsets["Color"] or escore.colors.text.main
								local text = groupsets["Text"] or ""
								local font = "escore_20_500"
								local textsize = escore.util.GetTextSize(text,font)
								-- draw.RoundedBox(26,grouppos-textsize.w*0.5-15,self.h*0.5-5,10,10,col)
								draw.SimpleText(text,font,grouppos,self.h*0.5,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
							end
						end
					end

					--ping
					local ping = ply:Ping()
					local col = escore.colors.text.main
					if ping <= 60 then
						col = escore.colors.scoreboard.goodping
					elseif ping <= 140 then
						col = escore.colors.scoreboard.averping
					else
						col = escore.colors.scoreboard.badping
					end

					draw.SimpleText(ping or "nil","escore_20_500",pingpos,self.h*0.5,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		        end

		        function pnl:Think()
		        	if not IsValid(ply) then
		        		self:Remove()
		        	end
		        end

		        ----------------
		       	/// PROFILER ///
		       	----------------
		        function pnl:DoClick()
		        	if IsValid(self.context) then self.context:Close(true) end

		        	local bBuild = false
		        	if IsValid(eboard.playerpanel) then
	        			prevposx,prevposy = eboard.playerpanel:GetPos()
		        		local posx, posy = eboard.playerpanel:GetPos()
		    			if eboard.playerpanel.player ~= ply then
		    				eboard.playerpanel:MoveTo(scrw,posy,escore.config.animtime*0.5,0,-1,function(data,pnl)
		    					eboard.playerpanel:Remove()
		    					if IsValid(self) then
		    						self:DoClick()
		    					end
		    				end)
		        		else
		        			eboard.playerpanel:MoveTo(scrw,posy,escore.config.animtime,0,-1,function(data,pnl)
		    					eboard.playerpanel:Remove()
		    				end)
		        		end
		        	else bBuild = true end

		        	if bBuild then
		        		eboard:ReloadButtons()
		        		eboard:ReloadInfoButtons()

		        		eboard.playerpanel = vgui.Create("escore.window",bg)
		        		local profiler = eboard.playerpanel
		        		profiler.player = ply

		        		profiler:SetSize(bg:GetWide()*0.16*eboard.xcoef,bg:GetTall()*0.35*eboard.ycoef)
		        		profiler:SetPos(bg:GetWide()+profiler:GetWide() ,prevposy or (bg:GetTall()*0.5 - profiler:GetTall()*0.5))
		        		profiler:MoveTo(prevposx or (bg:GetWide() - profiler:GetWide() - 10), prevposy or (bg:GetTall()*0.5 - profiler:GetTall()*0.5), escore.config.animtime)
		        		function profiler:OnClose()
	        				prevposx,prevposy = self:GetPos()
		        		end

		        		profiler:SetTitle(escore.config.ProfilerName)
		        		local content = profiler:GetContent()

		        		--top
		        		local paneltop = vgui.Create("DPanel",content)
	        			paneltop:SetSize(content:GetWide(),content:GetTall())
	        			paneltop:Dock(FILL)

	        			local avatarsize = paneltop:GetTall()*0.25
	        			local avatarbutton = vgui.Create("DButton",paneltop)
	        				avatarbutton:SetSize(avatarsize, avatarsize)
	        				avatarbutton:CenterHorizontal(0.2)
	        				avatarbutton:ESetPosY(paneltop:GetTall()*0.1)
	        				avatarbutton.Paint = nil
	        			function avatarbutton:DoClick()
	        				if IsValid(ply) then
	        					ply:ShowProfile()
	        				end
	        			end

		        		local avatar = vgui.Create("escore.avatar",avatarbutton)
		        			avatar:Dock(FILL)
		        			avatar:InvalidateParent(true)
		        			avatar:SetPlayer(ply,128)
		        			avatar:SetMouseInputEnabled(false)

		        		local cenx,ceny = avatarbutton:EGetCenter()
		        		local overlaycol = Color(13,13,15,200)
		        		function avatarbutton:PaintOver(w,h)
	        				local hovered = self:IsHovered()
	        				if hovered then
	        					local cenx,ceny = w*0.5,h*0.5
	        					--circle
	        					draw.NoTexture()
		        				surface.SetDrawColor(overlaycol:Unpack())
		        				escore.util.DrawCircle(cenx,ceny,avatarbutton:GetWide()*0.5,256)

		        				draw.SimpleText(escore.text["openprof"],"escore_16_500",cenx,ceny,escore.colors.text.main,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	        				end
	        			end

		        		function paneltop:Paint(w,h)
		        			if IsValid(ply) then
			        			local jobcolor = escore.colors.default.white

			        			if not escore.config.hide_all_jobs then
			        				jobcolor = team.GetColor(ply:Team()) or escore.colors.default.white
			        			end

			        			if not IsColor(jobcolor) then jobcolor = escore.colors.default.white end
			        			profiler:SetTitleColor( jobcolor )

			        			draw.RoundedBox(0,0,0,w,ceny,jobcolor)

			        			draw.NoTexture()
			        			surface.SetDrawColor(escore.colors.playerpanel.bg.r, escore.colors.playerpanel.bg.g, escore.colors.playerpanel.bg.b, escore.colors.playerpanel.bg.a)
			        			escore.util.DrawCircle(cenx,ceny,avatarbutton:GetWide()*0.5+8)

			        			draw.RoundedBox(0,0,h-1,w,1,jobcolor)
			        		end
		        		end

		        		local pnick = vgui.Create("DButton",paneltop)
		        		pnick:SetText("")
		        		local font = "escore_26_500"
		        		local nick = ply:Nick()
		        		local size = escore.util.GetTextSize(nick,font) 
		        		pnick:SetSize(size.w+10,size.h)
		        		pnick:SetPos(avatarbutton:EGetPosX()-8,avatarbutton:EGetPosY()+avatarbutton:GetTall()+10)
		        		function pnick:Paint(w,h)
		        			local text
		        			if IsValid(ply) then
		        				text = ply:Nick() or "nil"
		        				self.nick = text
		        			else
		        				text = (self.nick or "nil")
		        			end
		        			draw.SimpleText(text,font,w*0.5,h*0.5,self:IsHovered() and escore.colors.playerpanel.text or escore.colors.playerpanel.texthover, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		        		end
		        		function pnick:DoClick()
		        			eboard:Notify(escore.text["copyphrase"],2)
    						SetClipboardText(self.nick or "nil")
		        		end

		        		local ilist = vgui.Create("DIconLayout",paneltop)
		        		ilist:SetSpaceX(6)
		        		ilist:SetSpaceY(12)
		        		ilist:SetLayoutDir( TOP )
		        		local offset = 20
		        		ilist:SetPos(offset,pnick:EGetPosY()+pnick:GetTall()+10)
		        		ilist:SetSize(paneltop:GetWide()-offset*2,paneltop:GetTall()-pnick:EGetPosY())

		        		local font = "escore_20_500"
		        		for k,v in ipairs(eboard.infobuttons) do
		        			local dpanel = vgui.Create("DButton",ilist)
		        			dpanel:SetText("")
		        			dpanel.content = v.Info(ply)

		        			local text = v.Info(ply)
		        			if v.DisplayInfo then text = v.DisplayInfo(text) end
		        			dpanel:SetSize(5,ilist:GetTall()*0.12)

		        			local iconpnl = vgui.Create("DPanel",dpanel)
        					local size = dpanel:GetTall()*0.8
        					iconpnl:SetSize(size,size)
        					iconpnl:SetPos(5,0)
        					iconpnl:SetMouseInputEnabled(false)
        					iconpnl:CenterVertical()
        					function iconpnl:Paint(w,h)
        						local hovered = dpanel:IsHovered()
        						surface.SetDrawColor( hovered and escore.colors.playerpanel.iconshover or escore.colors.playerpanel.icons )
								surface.SetMaterial( v.Icon )
								surface.DrawTexturedRect( 0,0,w,h )
        					end

        					dpanel:SetSize(escore.util.GetTextSize(text,font).w+iconpnl:GetWide()+20,dpanel:GetTall())

		        			function dpanel:Paint(w,h)
		        				local hovered = self:IsHovered()
	        					draw.RoundedBox(8,0,0,w-1,h-1,hovered and escore.colors.playerpanel.iconshover or escore.colors.playerpanel.icons)
	        					draw.RoundedBox(8,1,1,w-3,h-3,escore.colors.playerpanel.bg)

		        				if IsValid(ply) then
									self.content = v.Info(ply)

									local text = self.content
									if v.DisplayInfo then text = v.DisplayInfo(text) end

									local color = escore.colors.playerpanel.text
									if v.Color then
										if type(v.Color) == "function" then color = v.Color(ply)
										elseif type(v.Color) == "table" then color = v.Color end
									end
									draw.SimpleText(text, font, h+5, h*0.5, self:IsHovered() and escore.colors.playerpanel.texthover or color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		        				else
		        					draw.SimpleText(self.content or escore.text["disconnected"], font, h+5, h*0.5, hovered and escore.colors.playerpanel.texthover or color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		        				end
		        			end

		        			function dpanel:DoClick()
		        				eboard:Notify(escore.text["copyphrase"],2)
		        				SetClipboardText(self.content)
		        			end
		        		end

						if escore.config.ProfilerQuickButtons then
							local quick = vgui.Create("DIconLayout",paneltop)
		        			local posx = avatarbutton:EGetPosX()+avatarbutton:GetWide()+15
		        			local posy = paneltop:GetTall()*0.1
		        			quick:SetSize(paneltop:GetWide()-posx-5,ceny-posy-5)
		        			quick:SetPos(posx,ceny*0.5-quick:GetTall()*0.5)

		        			local num = #eboard.buttons
		        			local size = quick:GetWide()/num
		        			for id,v in ipairs(eboard.buttons) do
		        				local button = vgui.Create("DButton",quick)
	        					button:SetSize(size,quick:GetTall())
	        					button:SetText("")
	        					button.Paint = nil
	        					eboard:AddHelpText(button,v.Text)
	        					function button:DoClick()
	        						if IsValid(ply) then
	        						if v.Func then
	        							eboard:Notify(v.Text,0.5)
	        							v.Func(ply)
	        						end
	        						end
	        					end

		        				local iconpnl = vgui.Create("DPanel",button)
	        					local size = 24
	        					iconpnl:SetSize(size,size)
	        					iconpnl:SetMouseInputEnabled(false)
	        					iconpnl:Center()
	        					function iconpnl:Paint(w,h)
	        						if v.Icon then
		        						local jobcolor = escore.colors.default.white
		        						if IsValid(ply) then
		        							if not escore.config.hide_all_jobs then
		        								jobcolor = team.GetColor(ply:Team()) or escore.colors.default.white
		        							end
			        						if type(jobcolor) ~= "table" then jobcolor = escore.colors.playerpanel.bg end
		        						end

	        							local dark = escore.util.TextColMustDark(jobcolor)
		        						surface.SetDrawColor( dark and escore.colors.default.black or escore.colors.default.white )
										surface.SetMaterial( v.Icon )
										surface.DrawTexturedRect( 0, 0, h, h )
									end
	        					end
		        			end
		        		end
		        	end --if bBuild
		        end -- Do Click funcI



		        --------------------
		        /// CONTEXT MENU ///
		        --------------------
		        function pnl:DoRightClick()
		        	if IsValid(self.context) then self.context:Close(true) return end
		        	eboard:ReloadContextButtons()

		        	local context = vgui.Create("escore.contextmenu",eboard.panel)
		        		local posx,posy = input.GetCursorPos()
		        		context:SetWide(200)
		        		context:SetPly(ply)
		        		context.origin = self
		        		function context:Think()
		        			if not IsValid(self.origin) or not IsValid(self:GetPly()) then
		        				self:Remove()
		        			end
		        		end

	        		for k,v in ipairs(eboard.contextbuttons) do
	        			local stype = string.lower(v.Type)
	        			if stype == "separator" then
	        				context:AddSeparator()
	        			elseif stype == "header" then
	        				context:AddHeader(v.Text)
	        			else
	        				context:AddButton(v.Text,v.Func)
	        			end
	        		end

	        		context:SetPosClamped(posx+5,posy+5)
		        	self.context = context
		        	eboard.panel.context = context
		        end
		        --FUNCTIONS ADD HERE

			    end     -- If IsValid(ply) -------------\

			end     -- for id, ply in ipairs(plist) ------\

			end -- if list category ------------------------\

		end -- for category,plist in ipairs(self.playerlist) -\

		--return old scroll value
		self.Scroll:Rebuild()
		if self.oldscroll then self.Scroll:GetVBar():SetScroll(self.oldscroll) end

	end -- Function BUILD PLAYERS ------------------------------\

	self:RefreshPlayers(true)
	self.panel.ready2close = true

	return bg
end



-----------------
/// FUNCTIONS ///
-----------------
--REFRESH PLAYER LIST ONLY
function eboard:RefreshPlayersList()
	local playerlist = table.Copy(player.GetAll())

	for k,v in pairs(playerlist) do
		if IsValid(v) then
			local sort = true
			if (v == LocalPlayer()) and sort then
				playerlist[k] = nil
				table.insert(playerlist,1,v)
				sort = false
			end
			if (v:GetFriendStatus() == "friend") and sort then
				playerlist[k] = nil
				table.insert(playerlist,2,v)
				sort = false
			end
		end
	end
	playerlist = table.ClearKeys(playerlist,true)

	self.online = #playerlist

	if DarkRP then
		local joblist = {}
		if escore.config.JobsCategories then
			for k,v in ipairs(playerlist) do
				if v.getJobTable then
					local job_cat = v:getJobTable()
					if job_cat and istable(job_cat) then
						if not joblist[job_cat.category or "Unknown"] then joblist[job_cat.category or "Unknown"] = {} end
						table.insert(joblist[job_cat.category or "Unknown"],v)
					end
				else
					if not joblist["Unknown"] then joblist["Unknown"] = {} end
					table.insert(joblist["Unknown"],v)
				end
			end
		else
			for k,v in ipairs(playerlist) do
				if not joblist[v:getDarkRPVar("job") or "Unknown"] then joblist[v:getDarkRPVar("job") or "Unknown"] = {} end
				table.insert(joblist[v:getDarkRPVar("job") or "Unknown"],v)
			end
		end
		self.playerlist = table.Copy(joblist)
	else
		playerlist = {["All"] = playerlist}
		self.playerlist = table.Copy(playerlist)
	end

	return playerlist
end

--REFRESH ONLY PANEL
function eboard:RefreshList(anim)
	if not anim then anim = true end
	if IsValid(self.panel.contextbg) then self.panel.contextbg:Remove() end
	if IsValid(self.plist) then
		self.oldscroll = self.Scroll:GetVBar():GetScroll()
		if anim then
			self.plist:AlphaTo(1,escore.config.animtime,0,function()
				self.plist:Remove()
				self:BuildPlayers()
			end)
		else
			self.plist:Remove()
			self:BuildPlayers()
		end
		return
	end
	self:BuildPlayers()
end

--REFRESH BOTH
--(force = true) if you need to update immediately
--(force = nil or false) next open updates the panel
function eboard:RefreshPlayers(force)
	if force then 
		self:RefreshPlayersList()
		self:RefreshList()
		self.needupdate = false
	else
		self.needupdate = true
	end
end

--SEARCH FUNCTION
local function strfind(what,where)
	if string.find(string.lower(what), string.lower(where)) then 
		return true 
	else return false end
end

function eboard:SearchPlayer(text)
	self:RefreshPlayersList()
	for categ,v in pairs(self.playerlist) do
		for k,v in ipairs(v) do
			local delete = false
			if not (strfind(v:Name(),text) or strfind(v:SteamID(),text)) then
				delete = true
			end
			if delete then self.playerlist[categ][k] = nil end
		end
	end
	self:RefreshList()
end

--NOTIFY
function eboard:Notify(text,time)
	local bg = self.panel
	if IsValid(bg) then
		if IsValid(bg.notifypanel) then 
			bg.notifypanel:Remove()
			if timer.Exists("escoreNotify") then
				timer.Remove("escoreNotify")
			end
		end

		bg.notifypanel = vgui.Create("DPanel",bg)
		local notify = bg.notifypanel
		notify:SetMouseInputEnabled(false)

		if text then
			local font = "escore_24_500"
			surface.SetFont(font)
			local wx,hy = surface.GetTextSize(text)

			local endtime = CurTime()+time
			notify:SetSize(wx+40,hy+10)
			notify:SetPos(bg:GetWide()*0.5-notify:GetWide()*0.5,bg:GetTall())
			notify:MoveTo(notify:EGetPosX(), bg:GetTall()-notify:GetTall(), escore.config.animtime)
			function notify:Close()
				self.closing = true
				self:MoveTo(self:EGetPosX(),bg:GetTall(),escore.config.animtime,0,-1,function()
					if IsValid(self) then self:Remove() end
				end)
			end
			function notify:Paint(w,h)
				if not timer.Exists("escoreNotify") then
					if not self.closing then
						self:Close()
					end
				end

				local ost = (endtime-CurTime())
				draw.RoundedBoxEx(12,0,0,w,h,escore.colors.notify.bg,true,true,false,false)
				draw.RoundedBox(0,0,h-3,w*(ost/time),3,escore.colors.notify.progressbar)
				draw.SimpleText(text,font,w*0.5,h*0.5,escore.colors.notify.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			if bg:IsVisible() then
				surface.PlaySound("ambient/water/rain_drip1.wav")
			end

		end

		timer.Create("escoreNotify",time,1,function()
			local pnl = bg.notifypanel
			if IsValid(pnl) then
				pnl:MoveTo(pnl:EGetPosX(),bg:GetTall(),escore.config.animtime,0,-1,function()
					if IsValid(pnl) then pnl:Remove() end
				end)
			end
		end)

	end
end

--HINT TEXT
function eboard:AddHelpText(pnl,text,font,offset,align)
	if not font then font = "escore_24_500" end
	if not offset then offset = 5 end
	if not align then align = "bottom" end
	local function HelpText(pnl,text,font,offset)
		if IsValid(eboard.panel) then
			local lbl = vgui.Create("DPanel",eboard.panel)
				surface.SetFont(font)
				local tx, ty = surface.GetTextSize(text)
				lbl:SetSize(tx+20,ty+6)
				lbl:SetMouseInputEnabled(false)
				local posx,posy = pnl:LocalToScreen()
				local x,y = 0,0
				if align == "top" then
					x = posx+pnl:GetWide()*0.5-lbl:GetWide()*0.5
					y = posy-lbl:GetTall()-offset
				elseif align == "right" then
					x = posx+pnl:GetWide()+offset
					y = posy+pnl:GetTall()*0.5-lbl:GetTall()*0.5
				else -- bottom
					x = posx+pnl:GetWide()*0.5-lbl:GetWide()*0.5
					y = posy+pnl:GetTall()+offset
				end
				x = math.Clamp( x, 0, ScrW() - lbl:GetWide() )
				y = math.Clamp( y, 0, ScrH() - lbl:GetTall() )
				lbl:SetPos(x,y)
				function lbl:Paint(w,h)
					draw.RoundedBox(0,0,0,w,h,escore.colors.notify.hoverbg2)
					draw.RoundedBox(0,2,2,w-4,h-4,escore.colors.notify.hoverbg)
					draw.SimpleText(text,font,w*0.5,h*0.5,escore.colors.notify.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
				function lbl:Think()
					if not IsValid(pnl) then
						self:Remove()
					end
				end
			return lbl
		end
	end

	function pnl:OnCursorEntered()
		if IsValid(self.helptext) then self.helptext:Remove() end
		self.helptext = HelpText(pnl,text,font,offset)
	end
	function pnl:OnCursorExited()
		if IsValid(self.helptext) then self.helptext:Remove() end
	end
end

function eboard:AddScreenSpaceClick(DoClick,DoRightClick)
	local parent = self.panel
	local outpnl = vgui.Create("DButton",parent)
	outpnl:SetSize(parent:GetWide(),parent:GetTall())
	outpnl:SetText("")
	outpnl.Paint = nil

	function outpnl:Close()
		self:SizeTo(1,1,escore.config.animtime*1.1,0,-1,function()
			self:Remove()
		end)
	end
	function outpnl.DoClick()
		outpnl:Close()
		if DoClick then DoClick() end
	end
	if DoRightClick then
		function outpnl.DoRightClick()
			outpnl:Close()
			DoRightClick()
		end
	end
	parent.contextbg = outpnl
end

function eboard:IsValid()
	return IsValid(self.panel)
end



-----------------------
/// RADIO FUNCTIONS ///
-----------------------
if escore.config.radio.enable then
CreateClientConVar("eradio_volume", "1", true, false, "escore radio volume variable", 0, 1)

local cv = GetConVar("eradio_volume")
eboard.radio = eboard.radio or escore.config.radio
eboard.radio.id = 1 --startid

function eboard.radio:Play()
	self:Stop()
	local id = self.id
	local url = self.stations[id].url

	self.state = "loading"
	self.playing_id = id
	sound.PlayURL( url, "noplay", function(station, errid, errname)
		if IsValid(station) then
			station:SetVolume(cv:GetFloat() or 1)
			station:Play()
			self.station = station
			eboard.panel:SetStation(self.station)
			self.playing_id = id
			self.state = "playing"
		else
			self.station = nil
			self.state = "error"
		end
	end)
end

function eboard.radio:Valid()
	return IsValid(self.station)
end

function eboard.radio:GetState()
	return self.state
end

function eboard.radio:Switch()
	if self.id == self.playing_id then
		if self:Valid() then self:Stop()
		else
			if self:GetState() ~= "loading" then self:Play() end
		end
	else
		if self:GetState() ~= "loading" then self:Play() end
	end
end

function eboard.radio:Stop()
	if self:Valid() then self.station:Stop() end
end

function eboard.radio:Next()
	self.id = self.id+1
	if self.id > #self.stations then self.id = 1 end
end

function eboard.radio:Prev()
	self.id = self.id-1
	if self.id < 1 then self.id = #self.stations end
end

function eboard.radio:GetStation(id)
	if id then return self.stations[id]
	else return self.stations[self.id] end
end

function eboard.radio:SetVolume(val)
	if self:Valid() then
		self.station:SetVolume(val or 1)
	end
end

end --if escore.config.radio.enable



--------------------
/// CLOSE / OPEN ///
--------------------
function eboard:Open()
	if self:IsValid() then
		if self.needupdate then
			self:RefreshPlayers(true)
		end
		if not self.panel:IsVisible() then
			self.createdtime = CurTime()
			self.panel:SetVisible(true)
			input.SetCursorPos(mousepos.x, mousepos.y)
			self.panel:SetAlpha(0)
			self.panel.ready2close = false
			self.panel:AlphaTo(255,escore.config.animtime,0,function()
				self.panel.ready2close = true
			end)
		end
	else
		self:Build()
	end
end

function eboard:Close()
	if self:IsValid() then
		if self.panel.ready2close then
			self.panel:AlphaTo( 0, escore.config.animtime, 0, function()
				self.panel:SetVisible( false )
				mousepos.x, mousepos.y = input.GetCursorPos()
				if IsValid(self.panel.context) then self.panel.context:Close(false) end
				if self.needupdate then
					self:RefreshPlayers(true)
				end
			end)
		end
	end
end

function eboard:Remove()
	if eboard.radio then 
		eboard.radio:Stop()
	end
	if self:IsValid() then
		eboard.panel:Remove()
	end
end



------------------------
/// CONSOLE COMMANDS ///
------------------------
concommand.Add("escore_open",function()
	eboard:Open()
end)
concommand.Add("escore_refresh",function()
	eboard:RefreshPlayers(true)
end)
concommand.Add("escore_close",function()
	eboard:Remove()
end)



--------------------------
/// OPEN / CLOSE HOOKS ///
--------------------------
--REMOVE STANDART GAMEMODE HOOKS
hook.Add("InitPostEntity", "escoreboard.removehooks", function()
	timer.Simple(0,function()
		GAMEMODE.ScoreboardShow = nil
		GAMEMODE.ScoreboardHide = nil

		hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
	end)
end)

--OPEN / CLOSE tab
hook.Add( "ScoreboardShow", "escoreboard.show", function()
	hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
	
	eboard:Open()
end )

hook.Add( "ScoreboardHide", "escoreboard.hide", function()
	eboard:Close()
end )

hook.Add("OnReloaded","escoreboard.ongamemodereload",function()
	timer.Simple(0,function()
		GAMEMODE.ScoreboardShow = nil
		GAMEMODE.ScoreboardHide = nil
	end)
end)


---------------------
/// REFRESH HOOKS ///
---------------------
--CONNECT
gameevent.Listen("player_connect_client")
hook.Add( "player_connect_client", "escoreboard.onconnect", function( data )
	if IsValid(eboard.panel) then
		eboard:RefreshPlayers()
		if data then
			eboard:Notify(data["name"].." "..escore.text["joined"],3)
		end
	end
end)

--DISCONNECT
gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "escoreboard.ondisconnect", function( data )
	if IsValid(eboard.panel) then
		eboard:RefreshPlayers()
		if data then
			eboard:Notify(data["name"].." "..escore.text["disconnected"],3)
		end
	end
end)

--CHANGE TEAM
net.Receive( "escore_plychangedteam", function( len, ply )
    if IsValid(eboard.panel) then
		eboard:RefreshPlayers()
	end
end)

--RESOLUTION CHANGE
hook.Add( "OnScreenSizeChanged", "escoreboard.onscreenchange", function(oldw,oldh)
	eboard:Remove()
end)