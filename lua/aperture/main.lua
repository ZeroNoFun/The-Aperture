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

-- Gel
APERTURESCIENCE.GEL_QUALITY = 1
APERTURESCIENCE.GEL_BOX_SIZE = 47
APERTURESCIENCE.GEL_MAXSIZE = 150
APERTURESCIENCE.GEL_MINSIZE = 40
APERTURESCIENCE.GEL_BOUNCE_COLOR = Color( 0, 100, 255 )
APERTURESCIENCE.GEL_SPEED_COLOR = Color( 255, 100, 0 )
APERTURESCIENCE.GEL_PORTAL_COLOR = Color( 180, 190, 200 )
APERTURESCIENCE.GEL_WATER_COLOR = Color( 200, 230, 255 )
APERTURESCIENCE.GELLED_ENTITIES = { }

-- Fizzle
APERTURESCIENCE.DISSOLVE_SPEED = 150
APERTURESCIENCE.DISSOLVE_ENTITIES = { }

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
	APERTURESCIENCE.ALLOWING.item_dopper = tobool( self.Convars[ "aperture_science_allow_item_dropper" ]:GetInt() )
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
		|| ent:GetClass() == "ent_tractor_beam"
		|| ent:GetClass() == "ent_wall_projector"
		|| ent:GetClass() == "ent_laser_field"
		|| ent:GetClass() == "ent_fizzler"
		|| ent:GetClass() == "ent_portal_laser"
		|| ent:GetClass() == "ent_laser_catcher"
		|| ent:GetClass() == "ent_laser_relay"
		|| ent:GetClass() == "ent_item_dropper"
		|| ent:GetClass() == "ent_arm_panel"
		|| ent:GetClass() == "ent_portal_button"
		|| ent:GetClass() == "sent_portalbutton_box"
		|| ent:GetClass() == "sent_portalbutton_ball"
		|| ent:GetClass() == "sent_portalbutton_normal"
		|| ent:GetClass() == "sent_portalbutton_old" ) )
		
end

function APERTURESCIENCE:GASLStuff( ent )

	return ( IsValid( ent ) && (
		ent:GetClass() == "env_portal_paint" 
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
		|| ent:GetClass() == "ent_catapult" ) )
	
end

function APERTURESCIENCE:IsValidEntity( ent )

	return ( IsValid( ent ) && !ent.GASL_Ignore 
		&& ( !IsValid( ent:GetPhysicsObject() ) || IsValid( ent:GetPhysicsObject() ) && ent:GetPhysicsObject():IsMotionEnabled() )
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

function APERTURESCIENCE:GetColorByGelType( paintType )

	local color = Color( 0, 0, 0 )
	if ( paintType == 1 ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( paintType == 2 ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	if ( paintType == 3 ) then color = APERTURESCIENCE.GEL_PORTAL_COLOR end
	if ( paintType == 4 ) then color = APERTURESCIENCE.GEL_WATER_COLOR end
	
	return color
	
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

function APERTURESCIENCE:CheckForGel( startpos, dir, skipprops )
	
	if ( skipprops == nil ) then skipprops = false end
	
	local paintedProp = false
	
	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		filter = function( ent ) if ( ent:GetClass() == "env_portal_paint" || !skipprops && ent.GASL_GelledType ) then return true end end
	} )
	
	local paintType = 0
	
	if ( !IsValid( trace.Entity ) ) then return NULL end
	
	if ( trace.Entity:GetClass() == "env_portal_paint" ) then
		paintType = trace.Entity:GetGelType()
	else
		paintType = trace.Entity.GASL_GelledType
	end
	
	return trace.Entity, paintType
	
end

if ( CLIENT ) then return end

hook.Add( "Think", "GASL_HandlingGel", function()
	
	for i, ply in pairs( player.GetAll() ) do
		
		-- Checking if player stands or hit paint
		
		local paint = NULL
		local paintType = 0
		
		if ( ply:IsOnGround() ) then
			paint, paintType = APERTURESCIENCE:CheckForGel( ply:GetPos(), Vector( 0, 0, -100 ) )
		else
			local dir = ply:GetVelocity() / 20
			
			if ( dir:Length() < 30 ) then
				dir = dir:GetNormalized() * 30
			end
			
			paint, paintType = APERTURESCIENCE:CheckForGel( ply:GetPos(), dir )
		end
		
		-- Exiting Gel
		if ( ply.GASL_LastStandingGelType && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
		
			if ( ply.GASL_LastStandingGelType == 1 ) then
				ply:EmitSound( "GASL.GelBounceExit" )
			end
			
			if ( ply.GASL_LastStandingGelType == 2 ) then
				ply:EmitSound( "GASL.GelSpeedExit" )
			end

			ply.GASL_LastStandingGelType = 0
		
		end

		-- Skip if paint doesn't found
		if ( !paint:IsValid() ) then continue end
		
		-- Footsteps sounds
		if ( ply:IsOnGround() && !timer.Exists( "GASL_GelFootsteps"..ply:EntIndex() )
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
		if ( ply:IsOnGround() ) then
		
			if ( !ply.GASL_LastTimeOnGel || ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
			
				if ( paintType == 1 ) then
					ply:EmitSound( "GASL.GelBounceEnter" )
				end
				
				if ( paintType == 2 ) then
					ply:EmitSound( "GASL.GelSpeedEnter" )
				end

				-- doesn't change if player ran on repulsion paint when he was on propulsion paint
				if ( !( paintType == 1 && ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then
					ply.GASL_LastStandingGelType = paintType
				end
				
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		
		end
		
		-- if player hit repulsion paint
		if ( paintType == 1 && !ply:KeyDown( IN_DUCK ) ) then
		
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
			if ( ply:IsOnGround() && !( ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then continue end
			
			local WTL = WorldToLocal( paint:GetPos() + plyVelocity, Angle( ), paint:GetPos(), paint:GetAngles() )
			WTL = Vector( 0, 0, math.max( -WTL.z * 2, 800 ) )
			local LTW = LocalToWorld( WTL, Angle( ), paint:GetPos(), paint:GetAngles() ) - paint:GetPos()
			LTW.z = math.max( 200, LTW.z / 2 )
			
			ply:SetVelocity( LTW - Vector( 0, 0, ply:GetVelocity().z ) )
			ply:EmitSound( "GASL.GelBounce" )

		end
		
		-- if player hit propulsion paint
		if (paintType == 2 ) then
		
			local plyVelocity = ply:GetVelocity()

			if ( !ply.GASL_GelPlayerVelocity ) then ply.GASL_GelPlayerVelocity = Vector( ) end
			
			if ( plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() ) then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
			
			if ( ply:KeyDown( IN_FORWARD ) ) then
				ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector( ply:GetForward().x, ply:GetForward().y, 0 ) * 30
			end

			ply:SetVelocity( Vector( ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0 ) / 2 * math.max( 1, ply:Ping() / 50 ) )
			ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
			
		end
		
	end
	
	-- Handling paintled entities
	for k, v in pairs( APERTURESCIENCE.GELLED_ENTITIES ) do
	
		-- skip and remove if entity is not exist
		if ( !IsValid( v ) ) then
			APERTURESCIENCE.GELLED_ENTITIES[ k ] = nil
			continue
		end

		if ( IsValid( v:GetPhysicsObject() ) && !v:GetPhysicsObject():IsMotionEnabled( ) ) then continue end
		
		if ( v.GASL_GelledType == 1 ) then
			
			local vPhys = v:GetPhysicsObject()
			local dir = vPhys:GetVelocity() / 50
			
			if ( dir:Length() < 40 ) then
			
				if ( dir == Vector() ) then dir = Vector( 0, 0, -1 ) end
				dir = dir:GetNormalized() * 40
				
			end
			
			local trace = { start = v:GetPos(), endpos = v:GetPos() + dir, filter = v }

			local tr = util.TraceEntity( trace, v )

			if ( tr.Hit ) then
				
				v:EmitSound( "GASL.GelBounceProp" )
				-- makes negative z for local hitnormal
				local WTL = WorldToLocal( vPhys:GetVelocity(), Angle( ), Vector( ), tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				WTL.z = math.max( -WTL.z, 400 )
				WTL = WTL + VectorRand() * 100
				local LTW = LocalToWorld( WTL, Angle( ), Vector( ), tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				
				vPhys:SetVelocity( LTW )
				
				v:GetPhysicsObject():AddAngleVelocity( VectorRand() * 400 )
				
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
		
		if ( paintType == 1 ) then
			
			ply:SetVelocity( Vector( 0, 0, 400 ) )
			ply:EmitSound( "GASL.GelBounce" )
			
		end
		
	end
	
end )
