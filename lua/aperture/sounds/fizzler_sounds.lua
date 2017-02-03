--[[

	FIZZLER SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.FizzlerDissolve =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.FizzlerDissolve",
	level	= 70,
	sound	= "props/material_emancipation_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.FizzlerDissolve )

APERTURESCIENCE.FizzlerEnable =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.FizzlerEnable",
	level	= 70,
	sound	= "vfx/fizzler_start_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.FizzlerEnable )

APERTURESCIENCE.FizzlerDisable =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.FizzlerDisable",
	level	= 70,
	sound	= "vfx/fizzler_shutdown_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.FizzlerDisable )
