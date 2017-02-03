AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Panel Arm"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Panell" )

end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 70 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()

	if ( trace.Entity:IsValid() ) then

		ent:SetParent( trace.Entity )
		
	end

	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	local panel = self:GetPanell()
	//APERTURESCIENCE:IK_Leg_two_dof( self:GetAngles() + Angle( 180, 0, 0 ), self:LocalToWorld( Vector( -13, 0, -45 ) ), panel:LocalToWorld( Vector( -27, 0, -5 ) ), 30, 60 )
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then

		self:SetModel( "models/props_livingwall/armliving64x64.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		if ( !self.GASL_Panel ) then
		
			local ent = ents.Create( "prop_physics" )
			ent:SetModel( "models/hunter/plates/plate1x1.mdl" )
			ent:SetPos( self:LocalToWorld( ( Vector( 0, 0, -1 ) + VectorRand() ) * 5 ) )
			ent:SetMoveType( MOVETYPE_NONE )
			ent:Spawn()
			self:SetPanell( ent )
			ent:DeleteOnRemove( self )
			self.GASL_Panel = ent
			
		end
		
		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable" } )
		
	end

	if ( CLIENT ) then
	
	end
	
end

function ENT:Think()

	self:NextThink( CurTime() )

	if ( SERVER ) then
		
		local baseDofLength1 = 30
		local baseDofLength2 = 60
		local baseDofsLength = ( baseDofLength1 + baseDofLength2 )
		local panel = self.GASL_Panel
		
		local startPos = self:LocalToWorld( Vector( -13, 0, -45 ) )
		local endPos = panel:LocalToWorld( Vector( -10, 0, -5 ) )
		local addingLength = 0

		if ( startPos:Distance( endPos ) > baseDofsLength / 1.2 ) then
			
			addingLength = math.min( 40, startPos:Distance( endPos ) - baseDofsLength / 1.2 )
			
		end

		local boneInx = 2
		
		local midpos, lang1, ang1, endpos, lang2, ang2 = APERTURESCIENCE:IK_Leg_two_dof( self:GetAngles() + Angle( 180, 0, 0 ), startPos, endPos, baseDofLength1, baseDofLength2 + addingLength )
		
		self:ManipulateBoneAngles( 0, Angle( lang1.y + 180, 0, 0 ) )
		self:ManipulateBoneAngles( 5, Angle( 0, 0, -lang1.p - 35 ) )
		
		local a = lang2.p - lang1.p + 190 + 60
		self:ManipulateBoneAngles( 8, Angle( 0, a / 2 + 180, 0 ) )

		local localPanelAng = self:WorldToLocalAngles( panel:GetAngles() )
		self:ManipulateBoneAngles( 9, Angle( 0, 90 - a / 2 + 160, 0 ) )
		//self:ManipulateBoneAngles( 13, Angle( -localPanelAng.r, lang2.p - 145 + localPanelAng.p, -localPanelAng.y ) )

		self:ManipulateBonePosition( 10, Vector( addingLength / 2, 0, 0 ) )
		self:ManipulateBonePosition( 11, Vector( addingLength / 2, 0, 0 ) )

	end

	if ( CLIENT ) then
		
		// 5 8 9 ( 10 11 )? 13

	end

	return true
	
end

-- no more client size
if ( CLIENT ) then return end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	if ( iname == "Reverse" ) then self:ToggleReverse( tobool( value ) ) end
	
end

numpad.Register( "aperture_science_tractor_beam_enable", function( pl, ent, keydown, idx )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_tractor_beam_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )
