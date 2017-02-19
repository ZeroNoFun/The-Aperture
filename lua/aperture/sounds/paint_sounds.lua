--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.GelSplatSmall =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelSplatSmall",
	level	= 75,
	sound	= { "physics/paint/paint_trickle_01.wav"
		, "physics/paint/paint_trickle_02.wav"
		, "physics/paint/paint_trickle_03.wav"
		, "physics/paint/paint_trickle_04.wav"
		, "physics/paint/paint_trickle_05.wav"
		, "physics/paint/paint_trickle_06.wav"
		, "physics/paint/paint_trickle_07.wav"
		, "physics/paint/paint_trickle_08.wav"
		, "physics/paint/paint_trickle_09.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelSplatSmall )

APERTURESCIENCE.GelSplat =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelSplat",
	level	= 75,
	sound	= { "physics/paint/paint_blob_splat_01.wav"
		, "physics/paint/paint_blob_splat_02.wav"
		, "physics/paint/paint_blob_splat_03.wav"
		, "physics/paint/paint_blob_splat_04.wav"
		, "physics/paint/paint_blob_splat_05.wav"
		, "physics/paint/paint_blob_splat_06.wav"
		, "physics/paint/paint_blob_splat_07.wav"
		, "physics/paint/paint_blob_splat_08.wav"
		, "physics/paint/paint_blob_splat_09.wav"
		, "physics/paint/paint_blob_splat_10.wav"
		, "physics/paint/paint_blob_splat_11.wav"
		, "physics/paint/paint_blob_splat_12.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelSplat )

APERTURESCIENCE.GelSplatBig =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelSplatBig",
	level	= 75,
	sound	= "physics/paint/phys_paint_bomb_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelSplatBig )

APERTURESCIENCE.GelBounceProp =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelBounceProp",
	level	= 75,
	sound	= { "physics/paint/phys_bouncy_cube_lg_01.wav"
		, "physics/paint/phys_bouncy_cube_lg_02.wav"
		, "physics/paint/phys_bouncy_cube_lg_03.wav"
		, "physics/paint/phys_bouncy_cube_lg_04.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelBounceProp )

APERTURESCIENCE.GelBounce =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelBounce",
	level	= 75,
	sound	= { "player/paint/player_bounce_jump_paint_01.wav"
		, "player/paint/player_bounce_jump_paint_02.wav"
		, "player/paint/player_bounce_jump_paint_03.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelBounce )

APERTURESCIENCE.GelFootsteps =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.GelFootsteps",
	level	= 60,
	sound	= { "player/footsteps/fs_fm_paint_01.wav"
		, "player/footsteps/fs_fm_paint_02.wav"
		, "player/footsteps/fs_fm_paint_03.wav"
		, "player/footsteps/fs_fm_paint_04.wav"
		, "player/footsteps/fs_fm_paint_05.wav"
		, "player/footsteps/fs_fm_paint_06.wav"
		, "player/footsteps/fs_fm_paint_07.wav"
		, "player/footsteps/fs_fm_paint_08.wav"
		, "player/footsteps/fs_fm_paint_09.wav"
		, "player/footsteps/fs_fm_paint_10.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelFootsteps )

APERTURESCIENCE.GelBounceEnter =
{
	channel	= CHAN_AUTO,
	name	= "GASL.GelBounceEnter",
	level	= 75,
	sound	= { "player/paint/player_enter_jump_paint_01.wav"
		, "player/paint/player_enter_jump_paint_02.wav"
		, "player/paint/player_enter_jump_paint_03.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelBounceEnter )

APERTURESCIENCE.GelSpeedEnter =
{
	channel	= CHAN_AUTO,
	name	= "GASL.GelSpeedEnter",
	level	= 75,
	sound	= { "player/paint/player_enter_speed_paint_01.wav"
		, "player/paint/player_enter_speed_paint_02.wav"
		, "player/paint/player_enter_speed_paint_03.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelSpeedEnter )

APERTURESCIENCE.GelBounceExit =
{
	channel	= CHAN_AUTO,
	name	= "GASL.GelBounceExit",
	level	= 75,
	sound	= { "player/paint/player_exit_jump_paint_01.wav"
		, "player/paint/player_exit_jump_paint_02.wav"
		, "player/paint/player_exit_jump_paint_03.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelBounceExit )

APERTURESCIENCE.GelSpeedExit =
{
	channel	= CHAN_AUTO,
	name	= "GASL.GelSpeedExit",
	level	= 75,
	sound	= { "player/paint/player_exit_speed_paint_01.wav"
		, "player/paint/player_exit_speed_paint_02.wav"
		, "player/paint/player_exit_speed_paint_03.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.GelSpeedExit )