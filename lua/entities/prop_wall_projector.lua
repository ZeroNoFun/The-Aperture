AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Hard Light Bridge"
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
		self:SetModel( "models/props/wall_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_EntInfo = { model = "models/wall_projector_bridge/wall.mdl", length = 50.393715, color = Color( 255, 255, 255 ) }
	end

	if ( CLIENT ) then

		
	end
	
end


function ENT:UpdateLabel()

	self:SetOverlayText( string.format( "Speed: %i\nResistance: %.2f", self:GetSpeed(), self:GetAirResistance() ) )

end

function ENT:Draw()

	self:DrawModel()

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
		
		self:SetRenderBounds( min, max, Vector( totalDistance, 0, 0 ) )
	end

	render.SetMaterial( MatBridgeBorder )
	render.DrawBeam( self:LocalToWorld( Vector( 0, BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
	render.DrawBeam( self:LocalToWorld( Vector( 0, -BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, -BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )

end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )

	if SERVER then
	
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
		
	end

	if CLIENT then
		
	end
	
	return true
end

if ( SERVER ) then
	
	numpad.Register( "aperture_science_catapult_enable", function( pl, ent, keydown, idx )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then end
		return true

	end )

	numpad.Register( "aperture_science_catapult_disable", function( pl, ent, keydown )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then end
		return true

	end )

	-- Removing wall props
	function ENT:OnRemove()
		
		self:RemoveBridges()
		
	end
end
