AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

local GASL_PaintRadius = 47.1

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_NONE )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )

		self:SetMaterial( "models/shiny" )
		
		self.GASL_GelType = 0
		self.GASL_GelSplatRadius = 0
	end

	if ( CLIENT ) then
		
	end
	
end

function ENT:Convert2Grid( pos, angle, rad )

	local WTL = WorldToLocal( pos, Angle( ), Vector( ), angle ) 
	WTL = Vector( math.Round( WTL.x / rad ) * rad, math.Round( WTL.y / rad ) * rad, pos.z )
	pos = LocalToWorld( WTL, Angle( ), Vector( ), angle )
	
	return pos
	
end

function ENT:PaintGel( pos, normal, rad )

	local maxseg = math.floor( rad / APERTURESCIENCE.GEL_BOX_SIZE )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetNormal( normal )
	effectdata:SetColor( self.GASL_GelType )
	
	self:EmitSound( "GASL.GelSplat" )
	util.Effect( "gel_splat_effect", effectdata )
	self:SetColor( Color( 0, 0, 0, 0 ) )
	self:GetPhysicsObject():EnableMotion( false )
	
	for x = -maxseg, maxseg do
	for y = -maxseg, maxseg do
	
		local offset = Vector( x * APERTURESCIENCE.GEL_BOX_SIZE, y * APERTURESCIENCE.GEL_BOX_SIZE, 0 )
		offset:Rotate( normal:Angle() + Angle( 90, 0, 0 ) )

		local location = pos + offset
		local gelTrace = APERTURESCIENCE:CheckForGel( location + normal * 5, -normal * 10 ) 
		
		if ( location:Distance( pos ) > rad ) then continue end
		
		if ( !gelTrace.Entity:IsValid() ) then
		
			local trace = util.QuickTrace( location + normal * 5, -normal * 10, ents.FindByClass( "ent_gel_puddle" ) )
			
			local gridPos = self:Convert2Grid( trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), APERTURESCIENCE.GEL_BOX_SIZE )
			local ent = ents.Create( "ent_gel_paint" )
			ent:SetPos( gridPos )
			ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			ent:SetMoveType( MOVETYPE_NONE )
			ent:Spawn()
			
			ent:SetGelType( self.GASL_GelType )
			ent:UpdateGel()

		else
			gelTrace.Entity:SetGelType( self.GASL_GelType )
			gelTrace.Entity:UpdateGel()
		end
		
	end
	end

end

function ENT:DrawTranslucent()
	
	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	if ( CLIENT ) then return true end

	local trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetVelocity() / 10,
		ignoreworld = true,
		filter = function( ent )
			if ( ent:GetClass() == "prop_portal" ) then return true end
			if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" ) then return false end
		end
	} )
	
	local traceEnt = trace.Entity
	
	if ( !traceEnt:IsValid() || traceEnt:IsValid() && traceEnt:GetClass() != "prop_portal" ) then
		trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetVelocity() / 10,
			filter = function( ent )
				if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" ) then return false end
			end
		} )
	end
	
	traceEnt = trace.Entity
	
	if ( trace.Hit && ( !traceEnt:IsValid() || traceEnt:IsValid() && traceEnt:GetClass() != "prop_portal" ) ) then
	
		self:PaintGel( trace.HitPos, trace.HitNormal, self.GASL_GelSplatRadius )
		timer.Simple( 1, function() if ( self:IsValid() ) then self:Remove() end end )
		self:NextThink( CurTime() + 2 )
	end
	
	return true
	
end
