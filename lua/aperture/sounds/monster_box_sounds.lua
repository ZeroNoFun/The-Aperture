--[[

	WALL PROJECTOR SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.MonsterBoxChitter =
{
	channel	= CHAN_VOICE,
	name	= "GASL.MonsterBoxChitter",
	level	= 65,
	sound	= { "npc/box_monster/box_monster_chitter_01.wav"
		, "npc/box_monster/box_monster_chitter_02.wav"
		, "npc/box_monster/box_monster_chitter_03.wav"
		, "npc/box_monster/box_monster_chitter_04.wav"
		, "npc/box_monster/box_monster_chitter_05.wav"
		, "npc/box_monster/box_monster_chitter_06.wav"
		, "npc/box_monster/box_monster_chitter_07.wav"
		, "npc/box_monster/box_monster_chitter_08.wav"
		, "npc/box_monster/box_monster_chitter_09.wav"
		, "npc/box_monster/box_monster_chitter_10.wav"
		, "npc/box_monster/box_monster_chitter_10.wav"
		, "npc/box_monster/box_monster_chitter_11.wav"
		, "npc/box_monster/box_monster_chitter_12.wav"
		, "npc/box_monster/box_monster_chitter_13.wav"
		, "npc/box_monster/box_monster_chitter_14.wav"
		, "npc/box_monster/box_monster_chitter_15.wav"
		, "npc/box_monster/box_monster_chitter_16.wav"
		, "npc/box_monster/box_monster_chitter_17.wav"
		, "npc/box_monster/box_monster_chitter_18.wav"
		, "npc/box_monster/box_monster_chitter_19.wav"
		, "npc/box_monster/box_monster_chitter_20.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.MonsterBoxChitter )

APERTURESCIENCE.MonsterBoxKick =
{
	channel	= CHAN_BODY,
	name	= "GASL.MonsterBoxKick",
	level	= 65,
	sound	= { "npc/box_monster/box_monster_leg_kick_01.wav"
		, "npc/box_monster/box_monster_leg_kick_02.wav"
		, "npc/box_monster/box_monster_leg_kick_03.wav"
		, "npc/box_monster/box_monster_leg_kick_04.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.MonsterBoxKick )

APERTURESCIENCE.MonsterBoxFootsteps =
{
	channel	= CHAN_BODY,
	name	= "GASL.MonsterBoxFootsteps",
	level	= 65,
	sound	= { "npc/box_monster/box_monster_fs_01.wav"
		, "npc/box_monster/box_monster_fs_02.wav"
		, "npc/box_monster/box_monster_fs_03.wav"
		, "npc/box_monster/box_monster_fs_04.wav"
		, "npc/box_monster/box_monster_fs_05.wav"
		, "npc/box_monster/box_monster_fs_06.wav"
		, "npc/box_monster/box_monster_fs_07.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.MonsterBoxFootsteps )
