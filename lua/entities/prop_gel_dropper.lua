AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

local GASL_PaintRadius = 47.1

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableCollisions( false )
		self:DrawShadow( false )

		self.GASL_GelType = 0
		self.GASL_GelSplatRadius = 0
	end

	if ( CLIENT ) then
		
	end
	
end

function ENT:CheckForGel( startpos, dir )

	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		ignoreworld = true,
		filter = function( ent ) if ( ent:GetClass() == "ent_gel_paint" ) then return true end end
	} )
	
	return trace
	
end

function ENT:Draw()
	
	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 1 )

	if ( SERVER ) then
	
	end 

	if ( CLIENT ) then
		
	end 
	
	return true
	
end

if ( SERVER ) then

	

end
