--[[

	CRUSHER SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.CrusherSmash =
{
	channel	= CHAN_WEAPON,
	name	= "TA.CrusherSmash",
	level	= 90,
	sound	= {
		"crusher/crusher_impact_01.wav",
		"crusher/crusher_impact_02.wav",
		"crusher/crusher_impact_03.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.CrusherSmash )

APERTURESCIENCE.CrusherOpen =
{
	channel	= CHAN_WEAPON,
	name	= "TA.CrusherOpen",
	level	= 75,
	sound	= {
		"crusher/crusher_open_01.wav",
		"crusher/crusher_open_02.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.CrusherOpen )

APERTURESCIENCE.CrusherSeparate =
{
	channel	= CHAN_WEAPON,
	name	= "TA.CrusherSeparate",
	level	= 75,
	sound	= {
		"crusher/crusher_separate_01.wav",
		"crusher/crusher_separate_02.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.CrusherSeparate )
