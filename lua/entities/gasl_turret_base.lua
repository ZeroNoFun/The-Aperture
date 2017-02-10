AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "TargetEntity" )
	
end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:GetPhysicsObject():Wake()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	local eyePos = self:LocalToWorld( Vector( 11, 0, 36.7 ) )
	local angle = self:GetManipulateBoneAngles( 1 )
	local dir = self:LocalToWorldAngles( Angle( angle.r, angle.p, 0 ) )
	local trace = util.QuickTrace( eyePos, dir:Forward() * 1000000, self )
	
	-- laser
	local distance = eyePos:Distance( trace.HitPos )
	render.SetMaterial( Material( "effects/redlaser1" ) )
	render.DrawBeam( eyePos, trace.HitPos, 1, distance / 100, 1, Color( 255, 255, 255 ) )
	
end

if( CLIENT ) then

	function ENT:Think()
	
		if ( !IsValid( self:GetTargetEntity() ) ) then return end

		local targetEnt = self:GetTargetEntity()
		local angle = self:GetManipulateBoneAngles( 1 )

		local angle = ( targetEnt:GetPos() - self:GetPos() ):Angle()
		angle = self:WorldToLocalAngles( angle )
		angle = Angle( math.max( -30, math.min( 30, angle.p ) ), math.max( -30, math.min( 30, angle.y ) ),0 )

		self:ManipulateBoneAngles( 1, Angle( angle.y, angle.r, angle.p ) )
		
		self:ManipulateBonePosition( 3, Vector( -7, 0, 0 ) )
		self:ManipulateBonePosition( 6, Vector( 7, 0, 0 ) )
		
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	if ( !WireAddon ) then return end
	
end


function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	//local findEnts = ents.FindInCone( self:GetPos(), self:GetForward(), 1000.0, 30.0 ) 
	local findEnts = ents.FindInSphere( self:GetPos(), 1000.0 ) 
	
	local closest = -1
	local closestEnt = NULL
	
	//PrintTable( findEnts )
	for _, ent in pairs( findEnts ) do
	
		if ( ent:IsNPC() || ent:IsPlayer() ) then
			if ( ent:GetPos():Distance( self:GetPos() ) < closest || closest == -1 ) then
				closest = ent:GetPos():Distance( self:GetPos() )
				closestEnt = ent
			end
		end
	
	end
	
	if ( self:GetTargetEntity() != closestEnt ) then
		self:SetTargetEntity( closestEnt )
	end
	
	return true
	
end

-- no more client size
if ( CLIENT ) then return end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
end
