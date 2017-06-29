AddCSLuaFile()

LIB_ACHIEVEMENT_TA = {}


-- Achievement
LIB_ACHIEVEMENT_TA.ACHIEVEMENT_INFO = {
	[1] = {img = "achievement/turret_sing", text = "The Turret Song!"},
	[2] = {img = "achievement/fried_potato", text = "Fried Potato"},
	[3] = {img = "achievement/turret_fly", text = "Turret can fly"},
	[4] = {img = "achievement/cake", text = "Cake is not a lie!"},
	[5] = {img = "achievement/radio", text = "Strange channel"},
}

function LIB_APERTURE:AchievAchievement(ply, achievementInx)
	
	if CLIENT then return end
	if not IsValid(ply) then return end
	
	net.Start("TA:NW_AchievedAchievement")
		net.WriteEntity(ply)
		net.WriteInt(achievementInx, 16)
	net.Send(ply)
end

net.Receive("TA:NW_AchievedAchievement", function(len, pl)

	-- local ply = net.ReadEntity()
	-- if not IsValid(ply) then return end

	-- local achievementInx = net.ReadInt( 16 )
	-- if ( !pl.GASL_Player_Achievements ) then pl.GASL_Player_Achievements = {} end
	
	-- -- achievement allready gotted
	-- if ( pl.GASL_Player_Achievements[ achievementInx ] ) then return end
	-- pl.GASL_Player_Achievements[ achievementInx ] = 1
	 
	-- if ( !pl.GASL_Player_HUD_Achievements ) then pl.GASL_Player_HUD_Achievements = {} end

	-- table.insert( pl.GASL_Player_HUD_Achievements, table.Count( pl.GASL_Player_HUD_Achievements ) + 1, 
		-- { achievementInx = achievementInx, ply = pl, init = false, posY = 0, timeToHide = CurTime() + 10 } )

end )