-- Warning: If you mess up the syntax of this file the script will break! Don't remove anything unless you know what you're doing.

return {
	-- Whether props should be hidden or not?
	-- On servers with lots of entities, this can cause extreme delays so it's not recommended.
	-- Other players will still be hidden.
	HideProps = false,

	-- Add entity class names here for props that should be visible in a sit room
	{
		"prop_*",
		"decal",
		"sammyservers_textscreen",
	},
}