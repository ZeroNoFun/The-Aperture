AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.AutomaticFrameAdvance = true

if ( !APERTURESCIENCE ) then APERTURESCIENCE = { } end
APERTURESCIENCE.ARM_PANNEL_SPEED = 40 // default 40

function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "ArmPos" )
	self:NetworkVar( "Angle", 1, "ArmAng" )
	self:NetworkVar( "Bool", 2, "Enable" )
	self:NetworkVar( "Bool", 3, "StartEnabled" )
	self:NetworkVar( "Entity", 4, "BasePanel" )
	
end

local function IKAngle(startpos, endpos, dofLength1, dofLength2)
	local dist = (startpos - endpos):Length()
	local a = dofLength1 * dofLength1 + dofLength2 * dofLength2 - dist * dist
	local b = a / (2 * dofLength1 * dofLength2)
	local angle = math.acos(b)
	return math.deg(angle)
end

function ENT:Draw()

	self:DrawModel()
	
	-- if ( CLIENT ) then
		-- render.SetMaterial(Material("models/wireframe"))
		-- render.DrawBox(firstDofPos, LTWA1, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		-- render.DrawBox(secondDofPos, LTWA2, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		
		-- render.DrawBox((startPos + firstDofPos) / 2, LTWA1, -Vector(dofLength1 / 2, 2, 2), Vector(dofLength1 / 2, 2, 2), Color(255, 255, 255), 0) 
		-- render.DrawBox((firstDofPos + secondDofPos) / 2, LTWA2, -Vector(dofLength2 / 2, 2, 2), Vector(dofLength2 / 2, 2, 2), Color(255, 255, 255), 0) 
	-- end
	
end

function ENT:MovePanel( pos, ang )

	if ( pos == self:GetArmPos() && ang == self:GetArmAng() ) then return end
	
	self:SetArmPos( pos )
	self:SetArmAng( ang )
	self.GASL_ArmPos = pos
	self.GASL_ArmAng = ang

	if ( !timer.Exists( "GASL_Timer_ArmPanel"..self:EntIndex() ) ) then
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_open_01.wav" )
	end
	
	timer.Create( "GASL_Timer_ArmPanel"..self:EntIndex(), 1.0, 1, function() end )
	
end

function ENT:IK_Leg_two_dof( parentAngle, startPos, endPos, dofLength1, dofLength2 )
	
	local distStartEnd = startPos:Distance( endPos )
	local rad2deg = 180 / math.pi
	
	// Getting Angles

	// Dof 1
	local a = math.pow( distStartEnd, 2 ) + math.pow( dofLength1, 2 ) - math.pow( dofLength2, 2 )
	local aa = a / ( 2 * distStartEnd * dofLength1 )
	aa = math.max( -1, math.min( 1, aa ) )
	
	local firstDofAng = math.acos( aa ) * rad2deg
	
	local WTLP, WTLA = WorldToLocal( Vector(), ( endPos - startPos ):Angle(), startPos, parentAngle )
	WTLA1 = Angle( WTLA.pitch - firstDofAng, WTLA.yaw, 0 )
	local LTWP, LTWA1 = LocalToWorld( Vector(), WTLA1, startPos, parentAngle )

	local firstDofPos = startPos + LTWA1:Forward() * dofLength1
	
	// Dof 2
	local b = math.pow( dofLength1, 2 ) + math.pow( dofLength2, 2 ) - math.pow( distStartEnd, 2 )
	local bb = b / ( 2 * dofLength1 * dofLength2 )
	bb = math.max( -1, math.min( 1, bb ) )
	
	local secondDofAng = math.acos( bb ) * rad2deg
	WTLA2 = Angle( WTLA.pitch - firstDofAng - secondDofAng + 180, WTLA.yaw, 0 )
	local LTWP, LTWA2 = LocalToWorld( Vector( 0, 0, 0 ), WTLA2, startPos, parentAngle )

	local secondDofPos = firstDofPos + LTWA2:Forward() * dofLength2
	
	local debugBoxSize = Vector( 3, 3, 3 )
	
	// Debug render
	if ( CLIENT ) then
		render.SetMaterial(Material("models/wireframe"))
		render.DrawBox(firstDofPos, LTWA1, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		render.DrawBox(secondDofPos, LTWA2, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		
		render.DrawBox((startPos + firstDofPos) / 2, LTWA1, -Vector(dofLength1 / 2, 2, 2), Vector(dofLength1 / 2, 2, 2), Color(255, 255, 255), 0) 
		render.DrawBox((firstDofPos + secondDofPos) / 2, LTWA2, -Vector(dofLength2 / 2, 2, 2), Vector(dofLength2 / 2, 2, 2), Color(255, 255, 255), 0) 
	end
	
	return firstDofPos, WTLA1, LTWA1, secondDofPos, WTLA2, LTWA2
	
end

if ( CLIENT ) then

	function ENT:Initialize()
	
		self.BaseClass.Initialize( self )
		
	end

	function ENT:Think()

		local Panel = self:GetBasePanel()
		if ( !IsValid( Panel ) ) then return end
		local LocalPanelAng = self:WorldToLocalAngles( Panel:GetAngles() )
		local ArmPanelAngle = self:LocalToWorldAngles( Angle( 0, LocalPanelAng.yaw, 0 ) )

		local BaseDofLength1 = 40
		local BaseDofLength2 = 50
		local BaseDofsLength = ( BaseDofLength1 + BaseDofLength2 )
		
		local Offset = Vector( -12, 0, -46 )
		Offset:Rotate( Angle( 0, LocalPanelAng.yaw, 0 ) )
		local endPos = Panel:LocalToWorld( Vector( -25, 0, -15 ) )
		local startPos = self:LocalToWorld( Offset )
		
		local addingLength = 0

		if ( startPos:Distance( endPos ) > BaseDofsLength / 1.2 ) then addingLength = math.min( 40, startPos:Distance( endPos ) - BaseDofsLength / 1.2 ) end

		local boneInx = 2
		local pitch = 140
		
		local _, LTWPitch = LocalToWorld( Vector(), Angle( pitch, 0, 0 ), Vector(), ArmPanelAngle )
		local midpos, lang1, ang1, endpos, lang2, ang2 = self:IK_Leg_two_dof( LTWPitch, startPos, endPos, BaseDofLength1, BaseDofLength2 + addingLength )
		
		local pitch1 = 135 + pitch
		local pitch2 = 100
		local pitch3 = -35 + pitch
		
		local a = lang2.p - lang1.p
		local b = -lang1.y + 180
		if ( b > 80 && b <= 180 ) then b = 80 end
		if ( b < 280 && b > 180 ) then b = 280 end
		if ( b > 180 ) then b = 360 - ( ( 360 - b ) / 4 ) end
		if ( b <= 180 ) then b = b / 4 end

		local panelAngles = Angle( 0, 0, lang2.p - pitch3 + LocalPanelAng.p )

		self:ManipulateBoneAngles( 0, Angle( LocalPanelAng.yaw, 0, 0 ) ) -- dof first
		self:ManipulateBoneAngles( 5, Angle( 0, 0, -lang1.p + pitch1 ) ) -- dof first
		self:ManipulateBoneAngles( 7, Angle( 0, -90, 0 ) ) -- dof second
		self:ManipulateBoneAngles( 8, Angle( 0, -a + pitch2, 0 ) ) -- dof second
		self:ManipulateBoneAngles( 11, panelAngles ) -- Panel

		self:ManipulateBonePosition( 9, Vector( addingLength / 2, 0, 0 ) ) -- pistons
		self:ManipulateBonePosition( 10, Vector( addingLength / 2, 0, 0 ) ) -- pistons
		
		local bonePanelInx = 11
		local angles = self:GetManipulateBoneAngles( bonePanelInx )
		local angle = self:LocalToWorldAngles( Angle( -LocalPanelAng.p, angles.p, -b * 2 ) )
		
	end
	
	-- no more client side
	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self:SetModel( "models/gasl/arm_panel_interior.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetSkin( 0 )
	self:GetPhysicsObject():EnableMotion( false )
	self:GetPhysicsObject():EnableCollisions( false )
	
	local ent = ents.Create( "prop_physics" )
	if ( !IsValid( ent ) ) then return end
	ent:SetModel( "models/gasl/paint.mdl" )
	ent:SetPos( self:LocalToWorld( Vector( 0, 0, 50 ) )  )
	ent:SetAngles( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	ent:Spawn()
	//ent:SetNoDraw( true )
	ent:SetRenderMode( RENDERGROUP_TRANSLUCENT )
	ent:SetColor( Color( 0, 0, 0, 0 ) )
	ent:GetPhysicsObject():SetMass( 10000000 )
	ent:GetPhysicsObject():EnableGravity( false )
	self:SetBasePanel( ent )
	
	self:SetArmPos( Vector( 0, 0, 50 ) )
	self:SetArmAng( Angle( 0, 0, 0 ) )
	self.GASL_ArmPos = Vector( 0, 0, 0 )
	self.GASL_ArmAng = Angle( 0, 0, 0 )
	self.GASL_SlowArmPos = self.GASL_ArmPos
	self.GASL_SlowArmAng = self.GASL_ArmAng
	self:ManipulateBoneAngles( 0, Angle( 0, 0, 0 ) )
	self:SetSubMaterial( 1, "models/gasl/arm_panel/floor_four_white" )


	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )

	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable", "Arm Position [VECTOR]", "Arm Angle [ANGLE]" } )
	
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	local Panel = self:GetBasePanel()
	if ( !IsValid( Panel ) ) then self:Remove() return end
	local armPos = self:LocalToWorld( self.GASL_ArmPos )
	local armAng = self:LocalToWorldAngles( self.GASL_ArmAng )
	
	if ( self:GetMaterial() != "" ) then
		self:SetSubMaterial( 1, self:GetMaterial() )
		self:SetMaterial( "" )
	end
	
	local length = math.min( APERTURESCIENCE.ARM_PANNEL_SPEED, ( armPos - self.GASL_SlowArmPos ):Length() )
	self.GASL_SlowArmPos = Panel:GetPos() + ( armPos - Panel:GetPos() ):GetNormalized() * length

	local divAng = Panel:WorldToLocalAngles( armAng )
	self.GASL_SlowArmAng = Panel:LocalToWorldAngles( Angle( divAng.p / 40, divAng.y / 40, divAng.r / 40 ) )
	
	local dir = self.GASL_SlowArmPos
	local angDir = self.GASL_SlowArmAng
	local angleVel = Panel:WorldToLocalAngles( angDir )
	angleVel.p = math.ApproachAngle( 0, angleVel.p, math.min( math.abs( angleVel.p / 4 ), FrameTime() * 4 * APERTURESCIENCE.ARM_PANNEL_SPEED ) )
	angleVel.y = math.ApproachAngle( 0, angleVel.y, math.min( math.abs( angleVel.y ), FrameTime() * 6 * APERTURESCIENCE.ARM_PANNEL_SPEED ) )
	angleVel.r = math.ApproachAngle( 0, angleVel.r, math.min( math.abs( angleVel.r ), FrameTime() * 6 * APERTURESCIENCE.ARM_PANNEL_SPEED ) )
	
	Panel:GetPhysicsObject():SetVelocity( ( dir - Panel:GetPos() ) * 10 )
	Panel:GetPhysicsObject():AddAngleVelocity( Vector( angleVel.r, angleVel.p, angleVel.y ) * 400 - Panel:GetPhysicsObject():GetAngleVelocity() )

	return true
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) )end
	if ( iname == "Arm Position" ) then self:MovePanel( Vector( value[1], value[2], value[3] ), self:GetArmAng() ) end
	if ( iname == "Arm Angle" ) then self:MovePanel( self:GetArmPos(), Angle( value[1], value[2], value[3] ) ) end

end

function ENT:ToggleEnable( bDown )
	if ( self:GetStartEnabled() ) then bDown = !bDown end
	if ( bDown == self:GetEnable() ) then return end

	self:SetEnable( bDown )
	
	if ( self:GetEnable() ) then
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_open_01.wav" )
		self.GASL_ArmPos = self:GetArmPos()
		self.GASL_ArmAng = self:GetArmAng()
	else
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_close_01.wav" )
		self.GASL_ArmPos = Vector( 0, 0, 0 )
		self.GASL_ArmAng = Angle( 0, 0, 0 )
	end
	
end

function ENT:OnRemove()

	if ( IsValid( self:GetBasePanel() ) ) then self:GetBasePanel():Remove() end
	
end
