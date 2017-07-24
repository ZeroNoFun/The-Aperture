--[[

	APERTURE API MAIN
	
]]
AddCSLuaFile( )

LIB_APERTURE = {}

-- Loading sounds
local paint_types = file.Find("sounds/*.lua", "LUA")
for _,plugin in ipairs(paint_types) do
	include("sounds/" .. plugin)
end

-- Loading entities data
local entities_data = file.Find("aperture/entities_data/*.lua", "LUA")
for _,plugin in ipairs(entities_data) do
	include("aperture/entities_data/"..plugin)
end

-- Loading math lib
include("aperture/math.lua")

-- Loading portal integration lib
include("aperture/portal_integration.lua")

-- Loading achievement lib
include("aperture/achievement.lua")

-- Loading paint lib
include("aperture/paint.lua")

-- Loading floor buttons lib
include("aperture/buttons.lua")

-- Main 
-- LIB_APERTURE.DRAW_HALOS = false
-- LIB_APERTURE.GRID_SIZE 	= 64

-- Funnel
LIB_APERTURE.FUNNEL_COLOR 			= Color(0, 150, 255)
LIB_APERTURE.FUNNEL_REVERSE_COLOR 	= Color(255, 150, 0)
LIB_APERTURE.FUNNEL_MOVE_SPEED 		= 173

-- Fizzler
LIB_APERTURE.DISSOLVE_SPEED 	= 150
LIB_APERTURE.DISSOLVE_ENTITIES 	= { }

-- Diversity Vent
LIB_APERTURE.DIVVENT_ENTITIES = { }

LIB_APERTURE.FALL_BOOTS_LEG_SIZE = 10
-- LIB_APERTURE.HUD_ACHIEVEMENTS = { }

-- Allowing
-- LIB_APERTURE.ALLOWED = { }

--
-- Console commands
-- LIB_APERTURE.Convars = {}
-- LIB_APERTURE.Convars[ "aperture_science_allow_arm_panel" ] = CreateConVar( "aperture_science_allow_arm_panel", "1", FCVAR_NONE, "ALLOWED Arm Panel" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_button" ] = CreateConVar( "aperture_science_allow_button", "1", FCVAR_NONE, "ALLOWED Button" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_catapult" ] = CreateConVar( "aperture_science_allow_catapult", "1", FCVAR_NONE, "ALLOWED Catapult" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_fizzler" ] = CreateConVar( "aperture_science_allow_fizzler", "1", FCVAR_NONE, "ALLOWED Fizzler" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_item_dropper" ] = CreateConVar( "aperture_science_allow_item_dropper", "1", FCVAR_NONE, "ALLOWED Item Dropper" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_laser_catcher" ] = CreateConVar( "aperture_science_allow_laser_catcher", "1", FCVAR_NONE, "ALLOWED Laser Catcher" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_laser" ] = CreateConVar( "aperture_science_allow_laser", "1", FCVAR_NONE, "ALLOWED Laser Emiter" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_laser_field" ] = CreateConVar( "aperture_science_allow_laser_field", "1", FCVAR_NONE, "ALLOWED Laser Field" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_linker" ] = CreateConVar( "aperture_science_allow_linker", "1", FCVAR_NONE, "ALLOWED Linker" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_paint" ] = CreateConVar( "aperture_science_allow_paint", "1", FCVAR_NONE, "ALLOWED Gel" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_tractor_beam" ] = CreateConVar( "aperture_science_allow_tractor_beam", "1", FCVAR_NONE, "ALLOWED Excursion Funnel" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_wall_projector" ] = CreateConVar( "aperture_science_allow_wall_projector", "1", FCVAR_NONE, "ALLOWED Hard Light Bridge" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_turret" ] = CreateConVar( "aperture_science_allow_turret", "1", FCVAR_NONE, "ALLOWED Arm Turrets" )
-- LIB_APERTURE.Convars[ "aperture_science_allow_floor_button" ] = CreateConVar( "aperture_science_allow_floor_button", "1", FCVAR_NONE, "ALLOWED Floor Button" )

-- function LIB_APERTURE:UpdateParameters()
	-- -- LIB_APERTURE.ALLOWED.arm_panel = tobool( self.Convars[ "aperture_science_allow_arm_panel" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.button = tobool( self.Convars[ "aperture_science_allow_button" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.catapult = tobool( self.Convars[ "aperture_science_allow_catapult" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.fizzler = tobool( self.Convars[ "aperture_science_allow_fizzler" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.item_dropper = tobool( self.Convars[ "aperture_science_allow_item_dropper" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.laser_catcher = tobool( self.Convars[ "aperture_science_allow_laser_catcher" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.laser = tobool( self.Convars[ "aperture_science_allow_laser" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.laser_field = tobool( self.Convars[ "aperture_science_allow_laser_field" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.linker = tobool( self.Convars[ "aperture_science_allow_linker" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.paint = tobool( self.Convars[ "aperture_science_allow_paint" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.tractor_beam = tobool( self.Convars[ "aperture_science_allow_tractor_beam" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.wall_projector = tobool( self.Convars[ "aperture_science_allow_wall_projector" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.turret = tobool( self.Convars[ "aperture_science_allow_turret" ]:GetInt() )
	-- -- LIB_APERTURE.ALLOWED.floor_button = tobool( self.Convars[ "aperture_science_allow_floor_button" ]:GetInt() )
-- end
-- hook.Add("Think", LIB_APERTURE, LIB_APERTURE.UpdateParameters)

function LIB_APERTURE:GetAIDisabled()
	local conVar = GetConVar("ai_disabled")
	if not conVar then return false end
	return tobool(conVar:GetInt())
end

function LIB_APERTURE:GetAIIgnorePlayers()
	local conVar = GetConVar("ai_ignoreplayers")
	if not conVar then return false end
	return tobool(conVar:GetInt())
end

function LIB_APERTURE:JumperBootsResizeLegs(ply, size)
	local ent = ply:GetNWEntity("TA:ItemJumperBootsEntity")
	local prCalf = ply:LookupBone("ValveBiped.Bip01_R_Calf")
	local plCalf = ply:LookupBone("ValveBiped.Bip01_L_Calf")
	local prFoot = ply:LookupBone("ValveBiped.Bip01_R_Foot")
	local plFoot = ply:LookupBone("ValveBiped.Bip01_L_Foot")
	local prToe0 = ply:LookupBone("ValveBiped.Bip01_R_Toe0")
	local plToe0 = ply:LookupBone("ValveBiped.Bip01_L_Toe0")
	ply:ManipulateBoneScale(prCalf, Vector(1, 1, 1) / size)
	ply:ManipulateBoneScale(plCalf, Vector(1, 1, 1) / size)
	ply:ManipulateBoneScale(prFoot, Vector(1, 1, 1) / size)
	ply:ManipulateBoneScale(plFoot, Vector(1, 1, 1) / size)
	ply:ManipulateBoneScale(prToe0, Vector(1, 1, 1) / size)
	ply:ManipulateBoneScale(plToe0, Vector(1, 1, 1) / size)

	if not IsValid(ent) then return end
	local rCalf = ent:LookupBone("ValveBiped.Bip01_R_Calf")
	local lCalf = ent:LookupBone("ValveBiped.Bip01_L_Calf")
	local rFoot = ent:LookupBone("ValveBiped.Bip01_R_Foot")
	local lFoot = ent:LookupBone("ValveBiped.Bip01_L_Foot")
	local rToe0 = ent:LookupBone("ValveBiped.Bip01_R_Toe0")
	local lToe0 = ent:LookupBone("ValveBiped.Bip01_L_Toe0")
	ent:ManipulateBoneScale(rCalf, Vector(1, 1, 1) * size)
	ent:ManipulateBoneScale(lCalf, Vector(1, 1, 1) * size)
	ent:ManipulateBoneScale(rFoot, Vector(1, 1, 1) * size)
	ent:ManipulateBoneScale(lFoot, Vector(1, 1, 1) * size)
	ent:ManipulateBoneScale(rToe0, Vector(1, 1, 1) * size)
	ent:ManipulateBoneScale(lToe0, Vector(1, 1, 1) * size)
end

function LIB_APERTURE:DissolveEnt(ent)
	if ent.IsDissolving then return end
	local phys = ent:GetPhysicsObject()
	ent:SetSolid(SOLID_NONE)
	ent.IsDissolving = true
	
	if phys:GetVelocity():Length() < 10 then
		phys:SetVelocity(Vector(0, 0, 10) + VectorRand() * 2)
		phys:AddAngleVelocity(VectorRand() * 100)
	else
		phys:SetVelocity(phys:GetVelocity() / 4)
	end
	phys:EnableGravity(false)
	ent:EmitSound("TA:FizzlerDissolve")
	-- Calling fizzle event
	if ent.OnFizzle then ent:OnFizzle() end
	table.insert(LIB_APERTURE.DISSOLVE_ENTITIES, ent)
end

function LIB_APERTURE:IsValidEntity(ent)
	if not IsValid(ent) then return false end
	return true
end

function LIB_APERTURE:IsValidPhysicsEntity(ent)
	if not IsValid(ent) then return false end
	if not IsValid(ent:GetPhysicsObject()) then return false end
	return true
end

hook.Add( "Initialize", "TA:Initialize", function()
	if SERVER then
		util.AddNetworkString("TA:NW_PaintCamera")
		util.AddNetworkString("TA:DivventFilterNetwork")
		//util.AddNetworkString( "GASL_NW_Player_Achievements" ) 
		//util.AddNetworkString( "GASL_LinkConnection" ) 
		//util.AddNetworkString( "GASL_Turrets_Activation" ) 
	end
	
	if CLIENT then
	end
end)

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

-- hook.Add( "PostDrawHUD", "GASL:HUDPaint", function()
	
	-- -- cam.Start3D()
	
		-- -- render.SetMaterial( Material( "cable/xbeam" ) )
		-- -- render.StartBeam( table.Count( LIB_APERTURE.CONNECTED_PAINTS ) )
		-- -- for k, v in pairs( LIB_APERTURE.CONNECTED_PAINTS ) do
			
			-- -- render.AddBeam( v:GetPos(), v:GetGelRadius(), 1, Color( 255, 255, 255, 255 ) ) 
			
		-- -- end
		-- -- render.EndBeam()
		
	-- -- cam.End3D()	
	
	-- -- LIB_APERTURE.CONNECTED_PAINTS = { }

	
	-- local AchivmentHeight = 100
	-- local AchivmentWidth = 300
	-- local ShadowX = 10
	-- local ShadowY = 10
	-- local ImgSize = 80
	-- local ImgXOffset = 10
	-- local TextXOffset = 10
	-- local TextYOffset = 10
	
	-- if ( !LocalPlayer().GASL_Player_HUD_Achievements ) then return end
	
	-- local itter = 0
	
	-- for k, v in pairs( LocalPlayer().GASL_Player_HUD_Achievements ) do
		
		-- if ( v.ply != LocalPlayer() ) then continue end
		
		-- if ( !v.init ) then
			-- LocalPlayer().GASL_Player_HUD_Achievements[ k ].init = true
			-- LocalPlayer():EmitSound( "garrysmod/save_load1.wav" )
		-- end
		
		-- local achievementInfo = LIB_APERTURE.ACHIEVEMENTS[ v.achievementInx ]
		-- local timeToHide = ( v.timeToHide - CurTime() ) * 100
		
		-- if ( v.posY < AchivmentHeight and timeToHide > AchivmentHeight ) then
			-- LocalPlayer().GASL_Player_HUD_Achievements[ k ].posY = math.min( AchivmentHeight, 1000 - timeToHide )
		-- else
			-- LocalPlayer().GASL_Player_HUD_Achievements[ k ].posY = math.min( AchivmentHeight, timeToHide )
		-- end

		-- local panelX = ScrW() - AchivmentWidth
		-- local panelY = v.posY + itter * AchivmentHeight - AchivmentHeight

		-- -- shadow
		-- surface.SetDrawColor( 0, 0, 0, 100 )
		-- surface.DrawRect( panelX - ShadowX, panelY + ShadowY, AchivmentWidth, AchivmentHeight ) 

		-- -- achievement background
		-- surface.SetDrawColor( 200, 200, 200, 255 )
		-- surface.DrawRect( panelX, panelY, AchivmentWidth, AchivmentHeight ) 
		
		-- surface.SetMaterial( Material( achievementInfo.img ) ) -- If you use Material, cache it!
		-- surface.DrawTexturedRect( panelX + ImgXOffset, panelY + AchivmentHeight / 2 - ImgSize / 2, ImgSize, ImgSize )
		
		-- surface.SetFont( "GASL_SecFont" )
		-- surface.SetTextColor( 255, 255, 255, 255 )
		-- local _, txtHeight = surface.GetTextSize( "" )
		-- surface.SetTextPos( panelX + ImgXOffset + ImgSize + TextXOffset, panelY + TextYOffset )
		-- surface.DrawText( achievementInfo.text )
		-- if ( timeToHide <= 0 ) then LocalPlayer().GASL_Player_HUD_Achievements[ k ] = nil end
		
		-- itter = itter + 1
		
	-- end
		
-- end )

local function HandleEntitiesInDivvent(ent, flow, inx, info)
	if not IsValid(ent) 
		or not IsValid(info.vent) 
		or ent:GetMoveType() == MOVETYPE_NOCLIP then
		LIB_APERTURE.DIVVENT_ENTITIES[ent] = nil
		return
	end

	local flowpoint = flow[inx]
	
	if flowpoint != Vector() then
		local physObj = ent:GetPhysicsObject()
		local centerPos = ent:LocalToWorld(physObj:GetMassCenter())
		-- remove entity from table if it too far from the point
		if centerPos:Distance(flowpoint) > 300 then
			LIB_APERTURE.DIVVENT_ENTITIES[ent] = nil
			return
		end
		
		local mass = physObj:GetMass()
		local dirN = (flowpoint - centerPos):GetNormalized()
		if ent:IsPlayer() or ent:IsNPC() then
			local velvec = dirN * 400 - ent:GetVelocity() / 2
			ent:SetVelocity(velvec)
		else
			local velvec = dirN * 100 - physObj:GetVelocity() / 10
			physObj:AddVelocity(velvec)
		end
		
		if flowpoint:Distance(centerPos) < 30 then
			info.index = inx + 1
			if (inx + 1) > #flow then
				LIB_APERTURE.DIVVENT_ENTITIES[ent] = nil
			end
		end
	end
end

local function HandleDissolvedEntities(ent, index)
	-- skip if entity doesn't exist
	if not IsValid(ent) then
		LIB_APERTURE.DISSOLVE_ENTITIES[index] = nil
		return
	end
	
	if not ent.TA_Dissovle then ent.TA_Dissovle = 0 end
	ent.TA_Dissovle = ent.TA_Dissovle + 1
	
	-- Turning entity into black and then fadeout alpha
	local colorBlack = (math.max(0, LIB_APERTURE.DISSOLVE_SPEED - ent.TA_Dissovle * 1.75) / LIB_APERTURE.DISSOLVE_SPEED) * 255
	local alpha = math.max(0, ent.TA_Dissovle - LIB_APERTURE.DISSOLVE_SPEED / 1.1) / (LIB_APERTURE.DISSOLVE_SPEED - LIB_APERTURE.DISSOLVE_SPEED / 1.1)
	alpha = 255 - alpha * 255
	ent:SetColor(Color(colorBlack, colorBlack, colorBlack, alpha))
	if alpha < 255 then ent:SetRenderMode(RENDERMODE_TRANSALPHA) end

	local effectdata = EffectData()
	effectdata:SetEntity(ent)
	util.Effect("fizzler_dissolve", effectdata)
	
	if ent.TA_Dissovle >= LIB_APERTURE.DISSOLVE_SPEED then
		LIB_APERTURE.DISSOLVE_ENTITIES[index] = nil
		ent:Remove()
	end
end

hook.Add("Think", "TA:Think", function()	
	-- Handling dissolved entities
	for k,v in pairs(LIB_APERTURE.DISSOLVE_ENTITIES) do
		HandleDissolvedEntities(v, k)
	end
	
	for k,v in pairs(LIB_APERTURE.DIVVENT_ENTITIES) do
		HandleEntitiesInDivvent(k, v.flow, v.index, v)
	end
	
	-- if CLIENT then
		-- for k,v in pairs(player.GetAll()) do
			-- if v:Alive() then
				-- local ent = v:GetNWEntity("TA:ItemJumperBootsEntity")
				-- if IsValid(ent) then DrawBoots(v, ent) end
			-- end
		-- end
	-- end

	-- Handling entities in diversity vent
	-- for k, v in pairs( LIB_APERTURE.DIVVENT_ENTITIES ) do
	
		-- local vDivventEnt = v.GASL_ENTITY_DivventEnt
		
		-- if ( !IsValid( vDivventEnt )
			-- || vDivventEnt:GetModel() != "models/props_backstage/vacum_scanner_b.mdl" 
			-- and ( vDivventEnt:GetPos():Distance( v:GetPos() ) > 1000 ) ) then 
				-- LIB_APERTURE.DIVVENT_ENTITIES[ k ] = nil
				-- continue 
			-- end
		
		-- if ( !vDivventEnt:ModelToFlowPos() ) then continue end
		-- local moveTo = vDivventEnt:LocalToWorld( vDivventEnt:ModelToFlowPos() )
		
		-- if ( v:GetPos():Distance( moveTo ) < 40 ) then
			
			-- if ( !vDivventEnt.GASL_DIVVENT_Connections ) then LIB_APERTURE.DIVVENT_ENTITIES[ k ] = nil continue end
			
			-- v.GASL_ENTITY_DivventEnt = vDivventEnt.GASL_DIVVENT_Connections[ 1 ]
		-- end
		
		-- if ( v:IsPlayer() || v:IsNPC() ) then
			-- local dir = ( moveTo - Vector( 0, 0, v:GetModelRadius() / 2 ) - v:GetPos() ):GetNormalized()
			-- v:SetVelocity( dir * 1000 + VectorRand() * math.max( 0, 200 - v:GetVelocity():Length() ) * 10 - v:GetVelocity() )
		-- elseif ( IsValid( v:GetPhysicsObject() ) ) then
			-- local dir = ( moveTo - v:GetPos() ):GetNormalized()
			-- local vPhys = v:GetPhysicsObject()
			-- vPhys:SetVelocity( vPhys:GetVelocity() / 2 + dir * 400 )
		-- end
	-- end
end )


hook.Add("PostDrawTranslucentRenderables", "TA:RenderObjects", function()
	-- Making render fullbright
	for k,v in pairs(ents.FindByClass("ent_tractor_beam")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("ent_portal_floor_turret")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("ent_portal_laser_emitter")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("ent_wall_projector")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("ent_portal_fizzler")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("ent_laser_field")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("npc_portal_turret_floor")) do v:Drawing() end
	for k,v in pairs(ents.FindByClass("npc_portal_rocket_turret")) do v:Drawing() end
end)

hook.Add("PhysgunPickup", "TA:DisablePhysgunPickup", function(ply, ent)
	if ent.TA_Untouchable then return false end
end)

hook.Add("GetFallDamage", "TA:GetFallDamage", function(ply, speed)
	if ply:GetNWBool("TA:ItemJumperBoots") then
		ply:EmitSound("TA:PlayerLand")
		return 0
	end
	return
end)

local function ResetingFallboots(ply)
	if ply:GetNWBool("TA:ItemJumperBoots") then
		ply:SetNWBool("TA:ItemJumperBoots", false)
		LIB_APERTURE:JumperBootsResizeLegs(ply, 1)
		local boots = ply:GetNWEntity("TA:ItemJumperBootsEntity")
		if IsValid(boots) then
			boots:Remove()
		end
	end
end

hook.Add("DoPlayerDeath", "TA:DoPlayerDeath", function(ply, attacker, dmg)
	ResetingFallboots(ply)
end)

local function Clear()
	LIB_APERTURE.DISSOLVE_ENTITIES = {}
	for k,v in pairs(player.GetAll()) do
		ResetingFallboots(v)
	end
end

hook.Add("PostCleanupMap", "TA:PostCleanupMap", Clear)

-- hook.Add( "KeyPress", "GASL:HandlePlayerJump", function( ply, key )

	-- if CLIENT then return end
	-- if ( key != IN_JUMP || !ply:IsOnGround() ) then return end
	
	-- local trace = { start = ply:GetPos(), endpos = ply:GetPos() - Vector( 0, 0, 100 ), filter = ply }
	-- local ent = util.TraceEntity(trace, ply).Entity
	-- local paintType, paintNormal = LIB_APERTURE:GetPaintInfo(ply:GetPos(), Vector(0, 0, -100))
	-- local paintInfo = LIB_APERTURE.PAINT_TYPES[paintType]

	-- -- Skip if it's not bridge or paint
	-- if IsValid(ent) and ent:GetModel() != "models/wall_projector_bridge/wall.mdl" and not paintType then return end
	-- if paintType then
		-- ent:EmitSound("TA:PaintFootsteps")
		-- if paintInfo.OnJump then paintInfo:OnJump(ply, paintNormal) end
	-- elseif IsValid(ent) and ent:GetModel() == "models/wall_projector_bridge/wall.mdl" then
		-- ent:EmitSound("TA:WallProjectorFootsteps")
	-- end
	
-- end )

-- hook.Add( "Move", "ZeroGravity", function( ply, mv )

-- 	if SERVER then return end

-- 	local vel = ply:GetVelocity()
-- 	local g = physenv:GetGravity()

-- 	mv:SetUpSpeed( -g.z * 2 )

-- 	return true;
	
-- end )

-- hook.Remove( "Move", "ZeroGravity")