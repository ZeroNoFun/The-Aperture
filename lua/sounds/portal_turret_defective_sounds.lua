--[[

	CATAPULT SOUNDS
	
]]

AddCSLuaFile()

local turretDefectiveChat =
{
	channel	= CHAN_VOICE,
	name	= "TA:TurretDefectiveChat",
	level	= 60,
	sound	= { "npc/turret_defective/sp_sabotage_factory_defect_chat01.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat02.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat03.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat04.wav"
	, "npc/turret_defective/sp_sabotage_factory_defect_chat05.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(turretDefectiveChat)

local turretDryFire =
{
	channel	= CHAN_WEAPON,
	name	= "TA:TurretDryFire",
	level	= 60,
	sound	= { "npc/turret_defective/defect_dryfire01.wav"
	, "npc/turret_defective/defect_dryfire02.wav"
	, "npc/turret_defective/defect_dryfire03.wav"
	, "npc/turret_defective/defect_dryfire04.wav"
	, "npc/turret_defective/defect_dryfire05.wav" },
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(turretDryFire)

local turretDefectiveActivateVO =
{
	channel	= CHAN_VOICE,
	name	= "TA:TurretDefectiveActivateVO",
	level	= 70,
	sound	= { "npc/turret_defective/glados_battle_defect_arrive01.wav"
	, "npc/turret_defective/glados_battle_defect_arrive02.wav"
	, "npc/turret_defective/glados_battle_defect_arrive03.wav"
	, "npc/turret_defective/glados_battle_defect_arrive04.wav"
	, "npc/turret_defective/glados_battle_defect_arrive05.wav"
	, "npc/turret_defective/glados_battle_defect_arrive06.wav"	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(turretDefectiveActivateVO)

local turretDetectiveAutoSearth =
{
	channel	= CHAN_VOICE,
	name	= "TA:TurretDetectiveAutoSearth",
	level	= 75,
	sound	= { "npc/turret_defective/defect_goodbye01.wav"
		, "npc/turret_defective/defect_goodbye02.wav" 
		, "npc/turret_defective/defect_goodbye03.wav" 
		, "npc/turret_defective/defect_goodbye04.wav" 
		, "npc/turret_defective/defect_goodbye05.wav" 
		, "npc/turret_defective/defect_goodbye06.wav" 
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(turretDetectiveAutoSearth)

local turretDetectiveFaill =
{
	channel	= CHAN_VOICE,
	name	= "TA:TurretDetectiveFaill",
	level	= 75,
	sound	= { "npc/turret_defective/finale02_turret_return_defect_fail01.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail02.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail03.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail04.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail05.wav"
		, "npc/turret_defective/finale02_turret_return_defect_fail06.wav"
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(turretDetectiveFaill)