--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.TurretShoot =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TurretShoot",
	level	= 60,
	sound	= { "npc/turret/turret_fire_4x_01.wav"
	, "npc/turret/turret_fire_4x_02.wav" 
	, "npc/turret/turret_fire_4x_03.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretShoot )

APERTURESCIENCE.TurretActivateVO =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretActivateVO",
	level	= 70,
	sound	= { "npc/turret_floor/turret_active_1.wav"
	, "npc/turret_floor/turret_active_2.wav"
	, "npc/turret_floor/turret_active_3.wav"
	, "npc/turret_floor/turret_active_4.wav"
	, "npc/turret_floor/turret_active_5.wav"
	, "npc/turret_floor/turret_active_6.wav"
	, "npc/turret_floor/turret_active_7.wav"
	, "npc/turret_floor/turret_active_8.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretActivateVO )

APERTURESCIENCE.TurretActivate =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TurretActivate",
	level	= 60,
	sound	= "npc/turret_floor/active.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretActivate )

APERTURESCIENCE.TurretPing =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TurretPing",
	level	= 60,
	sound	= "npc/turret_floor/ping.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretPing )

APERTURESCIENCE.TurretDeploy =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TurretDeploy",
	level	= 70,
	sound	= "npc/turret_floor/deploy.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDeploy )

APERTURESCIENCE.TurretSearth =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretSearth",
	level	= 75,
	sound	= { "npc/turret_floor/turret_search_1.wav"
	, "npc/turret_floor/turret_search_2.wav"
	, "npc/turret_floor/turret_search_3.wav"
	, "npc/turret_floor/turret_search_4.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretSearth )

APERTURESCIENCE.TurretAutoSearth =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretAutoSearth",
	level	= 75,
	sound	= { "npc/turret_floor/turret_autosearch_1.wav"
		, "npc/turret_floor/turret_autosearch_2.wav" 
		, "npc/turret_floor/turret_autosearch_3.wav"
		, "npc/turret_floor/turret_autosearch_4.wav"
		, "npc/turret_floor/turret_autosearch_5.wav"
		, "npc/turret_floor/turret_autosearch_6.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretAutoSearth )

APERTURESCIENCE.TurretRetract =
{
	channel	= CHAN_WEAPON,
	name	= "GASL.TurretRetract",
	level	= 60,
	sound	= "npc/turret_floor/retract.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretRetract )

APERTURESCIENCE.TurretPickup =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretPickup",
	level	= 60,
	sound	= { "npc/turret_floor/turret_pickup_1.wav"
	, "npc/turret_floor/turret_pickup_2.wav" 
	, "npc/turret_floor/turret_pickup_3.wav" 
	, "npc/turret_floor/turret_pickup_4.wav" 
	, "npc/turret_floor/turret_pickup_5.wav" 
	, "npc/turret_floor/turret_pickup_6.wav" 
	, "npc/turret_floor/turret_pickup_7.wav" 
	, "npc/turret_floor/turret_pickup_8.wav" 
	, "npc/turret_floor/turret_pickup_9.wav" 
	, "npc/turret_floor/turret_pickup_10.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretPickup )

APERTURESCIENCE.TurretLaunch =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretLaunch",
	level	= 60,
	sound	= { "npc/turret/turretlaunched01.wav"
	, "npc/turret/turretlaunched02.wav" 
	, "npc/turret/turretlaunched03.wav" 
	, "npc/turret/turretlaunched04.wav" 
	, "npc/turret/turretlaunched05.wav" 
	, "npc/turret/turretlaunched06.wav" 
	, "npc/turret/turretlaunched07.wav" 
	, "npc/turret/turretlaunched08.wav" 
	, "npc/turret/turretlaunched09.wav" 
	, "npc/turret/turretlaunched010.wav" 
	, "npc/turret/turretlaunched011.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretLaunch )

APERTURESCIENCE.TurretBurn =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretBurn",
	level	= 60,
	sound	= { "npc/turret/turretshotbylaser01.wav"
	, "npc/turret/turretshotbylaser02.wav"
	, "npc/turret/turretshotbylaser03.wav"
	, "npc/turret/turretshotbylaser04.wav"
	, "npc/turret/turretshotbylaser05.wav"
	, "npc/turret/turretshotbylaser06.wav"
	, "npc/turret/turretshotbylaser07.wav"
	, "npc/turret/turretshotbylaser08.wav"
	, "npc/turret/turretshotbylaser09.wav"
	, "npc/turret/turretshotbylaser10.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretBurn )

APERTURESCIENCE.TurretWithnessdeath =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretWithnessdeath",
	level	= 60,
	sound	= { "npc/turret/turretwitnessdeath01.wav"
	, "npc/turret/turretwitnessdeath02.wav"
	, "npc/turret/turretwitnessdeath03.wav"
	, "npc/turret/turretwitnessdeath04.wav"
	, "npc/turret/turretwitnessdeath05.wav"
	, "npc/turret/turretwitnessdeath06.wav"
	, "npc/turret/turretwitnessdeath07.wav"
	, "npc/turret/turretwitnessdeath08.wav"
	, "npc/turret/turretwitnessdeath09.wav"
	, "npc/turret/turretwitnessdeath10.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretWithnessdeath )

