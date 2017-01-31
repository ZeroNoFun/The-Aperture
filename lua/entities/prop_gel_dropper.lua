AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	
end

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/props_ingame/paint_dropper.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableCollisions( false )
		self:DrawShadow( false )

		self.GASL_GelType = 0
		self.GASL_GelRadius = 0
		self.GASL_GelRandomizeSize = 0
		self.GASL_GelAmount = 0
		self.GASL_GelLaunchSpeed = 0

	end

	if ( CLIENT ) then
	
	end
	
end

if ( SERVER ) then

function ENT:MakePuddle( )

		local ent = ents.Create( "ent_gel_puddle" )
		ent:SetPos( self:LocalToWorld( ( Vector( 0, 0, -1 ) + VectorRand() ) * 5 ) )
		ent:SetMoveType( MOVETYPE_NONE )
		ent:Spawn()
		ent:GetPhysicsObject():EnableCollisions( false )
		ent:GetPhysicsObject():Wake()
		ent:GetPhysicsObject():SetVelocity( -self:GetUp() * self.GASL_GelLaunchSpeed )
		
		ent.GASL_GelType = self.GASL_GelType
		-- Randomize makes random size between maxsize and minsize by selected procent
		local randSize = math.Rand( -self.GASL_GelRandomizeSize, self.GASL_GelRandomizeSize ) / 100
		local rad = math.max( APERTURESCIENCE.GEL_MINSIZE, math.min( APERTURESCIENCE.GEL_MAXSIZE, self.GASL_GelRadius + randSize * APERTURESCIENCE.GEL_MAXSIZE ) )
		ent:SetGelRadius( rad )
		ent.GASL_GelRandomizeSize = self.GASL_GelRandomizeSize
		ent.GASL_GelAmount = self.GASL_GelAmount

		local color = APERTURESCIENCE:GetColorByGelType( ent.GASL_GelType )
		ent:SetColor( color )
		
		return ent
	end
	
end

function ENT:SetGelType( gelType )

	if ( gelType == 1 ) then self:SetSkin( 1 ) end
	if ( gelType == 2 ) then self:SetSkin( 2 ) end
	if ( gelType == 3 ) then self:SetSkin( 3 ) end
	if ( gelType == 4 ) then self:SetSkin( 4 ) end
	
	self.GASL_GelType = gelType

end

function ENT:Draw()
	
	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 1 )

	if ( SERVER ) then
	
		self:NextThink( CurTime() + ( 100 / self.GASL_GelAmount ) / 20 )
		self:MakePuddle( )
	
	end 

	if ( CLIENT ) then
		
	end 
	
	return true
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetToggle( ) ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable( ) )
	else
		self:SetEnable( bDown )
	end
	
end

if ( SERVER ) then

	numpad.Register( "aperture_science_paint_dropper_enable", function( pl, ent, keydown, idx )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleEnable( true ) end
		return true

	end )

	numpad.Register( "aperture_science_paint_dropper_disabled", function( pl, ent, keydown )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleEnable( false ) end
		return true

	end )

end
