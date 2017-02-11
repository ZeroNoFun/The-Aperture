AddCSLuaFile( )

ENT.Base 			= "gasl_turret_base"

ENT.PrintName		= "Defective Turret"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, ply:EyeAngles().y, 0 ) )
	ent:Spawn()
	ent:GetPhysicsObject():Wake()
	ent:Activate()
		
	undo.Create( ent.PrintName )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()
	
end

function ENT:Draw()

	self.BaseClass.Draw( self )
	
end

if ( CLIENT ) then

	function ENT:Initialize()

		self.BaseClass.Initialize( self )
		
		self.GASL_Turret_Sounds = { 
			deploy = "GASL.TurretDefectiveActivateVO",
			retract = "GASL.TurretDetectiveAutoSearth",
			pickup = "GASL.TurretPickup",
			searth = "GASL.TurretDetectiveAutoSearth",
		}
		
		self.GASL_Turret_Bones = {
			antenna = -1,
			gunLeft = 3,
			gunRight = 6,
		}
		
		self.GASL_Turret_DrawLaser = false
		
	end
	
	-- no more client side
	return
	
end

function ENT:Initialize()

	self:SetModel( "models/npcs/turret/turret_skeleton.mdl" )
	self.BaseClass.Initialize( self )
	self:SetCanShoot( false )

end

function ENT:Think()

	self.BaseClass.Think( self )
	
end