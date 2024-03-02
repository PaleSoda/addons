local MODULE = GAS.Logging:MODULE()
MODULE.Category = "Mac's Rank System"
MODULE.Name = "Promotions"
MODULE.Colour = Color(255, 251, 0)

MODULE:Setup(function()
	MODULE:Hook("MRS.OnPromotion", "blogs.mrs.promotion", function(ply1, ply2, group, rid, rid1, rid2, rank)
		MODULE:LogPhrase("{1} set rank for {2} in group {4} to {3}", GAS.Logging:FormatPlayer(ply2), GAS.Logging:FormatPlayer(ply1), GAS.Logging:Highlight(rank), GAS.Logging:Highlight(group))
	end)

	MODULE:Hook("MRS.OnAutoPromotion", "blogs.mrs.autopromotion", function(ply, group, oid, nid, rank)
		MODULE:LogPhrase("{1} auto-promoted in group {2} ➞ {3}", GAS.Logging:FormatPlayer(ply),  GAS.Logging:Highlight(group), GAS.Logging:Highlight(rank))
	end)
end)

GAS.Logging:AddModule(MODULE)