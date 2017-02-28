AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.PrintName		= "Portal Frame"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !APERTURESCIENCE.ALLOWING.portal_frame && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end
	
	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "StartEnabled" )
	self:NetworkVar( "Int", 1, "PortalType" )

end

if ( CLIENT ) then

	function ENT:Think() 
		
	end

end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetModel( "models/props/portal_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_BridgeUpdate = { lastPos = Vector(), lastAngle = Angle() }
		self.GASL_PortalFrame_Portal = NULL
		self.isClone = true
		if ( TYPE_BLUE ) then self:SetPortalType( TYPE_BLUE ) end

		self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
		
		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable" } )
		
	end
	
	if ( CLIENT ) then
	end
	
	return true
	
end

function ENT:ClearPortal()

	if ( !IsValid( self.GASL_PortalFrame_Portal ) ) then return end
	self.GASL_PortalFrame_Portal:SuccessEffect()
	//self.GASL_PortalFrame_Portal:GetNWBool( "Potal:Other" ):SetNetworkedBool( "orange", false, true )
	//self.GASL_PortalFrame_Portal:GetNWBool( "Potal:Other" ):SuccessEffect()
	self.GASL_PortalFrame_Portal:Remove()

end

function ENT:OpenPortal( type )
	
	if ( !TYPE_BLUE ) then return end
	
	local OrangePortalEnt = self.Owner:GetNWEntity( "Portal:Orange", nil )
	local BluePortalEnt = self.Owner:GetNWEntity( "Portal:Blue", nil )
   
	local EntToUse = type == TYPE_BLUE and BluePortalEnt or OrangePortalEnt
	local OtherEnt = type == TYPE_BLUE and OrangePortalEnt or BluePortalEnt
	
	if !IsValid( EntToUse ) then
   
		local Portal = ents.Create( "prop_portal" )
		Portal:SetPos( self:LocalToWorld( Vector() ) )
		Portal:SetAngles( self:LocalToWorldAngles( Angle() ) )
		Portal:Spawn()
		Portal:Activate()
		Portal:SetMoveType( MOVETYPE_NONE )
		Portal:SetActivatedState( true )
		Portal:SetType( type )
		Portal:SuccessEffect()
		self.GASL_PortalFrame_Portal = Portal
	   
		if type == TYPE_BLUE then
   
			//self.Owner:SetNWEntity( "Portal:Blue", Portal )
			Portal:SetNetworkedBool( "blue", true, true )
		   
		else
	   
			//self.Owner:SetNWEntity( "Portal:Orange", Portal )
			Portal:SetNetworkedBool( "blue", false, true )
		   
		end
	   
		EntToUse = Portal
	   
		if IsValid( OtherEnt ) then
	   
			EntToUse:LinkPortals( OtherEnt )
			
		end
	   
	else

		EntToUse:MoveToNewPos( validpos, validnormang )
		EntToUse:SuccessEffect()
		   
	end
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	self.BaseClass.Think( self )
	
	if ( CLIENT ) then return end
	
	-- Skip this tick if exursion funnel is disabled and removing effect if possible
	if ( !self:GetEnable() ) then
		
		if ( self.GASL_BridgeUpdate.lastPos || self.GASL_BridgeUpdate.lastAngle ) then
				self.GASL_BridgeUpdate.lastPos = nil
				self.GASL_BridgeUpdate.lastAngle = nil
		end

		return
	end

	-- Handling changes position or angles
	if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() or self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_BridgeUpdate.lastPos = self:GetPos()
		self.GASL_BridgeUpdate.lastAngle = self:GetAngles()
		
		if ( IsValid( self.GASL_PortalFrame_Portal ) ) then
			self.GASL_PortalFrame_Portal:SetPos( self:LocalToWorld( Vector() ) )
			self.GASL_PortalFrame_Portal:SetAngles( self:LocalToWorldAngles( Angle() ) )
		end

		
	end
	
	return true
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	self:SetEnable( bDown )
	
	if ( self:GetEnable() ) then
		self:OpenPortal( self:GetPortalType() )
		self:SetSkin( self:GetPortalType() )
		//self:EmitSound( "GASL.WallEmiterEnabledNoises" )
	else
		self:ClearPortal()
		//self:StopSound( "GASL.WallEmiterEnabledNoises" )
		self:SetSkin( 0 )
	end
	
end

-- Removing wall props
function ENT:OnRemove()
	
	self:ClearPortal()
	//self:StopSound( "GASL.WallEmiterEnabledNoises" )
	
end
