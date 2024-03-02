util.AddNetworkString( "escore_plychangedteam" )

hook.Add("PlayerChangedTeam", "escore.playerchangedteam", function(ply,old,new)
	net.Start( "escore_plychangedteam" )
	net.WriteEntity( ply )
	net.Broadcast()
end)