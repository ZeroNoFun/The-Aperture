--[[

	WALL PROJECTOR SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.WallProjectorFootsteps =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.WallProjectorFootsteps",
	level	= 70,
	sound	= { "player/footsteps/fs_fm_lightbridge_01.wav" 
		, "player/footsteps/fs_fm_lightbridge_02.wav" 
		, "player/footsteps/fs_fm_lightbridge_03.wav" 
		, "player/footsteps/fs_fm_lightbridge_04.wav" 
		, "player/footsteps/fs_fm_lightbridge_05.wav" 
		, "player/footsteps/fs_fm_lightbridge_06.wav" 
		, "player/footsteps/fs_fm_lightbridge_07.wav" 
		, "player/footsteps/fs_fm_lightbridge_08.wav" 
		, "player/footsteps/fs_fm_lightbridge_09.wav" 
		, "player/footsteps/fs_fm_lightbridge_10.wav" 
		, "player/footsteps/fs_fm_lightbridge_11.wav" 
		, "player/footsteps/fs_fm_lightbridge_12.wav" 
		, "player/footsteps/fs_fm_lightbridge_13.wav" 
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.WallProjectorFootsteps )
