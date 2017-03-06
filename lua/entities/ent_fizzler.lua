AddCSLuaFile( )

ENT.Base 			= "ent_fizzler_base"

ENT.Editable		= true
ENT.PrintName		= "Fizzler"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	if ( !APERTURESCIENCE.ALLOWING.fizzler && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end

	local mdl = "models/props/fizzler_dynamic.mdl"
	
	local firstFizzler = ents.Create( ClassName )
	firstFizzler:SetPos( trace.HitPos )
	firstFizzler:SetModel( mdl )
	firstFizzler:SetAngles( trace.HitNormal:Angle() )
	firstFizzler:Spawn()
	firstFizzler:SetAngles( firstFizzler:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	local traceSecond = util.QuickTrace( firstFizzler:GetPos(), -firstFizzler:GetRight() * 1000, firstFizzler )
	
	local secondFizzler = ents.Create( ClassName )
	secondFizzler:SetPos( traceSecond.HitPos )
	secondFizzler:SetModel( mdl )
	secondFizzler:SetAngles( firstFizzler:GetAngles() )
	secondFizzler:Spawn()
	secondFizzler:SetAngles( secondFizzler:LocalToWorldAngles( Angle( 0, 180, 0 ) ) )
	
	firstFizzler:SetNWEntity( "GASL_ConnectedField", secondFizzler )
	secondFizzler:SetNWEntity( "GASL_ConnectedField", firstFizzler )
	
	constraint.Weld( secondFizzler, firstFizzler, 0, 0, 0, true, true )
	
	undo.Create( "LaserField" )
		undo.AddEntity( firstFizzler )
		undo.AddEntity( secondFizzler )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	if ( !self:GetEnable() ) then return end

	self:DrawFizzler( Material( "effects/fizzler" ), false )
	
	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !IsValid( secondField ) ) then return end

	-- close objects field effect
	
	local Height = 110
	
	local closesEntities = { }
	local tracer = util.TraceHull( {
		start = self:LocalToWorld( Vector() ),
		endpos = secondField:LocalToWorld( Vector() ),
		filter = function( ent ) 
			if ( !APERTURESCIENCE:GASLStuff( ent ) && ent != self && ent != secondField && !ent:IsPlayer() && !ent:IsNPC() ) then
				table.insert( closesEntities, table.Count( closesEntities ) + 1, ent )
			end

			return false
		end,
		ignoreworld = true,
		mins = -Vector( 1, 1, 1 ) * Height,
		maxs = Vector( 1, 1, 1 ) * Height,
		mask = MASK_SHOT_HULL
	} )
	
	for _, ent in pairs( closesEntities ) do
		
		local localEntPos = self:WorldToLocal( ent:GetPos() )
		local distToField = math.abs( localEntPos.x )
		localEntPos = Vector( 0, localEntPos.y, localEntPos.z )
		
		if ( localEntPos.y < 0 ) then return end
		
		local rad = math.min( Height, ent:GetModelRadius() * 3 )
		local p1 = self:LocalToWorld( localEntPos + Vector( 0, -1, -1 ) * rad )
		local p2 = self:LocalToWorld( localEntPos + Vector( 0, 1, -1 ) * rad )
		local p3 = self:LocalToWorld( localEntPos + Vector( 0, 1, 1 ) * rad )
		local p4 = self:LocalToWorld( localEntPos + Vector( 0, -1, 1 ) * rad )
		
		local alpha = math.max( 0, math.min( 1, ( 50 + 50 - distToField ) / 50 ) ) * 255
		render.SetMaterial( Material( "effects/fizzler_approach" ) )
		render.DrawQuad( p1, p2, p3, p4, Color( 255, 255, 255, alpha ) )
	
	end

end

if ( CLIENT ) then

	function ENT:Think()
	
		self.BaseClass.Think( self )
		
	end
	
	function ENT:Initialize()

		self.BaseClass.Initialize( self )
		//self.BaseClass.BaseClass.Initialize( self )
		
	end

	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	self.BaseClass.BaseClass.Initialize( self )
	
	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
	
end

function ENT:HandleEntityInField( ent )

	if ( ent:IsPlayer() ) then
	
		local weapon = ent:GetActiveWeapon( )
		
		if ( IsValid( weapon ) && weapon:GetClass() == "weapon_portalgun" ) then
			weapon:CleanPortals()
			weapon:IdleStuff()
		end
		
	elseif ( ent:GetClass() == "projectile_portal_ball" || ent:GetClass() == "prop_portal" ) then
	
		ent:Remove()
	
	elseif ( ent:GetPhysicsObject():IsValid() ) then
	
		APERTURESCIENCE:DissolveEnt( ent )
	
	end

end

-- no more client size
if ( CLIENT ) then return end

function ENT:Think()

	self.BaseClass.Think( self )

	local DivCount = 10
	local Height = 110
	
	self.GASL_AllreadyHandled = { }
	
	local SCANRAD = Vector( 1, 1, 1 ) * 100
	for i = 0, DivCount do
		local pos = self:LocalToWorld( Vector( 0, 0, -Height / 2 + i * ( Height / DivCount ) ) )
		local pos2 = self:GetNWEntity( "GASL_ConnectedField" ):LocalToWorld( Vector( 0, 0, -Height / 2 + i * ( Height / DivCount ) ) )
		
		local tracer = util.TraceHull( {
			start = pos,
			endpos = pos2,
			filter = function( ent ) 
				if ( ent:GetClass() == "projectile_portal_ball" ) then return true end
			end,
			ignoreworld = true,
			mins = -SCANRAD,
			maxs = SCANRAD,
			mask = MASK_SHOT_HULL
		} )
		
		if ( IsValid( tracer.Entity ) ) then
			self.GASL_AllreadyHandled[ tracer.Entity:EntIndex() ] = true
			self:HandleEntityInField( tracer.Entity )
		end
		
	end
	
	return true
	
end
