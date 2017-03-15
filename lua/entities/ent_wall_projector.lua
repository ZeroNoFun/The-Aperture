AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true


function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !APERTURESCIENCE.ALLOWING.wall_projector && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end
	
	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "StartEnabled" )

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
		filter = function( ent ) if ( ent == self || ent:GetClass() == "player" || ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance( trace.HitPos )
	
	if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() || self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
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

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	self:PEffectSpawnInit()

	self.GASL_BridgeUpdate = { lastPos = Vector(), lastAngle = Angle() }
	
	if ( SERVER ) then
	
		self:SetModel( "models/props/wall_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_EntInfo = { model = "models/wall_projector_bridge/wall.mdl", length = 200.393692, color = Color( 255, 255, 255 ) }

		self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )

		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable" } )
		
	end

	if ( CLIENT ) then
	
		local min, max = self:GetRenderBounds() 
		self.GASL_RenderBounds = { mins = min, maxs = max }
		
	end

	return true
	
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
			
			-- Removing effects
			self:ClearAllData( )

		end

		return
	end
	
	for k, v in pairs( self.GASL_EntitiesEffects ) do
	for k2, v2 in pairs( v ) do
		if ( v2:IsValid() ) then v2:RemoveAllDecals() end
	end
	end

	self:MakePEffect( )

	-- Handling changes position or angles
	if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() or self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_BridgeUpdate.lastPos = self:GetPos()
		self.GASL_BridgeUpdate.lastAngle = self:GetAngles()
		
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
		self:EmitSound( "GASL.WallEmiterEnabledNoises" )
	else
		self:StopSound( "GASL.WallEmiterEnabledNoises" )
	end
	
end

-- Removing wall props
function ENT:OnRemove()
	
	self:ClearAllData()
	self:StopSound( "GASL.WallEmiterEnabledNoises" )
	
end
