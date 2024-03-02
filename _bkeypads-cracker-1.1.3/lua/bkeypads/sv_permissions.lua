table.insert(bKeypads.Permissions.Registry, {
	Label = "Keypad Cracker",
	Value = "keypad_cracker",
	Icon  = "icon16/controller.png",

	{
		{
			Label   = "Pick Up Keypad Crackers",
			Value   = "pick_up",
			Icon    = "icon16/basket_remove.png",
			Tip     = "Allow this group to pickup dropped (DEPLOYABLE) keypad crackers?"
		},

		{
			Label   = "Remove Keypad Crackers",
			Value   = "remove",
			Icon    = "icon16/stop.png",
			Tip     = "Allow this group to STOP deployed keypad crackers by pressing E on them?"
		},
	}
})