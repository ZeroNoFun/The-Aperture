--[[

	LASER SOUNDS SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.LaserBodyBurn =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserBodyBurn",
	level	= 65,
	sound	= { "player/pl_burnpain1_no_vo.wav"
		, "player/pl_burnpain2_no_vo.wav"
		, "player/pl_burnpain3_no_vo.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserBodyBurn )

APERTURESCIENCE.LaserStart =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserStart",
	level	= 65,
	sound	= { "vfx/laser_beam_lp_01.wav"
		, "vfx/laser_beam_lp_02.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserStart )

APERTURESCIENCE.LaserCatcherOn =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserCatcherOn",
	level	= 75,
	sound	= "world/laser_node_power_on.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserCatcherOn )

APERTURESCIENCE.LaserCatcherOff =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserCatcherOff",
	level	= 75,
	sound	= "world/laser_node_power_off.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserCatcherOff )

APERTURESCIENCE.LaserCatcherLoop =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserCatcherLoop",
	level	= 75,
	sound	= "world/laser_node_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserCatcherLoop )
