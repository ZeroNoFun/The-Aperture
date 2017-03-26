AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "StartEnabled" )

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
		self:SetModel( "models/props/portal_door_combined.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:GetPhysicsObject():EnableMotion( false )
		
		local ent = ents.Create( "prop_physics" )
		if ( !IsValid( ent ) ) then return end
		ent:SetModel( "models/gasl/border_door_closed.mdl" )
		ent:SetPos( self:LocalToWorld( Vector( 0, 0, 0 ) )  )
		ent:SetAngles( self:LocalToWorldAngles( Angle( 90, 0, 0 ) ) )
		ent:SetMoveType( MOVETYPE_NONE )
		ent:Spawn()
		ent:SetNoDraw( true )
		ent:GetPhysicsObject():EnableMotion( false )
		self:SetNWEntity( "GASL:DoorBlock", ent )
		self:DeleteOnRemove( ent )
		ent:SetParent( self )
	
		self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
		APERTURESCIENCE:PlaySequence( self, "closeidle", 1.0 )
		
		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable" } )
	end

	if ( CLIENT ) then
		if ( !self:GetStartEnabled() ) then
			//self:SetModel( "models/props/portal_door_combined.mdl" )
		end
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
	-- Skipping tick if it disabled
	if ( !self:GetEnable() ) then return end

end

function ENT:DrawTranscluent()

	self:Draw()
	
end

function ENT:Think()

	self:NextThink( CurTime() )
	self.BaseClass.Think( self )
	
	if ( CLIENT ) then return true end
	
	return true
	
end

-- no more client size
if ( CLIENT ) then return end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end
	self:SetEnable( bDown )

	if ( bDown ) then
		//self:EmitSound( "GASL.TractorBeamLoop" )
		APERTURESCIENCE:PlaySequence( self, "open", 1.0 )
		self:GetNWEntity( "GASL:DoorBlock" ):SetCollisionGroup( COLLISION_GROUP_WORLD )
	else
		//self:EmitSound( "GASL.TractorBeamEnd" )
		APERTURESCIENCE:PlaySequence( self, "close", 1.0 )
		self:GetNWEntity( "GASL:DoorBlock" ):SetCollisionGroup( COLLISION_GROUP_NONE )
	end
	
end

function ENT:OnRemove()

	
end
