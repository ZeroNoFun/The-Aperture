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

APERTURESCIENCE.LaserImpact =
{
	channel	= CHAN_BODY,
	name	= "GASL.LaserImpact",
	level	= 65,
	sound	= "vfx/laser_beam_impact_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.LaserImpact )
