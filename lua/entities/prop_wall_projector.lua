AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Hard Light Bridge"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )

end

if ( CLIENT ) then

	function ENT:Think() 

		self:SetRenderBounds( self.GASL_RenderBounds.mins, self.GASL_RenderBounds.maxs )
		
	end

end

function ENT:Draw()

	self:DrawModel()
	
	if ( !self:GetEnable() ) then return end

	local BridgeDrawWidth = 35
	local BorderBeamWidth = 10
	
	local MatBridge = Material( "effects/projected_wall" )
	local MatBridgeBorder = Material( "effects/projected_wall_rail" )
	local MatSprite = Material( "sprites/gmdm_pickups/light" )

	local trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld( Vector( 10000, 0, 0 ) ),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance( trace.HitPos )
	
	if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() or self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_BridgeUpdate.lastPos = self:GetPos()
		self.GASL_BridgeUpdate.lastAngle = self:GetAngles()
		
		local min, max = self:GetRenderBounds() 
		max = max + Vector( totalDistance, 0, 0 )
		self.GASL_RenderBounds = { mins = min, maxs = max }
		
	end

	render.SetMaterial( MatBridgeBorder )
	render.DrawBeam( self:LocalToWorld( Vector( 0, BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
	render.DrawBeam( self:LocalToWorld( Vector( 0, -BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, -BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )

end

function ENT:UpdateLabel()

	self:SetOverlayText( string.format( "Speed: %i\nResistance: %.2f", self:GetSpeed(), self:GetAirResistance() ) )

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetModel( "models/props/wall_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_EntInfo = { model = "models/wall_projector_bridge/wall.mdl", length = 200.393692, color = Color( 255, 255, 255 ) }

		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable" } )
		
	end

	if ( CLIENT ) then

		local min, max = self:GetRenderBounds() 
		self.GASL_RenderBounds = { mins = min, maxs = max }
		
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )

	if ( self:GetEnable() ) then
		
		self:MakeBridges( )
		
		-- Handling changes position or angles
		if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() or self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
			self.GASL_BridgeUpdate.lastPos = self:GetPos()
			self.GASL_BridgeUpdate.lastAngle = self:GetAngles()
		end
		
		for k, v in pairs( self.GASL_EntitiesEffects ) do
		for k2, v2 in pairs( v ) do
			
			if ( v2:IsValid() ) then v2:RemoveAllDecals() end
				
		end
		end
		
	elseif ( self.GASL_BridgeUpdate.lastPos || self.GASL_BridgeUpdate.lastAngle ) then
		self.GASL_BridgeUpdate.lastPos = nil
		self.GASL_BridgeUpdate.lastAngle = nil
		self:RemoveBridges()
	end

	return true
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle( ) ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable( ) )
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable() ) then
		self:EmitSound( "GASL.WallEmiterEnabledNoises" )
	else
		self:StopSound( "GASL.WallEmiterEnabledNoises" )
	end
	
end

numpad.Register( "aperture_science_wall_projector_enable", function( pl, ent, keydown, idx )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_wall_projector_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )

-- Removing wall props
function ENT:OnRemove()
	
	self:RemoveBridges()
	self:StopSound( "GASL.WallEmiterEnabledNoises" )
	
end
