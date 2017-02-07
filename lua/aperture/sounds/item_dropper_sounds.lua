--[[

	LASER SOUNDS SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.ItemDropperOpen =
{
	channel	= CHAN_BODY,
	name	= "GASL.ItemDropperOpen",
	level	= 65,
	sound	= { "world/dropper_iris_open_01.wav"
		, "world/dropper_iris_open_01.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.ItemDropperOpen )

APERTURESCIENCE.ItemDropperClose =
{
	channel	= CHAN_BODY,
	name	= "GASL.ItemDropperClose",
	level	= 65,
	sound	= "world/dropper_iris_close_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.ItemDropperClose )
