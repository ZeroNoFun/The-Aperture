AddCSLuaFile( )

ENT.Base 			= "gasl_turret_base"

ENT.PrintName		= "Turret"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

-- function ENT:SpawnFunction( ply, trace, ClassName )
	
	-- //self.BaseClass.SpawnFunction( ply, trace, ClassName )

-- end

function ENT:Draw()

	self.BaseClass.Draw( self )

end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:SetModel( "models/npcs/turret/turret.mdl" )
	self.BaseClass.Initialize( self )
	
end

function ENT:Think()

	self.BaseClass.Think( self )
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
end
