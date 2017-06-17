AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base = "gasl_base_ent"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )

end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetModel( "models/props_ingame/paint_dropper.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:Activate()

	return ent

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
	
	self.GASL_PAINT_Type = PAINT_GEL_NONE
	self.GASL_PAINT_Radius = 0
	self.GASL_PAINT_Amount = 0
	self.GASL_PAINT_LaunchSpeed = 0
	
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
		self:NextThink( CurTime() + math.max( 1, 100 - self.GASL_PAINT_Amount ) / 50 )
		self:MakePuddle( )
	end	
	
	return true
	
end

function ENT:MakePuddle()

	-- Randomize makes random size between maxsize and minsize by selected procent
	local RandSize = math.Rand( -1, 1 ) * self.GASL_PAINT_Radius / 4

	local rad = math.max(APERTURESCIENCE.GEL_MINSIZE, math.min(APERTURESCIENCE.GEL_MAXSIZE, self.GASL_PAINT_Radius + RandSize))
	local randomSpread = VectorRand():GetNormalized() * (APERTURESCIENCE.GEL_MAXSIZE - rad) * (self.GASL_PAINT_LaunchSpeed / APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED)
	local velocity = -self:GetUp() * self.GASL_PAINT_LaunchSpeed + randomSpread
	local pos = self:LocalToWorld(Vector(0, 0, -50) + VectorRand() * (40 - (rad / APERTURESCIENCE.GEL_MAXSIZE ) * 40) / 4)
	
	local paint = APERTURESCIENCE:MakePaintPuddle(self.GASL_PAINT_Type, pos, velocity, rad)

	if IsValid(self.Owner) and self.Owner:IsPlayer() then paint:SetOwner(self.Owner) end
	
	return ent
	
end

function ENT:SetPaintType( paintType )

	self:SetSkin( paintType )
	self.GASL_PAINT_Type = paintType

end

function ENT:SetPaintRadius( paintRadius )

	self.GASL_PAINT_Radius = paintRadius
	
end

function ENT:SetPaintAmount( paintAmount )

	self.GASL_PAINT_Amount = math.max( 0, paintAmount )
	
end

function ENT:SetPaintLaunchSpeed( launchSpeed )

	self.GASL_PAINT_LaunchSpeed = math.max( 0, launchSpeed )
	
end

-- function ENT:TriggerInput( iname, value )
	-- if ( !WireAddon ) then return end

	-- if ( iname == "Enable" ) then self:SetEnable( tobool( value ) ) end
	-- if ( iname == "Gel Radius" ) then self:SetGelRadius( value ) end
	-- if ( iname == "Gel Randomize Size" ) then self:SetGelRandomizeSize( value ) end
	-- if ( iname == "Gel Amount" ) then self:SetGelAmount( value ) end
	-- if ( iname == "Gel Launch Speed" ) then self.GASL_GelLaunchSpeed = value end
	
-- end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end
	self:SetEnable( bDown )
	
end