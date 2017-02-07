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

end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then

		self:SetModel( "models/anim_wp/telescope_arm_trans/telescope_arm_trans.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetSkin( 2 )
		self:GetPhysicsObject():EnableMotion( false )
		
		local ent = ents.Create( "prop_physics" )
		ent:SetModel( "models/hunter/plates/plate1x1.mdl" )
		ent:SetPos( self:LocalToWorld( Vector( 0, 0, 0 ) )  )
		ent:SetMoveType( MOVETYPE_NONE )
		ent:Spawn()
		ent:SetRenderMode( RENDERMODE_TRANSALPHA )
		ent:SetColor( Color( 0, 0, 0, 0 ) )
		ent:GetPhysicsObject():SetMass( 10000000 )
		ent:GetPhysicsObject():EnableGravity( false )
		self.GASL_Panel = ent
		
		self:SetArmPos( self:LocalToWorld( Vector( 0, 0, 0 ) ) )
		self:SetArmAng( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
		self.GASL_SlowArmPos = self:GetArmPos()
		self.GASL_SlowArmAng = self:GetArmAng()
		
		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable", "Arm Position", "Arm Angle" } )
		
	end

	if ( CLIENT ) then
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Think()

	self:NextThink( CurTime() + 0.01 )
	
	local PanelMaxSpeed = 2 -- default 1
	
	local baseDofLength1 = 30
	local baseDofLength2 = 60
	local baseDofsLength = ( baseDofLength1 + baseDofLength2 )
	local panel = self.GASL_Panel
	local pointer = self.GASL_Pointer
	
	local offset = Vector( -45, 0, 0 )
	local endPos = panel:GetPos() - panel:GetUp() * 23 - self:GetForward() * 18
	local startPos = self:LocalToWorld( offset )

	local length = math.min( PanelMaxSpeed, ( self:GetArmPos() - self.GASL_SlowArmPos ):Length() / 4 )
	self.GASL_SlowArmPos = panel:GetPos() + ( self:GetArmPos() - panel:GetPos() ):GetNormalized() * length

	local divAng = panel:WorldToLocalAngles( self:GetArmAng() )
	self.GASL_SlowArmAng = panel:LocalToWorldAngles( Angle( divAng.p / 40, divAng.y / 40, divAng.r / 40 ) )
	
	local addingLength = 0

	if ( startPos:Distance( endPos ) > baseDofsLength / 1.2 ) then addingLength = math.min( 40, startPos:Distance( endPos ) - baseDofsLength / 1.2 ) end

	local boneInx = 2
	local pitch = 150
	
	local skip, LTWPitch = LocalToWorld( Vector(), Angle( pitch, 0, 0 ), Vector(), self:GetAngles() )
	local midpos, lang1, ang1, endpos, lang2, ang2 = APERTURESCIENCE:IK_Leg_two_dof( LTWPitch, startPos, endPos, baseDofLength1, baseDofLength2 + addingLength )
	
	local pitch1 = pitch - 10
	local pitch2 = pitch - 200
	local pitch3 = pitch - 250
	local pitch4 = pitch - 270
	
	local a = lang2.p - lang1.p + pitch2
	local b = -lang1.y + 180
	if ( b > 80 && b <= 180 ) then b = 80 end
	if ( b < 280 && b > 180 ) then b = 280 end
	if ( b > 180 ) then b = 360 - ( ( 360 - b ) / 4 ) end
	if ( b <= 180 ) then b = b / 4 end

	local localPanelAng = self:WorldToLocalAngles( panel:GetAngles() )
	local panelAngles = Angle( 0, -lang2.p - pitch4 - localPanelAng.p, 0 )

	self:ManipulateBoneAngles( 0, Angle( 0, -b, 0 ) ) -- dof first
	self:ManipulateBoneAngles( 2, Angle( 0, lang1.p + pitch1, 0 ) ) -- dof first
	self:ManipulateBoneAngles( 5, Angle( 0, a / 2 - 20, 0 ) ) -- dof second
	self:ManipulateBoneAngles( 6, Angle( 0, a / 2 + pitch3, 0 ) ) -- dof second
 	self:ManipulateBoneAngles( 10, panelAngles ) -- Panel

	self:ManipulateBonePosition( 8, Vector( addingLength / 2, 0, 0 ) ) -- pistons
	self:ManipulateBonePosition( 9, Vector( addingLength / 2, 0, 0 ) ) -- pistons
	
	local bonePanelInx = 11
	local angles = self:GetManipulateBoneAngles( bonePanelInx )
	local dir = self.GASL_SlowArmPos
	local angDir = self.GASL_SlowArmAng
	local angle = self:LocalToWorldAngles( Angle( -localPanelAng.p, angles.p, -b * 2 ) )
	local angleVel = panel:WorldToLocalAngles( angDir )
	panel:GetPhysicsObject():SetVelocity( ( dir - panel:GetPos() ) * 30 )
	panel:GetPhysicsObject():AddAngleVelocity( Vector( angleVel.r, angleVel.p, angleVel.y ) * 100 - panel:GetPhysicsObject():GetAngleVelocity() )

	return true
	
end

-- no more client size
if ( CLIENT ) then return end

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
		self:SetArmPos( self:LocalToWorld( Vector( -35, 0, 150 ) ) )
		//self:SetArmAng( self:LocalToWorldAngles( Angle( 0, 180, 0 ) ) )
	else
		self:SetArmPos( self:LocalToWorld( Vector( -35, 0, 70 ) ) )
		//self:SetArmAng( self:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
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
	self.GASL_Panel:Remove()
end
