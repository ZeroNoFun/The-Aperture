--[[

	Potato OS SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.PotatoOSChat =
{
	channel	= CHAN_VOICE,
	name	= "GASL.PotatoOSChat",
	level	= 60,
	sound	= { "npc/potatoos/potatos_lonely02.wav"
	, "npc/potatoos/potatos_meetup04.wav"
	, "npc/potatoos/potatos_meetup08.wav"
	, "npc/potatoos/potatos_sp_a3_00_fall18.wav"
	, "npc/potatoos/potatos_sp_a3_00_fall19.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.PotatoOSChat )
