--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

APERTURESCIENCE.TurretDefectiveChat =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretDefectiveChat",
	level	= 60,
	sound	= { "npc/turret_defective/sp_sabotage_factory_defect_chat01.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat02.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat03.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat04.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat05.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDefectiveChat )

APERTURESCIENCE.TurretDryFire =
{
	channel	= CHAN_WEAPON	,
	name	= "GASL.TurretDryFire",
	level	= 60,
	sound	= { "npc/turret_defective/defect_dryfire01.wav"
	, "npc/turret_defective/defect_dryfire02.wav"
	, "npc/turret_defective/defect_dryfire03.wav"
	, "npc/turret_defective/defect_dryfire04.wav"
	, "npc/turret_defective/defect_dryfire05.wav"
	, "npc/turret_defective/defect_dryfire06.wav"
	, "npc/turret_defective/defect_dryfire07.wav"
	, "npc/turret_defective/defect_dryfire08.wav"
	, "npc/turret_defective/defect_dryfire09.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDryFire )

APERTURESCIENCE.TurretDefectiveActivateVO =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretDefectiveActivateVO",
	level	= 70,
	sound	= { "npc/turret_defective/glados_battle_defect_arrive01.wav"
	, "npc/turret_defective/glados_battle_defect_arrive02.wav"
	, "npc/turret_defective/glados_battle_defect_arrive03.wav"
	, "npc/turret_defective/glados_battle_defect_arrive04.wav"
	, "npc/turret_defective/glados_battle_defect_arrive05.wav"
	, "npc/turret_defective/glados_battle_defect_arrive06.wav"
	, "npc/turret_defective/glados_battle_defect_arrive07.wav"
	, "npc/turret_defective/glados_battle_defect_arrive08.wav"
	, "npc/turret_defective/glados_battle_defect_arrive09.wav"
	, "npc/turret_defective/glados_battle_defect_arrive10.wav"
	, "npc/turret_defective/glados_battle_defect_arrive11.wav"
	, "npc/turret_defective/glados_battle_defect_arrive12.wav"
	, "npc/turret_defective/glados_battle_defect_arrive13.wav"
	, "npc/turret_defective/glados_battle_defect_arrive14.wav"
	, "npc/turret_defective/glados_battle_defect_arrive15.wav"
	, "npc/turret_defective/glados_battle_defect_arrive16.wav"
	, "npc/turret_defective/glados_battle_defect_arrive17.wav"
	, "npc/turret_defective/glados_battle_defect_arrive18.wav"
	, "npc/turret_defective/glados_battle_defect_arrive19.wav"	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDefectiveActivateVO )

APERTURESCIENCE.TurretDetectiveAutoSearth =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretDetectiveAutoSearth",
	level	= 75,
	sound	= { "npc/turret_defective/defect_goodbye01.wav"
		, "npc/turret_defective/defect_goodbye02.wav" 
		, "npc/turret_defective/defect_goodbye03.wav" 
		, "npc/turret_defective/defect_goodbye04.wav" 
		, "npc/turret_defective/defect_goodbye05.wav" 
		, "npc/turret_defective/defect_goodbye06.wav" 
		, "npc/turret_defective/defect_goodbye07.wav" 
		, "npc/turret_defective/defect_goodbye08.wav" 
		, "npc/turret_defective/defect_goodbye09.wav" 
		, "npc/turret_defective/defect_goodbye10.wav" 
		, "npc/turret_defective/defect_goodbye11.wav" 
		, "npc/turret_defective/defect_goodbye12.wav" 
		, "npc/turret_defective/defect_goodbye13.wav" 
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDetectiveAutoSearth )

APERTURESCIENCE.TurretDetectiveFaill =
{
	channel	= CHAN_VOICE,
	name	= "GASL.TurretDetectiveFaill",
	level	= 75,
	sound	= { "npc/turret_defective/finale02_turret_return_defect_fail01.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail02.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail03.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail04.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail05.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail06.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail07.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail08.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail09.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail10.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail11.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail12.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail13.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail14.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail15.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail16.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail17.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail18.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail19.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail20.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail21.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail22.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail23.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail24.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail25.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail26.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail27.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail28.wav" 
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add( APERTURESCIENCE.TurretDetectiveFaill )