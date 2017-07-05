--[[

	LASER SOUNDS SOUNDS
	
]]

AddCSLuaFile()

local laserBurn =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserBurn",
	level	= 65,
	sound	= "ambient/fire/amb_fire_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserBurn)

local laserBodyBurn =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserBodyBurn",
	level	= 65,
	sound	= { "player/pl_burnpain1_no_vo.wav"
		, "player/pl_burnpain2_no_vo.wav"
		, "player/pl_burnpain3_no_vo.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserBodyBurn)

local laserStart =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserStart",
	level	= 65,
	sound	= { "vfx/laser_beam_lp_01.wav"
		, "vfx/laser_beam_lp_02.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserStart)

local laserCatcherOn =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserCatcherOn",
	level	= 75,
	sound	= "world/laser_node_power_on.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserCatcherOn)

local laserCatcherOff =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserCatcherOff",
	level	= 75,
	sound	= "world/laser_node_power_off.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserCatcherOff)

local laserCatcherLoop =
{
	channel	= CHAN_BODY,
	name	= "TA:LaserCatcherLoop",
	level	= 75,
	sound	= "world/laser_node_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(laserCatcherLoop)
