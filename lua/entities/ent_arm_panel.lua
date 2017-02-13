AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Panel Arm"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "ArmPos" )
	self:NetworkVar( "Angle", 1, "ArmAng" )
	self:NetworkVar( "Bool", 2, "Enable" )
	self:NetworkVar( "Bool", 3, "StartEnabled" )
	self:NetworkVar( "Entity", 4, "BasePanel" )
	
end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	if ( !APERTURESCIENCE.ALLOWING.arm_panel && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 20 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:MovePanel( pos, ang )

	self:SetArmPos( pos )
	self:SetArmAng( ang )
	
	self.GASL_ArmPos = pos
	self.GASL_ArmAng = ang

	if ( !timer.Exists( "GASL_Timer_ArmPanel"..self:EntIndex() ) ) then
	
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_open_01.wav" )
		timer.Create( "GASL_Timer_ArmPanel"..self:EntIndex(), 2.0, 1, function() end )
		
	end
	
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

		local panel = self:GetBasePanel()

		local baseDofLength1 = 40
		local baseDofLength2 = 64
		local baseDofsLength = ( baseDofLength1 + baseDofLength2 )
		local pointer = self.GASL_Pointer
		
		if ( !IsValid( panel ) ) then return end
		
		local offset = Vector( -45, 0, 0 )
		local endPos = panel:LocalToWorld( Vector( -23, 0, -12 ) )
		local startPos = self:LocalToWorld( offset )
		
		local addingLength = 0

		if ( startPos:Distance( endPos ) > baseDofsLength / 1.2 ) then addingLength = math.min( 40, startPos:Distance( endPos ) - baseDofsLength / 1.2 ) end

		local boneInx = 2
		local pitch = 140
		
		local skip, LTWPitch = LocalToWorld( Vector(), Angle( pitch, 0, 0 ), Vector(), self:GetAngles() )
		local midpos, lang1, ang1, endpos, lang2, ang2 = self:IK_Leg_two_dof( LTWPitch, startPos, endPos, baseDofLength1, baseDofLength2 + addingLength )
		
		local pitch1 = 200 - pitch
		local pitch2 = -50
		local pitch3 = -73
		local pitch4 = 27  - pitch
		
		local a = lang2.p - lang1.p + pitch2
		local b = -lang1.y + 180
		if ( b > 80 && b <= 180 ) then b = 80 end
		if ( b < 280 && b > 180 ) then b = 280 end
		if ( b > 180 ) then b = 360 - ( ( 360 - b ) / 4 ) end
		if ( b <= 180 ) then b = b / 4 end

		local localPanelAng = self:WorldToLocalAngles( panel:GetAngles() )

		local panelAngles = Angle( 0, -lang2.p - pitch4 - localPanelAng.p, 0 )

		self:ManipulateBoneAngles( 0, Angle( 0, 0, -90 ) ) -- dof first
		self:ManipulateBoneAngles( 2, Angle( 0, lang1.p + pitch1, 0 ) ) -- dof first
		self:ManipulateBoneAngles( 4, Angle( 0, -50, 0 ) ) -- dof second
		self:ManipulateBoneAngles( 5, Angle( 0, a + pitch3, 0 ) ) -- dof second
		self:ManipulateBoneAngles( 9, panelAngles ) -- Panel

		self:ManipulateBonePosition( 7, Vector( addingLength / 2, 0, 0 ) ) -- pistons
		self:ManipulateBonePosition( 8, Vector( addingLength / 2, 0, 0 ) ) -- pistons
		
		local bonePanelInx = 11
		local angles = self:GetManipulateBoneAngles( bonePanelInx )
		local angle = self:LocalToWorldAngles( Angle( -localPanelAng.p, angles.p, -b * 2 ) )
		
	end
	
	-- no more client side
	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self:SetModel( "models/anim_wp/arm_panel/arm_panel.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetSkin( 2 )
	self:GetPhysicsObject():EnableMotion( false )
	self:GetPhysicsObject():EnableCollisions( false )
	
	local ent = ents.Create( "prop_physics" )
	ent:SetModel( "models/hunter/plates/plate1x1.mdl" )
	ent:SetPos( self:LocalToWorld( Vector( -30, 0, 50 ) )  )
	ent:SetAngles( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()
	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	ent:SetColor( Color( 0, 0, 0, 0 ) )
	ent:GetPhysicsObject():SetMass( 10000000 )
	ent:GetPhysicsObject():EnableGravity( false )
	self:SetBasePanel( ent )
	if ( !IsValid( ent ) ) then self:Remove() end
	
	self:SetArmPos( Vector( -30, 0, 140 ) )
	self:SetArmAng( Angle( 0, 0, 0 ) )
	self.GASL_ArmPos = Vector( -30, 0, 45 )
	self.GASL_ArmAng = Angle( 0, 0, 0 )
	self.GASL_SlowArmPos = self.GASL_ArmPos
	self.GASL_SlowArmAng = self.GASL_ArmAng
	self:ManipulateBoneAngles( 0, Angle( 0, 0, 0 ) )
	self:SetSubMaterial( 1, "hunter/myplastic" )

	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )

	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable", "Arm Position [VECTOR]", "Arm Angle [ANGLE]" } )
	
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	local PanelMaxSpeed = 5 -- default 1
	local panel = self:GetBasePanel()
	local armPos = self:LocalToWorld( self.GASL_ArmPos )
	local armAng = self:LocalToWorldAngles( self.GASL_ArmAng )
	
	if ( !IsValid( panel ) ) then
		self:Remove()
		return
	end
	
	if ( self:GetMaterial() != "" ) then
		
		self:SetSubMaterial( 1, self:GetMaterial() )
		self:SetMaterial( "" )
		
	end
	
	local length = math.min( PanelMaxSpeed, ( armPos - self.GASL_SlowArmPos ):Length() / 4 )
	self.GASL_SlowArmPos = panel:GetPos() + ( armPos - panel:GetPos() ):GetNormalized() * length

	local divAng = panel:WorldToLocalAngles( armAng )
	self.GASL_SlowArmAng = panel:LocalToWorldAngles( Angle( divAng.p / 40, divAng.y / 40, divAng.r / 40 ) )
	
	local dir = self.GASL_SlowArmPos
	local angDir = self.GASL_SlowArmAng
	local angleVel = panel:WorldToLocalAngles( angDir )
	
	panel:GetPhysicsObject():SetVelocity( ( dir - panel:GetPos() ) * 30 )
	panel:GetPhysicsObject():AddAngleVelocity( Vector( angleVel.r, angleVel.p, angleVel.y ) * 100 - panel:GetPhysicsObject():GetAngleVelocity() )

	return true
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) )end
	if ( iname == "Arm Position" ) then self:MovePanel( value, self:GetArmAng() ) end
	if ( iname == "Arm Angle" ) then self:MovePanel( self:GetArmPos(), value ) end

end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	self:SetEnable( bDown )
	
	if ( self:GetEnable() ) then
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_open_01.wav" )
		self.GASL_ArmPos = self:GetArmPos()
		self.GASL_ArmAng = self:GetArmAng()
	else
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_close_01.wav" )
		self.GASL_ArmPos = Vector( -30, 0, 45 )
		self.GASL_ArmAng = Angle( 0, 0, 0 )
	end
	
end

function ENT:OnRemove()

	if ( IsValid( self:GetBasePanel() ) ) then self:GetBasePanel():Remove() end
	
end
