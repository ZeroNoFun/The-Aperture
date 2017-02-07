AddCSLuaFile( )

ENT.Base 			= "ent_fizzler_base"

ENT.Editable		= true
ENT.PrintName		= "Fizzler"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local firstFizzler = ents.Create( ClassName )
	firstFizzler:SetPos( trace.HitPos )
	firstFizzler:SetModel( "models/props/fizzler_dynamic.mdl" )
	firstFizzler:SetAngles( trace.HitNormal:Angle() )
	firstFizzler:Spawn()
	firstFizzler:SetAngles( firstFizzler:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	local traceSecond = util.QuickTrace( firstFizzler:GetPos(), -firstFizzler:GetRight() * 1000, firstFizzler )
	
	local secondFizzler = ents.Create( ClassName )
	secondFizzler:SetPos( traceSecond.HitPos )
	secondFizzler:SetModel( "models/props/fizzler_dynamic.mdl" )
	secondFizzler:SetAngles( traceSecond.HitNormal:Angle() )
	secondFizzler:Spawn()
	secondFizzler:SetAngles( secondFizzler:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )
	
	firstFizzler:SetAngles( firstFizzler:LocalToWorldAngles( firstFizzler:ModelToInfo().angle ) )
	secondFizzler:SetAngles( secondFizzler:LocalToWorldAngles( secondFizzler:ModelToInfo().angle ) )

	firstFizzler:SetNWEntity( "GASL_ConnectedField", secondFizzler )
	secondFizzler:SetNWEntity( "GASL_ConnectedField", firstFizzler )
	
	undo.Create( "LaserField" )
		undo.AddEntity( firstFizzler )
		undo.AddEntity( secondFizzler )
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
	
	render.SetMaterial( Material( "effects/fizzler" ) )
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
		
	elseif ( ent:GetPhysicsObject():IsValid() ) then
	
		APERTURESCIENCE:DissolveEnt( ent )
	
	end

end

-- no more client size
if ( CLIENT ) then return end

function ENT:Think()

	self:NextThink( CurTime() )
	
	self.BaseClass.Think( self )

	return true
	
end
