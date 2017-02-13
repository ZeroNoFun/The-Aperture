 
if SERVER then // This is where the init.lua stuff goes.
 
	AddCSLuaFile ("shared.lua")
 
	SWEP.Weight = 5
 
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "Gel Gun"
 
	SWEP.Slot = 4
	SWEP.SlotPos = 1
 
	SWEP.DrawAmmo = false
 
	SWEP.DrawCrosshair = false
end
 
SWEP.Author = "CrishNate"
SWEP.Purpose = "Create gel from portal"
SWEP.Instructions = "Mouse 1 to spawn repulsion gel|Mouse 2 to spawn propulison gel|Reload to spawn water gel"

SWEP.Category = "Aperture science"
 
SWEP.Spawnable = true 
SWEP.AdminSpawnable = true
 
SWEP.ViewModel = "models/weapons/v_portalgun.mdl" 
SWEP.WorldModel = "models/weapons/w_portalgun.mdl"

SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true

function SWEP:Initialize()
	self.GASL_GelRadius = 100
end


function SWEP:PrimaryAttack()
	self:MakePuddle(1)
end

function SWEP:SecondaryAttack()
	self:MakePuddle(2)
end

function SWEP:Reload()
	self:MakePuddle(4)
end

	
 
function SWEP:MakePuddle( gel_type )
	if gel_type <= 0 then return end

	local ent = ents.Create( "ent_paint_puddle" )
	ent:SetPos( self.Owner:EyePos() + self.Owner:GetAimVector() * 16 + Vector(0,20,0))
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()

	ent:GetPhysicsObject():EnableCollisions( false )
	ent:GetPhysicsObject():Wake()
	ent:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 1000 )

	if ( IsValid( self.Owner ) && self.Owner:IsPlayer() ) then ent:SetOwner( self.Owner ) end

	ent.GASL_GelType = gel_type
	-- Randomize makes random size between maxsize and minsize by selected procent
	local randSize = math.Rand( 1, -1 )

	local rad = math.max( APERTURESCIENCE.GEL_MINSIZE, math.min( APERTURESCIENCE.GEL_MAXSIZE, randSize * 200 ) )
	ent:SetGelRadius( rad )

	local color = APERTURESCIENCE:GetColorByGelType( ent.GASL_GelType )
	ent:SetColor( color )
	
	return ent
end