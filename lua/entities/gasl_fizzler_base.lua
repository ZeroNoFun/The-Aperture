AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )
	
end

function ENT:DrawFizzler( material, stretch )
	if ( !self:GetEnable() ) then return end
	
	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !IsValid( secondField ) ) then return end
	
	local Height = 120
	local DivSize = 120
	
	local halfHeight = Height / 2
	local division = 1
	if ( !stretch ) then division = math.ceil( self:GetPos():Distance( secondField:GetPos() ) / DivSize ) end

	// if not stretch make field tiled
	for i = 1, division do
		local pos1 = self:LocalToWorld( Vector( 0, 0, halfHeight )  )
		local pos2 = secondField:LocalToWorld( Vector( 0, 0, halfHeight ) )
		local pos3 = secondField:LocalToWorld( Vector( 0, 0, -halfHeight ) )
		local pos4 = self:LocalToWorld( Vector( 0, 0, -halfHeight ) )

		local p1 = pos1 + ( ( pos2 - pos1 ) / division ) * ( i - 1 )
		local p2 = pos1 + ( ( pos2 - pos1 ) / division ) * i
		local p3 = pos4 + ( ( pos3 - pos4 ) / division ) * i
		local p4 = pos4 + ( ( pos3 - pos4 ) / division ) * ( i - 1 )
		
		render.SetMaterial( material )
		render.DrawQuad( p1, p2, p3, p4, Color( 255, 255, 255 ) )
	end
end

if ( CLIENT ) then

	function ENT:Think()
		local secondField = self:GetNWEntity( "GASL_ConnectedField" )
		if ( !IsValid( secondField ) ) then return end
		
		local min, max = self:GetRenderBounds() 
		local dis = secondField:GetPos():Distance( self:GetPos() )

		self:SetRenderBounds( min, max + Vector( 0, dis, 0 ) )
	end
	
	return
end

function ENT:ConnectFields( field )
	local ent = ents.Create( "gasl_fizzler_trigger" )
	if( !IsValid( ent ) ) then return end

	local dis = field:GetPos():Distance( self:GetPos() )
	local min, max = self:GetCollisionBounds()
	
	ent:SetPos( self:LocalToWorld( Vector( 0, dis / 2, 0 ) ) )
	ent:SetParent( self )
	ent:Spawn()
	ent:Activate()
	ent:SetBounds( min - Vector( 0, dis / 2, 0 ), max + Vector( 0, dis / 2, 0 ) )
	ent.Parent = self
	ent:SetAngles( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
	
	// connecting field
	self:SetNWEntity( "GASL_ConnectedField", field )
	field:SetNWEntity( "GASL_ConnectedField", self )
	
	self:SetNWEntity( "GASL_FIELD_Trigger", ent )
	//Entity(1):SetPos( ent:GetPos() )
end

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )
	
	APERTURESCIENCE:PlaySequence( self, "closeidle", 1.0 )
	
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )
end

function ENT:Think()
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then
		self:ToggleEnable( tobool( value ) )
	end
end

function ENT:SetEnableE( activate, noloop )
	
	if ( noloop == nil ) then noloop = true end
	self:SetEnable( activate )
	
	if ( activate ) then
		APERTURESCIENCE:PlaySequence( self, "open", 1.0 )
		self:EmitSound( "vfx/fizzler_start_01.wav" )
		EmitSound( "vfx/fizzler_start_01.wav", self:LocalToWorld( Vector( 0, 20, 0 ) ), self:EntIndex(), CHAN_AUTO, 1, 50, 0, 100 )
		
		if ( IsValid( self:GetNWEntity( "GASL_ConnectedField" ) ) && noloop ) then
			self:GetNWEntity( "GASL_ConnectedField" ):SetEnableE( true, false )
		end
	else
		APERTURESCIENCE:PlaySequence( self, "close", 1.0 )
		self:EmitSound( "vfx/fizzler_shutdown_01.wav" )
		EmitSound( "vfx/fizzler_shutdown_01.wav", self:LocalToWorld( Vector( 0, 20, 0 ) ), self:EntIndex(), CHAN_AUTO, 1, 50, 0, 100 )

		if ( IsValid( self:GetNWEntity( "GASL_ConnectedField" ) ) && noloop ) then
			self:GetNWEntity( "GASL_ConnectedField" ):SetEnableE( false, false )
		end
	end
end

function ENT:ToggleEnable( bDown, reverse, noloop )
	if ( reverse == nil ) then reverse = self:GetStartEnabled() end
	if ( reverse ) then bDown = !bDown end
	
	self:SetEnableE( bDown, noloop )
end

-- Removing field effect 
function ENT:OnRemove()

end
