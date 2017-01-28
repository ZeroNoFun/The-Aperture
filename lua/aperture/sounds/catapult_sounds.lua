--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.CatapultLaunch =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.CatapultLaunch",
	level	= 60,
	sound	= "door/heavy_metal_stop1.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.CatapultLaunch )
