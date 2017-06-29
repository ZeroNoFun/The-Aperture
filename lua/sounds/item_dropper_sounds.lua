--[[

	LASER SOUNDS SOUNDS
	
]]

AddCSLuaFile()

local itemDropperOpen =
{
	channel	= CHAN_BODY,
	name	= "TA:ItemDropperOpen",
	level	= 65,
	sound	= { "world/dropper_iris_open_01.wav"
		, "world/dropper_iris_open_01.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(itemDropperOpen)

local itemDropperClose =
{
	channel	= CHAN_BODY,
	name	= "TA:ItemDropperClose",
	level	= 65,
	sound	= "world/dropper_iris_close_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(itemDropperClose)
