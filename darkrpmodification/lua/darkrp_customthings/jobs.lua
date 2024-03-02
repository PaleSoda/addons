function EYNJobStats( int1, int2 )
    return function(ply)
        ply:SetHealth( int1 )
        ply:SetMaxHealth( int1 )
        ply:SetArmor( int2 )
        ply:SetMaxArmor( int2 )
    end
end


include( "darkrp_customthings/jobs/recruit.lua" )
include( "darkrp_customthings/jobs/navy.lua" )
include( "darkrp_customthings/jobs/impcom.lua" )
include( "darkrp_customthings/jobs/storm.lua" )
include( "darkrp_customthings/jobs/501st.lua" )
include( "darkrp_customthings/jobs/Death.lua" )
include( "darkrp_customthings/jobs/Medic.lua" )
include( "darkrp_customthings/jobs/Nova.lua" )
include( "darkrp_customthings/jobs/Starfighter.lua" )
include( "darkrp_customthings/jobs/Royal.lua" )

GAMEMODE.DefaultTeam = TEAM_CDT