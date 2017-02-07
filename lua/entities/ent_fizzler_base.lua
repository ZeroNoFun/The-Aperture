AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )
	
end

function ENT:Draw()

	self:DrawModel()

	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !secondField:IsValid() ) then return end
	
	local min, max = self:GetRenderBounds() 
	local dis = secondField:GetPos():Distance( self:GetPos() )

	self:SetRenderBounds( min, max, Vector( 0, dis, 0 ) )
	
end

function ENT:ModelToInfo()

	local modelsToInfo = {
		["models/props/fizzler_dynamic.mdl"] = { offset = Vector( 0, 0, 0 ), angle = Angle( 0, 0, 0 ) },
		["models/props_underground/underground_fizzler_wall.mdl"] = { offset = Vector( 0, 0, 70 ), angle = Angle( 0, 180, 0 ) }
	}

	return modelsToInfo[ self:GetModel() ]
	
end

if ( CLIENT ) then

	function ENT:Think()
		
	end
	
	return
	
end

function ENT:Initialize()
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )
	
	self:UpdateLabel()
	
	self.GASL_AllreadyHandled = { }
	
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )
	APERTURESCIENCE:PlaySequence( self, "closeidle", 1.0 )
	
end

function ENT:UpdateLabel()

	//self:SetOverlayText( string.format( "Enabled: %i", tonumber( self:GetEnable() ) ) )
	
end

function ENT:Think()

	self:NextThink( CurTime() )

	if ( !self:GetEnable() ) then return end
	
	local DivCount = 20
	local Height = 110
	
	self.GASL_AllreadyHandled = { }
	
	for i = 0, DivCount do
	
		local pos = self:LocalToWorld( Vector( 0, 0, -Height / 2 + i * ( Height / DivCount ) ) + self:ModelToInfo().offset )
		
		local tracer = util.TraceHull( {
			start = pos,
			endpos = pos + ( self:GetNWEntity( "GASL_ConnectedField" ):GetPos() - self:GetPos() ) * self:GetPos():Distance( self:GetNWEntity( "GASL_ConnectedField" ):GetPos() ),
			filter = function( ent ) 
				if ( ( APERTURESCIENCE:IsValidEntity( ent ) || ent:IsPlayer() || ent:IsNPC() ) && !self.GASL_AllreadyHandled[ ent:EntIndex() ] ) then
					return true
				end
				
				return false
			end,
			ignoreworld = true,
			mins = -Vector( 5, 5, 5 ),
			maxs = Vector( 5, 5, 5 ),
			mask = MASK_SHOT_HULL
		} )
		
		if ( tracer.Entity && tracer.Entity:IsValid() ) then
			self.GASL_AllreadyHandled[ tracer.Entity:EntIndex() ] = true
			self:HandleEntityInField( tracer.Entity )
		end
		
	end
	
	return true
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then
		self:ToggleEnable( tobool( value ) )
		self:GetNWEntity( "GASL_ConnectedField" ):ToggleEnable( tobool( value ) )
	end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable() )
		
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable() ) then
		APERTURESCIENCE:PlaySequence( self, "open", 1.0 )
		EmitSound( "vfx/fizzler_start_01.wav", self:LocalToWorld( Vector( 0, 20, 0 ) ), 1, CHAN_AUTO, 1, 50, 0, 100 )
	else
		APERTURESCIENCE:PlaySequence( self, "close", 1.0 )
		EmitSound( "vfx/fizzler_shutdown_01.wav", self:LocalToWorld( Vector( 0, 20, 0 ) ), 1, CHAN_AUTO, 1, 50, 0, 100 )
	end
	
end

numpad.Register( "aperture_science_fizzler_enable", function( pl, ent, keydown, idx )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_fizzler_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )

-- Removing field effect 
function ENT:OnRemove()

end
