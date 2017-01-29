--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

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
