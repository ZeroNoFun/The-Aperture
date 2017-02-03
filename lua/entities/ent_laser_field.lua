AddCSLuaFile( )

ENT.Base 			= "ent_fizzler_base"

ENT.Editable		= true
ENT.PrintName		= "Laser Field"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:Draw()

	self.BaseClass.Draw( self )
	
	if ( !self:GetEnable() ) then return end
	
	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !secondField:IsValid() ) then return end
	
	local Height = 110
	
	local halfHeight = Height / 2
	local pos1 = self:LocalToWorld( Vector( 0, 0, halfHeight ) )
	local pos2 = secondField:LocalToWorld( Vector( 0, 0, halfHeight ) )
	local pos3 = secondField:LocalToWorld( Vector( 0, 0, -halfHeight ) )
	local pos4 = self:LocalToWorld( Vector( 0, 0, -halfHeight ) )
	
	render.SetMaterial( Material( "effects/laserplane" ) )
	render.DrawQuad( pos1 , pos2, pos3, pos4, Color( 255, 255, 255 ) ) 

end

if ( CLIENT ) then

	function ENT:Think()
		
	end
	
	return
end

function ENT:Initialize()

	self:SetModel( "models/props/fizzler_dynamic.mdl" )
	self:SetSkin( 2 )
	self.BaseClass.Initialize( self )
	
end

function ENT:HandleEntityInField( ent )

	if ( ent:IsPlayer() ) then
		
		ent:TakeDamage( ent:Health(), self, self )
		
	elseif ( ent:GetPhysicsObject():IsValid() ) then
	
	end

end

-- no more client size
if ( CLIENT ) then return end

function ENT:Think()

	self:NextThink( CurTime() )
	
	self.BaseClass.Think( self )

	return true
	
end
