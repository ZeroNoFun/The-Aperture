AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !APERTURESCIENCE.ALLOWING.laser_field && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end

	if ( !trace.Hit ) then return end
	
	local mdl = "models/props/fizzler_dynamic.mdl"
	
	local firstLaserField = ents.Create( ClassName )
	firstLaserField:SetPos( trace.HitPos )
	firstLaserField:SetModel( mdl )
	firstLaserField:SetAngles( trace.HitNormal:Angle() )
	firstLaserField:Spawn()
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	local traceSecond = util.QuickTrace( firstLaserField:GetPos(), -firstLaserField:GetRight() * 1000, firstLaserField )

	local secondLaserField = ents.Create( ClassName )
	secondLaserField:SetPos( traceSecond.HitPos )
	secondLaserField:SetModel( mdl )
	secondLaserField:SetAngles( firstLaserField:GetAngles() )
	secondLaserField:Spawn()
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( Angle( 0, 180, 0 ) ) )
	
	firstLaserField:SetNWEntity( "GASL_ConnectedField", secondLaserField )
	secondLaserField:SetNWEntity( "GASL_ConnectedField", firstLaserField )
	
	constraint.Weld( secondLaserField, firstLaserField, 0, 0, 0, true, true )

	undo.Create( "LaserField" )
		undo.AddEntity( firstLaserField )
		undo.AddEntity( secondLaserField )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	if ( !self:GetEnable() ) then return end

	self:DrawFizzler( Material( "effects/laserplane" ) )


end

if ( CLIENT ) then

	function ENT:Think()
		
		self.BaseClass.Think( self )

	end
	
	function ENT:Initialize()

		self.BaseClass.Initialize( self )
		//self.BaseClass.BaseClass.Initialize( self )

	end

	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	self.BaseClass.BaseClass.Initialize( self )

	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
	
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

	self.BaseClass.Think( self )

	return true
	
end
