--[[

	Radio SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.RadioLoop =
{
	channel	= CHAN_VOICE,
	name	= "GASL.RadioLoop",
	level	= 60,
	sound	= "music/looping_radio_mix.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.RadioLoop )

APERTURESCIENCE.RadioStrangeNoice =
{
	channel	= CHAN_VOICE,
	name	= "GASL.RadioStrangeNoice",
	level	= 60,
	sound	= "music/vsc_radio5.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.RadioStrangeNoice )
