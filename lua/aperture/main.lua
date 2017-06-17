--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

-- Main 
APERTURESCIENCE.DRAW_HALOS 	= false
APERTURESCIENCE.GRID_SIZE 	= 64

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

function APERTURESCIENCE:ConvertToGrid( pos, rad )

	local pos = Vector( math.Round( pos.x / rad ) * rad, math.Round( pos.y / rad ) * rad, math.Round( pos.z / rad ) * rad )
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
		|| ent:GetClass() == "ent_portal_door"
		|| ent:GetClass() == "ent_portal_frame"
		|| ent:GetClass() == "ent_portal_button"
		|| ent:GetClass() == "ent_portal_button_box"
		|| ent:GetClass() == "ent_portal_button_ball"
		|| ent:GetClass() == "ent_portal_button_normal"
		|| ent:GetClass() == "ent_portal_button_old" ) )
		
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
		|| ent:GetClass() == "ent_portal_door"
		|| ent:GetClass() == "ent_portal_frame"
		|| ent:GetClass() == "ent_portal_button_box"
		|| ent:GetClass() == "ent_portal_button_ball"
		|| ent:GetClass() == "ent_portal_button_normal"
		|| ent:GetClass() == "ent_portal_button_old" ) )
	
end

function APERTURESCIENCE:IsValidEntity( ent )

	return ( IsValid( ent ) && !ent.GASL_Ignore && ent:GetClass() != "prop_portal"
		&& IsValid( ent:GetPhysicsObject() )
		&& !APERTURESCIENCE:GASLStuff( ent )
		&& ent:GetClass() != "env_portal_wall" )
		
end

function APERTURESCIENCE:IsValidStaticEntity( ent )

	return ( IsValid( ent ) 
		&& ( !ent.GASL_Ignore && ent:GetClass() != "prop_portal"
		&& IsValid( ent:GetPhysicsObject() ) && !ent:GetPhysicsObject():IsMotionEnabled()
		&& !APERTURESCIENCE:GASLStuff( ent ) 
		|| ent:GetClass() == "env_portal_wall" ) )
		
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

-- if ( CLIENT ) then
	-- function draw.Circle( x, y, radius, rad2, seg )
		-- local cir = {}

		-- local rad = 10 
		-- table.insert( cir, { x = math.Round( x / rad ) * rad, y = math.Round( y / rad ) * rad, u = 0.5, v = 0.5 } )
		-- for i = 0, seg do
			-- local a = math.rad( ( i / seg ) * -360 )
			-- table.insert( cir, { 
				-- x = x + math.Round( math.sin( a ) * radius / rad ) * rad, 
				-- y = y + math.Round( math.cos( a ) * rad2 / rad ) * rad, 
				-- u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 
			-- } )
		-- end

		-- local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		-- table.insert( cir, { 
		-- x = math.Round( (x + math.sin( a ) * radius) / rad ) * rad, 
		-- y = math.Round( (y + math.cos( a ) * rad2) / rad ) * rad, 
		-- u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		-- surface.DrawPoly( cir )
	-- end

	-- hook.Add( "PostDrawOpaqueRenderables", "example", function()

		-- local trace = LocalPlayer():GetEyeTrace()
		-- local angle = trace.HitNormal:Angle()

		-- render.DrawLine( trace.HitPos, trace.HitPos + 8 * angle:Forward(), Color( 255, 0, 0 ), true )
		-- render.DrawLine( trace.HitPos, trace.HitPos + 8 * -angle:Right(), Color( 0, 255, 0 ), true )
		-- render.DrawLine( trace.HitPos, trace.HitPos + 8 * angle:Up(), Color( 0, 0, 255 ), true )
		-- //render.SetModelLighting( BOX_FRONT, 255, 255, 255 )
		-- render.ComputeDynamicLighting( trace.HitPos, trace.HitNormal ) 
		-- render.OverrideDepthEnable( true, false )
		-- render.SetLightingMode( 2 ) 
		-- render.SetLightmapTexture( Material( "paint/paint_fill" ):GetTexture( "$basetexture" ) )
		-- render.SetMaterial( Material( "paint/paint_fill" ) )
		-- render.SetLightingOrigin( Vector( 0, 0, 100 ) ) 

		-- render.PushFlashlightMode( false ) 
		-- cam.Start3D2D( trace.HitPos, angle + Angle( 90, 0, 0 ), 1 )

			-- surface.SetMaterial( Material( "paint/paint_fill" ) )
			-- surface.SetDrawColor( 255, 255, 255, 255 )
			-- draw.Circle( 0, 0, 50 + math.sin( CurTime() ) * 30, 50 + math.cos( CurTime() ) * 30, math.sin( CurTime() ) + 25 )

			-- --Usage:
			-- --draw.Circle( x, y, radius, segments )
		-- cam.End3D2D()
		
		-- render.PopFlashlightMode() 
		-- render.OverrideDepthEnable( false, false )
		-- render.SetLightingMode( 0 )
	-- end )
-- end

hook.Add( "PostDrawTranslucentRenderables", "GASL:Render", function()

	for k, v in pairs( ents.FindByClass( "ent_tractor_beam" ) ) do
		v:Drawing()
	end
	for k, v in pairs( ents.FindByClass( "ent_portal_floor_turret" ) ) do
		v:Drawing()
	end
	for k, v in pairs( ents.FindByClass( "ent_portal_laser" ) ) do
		v:Drawing()
	end
	
end )

hook.Add( "PostDrawHUD", "GASL:HUDPaint", function()
	
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

hook.Add( "Think", "GASL:Think", function()	

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

hook.Add( "PhysgunPickup", "GASL:DisablePhysgunPickup", function( ply, ent )
	if ( ent.GASL_Untouchable ) then return false end
end )

hook.Add( "KeyPress", "GASL:HandlePlayerJump", function( ply, key )

	if CLIENT then return end
	if ( key != IN_JUMP || !ply:IsOnGround() ) then return end
	
	local trace = { start = ply:GetPos(), endpos = ply:GetPos() - Vector( 0, 0, 100 ), filter = ply }
	local ent = util.TraceEntity( trace, ply ).Entity
	local paintType = APERTURESCIENCE:CheckForGel( ply:GetPos(), Vector( 0, 0, -100 ) )
	
	-- Skip if it's not bridge or paint
	if ent:GetModel() != "models/wall_projector_bridge/wall.mdl" && paintType == nil then return end
	if paintType != nil then
		ent:EmitSound( "GASL.GelFootsteps" )
		if ( paintType == PORTAL_GEL_BOUNCE ) then
			ply:SetVelocity( Vector( 0, 0, 400 ) )
			ply:EmitSound( "GASL.GelBounce" )
		end
	elseif ent:GetModel() == "models/wall_projector_bridge/wall.mdl" then
		ent:EmitSound( "GASL.WallProjectorFootsteps" )
	end
	
end )

-- hook.Add( "Move", "ZeroGravity", function( ply, mv )

-- 	if SERVER then return end

-- 	local vel = ply:GetVelocity()
-- 	local g = physenv:GetGravity()

-- 	mv:SetUpSpeed( -g.z * 2 )

-- 	return true;
	
-- end )

-- hook.Remove( "Move", "ZeroGravity")