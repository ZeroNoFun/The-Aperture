 
if SERVER then // This is where the init.lua stuff goes.
 
	AddCSLuaFile ("shared.lua")
 
	SWEP.Weight = 3
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	SWEP.Spawnable = true
	SWEP.AdminSpawnable = true
 
elseif CLIENT then
	SWEP.PrintName = "Paint Gun"
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Purpose = "Create gel from portal"
SWEP.Instructions = "Mouse 1 to spawn repulsion gel|Mouse 2 to spawn propulison gel|Reload to spawn water gel"

SWEP.Category = "Aperture Science"
 
SWEP.Spawnable = true 
SWEP.AdminSpawnable = true
 
SWEP.ViewModel = "models/weapons/v_aperture_paintgun.mdl" 
SWEP.WorldModel = "models/weapons/w_aperture_paintgun.mdl"

SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true

function SWEP:Initialize()
	self.GASL_GelRadius = 100
end


function SWEP:PrimaryAttack()
	if ( CLIENT ) then return end
	self:MakePuddle( 1 )
end

function SWEP:SecondaryAttack()
	if ( CLIENT ) then return end
	self:MakePuddle( 2 )
end

function SWEP:Reload()
	if ( CLIENT ) then return end
	self:MakePuddle( 4 )
end

	
 
function SWEP:MakePuddle( gel_type )

	if ( timer.Exists( "GASL_Player_ShootingPaint"..self.Owner:EntIndex() ) ) then return end
	
	timer.Create( "GASL_Player_ShootingPaint"..self.Owner:EntIndex(), 0.01, 1, function() end )
	
	if gel_type <= 0 then return end

	local OwnerShootPos = self.Owner:GetShootPos()
	local OwnerEyeAngles = self.Owner:EyeAngles()
	local forward = OwnerEyeAngles:Forward()
	local traceForce = util.QuickTrace( OwnerShootPos, forward * 1000, self.Owner )
	local force = traceForce.HitPos:Distance( OwnerShootPos )
	
	local ent = ents.Create( "ent_paint_puddle" )
	ent:SetPos( OwnerShootPos )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()
	ent:SetOwner( self.Owner )
	
	ent:GetPhysicsObject():EnableCollisions( false )
	ent:GetPhysicsObject():Wake()
	ent:GetPhysicsObject():SetVelocity( forward * math.max( 0, force - 100 ) * 4 )

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