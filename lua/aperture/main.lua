--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

-- Main 
APERTURESCIENCE.DRAW_HALOS = false

-- Funnel
APERTURESCIENCE.FUNNEL_MOVE_SPEED = 173
APERTURESCIENCE.FUNNEL_COLOR = Color( 0, 150, 255 )
APERTURESCIENCE.FUNNEL_REVERSE_COLOR = Color( 255, 150, 0 )

-- Fizzle
APERTURESCIENCE.DISSOLVE_SPEED = 150
APERTURESCIENCE.DISSOLVE_ENTITIES = { }

-- Diversity Vent
APERTURESCIENCE.DIVVENT_ENTITIES = { }

-- Achievement
APERTURESCIENCE.ACHIEVEMENTS = {
	[1] = { img = "achievement/turret_sing", text = "The Turret Song!" },
	[2] = { img = "achievement/fried_potato", text = "Fried Potato" },
	[3] = { img = "achievement/turret_fly", text = "Turret can fly" },
	[4] = { img = "achievement/cake", text = "Cake is not a lie!" },
	[5] = { img = "achievement/radio", text = "Strange channel" },
}
APERTURESCIENCE.HUD_ACHIEVEMENTS = { }

-- Allowing
APERTURESCIENCE.ALLOWING = {
	arm_panel = true
	, button = true
	, catapult = true
	, fizzler = true
	, item_dopper = true
	, laser_catcher = true
	, laser = true
	, laser_field = true
	, linker = true
	, paint = true
	, tractor_beam = true
	, wall_projector = true
	, turret = true
}

include( "aperture/sounds/paint_sounds.lua" )
include( "aperture/sounds/tractor_beam_sounds.lua" )
include( "aperture/sounds/catapult_sounds.lua" )
include( "aperture/sounds/wall_projector_sounds.lua" )
include( "aperture/sounds/monster_box_sounds.lua" )
include( "aperture/sounds/fizzler_sounds.lua" )
include( "aperture/sounds/laser_sounds.lua" )
include( "aperture/sounds/item_dropper_sounds.lua" )
include( "aperture/sounds/portal_button_sounds.lua" )
include( "aperture/sounds/portal_turret_sounds.lua" )
include( "aperture/sounds/portal_turret_different_sounds.lua" )
include( "aperture/sounds/portal_turret_defective_sounds.lua" )
include( "aperture/sounds/potatoos_sounds.lua" )
include( "aperture/sounds/radio_sounds.lua" )

include( "aperture/paint.lua" )

-- Console commands
APERTURESCIENCE.Convars = {}
APERTURESCIENCE.Convars[ "aperture_science_allow_arm_panel" ] = CreateConVar( "aperture_science_allow_arm_panel", "1", FCVAR_NONE, "Allowing Arm Panel" )
APERTURESCIENCE.Convars[ "aperture_science_allow_button" ] = CreateConVar( "aperture_science_allow_button", "1", FCVAR_NONE, "Allowing Button" )
APERTURESCIENCE.Convars[ "aperture_science_allow_catapult" ] = CreateConVar( "aperture_science_allow_catapult", "1", FCVAR_NONE, "Allowing Catapult" )
APERTURESCIENCE.Convars[ "aperture_science_allow_fizzler" ] = CreateConVar( "aperture_science_allow_fizzler", "1", FCVAR_NONE, "Allowing Fizzler" )
APERTURESCIENCE.Convars[ "aperture_science_allow_item_dropper" ] = CreateConVar( "aperture_science_allow_item_dropper", "1", FCVAR_NONE, "Allowing Item Dropper" )
APERTURESCIENCE.Convars[ "aperture_science_allow_laser_catcher" ] = CreateConVar( "aperture_science_allow_laser_catcher", "1", FCVAR_NONE, "Allowing Laser Catcher" )
APERTURESCIENCE.Convars[ "aperture_science_allow_laser" ] = CreateConVar( "aperture_science_allow_laser", "1", FCVAR_NONE, "Allowing Laser Emiter" )
APERTURESCIENCE.Convars[ "aperture_science_allow_laser_field" ] = CreateConVar( "aperture_science_allow_laser_field", "1", FCVAR_NONE, "Allowing Laser Field" )
APERTURESCIENCE.Convars[ "aperture_science_allow_linker" ] = CreateConVar( "aperture_science_allow_linker", "1", FCVAR_NONE, "Allowing Linker" )
APERTURESCIENCE.Convars[ "aperture_science_allow_paint" ] = CreateConVar( "aperture_science_allow_paint", "1", FCVAR_NONE, "Allowing Gel" )
APERTURESCIENCE.Convars[ "aperture_science_allow_tractor_beam" ] = CreateConVar( "aperture_science_allow_tractor_beam", "1", FCVAR_NONE, "Allowing Excursion Funnel" )
APERTURESCIENCE.Convars[ "aperture_science_allow_wall_projector" ] = CreateConVar( "aperture_science_allow_wall_projector", "1", FCVAR_NONE, "Allowing Hard Light Bridge" )
APERTURESCIENCE.Convars[ "aperture_science_allow_turret" ] = CreateConVar( "aperture_science_allow_turret", "1", FCVAR_NONE, "Allowing Arm Turrets" )
APERTURESCIENCE.Convars[ "aperture_science_allow_floor_button" ] = CreateConVar( "aperture_science_allow_floor_button", "1", FCVAR_NONE, "Allowing Floor Button" )

function APERTURESCIENCE:IsValid() return true end

function APERTURESCIENCE:UpdateParameters()

	APERTURESCIENCE.ALLOWING.arm_panel = tobool( self.Convars[ "aperture_science_allow_arm_panel" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.button = tobool( self.Convars[ "aperture_science_allow_button" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.catapult = tobool( self.Convars[ "aperture_science_allow_catapult" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.fizzler = tobool( self.Convars[ "aperture_science_allow_fizzler" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.item_dropper = tobool( self.Convars[ "aperture_science_allow_item_dropper" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.laser_catcher = tobool( self.Convars[ "aperture_science_allow_laser_catcher" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.laser = tobool( self.Convars[ "aperture_science_allow_laser" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.laser_field = tobool( self.Convars[ "aperture_science_allow_laser_field" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.linker = tobool( self.Convars[ "aperture_science_allow_linker" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.paint = tobool( self.Convars[ "aperture_science_allow_paint" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.tractor_beam = tobool( self.Convars[ "aperture_science_allow_tractor_beam" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.wall_projector = tobool( self.Convars[ "aperture_science_allow_wall_projector" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.turret = tobool( self.Convars[ "aperture_science_allow_turret" ]:GetInt() )
	APERTURESCIENCE.ALLOWING.floor_button = tobool( self.Convars[ "aperture_science_allow_floor_button" ]:GetInt() )
	
end
hook.Add( "Think", APERTURESCIENCE, APERTURESCIENCE.UpdateParameters )

function APERTURESCIENCE:ConvertToGridWithoutZ( pos, angle, rad )

	local WTL = WorldToLocal( pos, Angle( ), Vector( ), angle ) 
	WTL = Vector( math.Round( WTL.x / rad ) * rad, math.Round( WTL.y / rad ) * rad, WTL.z )
	pos = LocalToWorld( WTL, Angle( ), Vector( ), angle )
	
	return pos
	
end

function APERTURESCIENCE:PlaySequence( self, seq, rate )

	if ( !IsValid( self ) ) then return end
	
	local sequence = self:LookupSequence( seq )
	self:ResetSequence( sequence )

	self:SetPlaybackRate( rate )
	self:SetSequence( sequence )
	
	return self:SequenceDuration( sequence )
	
end

function APERTURESCIENCE:ConnectableStuff( ent )

	return ( IsValid( ent ) &&
		( ent:GetClass() == "ent_paint_dropper"
		|| ent:GetClass() == "ent_catapult"
		|| ent:GetClass() == "ent_tractor_beam"
		|| ent:GetClass() == "ent_wall_projector"
		|| ent:GetClass() == "ent_laser_field"
		|| ent:GetClass() == "ent_fizzler"
		|| ent:GetClass() == "ent_portal_laser"
		|| ent:GetClass() == "ent_laser_catcher"
		|| ent:GetClass() == "ent_laser_relay"
		|| ent:GetClass() == "ent_item_dropper"
		|| ent:GetClass() == "ent_arm_panel"
		|| ent:GetClass() == "ent_portal_frame"
		|| ent:GetClass() == "ent_portal_button"
		|| ent:GetClass() == "sent_portalbutton_box"
		|| ent:GetClass() == "sent_portalbutton_ball"
		|| ent:GetClass() == "sent_portalbutton_normal"
		|| ent:GetClass() == "sent_portalbutton_old" ) )
		
end

function APERTURESCIENCE:GASLStuff( ent )

	return ( IsValid( ent ) && 
		( ent:GetClass() == "env_portal_paint" 
		|| ent:GetClass() == "ent_paint_puddle"
		|| ent:GetClass() == "ent_paint_dropper"
		|| ent:GetClass() == "ent_tractor_beam"
		|| ent:GetClass() == "ent_wall_projector"
		|| ent:GetClass() == "ent_laser_field"
		|| ent:GetClass() == "ent_fizzler"
		|| ent:GetClass() == "ent_portal_laser"
		|| ent:GetClass() == "ent_laser_catcher"
		|| ent:GetClass() == "ent_laser_relay"
		|| ent:GetClass() == "ent_item_dropper"
		|| ent:GetClass() == "ent_portal_button"
		|| ent:GetClass() == "ent_portal_bomb"
		|| ent:GetClass() == "ent_catapult"
		|| ent:GetClass() == "ent_portal_frame"
		|| ent:GetClass() == "sent_portalbutton_box"
		|| ent:GetClass() == "sent_portalbutton_ball"
		|| ent:GetClass() == "sent_portalbutton_normal"
		|| ent:GetClass() == "sent_portalbutton_old" ) )
	
end

function APERTURESCIENCE:IsValidEntity( ent )

	return ( IsValid( ent ) && !ent.GASL_Ignore && ent:GetClass() != "prop_portal"
		&& IsValid( ent:GetPhysicsObject() )
		&& !APERTURESCIENCE:GASLStuff( ent ) )
		
end

function APERTURESCIENCE:IsValidStaticEntity( ent )

	return ( IsValid( ent ) && !ent.GASL_Ignore && ent:GetClass() != "prop_portal"
		&& IsValid( ent:GetPhysicsObject() ) && !ent:GetPhysicsObject():IsMotionEnabled()
		&& !APERTURESCIENCE:GASLStuff( ent ) )
		
end

function APERTURESCIENCE:DissolveEnt( ent )

	local phys = ent:GetPhysicsObject()
	ent:SetSolid( SOLID_NONE )
	if ( phys:GetVelocity():Length() < 10 ) then
		phys:SetVelocity( Vector( 0, 0, 10 ) + VectorRand() * 2 )
		phys:AddAngleVelocity( VectorRand() * 100 )
	else
		phys:SetVelocity( phys:GetVelocity() / 4 )
	end
	phys:EnableGravity( false )
	ent:EmitSound( "GASL.FizzlerDissolve" )
	table.insert( APERTURESCIENCE.DISSOLVE_ENTITIES, table.Count( APERTURESCIENCE.DISSOLVE_ENTITIES ) + 1, ent )

end

hook.Add( "Initialize", "GASL_Initialize", function()

	if ( SERVER ) then
		util.AddNetworkString( "GASL_NW_Player_Achievements" ) 
		util.AddNetworkString( "GASL_LinkConnection" ) 
		util.AddNetworkString( "GASL_Turrets_Activation" ) 
	end

end )

function APERTURESCIENCE:GiveAchievement( ply, achievementInx )
	
	if ( CLIENT ) then return end
	
	if ( !IsValid( ply ) ) then return end
	
	net.Start( "GASL_NW_Player_Achievements" )
		net.WriteString( "giveach" )
		net.WriteEntity( ply )
		net.WriteInt( achievementInx, 16 )
	net.Send( ply )
end

net.Receive( "GASL_NW_Player_Achievements", function( len, pl )

	local task = net.ReadString()
	
	pl = net.ReadEntity()
	if ( !IsValid( pl ) ) then return end

	if ( task == "giveach" ) then
		local achievementInx = net.ReadInt( 16 )
		if ( !pl.GASL_Player_Achievements ) then pl.GASL_Player_Achievements = {} end
		
		-- achievement allready gotted
		if ( pl.GASL_Player_Achievements[ achievementInx ] ) then return end
		pl.GASL_Player_Achievements[ achievementInx ] = 1
		 
		if ( !pl.GASL_Player_HUD_Achievements ) then pl.GASL_Player_HUD_Achievements = {} end
	
		table.insert( pl.GASL_Player_HUD_Achievements, table.Count( pl.GASL_Player_HUD_Achievements ) + 1, 
			{ achievementInx = achievementInx, ply = pl, init = false, posY = 0, timeToHide = CurTime() + 10 } )
			
	end

end )

hook.Add( "PostDrawHUD", "GASL_HUDPaint", function()
	
	-- cam.Start3D()
	
		-- render.SetMaterial( Material( "cable/xbeam" ) )
		-- render.StartBeam( table.Count( APERTURESCIENCE.CONNECTED_PAINTS ) )
		-- for k, v in pairs( APERTURESCIENCE.CONNECTED_PAINTS ) do
			
			-- render.AddBeam( v:GetPos(), v:GetGelRadius(), 1, Color( 255, 255, 255, 255 ) ) 
			
		-- end
		-- render.EndBeam()
		
	-- cam.End3D()	
	
	-- APERTURESCIENCE.CONNECTED_PAINTS = { }

	
	local AchivmentHeight = 100
	local AchivmentWidth = 300
	local ShadowX = 10
	local ShadowY = 10
	local ImgSize = 80
	local ImgXOffset = 10
	local TextXOffset = 10
	local TextYOffset = 10
	
	if ( !LocalPlayer().GASL_Player_HUD_Achievements ) then return end
	
	local itter = 0
	
	for k, v in pairs( LocalPlayer().GASL_Player_HUD_Achievements ) do
		
		if ( v.ply != LocalPlayer() ) then continue end
		
		if ( !v.init ) then
			LocalPlayer().GASL_Player_HUD_Achievements[ k ].init = true
			LocalPlayer():EmitSound( "garrysmod/save_load1.wav" )
		end
		
		local achievementInfo = APERTURESCIENCE.ACHIEVEMENTS[ v.achievementInx ]

		local timeToHide = ( v.timeToHide - CurTime() ) * 100
		
		if ( v.posY < AchivmentHeight && timeToHide > AchivmentHeight ) then
			LocalPlayer().GASL_Player_HUD_Achievements[ k ].posY = math.min( AchivmentHeight, 1000 - timeToHide )
		else
			LocalPlayer().GASL_Player_HUD_Achievements[ k ].posY = math.min( AchivmentHeight, timeToHide )
		end

		local panelX = ScrW() - AchivmentWidth
		local panelY = v.posY + itter * AchivmentHeight - AchivmentHeight

		-- shadow
		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( panelX - ShadowX, panelY + ShadowY, AchivmentWidth, AchivmentHeight ) 

		-- achievement background
		surface.SetDrawColor( 200, 200, 200, 255 )
		surface.DrawRect( panelX, panelY, AchivmentWidth, AchivmentHeight ) 
		
		surface.SetMaterial( Material( achievementInfo.img ) ) -- If you use Material, cache it!
		surface.DrawTexturedRect( panelX + ImgXOffset, panelY + AchivmentHeight / 2 - ImgSize / 2, ImgSize, ImgSize )
		
		surface.SetFont( "GASL_SecFont" )
		surface.SetTextColor( 255, 255, 255, 255 )
		local _, txtHeight = surface.GetTextSize( "" )
		surface.SetTextPos( panelX + ImgXOffset + ImgSize + TextXOffset, panelY + TextYOffset )
		surface.DrawText( achievementInfo.text )
		if ( timeToHide <= 0 ) then LocalPlayer().GASL_Player_HUD_Achievements[ k ] = nil end
		
		itter = itter + 1
		
	end
		
end )

if ( CLIENT ) then

	// STICKY gel camera orientation
	hook.Add( "Think", "GASL_CamOrient", function()
	
		local eyeAngles = LocalPlayer():EyeAngles()
		local newEyeAngle = Angle()
		local orientation = LocalPlayer():GetNWVector( "GASL:Orientation" )

		if ( !LocalPlayer():GetNWAngle( "GASL:OrientationAng" ) ) then LocalPlayer():SetNWAngle( "GASL:OrientationAng", eyeAngles ) end
		if ( !LocalPlayer():GetNWAngle( "GASL:PlayerAng" ) ) then LocalPlayer():SetNWAngle( "GASL:PlayerAng", eyeAngles ) end
		if ( !LocalPlayer():GetNWAngle( "GASL:PlayerEyeAngle" ) ) then LocalPlayer():SetNWAngle( "GASL:PlayerEyeAngle", eyeAngles ) end
		local playerEyeAngle = LocalPlayer():GetNWAngle( "GASL:PlayerEyeAngle" )

		if ( orientation == Vector( 0, 0, 1 ) ) then
		
			if ( math.abs( playerEyeAngle.r ) > 0.1 ) then
				playerEyeAngle.r = math.ApproachAngle( playerEyeAngle.r, 0, FrameTime() * math.min( playerEyeAngle.r * 10, 160 ) )
			elseif ( playerEyeAngle.r != 0 ) then
				playerEyeAngle.r = 0
			end
			
		end
		
		if ( newEyeAngle != eyeAngles ) then
			
			local orientationAng = LocalPlayer():GetNWAngle( "GASL:OrientationAng" )
			
			local playerAng = LocalPlayer():GetNWAngle( "GASL:PlayerAng" )

			if ( playerAng != eyeAngles ) then
			
				local angOffset = ( eyeAngles - playerAng )
				
				playerEyeAngle.p = math.max( -88, math.min( 88, playerEyeAngle.p ) )
				if ( playerEyeAngle.y > 360 ) then playerEyeAngle.y = playerEyeAngle.y - 360 end
				if ( playerEyeAngle.y < -360 ) then playerEyeAngle.y = playerEyeAngle.y + 360 end
				
				LocalPlayer():SetNWAngle( "GASL:PlayerEyeAngle", playerEyeAngle + angOffset )
				playerAng = eyeAngles
				LocalPlayer():SetNWAngle( "GASL:PlayerAng", playerAng )
				
			end
			
			local orientAng = orientation:Angle() + Angle( 90, 0, 0 )
			orientationAng.p = math.ApproachAngle( orientationAng.p, orientAng.p, FrameTime() * 150 )
			orientationAng.y = math.ApproachAngle( orientationAng.y, orientAng.y, FrameTime() * 150 )
			orientationAng.r = math.ApproachAngle( orientationAng.r, orientAng.r, FrameTime() * 150 )
			LocalPlayer():SetNWAngle( "GASL:OrientationAng", orientationAng )
			
			_, newEyeAngle = LocalToWorld( Vector(), playerEyeAngle, Vector(), orientationAng )
			
			local plyAng = -LocalPlayer():GetAngles()
			local _, orientAngToPly = WorldToLocal( Vector( ), plyAng, Vector( ), orientationAng )

			// changing cam orientation when player is have different orientation or roll is inccorect
			if ( orientation != Vector( 0, 0, 1 ) || orientation == Vector( 0, 0, 1 ) && math.abs( LocalPlayer():EyeAngles().r ) > 0.1 ) then
				LocalPlayer():ManipulateBoneAngles( 0, Angle( 0, 0, 0 ) )
				LocalPlayer():SetEyeAngles( newEyeAngle )
				LocalPlayer():SetNWAngle( "GASL:PlayerAng", newEyeAngle )
			end
		end
		
	end )
	
end

function APERTURESCIENCE:IsPlayerOnGround( ply )

	local orientation = ply:GetNWVector( "GASL:Orientation" )
	return orientation && orientation != Vector( 0, 0, 1 ) || ply:IsOnGround()
	
end

function APERTURESCIENCE:InvertNormal( normal )

	if ( normal.x != 0 ) then normal.x = normal.x * -1 end
	if ( normal.y != 0 ) then normal.y = normal.y * -1 end
	if ( normal.z != 0 ) then normal.z = normal.z * -1 end
	
end

function APERTURESCIENCE:NormalFlipZeros( normal )

	local lower = 0.000001
	if ( math.abs( normal.x ) < lower ) then normal.x = 0 end
	if ( math.abs( normal.y ) < lower ) then normal.y = 0 end
	if ( math.abs( normal.z ) < lower ) then normal.z = 0 end
	
end

if ( CLIENT ) then return end

hook.Add( "Think", "GASL_HandlingGel", function()	

	for i, ply in pairs( player.GetAll() ) do
		
		//ply:SetAngle( 0, Angle( 0, 0, 0 ) )
		-- Checking if player stands or hit paint
		if ( ply:GetNWVector( "GASL:Orientation" ) == Vector() ) then ply:SetNWVector( "GASL:Orientation", Vector( 0, 0, 1 ) ) end
		if ( !ply:GetNWVector( "GASL:OrientationWalk" ) ) then ply:SetNWVector( "GASL:OrientationWalk", Vector( 0, 0, 0 ) ) end
		if ( !ply.GASL_Player_Orient ) then ply.GASL_Player_Orient = Angle() end
		if ( !ply.GASL_Player_PrevOrient ) then ply.GASL_Player_PrevOrient = Angle() end

		local paint = NULL
		local paintType = 0
		local PaintNormal = Vector( )
		local orientation = ply:GetNWVector( "GASL:Orientation" )
		
		// Handling changing orientation
		if ( !ply.GASL_FloorDown || ply.GASL_FloorDown && ply.GASL_FloorDown:Distance( orientation ) > 0.000001 ) then
		
			ply.GASL_FloorDown = orientation
			local orientPos = orientation * ply:GetModelRadius()
			local plyAngle = ply:EyeAngles()
			local plyOrientCenter = ply:GetPos() + orientation * ply:GetModelRadius() / 2
			
			ply:SetCurrentViewOffset( Vector( orientPos.x, orientPos.y, 0 )  )
			ply:SetViewOffset( Vector( 0, 0, orientPos.z ) )
			
			//local _, localangle = WorldToLocal( Vector(), ply.GASL_Player_PrevOrient + Angle( 90, 0, 0 ), Vector(), orientation:Angle() + Angle( 90, 0, 0 ) )
			-- localangle = Angle( 0, localangle.y, 0 )
			-- local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), orientation:Angle() - Angle( 90, 0, 0 ) )
			-- worldangle = Angle( 0, worldangle.y, 0 )
			//plyAngle.yaw = plyAngle.yaw - ( ply.GASL_Player_Orient.yaw - ply.GASL_Player_PrevOrient.yaw )
			//ply:SetEyeAngles( plyAngle )
			//print( ply.GASL_Player_PrevOrient, "_____", ply.GASL_Player_Orient )
			//ply.GASL_Player_PrevOrient = ply.GASL_Player_Orient
			
			local trace = util.QuickTrace( plyOrientCenter, -orientation * ( ply:GetModelRadius() + 50 ), ply )
			ply:SetPos( trace.HitPos )
			
			// cooldown for changing
			timer.Create( "GASL_Player_Changed"..ply:EntIndex(), 0.1, 1, function() end ) // disable changeabling for a second
			
		end
		
		local eyeAngle = ply:EyeAngles()
		
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) || orientation != Vector( 0, 0, 1 ) ) then
			paint, paintType, PaintNormal = APERTURESCIENCE:CheckForGel( ply:GetPos() + orientation * ply:GetModelRadius() / 2, -orientation * ( ply:GetModelRadius() + 50 ) )
		else
			local dir = ply:GetVelocity() / 20
			
			if ( dir:Length() < ply:GetModelRadius() ) then
				dir = dir:GetNormalized() * ply:GetModelRadius()
			end
			
			paint, paintType, PaintNormal = APERTURESCIENCE:CheckForGel( ply:GetPos() + orientation * ply:GetModelRadius() / 2, dir )
		end

		-- Checking Wall when on Sticky Gel
		local speed = ply:KeyDown( IN_SPEED ) and ply:GetRunSpeed() or ply:GetWalkSpeed()
		local moveDirection = Vector( 0, 0, 0 )
		local plyOrientCenter = ply:GetPos() + orientation * ply:GetModelRadius() / 2
		
		if ( ply:KeyDown( IN_FORWARD ) ) then moveDirection.x = 1 end
		if ( ply:KeyDown( IN_BACK ) ) then moveDirection.x = -1 end
		if ( ply:KeyDown( IN_MOVELEFT ) ) then moveDirection.y = 1 end
		if ( ply:KeyDown( IN_MOVERIGHT ) ) then moveDirection.y = -1 end
		moveDirection:Normalize() 
		moveDirection = moveDirection * ply:GetModelRadius() / 2
		
		local eyeAng = ply:EyeAngles()
		local orientAng = orientation:Angle() + Angle( 90, 0, 0 )
		local _, localangle = WorldToLocal( Vector(), eyeAng, Vector(), orientAng )
		localangle = Angle( 0, localangle.yaw, 0 )
		local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), orientAng )
		moveDirection:Rotate( worldangle )

		local p, pT, pN = APERTURESCIENCE:CheckForGel( plyOrientCenter, moveDirection )
		
		if ( IsValid( p ) && pT == PORTAL_GEL_STICKY && !timer.Exists( "GASL_Player_Changed"..ply:EntIndex() ) ) then
			orientation = pN
			ply.GASL_Player_Orient = pN:Angle() + Angle( 90, 0, 0 )

			ply:SetNWVector( "GASL:Orientation", orientation )
			
			local trace = util.QuickTrace( plyOrientCenter, -orientation * ( ply:GetModelRadius() + 50 ), ply )
			ply:SetNWVector( "GASL:OrientationWalk", trace.HitPos )
			ply:SetPos( trace.HitPos )
			ply:SetVelocity( -ply:GetVelocity() )

		end
		
		-- Exiting Gel
		if ( ply.GASL_LastStandingGelType && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
		
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_BOUNCE ) then
				ply:EmitSound( "GASL.GelBounceExit" )
			end
			
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_SPEED ) then
				ply:EmitSound( "GASL.GelSpeedExit" )
			end
			
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_STICKY ) then
				local offset = orientation * ( orientation - Vector( 0, 0, 1 ) ):Length() * ply:GetModelRadius() / 1.5
				local traceFloor = util.QuickTrace( ply:GetPos() + offset, Vector( 0, 0, -ply:GetModelRadius() ), ply )
				offset = offset - Vector( 0, 0, traceFloor.Fraction * ply:GetModelRadius() )
				
				ply:SetPos( ply:GetPos() + offset )
				ply:SetNWVector( "GASL:Orientation", Vector( 0, 0, 1 ) )
				ply:SetNWVector( "GASL:OrientationWalk", Vector( ) )
			end

			ply.GASL_LastStandingGelType = 0
		
		end

		if ( !IsValid( paint ) ) then
		
			-- if ( orientation != Vector( 0, 0, 1 ) ) then
				-- ply:SetNWVector( "GASL:Orientation", Vector( 0, 0, 1 ) )
			-- end
			
			-- Skip if paint doesn't found
			continue
		end
		APERTURESCIENCE:NormalFlipZeros( PaintNormal )
		
		-- Footsteps sounds
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) && !timer.Exists( "GASL_GelFootsteps"..ply:EntIndex() )
			&& ( ply:KeyDown( IN_FORWARD )
			|| ply:KeyDown( IN_BACK )
			|| ply:KeyDown( IN_MOVERIGHT )
			|| ply:KeyDown( IN_MOVELEFT ) ) ) then
		
			ply:EmitSound( "GASL.GelFootsteps" )

			local tick
			if ( ply:KeyDown( IN_SPEED ) ) then
				tick = 0.2
			else
				tick = 0.4
			end
			
			timer.Create( "GASL_GelFootsteps"..ply:EntIndex(), tick, 1, function() end )
			
		end
		
		-- Entering Gel
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) ) then
			
			if ( !ply.GASL_LastTimeOnGel || ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
			
				if ( paintType == PORTAL_GEL_BOUNCE ) then
					ply:EmitSound( "GASL.GelBounceEnter" )
				end
				
				if ( paintType == PORTAL_GEL_SPEED ) then
					ply:EmitSound( "GASL.GelSpeedEnter" )
				end
				
				if ( paintType == PORTAL_GEL_STICKY ) then
					local plyOrientCenter = ply:GetPos() + orientation * ply:GetModelRadius() / 2
					local trace = util.QuickTrace( plyOrientCenter, -orientation * ( ply:GetModelRadius() + 50 ), ply )
					orientation = ply:GetNWVector( "GASL:Orientation" )
					
					ply:SetNWVector( "GASL:OrientationWalk", trace.HitPos )
					ply.GASL_Player_Orient = PaintNormal:Angle() + Angle( 90, 0, 0 )
					ply:SetPos( trace.HitPos )
					ply:SetVelocity( -ply:GetVelocity() )
				end
				
				-- doesn't change if player ran on repulsion paint when he was on propulsion paint
				if ( !( paintType == PORTAL_GEL_BOUNCE && ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then
					ply.GASL_LastStandingGelType = paintType
				end
				
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		
		end
		
		-- if player stand on repulsion paint
		if ( paintType == PORTAL_GEL_BOUNCE && !ply:KeyDown( IN_DUCK ) ) then
		
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
			if ( APERTURESCIENCE:IsPlayerOnGround( ply ) && !( ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then continue end
			
			local WTL = WorldToLocal( paint:GetPos() + plyVelocity, Angle( ), paint:GetPos(), paint:GetAngles() )
			WTL = Vector( 0, 0, math.max( -WTL.z * 2, 800 ) )
			local LTW = LocalToWorld( WTL, Angle( ), paint:GetPos(), paint:GetAngles() ) - paint:GetPos()
			LTW.z = math.max( 200, LTW.z / 2 )
			
			ply:SetVelocity( LTW - Vector( 0, 0, ply:GetVelocity().z ) )
			ply:EmitSound( "GASL.GelBounce" )

		end
		
		-- if player stand on propulsion paint
		if ( paintType == PORTAL_GEL_SPEED ) then
		
			local plyVelocity = ply:GetVelocity()

			if ( !ply.GASL_GelPlayerVelocity ) then ply.GASL_GelPlayerVelocity = Vector( ) end
			
			if ( plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() ) then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
			
			if ( ply:KeyDown( IN_FORWARD ) ) then
				ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector( ply:GetForward().x, ply:GetForward().y, 0 ) * 20
			end

			ply:SetVelocity( Vector( ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0 ) * FrameTime() * 40 )
			ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
			
		end
		
		-- if player stand on sticky paint
		if ( paintType == PORTAL_GEL_STICKY && ply:GetNWVector( "GASL:OrientationWalk" ) != Vector() ) then

			orientation = ply:GetNWVector( "GASL:Orientation" )
			
			if ( !timer.Exists( "GASL_Player_Changed"..ply:EntIndex() ) && PaintNormal:Distance( orientation ) > 0.000001 ) then
				orientation = PaintNormal

				APERTURESCIENCE:NormalFlipZeros( orientation )
				ply.GASL_Player_Orient = PaintNormal:Angle() + Angle( 90, 0, 0 )
				ply:SetNWVector( "GASL:Orientation", orientation )
				
				//print( ply.GASL_Player_Orient )
				
			end
			
			local localPos = ply:GetNWVector( "GASL:OrientationWalk" )
			
			if ( localPos != Vector( ) && orientation != Vector( 0, 0, 1 ) ) then
				
				local eyeAng = ply:EyeAngles()
				
				local speed = ply:KeyDown( IN_SPEED ) and ply:GetRunSpeed() or ply:GetWalkSpeed()
				local moveDirection = Vector( 0, 0, 0 )

				if ( ply:KeyDown( IN_FORWARD ) ) then moveDirection.x = 1 end
				if ( ply:KeyDown( IN_BACK ) ) then moveDirection.x = -1 end
				if ( ply:KeyDown( IN_MOVELEFT ) ) then moveDirection.y = 1 end
				if ( ply:KeyDown( IN_MOVERIGHT ) ) then moveDirection.y = -1 end
				
				moveDirection = moveDirection:GetNormalized() * speed / 50
				
				local orientAng = orientation:Angle() + Angle( 90, 0, 0 )
				local _, localangle = WorldToLocal( Vector(), eyeAng, Vector(), orientAng )
				localangle = Angle( 0, localangle.yaw, 0 )
				local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), orientAng )
				moveDirection:Rotate( worldangle )

				if ( ply:KeyDown( IN_JUMP ) ) then
					local traceFloor = util.QuickTrace( ply:GetPos(), Vector( 0, 0, -ply:GetModelRadius() ), ply )
					moveDirection = orientation * ( orientation - Vector( 0, 0, 1 ) ):Length() * ply:GetModelRadius() / 1.5 - Vector( 0, 0, ply:GetModelRadius() * traceFloor.Fraction )
					ply:SetNWVector( "GASL:Orientation", Vector( 0, 0, 1 ) )
					ply:SetNWVector( "GASL:OrientationWalk", Vector( ) )
					ply:SetVelocity( orientation * ply:GetJumpPower() )
				end

				local plyWidth = 30
				local traceForward = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, orientAng:Forward() * plyWidth, ply )
				local traceBack = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, -orientAng:Forward() * plyWidth, ply )
				local traceRight = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, orientAng:Right() * plyWidth, ply )
				local traceLeft = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, -orientAng:Right() * plyWidth, ply )
				
				if ( traceForward.Hit ) then moveDirection = moveDirection - orientAng:Forward() * ( 1 - traceForward.Fraction ) * plyWidth end
				if ( traceBack.Hit ) then moveDirection = moveDirection + orientAng:Forward() * ( 1 - traceBack.Fraction ) * plyWidth end
				if ( traceRight.Hit ) then moveDirection = moveDirection - orientAng:Right() * ( 1 - traceRight.Fraction ) * plyWidth end
				if ( traceLeft.Hit ) then moveDirection = moveDirection + orientAng:Right() * ( 1 - traceLeft.Fraction ) * plyWidth end
				
				local walk = localPos + moveDirection
				ply:SetNWVector( "GASL:OrientationWalk", walk )
				ply:SetPos( walk )
				if ( !ply:KeyDown( IN_JUMP ) ) then
					ply:SetVelocity( -ply:GetVelocity() )
				end
			end
			
		end
		
	end
	
	-- Handling paintled entities
	for k, v in pairs( APERTURESCIENCE.GELLED_ENTITIES ) do
	
		-- skip and remove if entity is not exist
		if ( !IsValid( v ) ) then
			APERTURESCIENCE.GELLED_ENTITIES[ k ] = nil
			continue
		end

		-- skip if props is freezed or it is holding by the player
		if ( IsValid( v:GetPhysicsObject() ) && !v:GetPhysicsObject():IsMotionEnabled( ) || v:IsPlayerHolding() ) then continue end
		
		local vPhys = v:GetPhysicsObject()
		local dir = vPhys:GetVelocity() / 10
		
		local trace = util.TraceEntity( { 
			start = v:GetPos()
			, endpos = v:GetPos() + dir
			, filter = v 
		}, v )

		if ( v.GASL_GelledType == PORTAL_GEL_BOUNCE ) then
		
			if ( trace.Hit ) then
				
				v:EmitSound( "GASL.GelBounceProp" )
				-- makes negative z for local hitnormal
				local WTL = WorldToLocal( vPhys:GetVelocity(), Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				WTL.z = math.max( -WTL.z, 400 )
				WTL = WTL + VectorRand() * 100
				local LTW = LocalToWorld( WTL, Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				
				vPhys:SetVelocity( LTW )
				
				v:GetPhysicsObject():AddAngleVelocity( VectorRand() * 400 )
				
			end
			
		end
		
		if ( v.GASL_GelledType == PORTAL_GEL_STICKY ) then
		
			if ( trace.Hit && ( !IsValid( trace.Entity ) || IsValid( trace.Entity ) && !IsValid( constraint.Find( v, trace.Entity, "Weld", 0, 0 ) ) ) ) then
				timer.Simple( dir:Length() / 1000, function()
					if ( IsValid( v ) && IsValid( v:GetPhysicsObject() ) ) then
						if ( trace.HitWorld ) then
							v:GetPhysicsObject():EnableMotion( false )
						elseif( IsValid( trace.Entity ) ) then
							constraint.Weld( v, trace.Entity, 0, trace.PhysicsBone, 5000, collision == 0, false )
						end
					end
				end )
			end
			
		end
		
	end
	
	-- Handling dissolved entities
	for k, v in pairs( APERTURESCIENCE.DISSOLVE_ENTITIES ) do
	
		-- skip if entity doesn't exist
		if ( !v:IsValid() ) then
			APERTURESCIENCE.DISSOLVE_ENTITIES[ k ] = nil
			continue
		end
		
		if ( !v.GASL_Dissolve ) then v.GASL_Dissolve = 0 end
		v.GASL_Dissolve = v.GASL_Dissolve + 1
		
		-- turning entity into black and then fadeout alpha
		local colorBlack = ( math.max( 0, APERTURESCIENCE.DISSOLVE_SPEED - v.GASL_Dissolve * 1.75 ) / APERTURESCIENCE.DISSOLVE_SPEED ) * 255
		
		local alpha = math.max( 0, v.GASL_Dissolve - APERTURESCIENCE.DISSOLVE_SPEED / 1.1 ) / ( APERTURESCIENCE.DISSOLVE_SPEED - APERTURESCIENCE.DISSOLVE_SPEED / 1.1 )
		alpha = 255 - alpha * 255
		v:SetColor( Color( colorBlack, colorBlack, colorBlack, alpha ) )
		
		if ( alpha < 255 ) then v:SetRenderMode( RENDERMODE_TRANSALPHA ) end

		local effectdata = EffectData()
		effectdata:SetEntity( v )
		util.Effect( "fizzler_dissolve", effectdata )
		
		if ( v.GASL_Dissolve >= APERTURESCIENCE.DISSOLVE_SPEED ) then
		
			APERTURESCIENCE.DISSOLVE_ENTITIES[ k ] = nil
			v:Remove()
			
		end
		
	end

	-- Handling entities in diversity vent
	for k, v in pairs( APERTURESCIENCE.DIVVENT_ENTITIES ) do
	
		local vDivventEnt = v.GASL_ENTITY_DivventEnt
		
		if ( !IsValid( vDivventEnt )
			|| vDivventEnt:GetModel() != "models/props_backstage/vacum_scanner_b.mdl" 
			&& ( vDivventEnt:GetPos():Distance( v:GetPos() ) > 1000 ) ) then 
				APERTURESCIENCE.DIVVENT_ENTITIES[ k ] = nil
				continue 
			end
		
		if ( !vDivventEnt:ModelToFlowPos() ) then continue end
		local moveTo = vDivventEnt:LocalToWorld( vDivventEnt:ModelToFlowPos() )
		
		if ( v:GetPos():Distance( moveTo ) < 40 ) then
			
			if ( !vDivventEnt.GASL_DIVVENT_Connections ) then APERTURESCIENCE.DIVVENT_ENTITIES[ k ] = nil continue end
			
			v.GASL_ENTITY_DivventEnt = vDivventEnt.GASL_DIVVENT_Connections[ 1 ]
		end
		
		if ( v:IsPlayer() || v:IsNPC() ) then
			
			local dir = ( moveTo - Vector( 0, 0, v:GetModelRadius() / 2 ) - v:GetPos() ):GetNormalized()
			v:SetVelocity( dir * 1000 + VectorRand() * math.max( 0, 200 - v:GetVelocity():Length() ) * 10 - v:GetVelocity() )
		
		elseif ( IsValid( v:GetPhysicsObject() ) ) then

			local dir = ( moveTo - v:GetPos() ):GetNormalized()

			local vPhys = v:GetPhysicsObject()
			vPhys:SetVelocity( vPhys:GetVelocity() / 2 + dir * 400 )
			
		end
		
	end

end )

hook.Add( "PhysgunPickup", "GASL_DisablePhysgunPickup", function( ply, ent )
	if ( ent.GASL_Untouchable ) then return false end
end )

hook.Add( "KeyPress", "GASL_HandlePlayerJump", function( ply, key )

	if ( key != IN_JUMP || !ply:IsOnGround() ) then return end
	
	local trace = { start = ply:GetPos(), endpos = ply:GetPos() - Vector( 0, 0, 100 ), filter = ply }
	local ent = util.TraceEntity( trace, ply ).Entity
	local paintType = 0
	
	if ( IsValid( ent ) ) then
		if ( ent:GetClass() == "env_portal_paint" ) then
			paintType = ent:GetGelType()
		else
			paintType = 0
		end
	else
		ent, paintType = APERTURESCIENCE:CheckForGel( ply:GetPos(), Vector( 0, 0, -100 ) )
	end
	
	-- Skip if it's not bridge or paint
	if ( !ent:IsValid() || ent:IsValid() 
		&& ( ent:GetModel() != "models/wall_projector_bridge/wall.mdl"
		&& ent:GetClass() != "env_portal_paint" ) ) then return end
		
	if ( ent:GetModel() == "models/wall_projector_bridge/wall.mdl" ) then
		ent:EmitSound( "GASL.WallProjectorFootsteps" )
	elseif ( ent:GetClass() == "env_portal_paint" ) then
	
		ent:EmitSound( "GASL.GelFootsteps" )
		
		if ( paintType == PORTAL_GEL_BOUNCE ) then
			
			ply:SetVelocity( Vector( 0, 0, 400 ) )
			ply:EmitSound( "GASL.GelBounce" )
			
		end
		
	end
	
end )
