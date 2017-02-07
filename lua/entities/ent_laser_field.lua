AddCSLuaFile( )

ENT.Base 			= "ent_fizzler_base"

ENT.Editable		= true
ENT.PrintName		= "Laser Field"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local firstLaserField = ents.Create( ClassName )
	firstLaserField:SetPos( trace.HitPos )
	firstLaserField:SetModel( "models/props/fizzler_dynamic.mdl" )
	firstLaserField:SetAngles( trace.HitNormal:Angle() )
	firstLaserField:Spawn()
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	local traceSecond = util.QuickTrace( firstLaserField:GetPos(), -firstLaserField:GetRight() * 1000, firstLaserField )

	local secondLaserField = ents.Create( ClassName )
	secondLaserField:SetPos( traceSecond.HitPos )
	secondLaserField:SetModel( "models/props/fizzler_dynamic.mdl" )
	secondLaserField:SetAngles( traceSecond.HitNormal:Angle() )
	secondLaserField:Spawn()
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	print( secondLaserField.BaseClass.ModelToInfo( secondLaserField ), 123 )
	
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( firstLaserField:ModelToInfo().angle ) )
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( secondLaserField:ModelToInfo().angle ) )

	firstLaserField:SetNWEntity( "GASL_ConnectedField", secondLaserField )
	secondLaserField:SetNWEntity( "GASL_ConnectedField", firstLaserField )
	
	undo.Create( "LaserField" )
		undo.AddEntity( firstLaserField )
		undo.AddEntity( secondLaserField )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return ent

end

function ENT:Draw()

	self.BaseClass.Draw( self )
	
	if ( !self:GetEnable() ) then return end
	
	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !secondField:IsValid() ) then return end
	
	local Height = 110
	
	local halfHeight = Height / 2
	local pos1 = self:LocalToWorld( Vector( 0, 0, halfHeight ) + self:ModelToOffset() )
	local pos2 = secondField:LocalToWorld( Vector( 0, 0, halfHeight ) + self:ModelToOffset() )
	local pos3 = secondField:LocalToWorld( Vector( 0, 0, -halfHeight ) + self:ModelToOffset() )
	local pos4 = self:LocalToWorld( Vector( 0, 0, -halfHeight ) + self:ModelToOffset() )
	
	render.SetMaterial( Material( "effects/laserplane" ) )
	render.DrawQuad( pos1 , pos2, pos3, pos4, Color( 255, 255, 255 ) ) 

end

if ( CLIENT ) then

	function ENT:Think()
		
	end
	
	return
end

function ENT:Initialize()

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
