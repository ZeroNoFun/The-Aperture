--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

local catapultLaunch =
{
	channel	= CHAN_WEAPON,
	name	= "TA:CatapultLaunch",
	level	= 60,
	sound	= "door/heavy_metal_stop1.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(catapultLaunch)
