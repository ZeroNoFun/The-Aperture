--[[

	PORTAL BUTTON SOUNDS
	
]]

AddCSLuaFile()

local buttonClick =
{
	channel	= CHAN_WEAPON,
	name	= "TA:ButtonClick",
	level	= 70,
	sound	= "buttons/button_synth_positive_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(buttonClick)

local buttonUp =
{
	channel	= CHAN_WEAPON,
	name	= "TA:ButtonUp",
	level	= 70,
	sound	= "buttons/button_synth_negative_02.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(buttonUp)

local oldButtonClick =
{
	channel	= CHAN_WEAPON,
	name	= "TA:OldButtonClick",
	level	= 70,
	sound	= "buttons/og_switch_press_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(oldButtonClick)

local oldButtonUp =
{
	channel	= CHAN_WEAPON,
	name	= "TA:OldButtonUp",
	level	= 70,
	sound	= "buttons/og_switch_release_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(oldButtonUp)