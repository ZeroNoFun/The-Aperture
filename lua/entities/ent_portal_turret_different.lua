AddCSLuaFile( )

ENT.Base 			= "gasl_turret_base"

ENT.PrintName		= "Different Turret"
ENT.Category		= "Aperture Science"
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:PostEntityPaste( ply, ent )

	ent:SetOwner( ply )
	
end

if ( CLIENT ) then
	
	function ENT:Initialize()
	end
	
	function ENT:Think()		
	end

	-- no more client side
	return
	
end

function ENT:Initialize()

	self:SetModel( "models/npcs/turret/turret.mdl" )
	self.BaseClass.Initialize( self )
	self.GASL_Turret_Opera = { }
	
	self:EmitSound( "GASL.TurretDifferent" )

end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	if ( !self.GASL_Turret_Opera ) then return end
	
	if ( table.Count( self.GASL_Turret_Opera ) < 4 ) then

		-- random turret truth
		if ( !timer.Exists( "GASL_Turret_TurretThruth" ) ) then
			timer.Create( "GASL_Turret_TurretThruth", 10.0, 1, function() end )
			
			self:EmitSound( "GASL.TurretThruth" )
		end
		
		local findResult = ents.FindInSphere( self:GetPos(), 200 )
		
		for k, turret in pairs( findResult ) do
			
			if ( turret:GetClass() == "ent_portal_turret_different" && turret.GASL_Turret_Opera 
				&& !turret:IsFallover() ) then
			
				if ( table.Count( turret.GASL_Turret_Opera ) < 4 ) then
					self.GASL_Turret_Opera[ turret:EntIndex() ] = turret
				end
				
				if ( table.Count( turret.GASL_Turret_Opera ) > table.Count( self.GASL_Turret_Opera )
					&& !turret.GASL_Turret_OperaAnimInx ) then
					self.GASL_Turret_Opera = turret.GASL_Turret_Opera
				end
				
			end

		end
		
	end
		
	-- if any turret is missing stop sining
	for k, turret in pairs( self.GASL_Turret_Opera ) do
		if ( !IsValid( turret ) || turret:IsFallover() ) then
			self.GASL_Turret_Opera[ k ] = nil
			self:StopSing()
		end
	end
	
	-- if turret fallover stop sining
	if ( self:IsFallover() && self.GASL_Turret_OperaAnimInx ) then
		for k, turret in pairs( self.GASL_Turret_Opera ) do
			if ( !IsValid( turret ) ) then continue end
			
			turret:StopSing()
			turret.GASL_Turret_Opera[ self:EntIndex() ] = nil
			turret.GASL_Turret_Opera_Song = false
		end
		
		self:StopSing()
		self.GASL_Turret_Opera_Song = false
	end
	
	if ( table.Count( self.GASL_Turret_Opera ) == 4 ) then
		
		if ( !self.GASL_Turret_OperaAnimInx && !timer.Exists( "GASL_Turret_SingDelay"..self:EntIndex() ) ) then
			timer.Create( "GASL_Turret_SingDelay"..self:EntIndex(), 2, 1, function()
				if ( IsValid( self ) ) then self:SingInit() end
			end )
		end
		
	end
	
	return true
	
end

function ENT:SingInit()

	if ( !IsValid( self ) ) then return end

	local centerPos = Vector()
	
	local animInx = 1
	local playSong = true
	-- Getting unique anim index
	for k, turret in pairs( self.GASL_Turret_Opera ) do
	
		if ( !IsValid( turret ) ) then return end
		if ( turret.GASL_Turret_OperaAnimInx ) then animInx = animInx + 1 end
		if ( turret.GASL_Turret_Opera_Song ) then playSong = false end
	end

	self.GASL_Turret_OperaAnimInx = true
	
	APERTURESCIENCE:PlaySequence( self, "idle", 0.0 )
	
	if ( IsValid( self:GetOwner() ) ) then
		-- Achievement System
		APERTURESCIENCE:GiveAchievement( self:GetOwner(), 1 )
	end
	
	if ( animInx == 1 ) then APERTURESCIENCE:PlaySequence( self, "3penny_hi", 1.0 )
	elseif ( animInx == 2 ) then APERTURESCIENCE:PlaySequence( self, "3penny_lo", 1.0 )
	elseif ( animInx == 3 ) then APERTURESCIENCE:PlaySequence( self, "3penny_mid", 1.0 )
	elseif ( animInx == 4 ) then APERTURESCIENCE:PlaySequence( self, "3penny_perc", 1.0 ) end

	if ( playSong ) then
		self.GASL_Turret_Opera_Song = true
		self:EmitSound( "GASL.TurretSong" )
	end
	
end

function ENT:StopSing()

	timer.Remove( "GASL_Turret_SingDelay"..self:EntIndex() )
	APERTURESCIENCE:PlaySequence( self, "idle", 1.0 )
	self.GASL_Turret_OperaAnimInx = false
	self:StopSound( "GASL.TurretSong" )
	
end

function ENT:OnRemove()

	timer.Remove( "GASL_Turret_SingDelay"..self:EntIndex() )
	self:StopSound( "GASL.TurretSong" )

	for k, turret in pairs( self.GASL_Turret_Opera ) do
		if ( !IsValid( turret ) ) then continue end
		
		turret.GASL_Turret_Opera[ self:EntIndex() ] = nil
		turret.GASL_Turret_Opera_Song = false
		turret:StopSing()
	end
	
end
