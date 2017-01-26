--[[

	TRACTOR BEAM SOUNDS
	
]]

AddCSLuaFile()

--------------------- Tractor Beam soundscripts ----------------------------

APERTURESCIENCE.TractorBeamLoop =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TractorBeamLoop",
	level	= 60,
	sound	= "props/tbeam_emitter_spin_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamLoop )

APERTURESCIENCE.TractorBeamStart =
{
	channel	= CHAN_BODY,
	name	= "GASL.TractorBeamStart",
	level	= 60,
	sound	= "props/tbeam_emitter_start_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamStart )

APERTURESCIENCE.TractorBeamMiddle =
{
	channel	= CHAN_BODY,
	name	= "GASL.TractorBeamMiddle",
	level	= 60,
	sound	= "props/tbeam_emitter_middle_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamMiddle )

APERTURESCIENCE.TractorBeamEnd =
{
	channel	= CHAN_BODY,
	name	= "GASL.TractorBeamEnd",
	level	= 60,
	sound	= "props/tbeam_emitter_end_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamEnd )

APERTURESCIENCE.TractorBeamEnter =
{
	channel	= CHAN_BODY,
	name	= "GASL.TractorBeamEnter",
	level	= 60,
	sound	= {
		"vfx/player_enter_tbeam_lp_01.wav",
		"vfx/player_enter_tbeam_lp_02.wav",
		"vfx/player_enter_tbeam_lp_03.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamEnter )

APERTURESCIENCE.TractorBeamEnterSS =
{
	channel	= CHAN_BODY,
	name	= "GASL.TractorBeamEnterSS",
	level	= 60,
	sound	= {
		"vfx/player_enter_tbeam_ss_lp_01.wav",
		"vfx/player_enter_tbeam_ss_lp_02.wav",
		"vfx/player_enter_tbeam_ss_lp_03.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TractorBeamEnterSS )