AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.PrintName 		= "Pneumatic Diversity Vent"
ENT.Spawnable 		= false
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	
	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )
	
end

function ENT:ModelToFlowPos( )

	local modelToCoords = {
		["models/props_backstage/vacum_scanner_b.mdl"] = Vector( 0, -50, 0 ),
		["models/props_bts/vactube_128_straight.mdl"] = Vector( 0, 60, 0 ),
		["models/props_bts/vactube_90deg_01.mdl"] = Vector( 0, 50, -20 ),
		["models/props_bts/vactube_90deg_02.mdl"] = Vector( 0, 85, -35 ),
		["models/props_bts/vactube_90deg_03.mdl"] = Vector( 0, 140, -55 ),
		["models/props_bts/vactube_90deg_04.mdl"] = Vector( 0, 190, -80 ),
		["models/props_bts/vactube_90deg_05.mdl"] = Vector( 0, 225, -95 ),
		["models/props_bts/vactube_90deg_06.mdl"] = Vector( 0, 275, -115 ),
		["models/props_bts/vactube_tjunction.mdl"] = Vector( 0, 64, 0 ),
		["models/props_bts/vactube_crossroads.mdl"] = Vector( 0, 64, 0 ),
	}
	
	return modelToCoords[ self:GetModel() ]
	
end

if ( CLIENT ) then

	function ENT:Think()
		
	end

	function ENT:Initialize()
		
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )

	self.GASL_DIVVENT_Connections = { }
	
end

function ENT:Think()

	self:NextThink( CurTime() )
	
	if ( self:GetModel() == "models/props_backstage/vacum_scanner_b.mdl" ) then
	
		local traceHull = util.TraceHull( {
			start = self:LocalToWorld( Vector( 0, -200, 0 ) ),
			endpos = self:LocalToWorld( Vector( ) ),
			mins = Vector( -1, -1, -1 ) * 100,
			maxs = Vector( 1, 1, 1 ) * 100,
			ignoreworld = true,
			mask = MASK_SHOT_HULL,
			filter = function( ent ) 
				
				if ( !ent.GASL_Ignore && !APERTURESCIENCE.DIVVENT_ENTITIES[ ent:EntIndex() ] && ( ent:IsPlayer() || ent:IsNPC() 
						|| IsValid( ent:GetPhysicsObject() ) && ent:GetPhysicsObject():IsValid() && ent:GetPhysicsObject():IsMotionEnabled() ) ) then 
					
					table.insert( APERTURESCIENCE.DIVVENT_ENTITIES, ent:EntIndex(), ent )
					ent.GASL_ENTITY_DivventEnt = self
					
				end
			end,
		} )
	end
	
	-- skip if disabled
	if ( !self:GetEnable() ) then return end

	return true
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end
	
	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable() )
		
	else
		self:SetEnable( bDown )
	end
	
end

function ENT:OnRemove()

end
