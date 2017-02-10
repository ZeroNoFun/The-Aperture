AddCSLuaFile( )
DEFINE_BASECLASS( "gasl_base_ent" )

ENT.PrintName		= "Button"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Int", 1, "Timer" )

end

if ( CLIENT ) then

	function ENT:Initialize() 
	
		self.BaseClass.Initialize( self )
		
	end

	function ENT:Think() 
		
	end

end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( CLIENT ) then return end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )
	
	self.GASL_EntInfo = { model = "models/wall_projector_bridge/wall.mdl", length = 200.393692, color = Color( 255, 255, 255 ) }

	self:AddOutput( "Activated", false )

	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )
	
	return true
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:ModelToInfo()

	local modelToInfo = {
		["models/props/switch001.mdl"] = { sounddown = "GASL.ButtonClick", soundup = "GASL.ButtonUp", animdown = "down", animup = "up" },
		["models/props_underground/underground_testchamber_button.mdl"] = { sounddown = "GASL.UndergroundButtonClick", soundup = "GASL.UndergroundButtonUp", animdown = "press", animup = "release" }
	}
	
	return modelToInfo[ self:GetModel() ]

end

function ENT:Use( activator, caller, usetype, val )

	if ( IsValid( caller ) && caller:IsPlayer() ) then
	
		if ( timer.Exists( "GASL_Button_Block"..self:EntIndex() ) ) then return end
		timer.Create( "GASL_Button_Block"..self:EntIndex(), 1, 1, function() end )
		
		local info = self:ModelToInfo()
		self:EmitSound( info.sounddown )
		if ( !timer.Exists( "GASL_Button_Timer"..self:EntIndex() ) ) then
				
			APERTURESCIENCE:PlaySequence( self, info.animdown, 1.0 )
			self:UpdateOutput( "Activated", true )
		end
		
		timer.Create( "GASL_Button_Timer"..self:EntIndex(), self:GetTimer(), 1, function()

			if ( IsValid( self ) ) then
				local info = self:ModelToInfo()
				
				self:EmitSound( info.soundup )
				APERTURESCIENCE:PlaySequence( self, info.animup, 1.0 )
				self:UpdateOutput( "Activated", false )
				
			end
			
		end )
		
	end
	
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	self.BaseClass.Think( self )

	return true
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle( ) ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable( ) )
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable() ) then
		self:EmitSound( "GASL.WallEmiterEnabledNoises" )
	else
		self:StopSound( "GASL.WallEmiterEnabledNoises" )
	end
	
end

-- Removing wall props
function ENT:OnRemove()

	
	
end
