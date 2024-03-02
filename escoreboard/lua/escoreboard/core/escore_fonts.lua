------------
/* FONTS  */
------------

-- Add to download list (without this line, players will not receive the font file)
if ( SERVER ) then
	resource.AddFile("resource/fonts/gardens_cm.ttf")
end


if ( CLIENT ) then
	
local defaultfont = "Gardens CM" --This is not the name of the FILE but the name of the FONT
local function CreateFont(name,size,weight,fontfamily)
	name = name .. "_" .. size .. "_" .. weight
	surface.CreateFont(name, {
		font = fontfamily or defaultfont,
		size = size,
		weight = (weight or 500),
		extended = true
	})
end

-- do not change this
local fontname = "escore"

----------------------
/// CREATING FONTS ///
----------------------

--12
CreateFont(fontname,12,500) -- escore_12_500

--14
CreateFont(fontname,14,500)

--16
CreateFont(fontname,16,500)
CreateFont(fontname,16,1000)

--18
CreateFont(fontname,18,500)

--20
CreateFont(fontname,20,500)

--24
CreateFont(fontname,24,500)
CreateFont(fontname,24,1000)

--26
CreateFont(fontname,26,500)
CreateFont(fontname,26,1000) -- escore_26_1000

--30
CreateFont(fontname,30,1000)
CreateFont(fontname,36,1000)

--60
CreateFont(fontname,60,500) -- escore_60_500


end