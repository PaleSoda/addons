local PANEL = {}

XeninUI:CreateFont("F4Menu.Jobs.Slideout.Desc", 15)

function PANEL:Init()
	self:DockMargin(24, 16, 16, 24)
end

function PANEL:SetContent(content, html)
	self.Content = self:Add(html and "DHTML" or "DLabel")

	if html then

		content = [[
			<header>
				<link href="https://fonts.googleapis.com/css?family=Montserrat&display=swap" rel="stylesheet">

				<style>
					body { padding: 0; margin: 0; overflow: hidden; color: rgb(212, 212, 212); font-family: "Montserrat", sans-serif; font-size: 13px; }

					.container {
						width: 100%;
						height: 100%;
					}

					a {
						color: rgb(41, 128, 185);
					}

					h1, h2, h3, h4, h5, h6 {
						margin: 5px 0px;
					}

					img {
						margin: 5px 0px;
						display: block;
						width: 100%;
						height: auto;
					}

					.display-block {
						display: block;
					}

					.margin-top-5 {
						margin-top: 5px;
					}

					ul {
						margin-left: 10px;
						margin-top: 5px;
						padding-left: 18px;
					}

					ul > li {
						padding-left: 0px;
						margin-left: 0px;
					}

					ul > li > ul {
						margin-left: 0px;
					}
				</style>
			</header>
			<body>
				<div class="container">
					]] .. content .. [[
				</div>
			</body>
		]]





		self.Content:SetHTML(content)
	else
		self.Content:SetFont("F4Menu.Jobs.Slideout.Desc")
		self.Content:SetTextColor(Color(212, 212, 212))
		self.Content:SetWrap(true)
		self.Content:SetAutoStretchVertical(true)

		self.Content:SetText(content)
	end
end

function PANEL:PerformLayout(w, h)
	self.Content:SetSize(w, h)
end

vgui.Register("F4Menu.Jobs.Slideout.Desc", PANEL, "Panel")
