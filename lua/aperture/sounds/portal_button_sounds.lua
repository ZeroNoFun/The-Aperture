--[[

	PORTAL BUTTON SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.ButtonClick =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.ButtonClick",
	level	= 70,
	sound	= "buttons/button_synth_positive_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.ButtonClick )

APERTURESCIENCE.ButtonUp =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.ButtonUp",
	level	= 70,
	sound	= "buttons/button_synth_negative_02.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.ButtonUp )

APERTURESCIENCE.UndergroundButtonClick =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.UndergroundButtonClick",
	level	= 70,
	sound	= "buttons/og_switch_press_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.UndergroundButtonClick )

APERTURESCIENCE.UndergroundButtonUp =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.UndergroundButtonUp",
	level	= 70,
	sound	= "buttons/og_switch_release_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.UndergroundButtonUp )