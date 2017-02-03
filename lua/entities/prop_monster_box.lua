AddCSLuaFile( )

ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Frankenturret"
ENT.Category		= "Aperture Science"
ENT.Spawnable 		= true
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 30 )
	ent:SetAngles( Angle( 0, ply:EyeAngles().y, 0) )
	ent:Spawn()
	
	for k, v in pairs( ent:GetBodyGroups() ) do
		if ( math.random( 0, 1 ) == 1 ) then ent:SetBodygroup( v.id, 1 ) end
	end

	if ( trace.Entity:IsValid() ) then

		ent:SetParent( trace.Entity )
		
	end

	return ent

end

function ENT:Initialize()

	if ( SERVER ) then
		
		self:SetModel( "models/npcs/monsters/monster_a.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
	end

	if ( CLIENT ) then
	
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	local trace = util.QuickTrace( self:GetPos() + self:GetForward() * 20, -self:GetUp() * 50, self )
	
	-- random chitter sounds
	if ( !timer.Exists( "GASL_Monsterbox_chitter"..self:EntIndex() ) ) then 
		timer.Create( "GASL_Monsterbox_chitter"..self:EntIndex(), math.Rand( 1, 3 ), 1, function() end )
		
		self:EmitSound( "GASL.MonsterBoxChitter" )
	end
	
	local traceDown = util.QuickTrace( self:GetPos(), -Vector( 0, 0, 50 ), self )
	-- When player is holding or it stand on the button transform into a cube mode
	if ( self:IsPlayerHolding() || ( traceDown.Entity:IsValid()
		&& ( traceDown.Entity:GetClass() == "sent_portalbutton_box"
		|| traceDown.Entity:GetClass() == "sent_portalbutton_normal"
		|| traceDown.Entity:GetClass() == "sent_portalbutton_old"
		|| traceDown.Entity:GetClass() == "portalbutton_phys" ) ) ) then
		
		if ( !timer.Exists( "GASL_Monsterbox_hermit"..self:EntIndex() ) ) then 
			timer.Create( "GASL_Monsterbox_hermit"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "hermit_idle", 1.0 ), 1, function() end )
		end
		
		return true
		
	end
	
	if ( self.GASL_TractorBeamEnter ) then
	
		if ( !timer.Exists( "GASL_Monsterbox_intheair"..self:EntIndex() ) ) then 
			timer.Create( "GASL_Monsterbox_intheair"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "intheair", 1.0 ), 1, function() end )
		end

		return true		
	
	end
	
	if ( !trace.Hit ) then
	
		if ( !timer.Exists( "GASL_Monsterbox_fallover"..self:EntIndex() ) ) then 
			timer.Create( "GASL_Monsterbox_fallover"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "fallover_idle", 1.0 ), 1, function() end )
		end
		
		if ( timer.Exists( "GASL_Monsterbox_trapped"..self:EntIndex() ) ) then
			timer.Remove( "GASL_Monsterbox_trapped"..self:EntIndex() )
		end
		
		return true
		
	else
	
		local traceForward = util.QuickTrace( self:GetPos(), self:GetForward() * 60, self )

		if ( traceForward.Hit ) then
			
			if ( !timer.Exists( "GASL_Monsterbox_trapped"..self:EntIndex() ) ) then 
				timer.Create( "GASL_Monsterbox_trapped"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "trapped", 1.0 ), 0, function() end )
			end
			
			return true
			
		elseif ( timer.Exists( "GASL_Monsterbox_trapped"..self:EntIndex() ) ) then
			timer.Remove( "GASL_Monsterbox_trapped"..self:EntIndex() )
		end
		
	end
	
	if ( !timer.Exists( "GASL_Monsterbox_straight"..self:EntIndex() ) ) then 
		local animType = math.random( 1, 3 )
		
		timer.Create( "GASL_Monsterbox_straight"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "straight0"..animType, 1.0 ), 1, function() end )

		if ( animType == 1 ) then
			timer.Simple( 0.25, function() if ( self:IsValid() ) then self:Jump( 100, 100 ) end end )
			timer.Simple( 1.5, function() if ( self:IsValid() ) then self:Jump( 100, 100 ) end end )
		end
		
		if ( animType == 2 ) then
			timer.Simple( 0, function() if ( self:IsValid() ) then self:Jump( 100, 100 ) end end )
			timer.Simple( 0.5, function() if ( self:IsValid() ) then self:Jump( 80, 100 ) end end )
			timer.Simple( 1.2, function() if ( self:IsValid() ) then self:Jump( 80, 85 ) end end )
		end

		if ( animType == 3 ) then
			timer.Simple( 0.25, function() if ( self:IsValid() ) then self:Jump( 150, 100 ) end end )
		end

	end

	return true
	
end

function ENT:Jump( force, forceUp )

	-- skip if it trapped or player is holding it
	if ( timer.Exists(  "GASL_Monsterbox_trapped"..self:EntIndex() ) || self:IsPlayerHolding() ) then return end
	
	self:GetPhysicsObject():SetVelocity( self:GetForward() * force + Vector( 0, 0, forceUp ) )
	self:EmitSound( "GASL.MonsterBoxKick" )
	
	timer.Simple( 0.25, function()
		if ( self:IsValid() ) then self:EmitSound( "GASL.MonsterBoxFootsteps" ) end
	end )
	
end

function ENT:OnRemove()

	timer.Remove( "GASL_Monsterbox_trapped"..self:EntIndex() )
	
end
