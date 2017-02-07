AddCSLuaFile( )

ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Aerial Faith Plate"
ENT.AutomaticFrameAdvance = true


function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "LandPoint" )
	self:NetworkVar( "Float", 1, "LaunchHeight" )
	self:NetworkVar( "Bool", 2, "Enable" )
	self:NetworkVar( "Bool", 3, "Toggle" )
	self:NetworkVar( "Bool", 4, "StartEnabled" )

end

function ENT:Draw()

	self:DrawModel()
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.GASL_Cooldown = 0
	self.GASL_LaunchedEntities = { }
	self.GASL_TrajectoryCurve = { }
	self.GASL_CatapultUpdate = Vector( )
	self.GASL_LaunchAngle = 0
	self.GASL_LaunchForce = 0
	self.GASL_FlyTime = 0
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if ( self:GetLandPoint() == Vector() ) then return end
	
	local FlyingSpeedMult = 4
	local BoxSize = 50

	local trace = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetUp() * BoxSize,
		filter = self,
		ignoreworld = true,
		mins = Vector( -BoxSize, -BoxSize, -BoxSize ),
		maxs = Vector( BoxSize, BoxSize, BoxSize ),
		mask = MASK_SHOT_HULL
	} )
	
	-- Handling catapult location change
	if ( self.GASL_CatapultUpdate != self:GetPos() ) then
		self.GASL_CatapultUpdate = self:GetPos()
		
		-- local startpos = self:GetPos()
		-- local endpos = self:GetLandPoint()
		-- local middlepos = ( startpos + endpos ) / 2 + Vector( 0, 0, self:GetLaunchHeight() * 2 )
		-- local dist = startpos:Distance( endpos )
		-- self.GASL_TrajectoryCurve = APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos, endpos, 20 )

		
	
	end
	
	-- launch init
	if ( trace.Entity:IsValid() && self.GASL_Cooldown == 0 && self:GetEnable()
		&& ( trace.Entity:IsNPC() 
		|| trace.Entity:IsPlayer() 
		|| trace.Entity:GetPhysicsObject():IsValid() ) ) then

		local ent = trace.Entity
		
		APERTURESCIENCE:PlaySequence( self, "straightup", 1.0 )
		self:EmitSound( "door/heavy_metal_stop1.wav" )
		EmitSound( "door/heavy_metal_stop1.wav", self:LocalToWorld( Vector( 0, 0, 100 ) ), self:EntIndex(), CHAN_AUTO, 1, 75, 0, 100 )
		
		self:LaunchEntity( ent )
		
		self.GASL_Cooldown = 2

	end
	
	-- Reseting cooldown
	if ( self.GASL_Cooldown > 0 ) then self.GASL_Cooldown = self.GASL_Cooldown - 1
	elseif ( self.GASL_Cooldown < 0 ) then  self.GASL_Cooldown = 0 end		

	return true
	
end

function ENT:CalculateTrajectoryForceAng( )

	local pos = self:GetPos()
	local destination = self:GetLandPoint()
	local locXY = Vector( destination.x, destination.y, 0 ):Distance( Vector( pos.x, pos.y, 0 ) )
    local locZ = destination.z - pos.z
	local Gravity = -physenv.GetGravity().z
	
	local force = 2000 -- start force
	local dist = 0
	local angle = 0
	local time = 0
	local velX = 0
	local velY = 0
	local maxY = 0
	
	while math.sqrt ( ( dist - locXY ) * ( dist - locXY ) ) > 1 do

		-- if doesn't found add force
		if ( angle > 360 ) then
			angle = angle - 360
			force = force + 100
		end

		angle = angle + ( locXY - dist ) / 5000
		
		velX = math.cos( ( 90 - angle ) * math.pi / 180 ) * force
		velY = math.sin( ( 90 - angle ) * math.pi / 180 ) * force
		time = velY / Gravity -- time to lift up
		maxY = ( velY * velY ) / ( 2 * Gravity )
		
		time = time + math.sqrt( ( ( maxY - locZ ) * 2 ) / Gravity )
		dist = velX * time
		
	end
	
	print("VelX: ", math.Round( velX ),"  VelY: ", math.Round( velY ), "  MaxY: ", math.Round( maxY ), "  Time: ", math.Round( time * 100 ) / 100, " Force: ", force )
	
	self.GASL_LaunchAngle = angle
	self.GASL_LaunchForce = force
	self.GASL_FlyTime = time

	return angle, force, time
	
end

function ENT:LaunchEntity( entity )

	local angle = self.GASL_LaunchAngle
	local force = self.GASL_LaunchForce
	local time = self.GASL_FlyTime
	
	local destination = self:GetLandPoint()
	local direction = Angle( -90 + angle, ( destination - self:GetPos() ):Angle().y, 0 )

	local velocity = direction:Forward() * force
	
	velocity = velocity + ( self:GetPos() - entity:GetPos() ) / time
	
	if ( entity:IsPlayer() ) then
		
		entity:SetVelocity( velocity - entity:GetVelocity() )
		
	elseif ( entity:GetPhysicsObject():IsValid() ) then
	
		entity:GetPhysicsObject():SetVelocity( velocity )
		
	end
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end

	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable() )
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable() ) then self:SetSkin( 0 ) else self:SetSkin( 1 ) end
	
end

function ENT:SetLandingPoint( point )

	self:SetLandPoint( point )
	self:CalculateTrajectoryForceAng()
	
end

numpad.Register( "aperture_science_catapult_enable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_catapult_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )