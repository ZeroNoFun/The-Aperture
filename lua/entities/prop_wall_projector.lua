AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Hard Light Bridge"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos
	local SpawnAng = tr.HitNormal:Angle()
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()

	if SERVER then
		self:SetModel( "models/props/wall_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		self.wallProjectorWalls = { }
	end // SERVER

	if CLIENT  then
		
	end // CLIENT
	
	self.GASL_Walls = { }
end

function ENT:Draw()

	self:DrawModel()

	local BridgeDrawWidth = 35
	local BorderBeamWidth = 10
	
	local MatBridge = Material( "effects/projected_wall" )
	local MatBridgeBorder = Material( "effects/projected_wall_rail" )
	local MatSprite = Material( "sprites/gmdm_pickups/light" )

	local bridge_trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld( Vector( 10000, 0, 0 ) ),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance( bridge_trace.HitPos )
		
	if ( self.GASL_Walls.lastPos != self:GetPos() or self.GASL_Walls.lastAngle != self:GetAngles() ) then
		self.GASL_Walls.lastPos = self:GetPos()
		self.GASL_Walls.lastAngle = self:GetAngles()
		
		local min, max = self:GetRenderBounds() 
		
		self:SetRenderBounds( min, max + Vector( totalDistance, 0, 0 ) )
	end

	render.SetMaterial( MatBridgeBorder )
	render.DrawBeam( self:LocalToWorld( Vector( 0, BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
	render.DrawBeam( self:LocalToWorld( Vector( 0, -BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, -BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )

end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	if SERVER then
		
		local PlateLength = 50.393715
		
		local bridge_trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:LocalToWorld( Vector( 10000, 0, 0 ) ),
			filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
		} )
		
		local totalDistance = self:GetPos():Distance( bridge_trace.HitPos )
		
		-- Handling changes position or angles
		if ( self.GASL_Walls.lastPos != self:GetPos() or self.GASL_Walls.lastAngle != self:GetAngles() ) then
			self.GASL_Walls.lastPos = self:GetPos()
			self.GASL_Walls.lastAngle = self:GetAngles()
			
			for k, v in pairs( self.wallProjectorWalls ) do
				if ( v:IsValid() ) then v:Remove() end
			end
			
			local addingDist = 0
			
			while ( totalDistance > addingDist ) do
				
				local ent = ents.Create( "prop_physics" )
				ent:SetModel( "models/wall_projector_bridge/wall.mdl" )
				ent:SetPos( self:LocalToWorld( Vector( addingDist, 0, -1 ) ) )
				ent:SetAngles( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
				ent:Spawn()
				ent:DrawShadow( false )

				local physEnt = ent:GetPhysicsObject()
				physEnt:SetMaterial("item")
				physEnt:EnableMotion(false)
				
				table.insert(self.wallProjectorWalls, table.Count(self.wallProjectorWalls) + 1, ent)
				addingDist = addingDist + PlateLength
			end
		end
		
		for k, v in pairs( self.wallProjectorWalls ) do
			if ( v:IsValid() ) then
				v:RemoveAllDecals()
			end
		end
	end // SERVER

	if CLIENT then
		
	end // CLIENT
	
	return true
end

if SERVER then
	-- Removing wall props
	function ENT:OnRemove()
		for k, v in pairs( self.wallProjectorWalls ) do
			if (v:IsValid()) then v:Remove() end
		end
	end
end
