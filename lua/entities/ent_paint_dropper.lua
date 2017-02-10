AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "gasl_base_ent"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )

end

if ( CLIENT ) then

	function ENT:Think()
		
		self.BaseClass.Think( self )
	
	end
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	if ( CLIENT ) then return end
	
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
	
	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )

	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable", "Gel Radius", "Gel Randomize Size", "Gel Amount", "Gel Launch Speed" } )

end

function ENT:Draw()
	
	self:DrawModel()
	
end

-- No more client side
if ( CLIENT ) then return end

function ENT:Think()
	
	self.BaseClass.Think( self )

	self:NextThink( CurTime() + 1 )
	if ( self:GetEnable( ) ) then
		self:NextThink( CurTime() + ( 100 / self.GASL_GelAmount ) / 20 )
		self:MakePuddle( )
	end	
	
	return true
	
end

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
	local randSize = math.Rand( -self.GASL_GelRandomizeSize, self.GASL_GelRandomizeSize ) / 100 * APERTURESCIENCE.GEL_MAXSIZE

	local rad = math.max( APERTURESCIENCE.GEL_MINSIZE, math.min( APERTURESCIENCE.GEL_MAXSIZE, self.GASL_GelRadius + randSize ) )
	ent:SetGelRadius( rad )
	ent.GASL_GelRandomizeSize = self.GASL_GelRandomizeSize
	ent.GASL_GelAmount = self.GASL_GelAmount

	local color = APERTURESCIENCE:GetColorByGelType( ent.GASL_GelType )
	ent:SetColor( color )
	
	return ent
end

function ENT:SetGelType( gelType )

	if ( gelType == 1 ) then self:SetSkin( 1 ) end
	if ( gelType == 2 ) then self:SetSkin( 2 ) end
	if ( gelType == 3 ) then self:SetSkin( 3 ) end
	if ( gelType == 4 ) then self:SetSkin( 4 ) end
	
	self.GASL_GelType = gelType

end

function ENT:SetGelRadius( gelRadius )

	self.GASL_GelRadius = math.max( APERTURESCIENCE.GEL_MINSIZE, math.min( APERTURESCIENCE.GEL_MAXSIZE, gelRadius ) )
	
end

function ENT:SetGelRandomizeSize( randomizeSize )

	self.GASL_GelRandomizeSize = math.max( 0, math.min( 100, randomizeSize ) )
	
end

function ENT:SetGelAmount( gelAmount )

	self.GASL_GelAmount = math.max( 1, math.min( 100, gelAmount ) )
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end

	if ( iname == "Enable" ) then self:SetEnable( tobool( value ) ) end
	if ( iname == "Gel Radius" ) then self:SetGelRadius( value ) end
	if ( iname == "Gel Randomize Size" ) then self:SetGelRandomizeSize( value ) end
	if ( iname == "Gel Amount" ) then self:SetGelAmount( value ) end
	if ( iname == "Gel Launch Speed" ) then self.GASL_GelLaunchSpeed = value end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable() )
	else
		self:SetEnable( bDown )
	end
	
end

numpad.Register( "aperture_science_paint_dropper_enable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_paint_dropper_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )
