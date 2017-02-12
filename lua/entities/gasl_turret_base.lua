AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"
ENT.AutomaticFrameAdvance = true

local TurretDeployingWidth = 9
local TurretSearthingTimeSeconds = 4.0

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "TargetEntity" )
	self:NetworkVar( "Vector", 0, "TargetEntityVector" )
	self:NetworkVar( "Bool", 1, "Activated" )
	self:NetworkVar( "Bool", 2, "CanShoot" )
	self:NetworkVar( "Bool", 3, "TotalDisable" )
	
end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:GetPhysicsObject():Wake()
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	if ( self:GetTotalDisable() ) then return end
	
	local eyePos = self:LocalToWorld( Vector( 11, 0, 36.7 ) )
	local angle = self:GetManipulateBoneAngles( 1 )
	local dir = self:LocalToWorldAngles( Angle( angle.r, angle.p, 0 ) )
	local trace = util.QuickTrace( eyePos, dir:Forward() * 1000000, self )
	
	-- laser
	if ( !self.GASL_Turret_DrawLaser ) then return end

	local points = self:GetAllPortalPassages( eyePos, dir )

	if ( table.Count( points ) > 0 ) then
		
		render.SetMaterial( Material( "effects/redlaser1" ) )
		
		for k, v in pairs( points ) do
		
			local startpos = v.startpos
			local endpos = v.endpos

			local localEndPos = self:WorldToLocal( endpos )
			
			if ( localEndPos.x > self.GASL_RenderBounds.maxs.x ) then self.GASL_RenderBounds.maxs.x = localEndPos.x end
			if ( localEndPos.y > self.GASL_RenderBounds.maxs.y ) then self.GASL_RenderBounds.maxs.y = localEndPos.y end
			if ( localEndPos.z > self.GASL_RenderBounds.maxs.z ) then self.GASL_RenderBounds.maxs.z = localEndPos.z end
			
			if ( localEndPos.x < self.GASL_RenderBounds.mins.x ) then self.GASL_RenderBounds.mins.x = localEndPos.x end
			if ( localEndPos.y < self.GASL_RenderBounds.mins.y ) then self.GASL_RenderBounds.mins.y = localEndPos.y end
			if ( localEndPos.z < self.GASL_RenderBounds.mins.z ) then self.GASL_RenderBounds.mins.z = localEndPos.z end
			
			local distance = startpos:Distance( endpos )
			render.DrawBeam( startpos, endpos, 1, distance / 100, 1, Color( 255, 255, 255 ) )
			
		end
	
	end
	
end

if( CLIENT ) then

	function ENT:TurretActivate( act )
	
		net.Start( "GASL_Turrets_Activation" )
			net.WriteEntity( self )
			net.WriteBool( act )
		net.SendToServer()
		
	end

	function ENT:Initialize()
	
		self.GASL_Turret_Deploy = 0
		self.GASL_Turret_Deployed = false
		self.GASL_Turret_Angles = Angle()
		self.GASL_Turret_EntityInView = false
		self.GASL_Turret_DrawLaser = true
		self.GASL_Turret_Sounds = { 
			deploy = "",
			retract = "",
			pickup = "",
			searth = "",
			autosearth = "",
		}
		
		self.GASL_Turret_Bones = {
			antenna = -1,
			gunLeft = -1,
			gunRight = -1,
		}
		
		local min, max = self:GetRenderBounds() 
		self.GASL_RenderBounds = { mins = min, maxs = max }
		self.GASL_UpdateRenderBounds = { mins = Vector(), maxs = Vector() }

	end

	function ENT:Think()
	
		local targetEnt = self:GetTargetEntity()
		
		self:SetRenderBounds( self.GASL_RenderBounds.mins, self.GASL_RenderBounds.maxs )
		
		-- when turret fallover
		if ( self:IsFallover() && !self:GetTotalDisable() ) then
			self:TurretFallover()
			return
		end
		
		-- When target is in the view
		if ( IsValid( targetEnt ) && !timer.Exists( "GASL_Turret_DeployAnim"..self:EntIndex() ) && !self.GASL_Turret_Deployed ) then
		
			-- Timer that make delay between closed state and opened state
			timer.Create( "GASL_Turret_DeployDelay"..self:EntIndex(), 1, 1.0, function()
				
				self:EmitSound( self.GASL_Turret_Sounds.deploy )
				self:EmitSound( "GASL.TurretDeploy" )
				timer.Create( "GASL_Turret_DeployAnim"..self:EntIndex(), 0.6, 1.0, function()
					if ( IsValid( self ) ) then
						self:TurretActivate( true )
						self:ManipulateBonePosition( self.GASL_Turret_Bones.gunLeft, Vector( -TurretDeployingWidth, 0, 0 ) )
						self:ManipulateBonePosition( self.GASL_Turret_Bones.gunRight, Vector( TurretDeployingWidth, 0, 0 ) )
						self:ManipulateBonePosition( self.GASL_Turret_Bones.antenna, Vector( 0, TurretDeployingWidth * 1.5, 0 ) )
					end
				end )
			end )
			
			self.GASL_Turret_Deployed = true
			
		elseif( !IsValid( targetEnt ) && self.GASL_Turret_Deployed
			&& !timer.Exists( "GASL_Turret_DeployAnim"..self:EntIndex() ) 
			&& !timer.Exists( "GASL_Turret_Searthing"..self:EntIndex() ) ) then
			
			-- Timer that make delay between idle state and closed state
			timer.Create( "GASL_Turret_DeployDelay"..self:EntIndex(), 2, 1.0, function()

				self:EmitSound( self.GASL_Turret_Sounds.retract )
				self:EmitSound( "GASL.TurretRetract" )
				timer.Create( "GASL_Turret_DeployAnim"..self:EntIndex(), 0.6, 1.0, function()
					if ( IsValid( self ) ) then
						self:ManipulateBonePosition( self.GASL_Turret_Bones.gunLeft, Vector( 0, 0, 0 ) )
						self:ManipulateBonePosition( self.GASL_Turret_Bones.gunRight, Vector( 0, 0, 0 ) )
						self:ManipulateBonePosition( self.GASL_Turret_Bones.antenna, Vector( 0, 0, 0 ) )
					end
				end )
			end )
			
			self:TurretActivate( false )
			self.GASL_Turret_Deployed = false
			
		end
		
		-- Deploying animation
		if ( timer.Exists( "GASL_Turret_DeployAnim"..self:EntIndex() ) ) then
		
			local deploy = self.GASL_Turret_Deploy
			if ( self.GASL_Turret_Deployed ) then
				if ( deploy <= TurretDeployingWidth ) then self.GASL_Turret_Deploy = deploy + 0.1 end
			else
				if ( deploy >= 0 ) then self.GASL_Turret_Deploy = deploy - 0.1 end
			end
			
			self:ManipulateBonePosition( self.GASL_Turret_Bones.gunLeft, Vector( -deploy, 0, 0 ) )
			self:ManipulateBonePosition( self.GASL_Turret_Bones.gunRight, Vector( deploy, 0, 0 ) )
			self:ManipulateBonePosition( self.GASL_Turret_Bones.antenna, Vector( 0, deploy * 1.5, 0 ) )
		
		end
		
		-- Target aiming
		if ( IsValid( targetEnt ) ) then
		
			if ( !timer.Exists( "GASL_Turret_DeployAnim"..self:EntIndex() )
				&& !timer.Exists( "GASL_Turret_DeployDelay"..self:EntIndex() ) ) then
			
				-- Timer that represent how long turret will searth for tarrget when it enabled
				timer.Create( "GASL_Turret_Searthing"..self:EntIndex(), TurretSearthingTimeSeconds, 1.0, function() end )

				local targetPos = Vector()
				if ( self:GetTargetEntityVector() != Vector() ) then
					targetPos = self:GetTargetEntityVector()
				else
					targetPos = targetEnt:GetPos()
				end

				local angle = ( targetPos - self:GetPos() ):Angle()
				angle = self:WorldToLocalAngles( angle )
				//angle = Angle( math.max( -45, math.min( 45, angle.p ) ), math.max( -45, math.min( 45, angle.y ) ), 0 )

				self.GASL_Turret_Angles = Angle( angle.y, angle.r, angle.p )
			end
			
			self.GASL_Turret_EntityInView = true
	
		else
			
			if ( self.GASL_Turret_EntityInView ) then
				self.GASL_Turret_EntityInView = false
				self:EmitSound( self.GASL_Turret_Sounds.searth )
			end
			
			-- Target searthing animation
			if ( timer.Exists( "GASL_Turret_Searthing"..self:EntIndex() ) ) then
				self.GASL_Turret_Angles = Angle( math.cos( CurTime() * 3 ) * 45, 0, math.sin( CurTime() * 2 ) * 30 )
				
				if ( !timer.Exists( "GASL_Turret_SearthingPing"..self:EntIndex() ) ) then
					timer.Create( "GASL_Turret_SearthingPing"..self:EntIndex(), 1.0, 1, function() end )
					self:EmitSound( "GASL.TurretPing" )
				end
				
			else
				self.GASL_Turret_Angles = Angle( 0, 0, 0 )
			end
		
		end

		local gunsAimingAngle = self:GetManipulateBoneAngles( 1 )
		local offsetAngle = ( self.GASL_Turret_Angles - gunsAimingAngle )
		local speedDiv = 20
		
		if ( IsValid( targetEnt ) 
				&& !timer.Exists( "GASL_Turret_DeployAnim"..self:EntIndex() )
					&& !timer.Exists( "GASL_Turret_DeployDelay"..self:EntIndex() ) ) then
			
			-- increesing turing speed
			speedDiv = 2
			
		end
		
		offsetAngle = Angle( offsetAngle.p / speedDiv , offsetAngle.y / speedDiv , offsetAngle.r / speedDiv )
		self:ManipulateBoneAngles( 1, gunsAimingAngle + offsetAngle )
		
	end
	
	function ENT:OnRemove()
		timer.Remove( "GASL_Turret_TotalDisableIn"..self:EntIndex() )
		timer.Remove( "GASL_Turret_DeployDelay"..self:EntIndex() )
		timer.Remove( "GASL_Turret_DeployAnim"..self:EntIndex() )
		timer.Remove( "GASL_Turret_Searthing"..self:EntIndex() )
		timer.Remove( "GASL_Turret_SearthingPing"..self:EntIndex() )
	end
	
end

function ENT:IsFallover()
	
	if ( !IsValid( self ) ) then return end
	
	local angle = self:GetAngles()
	return ( ( angle.r > 50 || angle.r < -50 ) || ( angle.p > 40 || angle.p < -40 ) )
end

function ENT:TurretFallover()

	if ( CLIENT ) then
	
		self:ManipulateBonePosition( self.GASL_Turret_Bones.gunLeft, Vector( -TurretDeployingWidth, 0, 0 ) )
		self:ManipulateBonePosition( self.GASL_Turret_Bones.gunRight, Vector( TurretDeployingWidth, 0, 0 ) )
		self:ManipulateBonePosition( self.GASL_Turret_Bones.antenna, Vector( 0, TurretDeployingWidth * 1.5, 0 ) )
		self:ManipulateBoneAngles( 1, Angle( math.cos( CurTime() * 10 ) * 20, 0, math.sin( CurTime() * 20 ) * 40 ) )
		timer.Create( "GASL_Turret_DeployAnim"..self:EntIndex(), 1, 1.0, function() end )
		self.GASL_Turret_Deploy = TurretDeployingWidth
	end
	
	if ( SERVER ) then

		self:TurretShoot( ( Vector( 2, 0, 0 ) + VectorRand() ):Angle() )
		self:SetTargetEntity( NULL )
		
		if ( !timer.Exists( "GASL_Turret_TotalDisableIn"..self:EntIndex() ) ) then
			timer.Create( "GASL_Turret_TotalDisableIn"..self:EntIndex(), 3, 1.0, function()
				if ( IsValid( self ) ) then self:SetTotalDisable( true ) end
			end )
		end
	
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
end

function ENT:FindClosestEntityThrowPortal( pos, ang, distance, isportal )

	local findEnts = ents.FindInSphere( pos, distance ) 
	
	local closest = -1
	
	local closestEnt = NULL
	local angleDir = Angle()
	local dirThrowPortal = Vector()
	
	for _, ent in pairs( findEnts ) do

		local angle = ( ent:GetPos() - pos ):Angle()
		local _, angle = WorldToLocal( pos, ang, Vector(), angle )
		
		if ( ( ( ent:IsNPC() || ent:IsPlayer() ) && ent:Health() > 0 || ent:GetClass() == "prop_portal" )
			&& ( angle.p > -45 && angle.p < 45 ) 
			&& ( angle.y > -45 && angle.y < 45 ) ) then
			
			-- getting center pos
			local centerPos = Vector()
			if ( ent:GetClass() == "prop_portal" ) then
				centerPos = ent:GetPos()
			else
				centerPos = ent:GetPos()
			end

			local trace = util.TraceLine( {
				start = pos,
				endpos = centerPos,
				filter = function( ent ) if ( ent:IsPlayer() || ent:IsNPC() || ent:GetClass() == "prop_portal" || ent:GetModel() == "models/wall_projector_bridge/wall.mdl" ) then return false end end
			} )
			
			-- If tracer hit something skip this tick
			if ( trace.Hit ) then continue end
			
			if ( ent:GetClass() == "prop_portal"
				&& IsValid( ent:GetNWBool( "Potal:Other" ) ) ) then
			
				-- geting portal exit
				local exitPortal = ent:GetNWBool( "Potal:Other" )
				local distPosToPortal = centerPos:Distance( pos )
				local angleToPortal = ( centerPos - pos ):Angle()
				angleToPortal = ent:WorldToLocalAngles( angleToPortal )
				angleToPortal = exitPortal:LocalToWorldAngles( angleToPortal + Angle( 0, 180, 0 ) )
				
				-- recursion method to find nearest alive entity even throw portal
				local clstEnt, angDir, clst, dirTrowPortal = self:FindClosestEntityThrowPortal( exitPortal:GetPos(), angleToPortal, distance - distPosToPortal, true )
				if ( ( distPosToPortal + clst ) < closest || closest == -1 ) then
					closestEnt = clstEnt
					closest = distPosToPortal + clst
					angleDir = angDir
					
					-- converting from portal that receved vector to local portal
					dirTrowPortal = exitPortal:WorldToLocal( dirTrowPortal )
					dirTrowPortal:Rotate( Angle( 0, 180, 0 ) )
					dirTrowPortal = ent:LocalToWorld( dirTrowPortal )
					
					dirThrowPortal = dirTrowPortal
				end
			
			elseif ( centerPos:Distance( self:GetPos() ) < closest || closest == -1 ) then
				dirThrowPortal = Vector()
				closest = centerPos:Distance( self:GetPos() )
				closestEnt = ent
				angleDir = angle
				
				if ( isportal ) then
					-- converting vector to local portal vector
					dirThrowPortal = centerPos
					
				end
				
			end
			
		end
	
	end
	
	return closestEnt, -angleDir, closest, dirThrowPortal
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if ( self:GetTotalDisable() ) then return end
	
	local closestEnt, angleDir, _, dirThrowPortal = self:FindClosestEntityThrowPortal( self:GetPos(), self:GetAngles(), 1000.0 )
	local eyePos = self:LocalToWorld( Vector( 11, 0, 36.7 ) )
	local eyeAngDir = self:LocalToWorldAngles( angleDir ):Forward()
	
	local trace = util.QuickTrace( eyePos, eyeAngDir * 1100, self )
	
	if ( IsValid( closestEnt )
		&& self:GetActivated() && ( !IsValid( trace.Entity ) || IsValid( trace.Entity ) && trace.Entity:GetModel() != "models/wall_projector_bridge/wall.mdl" ) ) then
		
			if ( dirThrowPortal != Vector() ) then
				angleDir = self:WorldToLocalAngles( ( dirThrowPortal - self:GetPos() ):Angle() )
			end

		self:TurretShoot( angleDir )
		
	end
	
	if ( self:GetTargetEntity() != closestEnt 
		|| self:GetTargetEntityVector() != dirThrowPortal ) then
		
		self:SetTargetEntity( closestEnt )
		self:SetTargetEntityVector( dirThrowPortal )
		
	end

	-- when turret fallover
	local angle = self:GetAngles()
	if ( self:IsFallover() ) then
		self:TurretFallover()
	elseif( timer.Exists( "GASL_Turret_TotalDisableIn"..self:EntIndex() ) ) then
		timer.Remove( "GASL_Turret_TotalDisableIn"..self:EntIndex() )
	end
	
	return true
	
end

function ENT:TurretShoot( localAngle )

	if ( !self:GetCanShoot() ) then
		if ( !timer.Exists( "GASL_Turret_DryfireDelay"..self:EntIndex() ) ) then
			timer.Create( "GASL_Turret_DryfireDelay"..self:EntIndex(), 1, 1, function() end )
			
			self:EmitSound( "GASL.TurretDryFire" )
		end
		
		return
	end
		
	local direction = self:LocalToWorldAngles( localAngle ):Forward()
	self:EmitSound( "GASL.TurretShoot" )
	
	-- left effect
	local offsetGunLeft = Vector( 10, 10, 0 )
	offsetGunLeft:Rotate( self:LocalToWorldAngles( Angle( localAngle.p, localAngle.y, 0 ) ) )
	self:TurretMuzzleEffect( self:LocalToWorld( Vector( 5, 0, 37 ) ) + offsetGunLeft, direction )

	-- right effect
	local offsetGunLeft = Vector( 10, -10, 0 )
	offsetGunLeft:Rotate( self:LocalToWorldAngles( Angle( localAngle.p, localAngle.y, 0 ) ) )
	self:TurretMuzzleEffect( self:LocalToWorld( Vector( 5, 0, 37 ) ) + offsetGunLeft, direction )
	
	self:TurretShootBullets( self:LocalToWorld( Vector( 5, 0, 30 ) ), direction )
	for i = 0, 2 do
		timer.Simple( i / 10, function()
			if( !IsValid( self ) ) then return end
			self:TurretShootBullets( self:LocalToWorld( Vector( 5, 0, 30 ) ), direction )
		end )
	end
	
end

function ENT:TurretMuzzleEffect( startpos, dir )
	
	local vPoint = Vector( 0, 0, 0 )
	local effectdata = EffectData()
	effectdata:SetOrigin( startpos )
	effectdata:SetNormal( dir )
	util.Effect( "turret_muzzle", effectdata )	

end

function ENT:TurretShootBullets( startpos, dir )

	self:FireBullets( {
	Attacker = self,
	Damage = 7,
	Force = 1,
	Dir = dir,
	Spread = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 0.05,
	Src = startpos,
	}, false )
	
end

net.Receive( "GASL_Turrets_Activation", function( len, pl )

	local mEnt = net.ReadEntity()
	local mAct = net.ReadBool()
	
	if ( !IsValid( mEnt ) || mAct == nil ) then return end
	mEnt:SetActivated( mAct )
	
end )
