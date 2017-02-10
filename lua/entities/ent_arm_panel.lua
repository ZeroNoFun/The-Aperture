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
	self:NetworkVar( "Bool", 3, "Toggle" )
	self:NetworkVar( "Bool", 4, "StartEnabled" )
	self:NetworkVar( "Entity", 4, "BasePanel" )
	
end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 20 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()

			
		local panel = self:GetBasePanel()

		local baseDofLength1 = 40
		local baseDofLength2 = 64
		local baseDofsLength = ( baseDofLength1 + baseDofLength2 )
		local pointer = self.GASL_Pointer
		
		local offset = Vector( -45, 0, 0 )
		local endPos = panel:LocalToWorld( Vector( -23, 0, -12 ) )
		local startPos = self:LocalToWorld( offset )
		
		local addingLength = 0

		if ( startPos:Distance( endPos ) > baseDofsLength / 1.2 ) then addingLength = math.min( 40, startPos:Distance( endPos ) - baseDofsLength / 1.2 ) end

		local boneInx = 2
		local pitch = 140
		
		local skip, LTWPitch = LocalToWorld( Vector(), Angle( pitch, 0, 0 ), Vector(), self:GetAngles() )
		local midpos, lang1, ang1, endpos, lang2, ang2 = APERTURESCIENCE:IK_Leg_two_dof( LTWPitch, startPos, endPos, baseDofLength1, baseDofLength2 + addingLength )
		
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

		-- self:ManipulateBoneAngles( 9, Angle( 0, CurTime() * 100, 0 ) )
		-- self:ManipulateBoneAngles( 3, Angle( 0, 0, 0 ) )
		self:ManipulateBoneAngles( 0, Angle( 0, -b, -90 ) ) -- dof first
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

function ENT:MovePanel( pos, ang )

	self:SetArmPos( pos )
	self:SetArmAng( ang )

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then

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
		
		self:SetArmPos( ent:GetPos() )
		self:SetArmAng( ent:GetAngles() )
		self.GASL_SlowArmPos = self:GetArmPos()
		self.GASL_SlowArmAng = self:GetArmAng()
		
		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable", "Arm Position", "Arm Angle" } )
		
		self:ManipulateBoneAngles( 0, Angle( 0, 0, 0 ) )
		
	end

	if ( CLIENT ) then
	end
	
end

if ( CLIENT ) then

	function ENT:Think()

	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.05 )
	
	local PanelMaxSpeed = 5 -- default 1
	local panel = self:GetBasePanel()
	
	local length = math.min( PanelMaxSpeed, ( self:GetArmPos() - self.GASL_SlowArmPos ):Length() / 4 )
	self.GASL_SlowArmPos = panel:GetPos() + ( self:GetArmPos() - panel:GetPos() ):GetNormalized() * length

	local divAng = panel:WorldToLocalAngles( self:GetArmAng() )
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
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	if ( iname == "Arm Position" ) then self:SetArmPos( value ) end
	if ( iname == "Arm Angle" ) then self:SetArmPos( value ) end

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
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_open_01.wav" )
		self:SetArmPos( self:LocalToWorld( Vector( -30, 0, 150 ) ) )
		self:SetArmAng( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
	else
		self:EmitSound( "world/interior_robot_arm/interior_arm_platform_close_01.wav" )
		self:SetArmPos( self:LocalToWorld( Vector( -30, 0, 45 ) ) )
		self:SetArmAng( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
	end
	
end

numpad.Register( "aperture_science_arm_panel_enable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_arm_panel_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )

function ENT:OnRemove()
	self:GetBasePanel():Remove()
end
