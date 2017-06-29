AddCSLuaFile( )

DEFINE_BASECLASS("base_aperture_ent")

ENT.FUNNEL_MOVE_SPEED = 173
ENT.FUNNEL_COLOR = Color(0, 150, 255)
ENT.FUNNEL_REVERSE_COLOR = Color(255, 150, 0)
ENT.FUNNEL_WITDH = 60

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Reverse")
	self:NetworkVar("Bool", 1, "Enable")
	self:NetworkVar("Bool", 2, "StartEnabled")
	self:NetworkVar("Bool", 3, "StartReversed")
end

function ENT:Initialize()

	self.BaseClass.Initialize(self)
	
	if SERVER then
		self:SetModel("models/aperture/tractor_beam.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		
		self.TA_TractorBeamLeavedEntities = {}
		
		-- self:AddInput("Enable", function(value) self:ToggleEnable(value) end)
		-- self:AddInput("Reverse", function(value) self:ToggleReverse(value) end)
		self:SetEnable(true)
		self.TA_FunnelUpdate = {}
		
		if not WireAddon then return end
		self.Inputs = Wire_CreateInputs(self, {"Enable", "Reverse"})
	end

	if CLIENT then
		self.BaseRotation = 0
		self.FieldEffects = {}
		
		if not self:GetStartEnabled() then
			--APERTURESCIENCE:PlaySequence( self, "tractor_beam_idle", 1.0 )
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Drawing()

	-- Skipping tick if it disabled
	if not self:GetEnable() then return end

	local reverse = self:GetReverse()
	local color = reverse and self.FUNNEL_REVERSE_COLOR or self.FUNNEL_COLOR
	local dir = reverse and -1 or 1
	local material = reverse and Material("effects/particle_ring_pulled_add_oriented_reverse") or Material("effects/particle_ring_pulled_add_oriented")

	render.SuppressEngineLighting(true) 
	render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
	if self.FieldEffects then
		for k,v in pairs(self.FieldEffects) do v:DrawModel() end
	end
	render.SuppressEngineLighting(false) 
	render.SetColorModulation(1, 1, 1)

	local TA_FunnelWidth = 60
	
	-- Tractor beam particle effect 
	local ParticleEffectWidth = 40
	local RotationMultiplier = 2.5
	local QuadRadius = 140

	local tractorBeamTrace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(0, 0, 1000000)),
		filter = function(ent)
			if ent == self or ent:GetClass() == "prop_portal" or ent:IsPlayer() or ent:IsNPC() then return false end
		end
	} )
	local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )

	-- if CurTime() > self.TA_ParticleEffectTime then
		-- self.TA_ParticleEffectTime = CurTime() + 0.1
		
		-- for i = 0,1,0.1 do 
			-- for k = 1,3 do 
				-- local cossinValues = CurTime() * RotationMultiplier * dir + ((math.pi * 2) / 3) * k
				-- local multWidth = i * ParticleEffectWidth
				-- local localVec = Vector(math.cos(cossinValues) * multWidth, math.sin(cossinValues) * multWidth, 30)
				-- local particlePos = self:LocalToWorld( localVec ) + VectorRand() * 5
				
				-- local p = self.TA_ParticleEffect:Add("sprites/light_glow02_add", particlePos)
				-- p:SetDieTime(math.random( 1, 2 ) * ((0 - i) / 2 + 1))
				-- p:SetStartAlpha( math.random( 0, 50 ) ) 
				-- p:SetEndAlpha( 255 )
				-- p:SetStartSize( math.random( 10, 20 ) )
				-- p:SetEndSize( 0 )
				-- p:SetVelocity( self:GetUp() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * dir + VectorRand() * 5 )
				-- p:SetGravity( VectorRand() * 5 )
				-- p:SetColor( color.r, color.g, color.b )
				-- p:SetCollide( true )
			-- end
		-- end

		-- for repeats = 1, 2 do
			
			-- local randDist = math.min( totalDistance - TA_FunnelWidth, math.max( TA_FunnelWidth, math.random( 0, totalDistance ) ) )
			-- local randVecNormalized = VectorRand()
			-- randVecNormalized:Normalize()
			
			-- local particlePos = self:LocalToWorld( Vector( 0, 0, randDist ) + randVecNormalized * TA_FunnelWidth )
			
			-- local p = self.TA_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
			-- p:SetDieTime( math.random( 3, 5 ) )
			-- p:SetStartAlpha( math.random( 200, 255 ) )
			-- p:SetEndAlpha( 0 )
			-- p:SetStartSize( math.random( 5, 10 ) )
			-- p:SetEndSize( 0 )
			-- p:SetVelocity( self:GetUp() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * 4 * dir )
			
			-- p:SetColor( color.r, color.g, color.b )
			-- p:SetCollide( true )
			
		-- end
	-- end

	render.SetMaterial( material )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir + 120 )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir * 2 )

end

if CLIENT then

	function ENT:OnRemove()
		for k, v in pairs(self.FieldEffects) do v:Remove() end
	end

	function ENT:Think()			

		--self.BaseClass.Think( self )
		local reverse = self:GetReverse()
		local color = reverse and self.FUNNEL_REVERSE_COLOR or self.FUNNEL_COLOR
		local dir = reverse and -1 or 1
		local angle = reverse and -90 or 90
		local offset = reverse and 320 or 0

		-- local tractorBeamTrace = util.TraceLine( {
			-- start = self:GetPos(),
			-- endpos = self:LocalToWorld( Vector( 0, 0, 1000000 ) ),
			-- filter = function( ent )
				-- if ( ent == self or ent:GetClass() == "prop_portal" or ent:IsPlayer() or ent:IsNPC() ) then
					-- return false end
			-- end
		-- } )
		-- local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )
		
		local passagesPoints = LIB_APERTURE:GetAllPortalPassages(self:GetPos(), self:GetForward(), nil, self)
		
		local requireToSpawn = table.Count(passagesPoints)
		for k,v in pairs(passagesPoints) do
			requireToSpawn = requireToSpawn + math.floor(v.startpos:Distance(v.endpos) / 320)
		end

		if table.Count(self.FieldEffects) != requireToSpawn or !self:GetEnable() then
			for k, v in pairs(self.FieldEffects) do v:Remove() end
			self.FieldEffects = { }
		end
		
		if self:GetEnable() then
			local itterator = 0
			for k,v in pairs(passagesPoints) do
				local direction = (v.endpos - v.startpos):GetNormalized()
				local _, angles = LocalToWorld(Vector(), Angle(angle, 0, 0), Vector(), v.angles)
				
				for i = 0,v.startpos:Distance(v.endpos), 320 do
					itterator = itterator + 1
					
					if table.Count(self.FieldEffects) != requireToSpawn then
						local c_Model = ClientsideModel("models/aperture/effects/tractor_beam_field_effect.mdl")
						c_Model:SetPos(v.startpos + (i + offset) * direction)
						c_Model:SetAngles(angles)
						c_Model:SetNoDraw(true)
						c_Model:Spawn()
						table.insert(self.FieldEffects, table.Count(self.FieldEffects) + 1, c_Model)
					else
						local c_Model = self.FieldEffects[itterator]
						c_Model:SetPos(v.startpos + (i + offset) * direction)
						c_Model:SetAngles(angles)
					end
				end
			end
			
			self.BaseRotation = self.BaseRotation + FrameTime() * dir * 150
			if self.BaseRotation > 360 then self.BaseRotation = self.BaseRotation - 360 end
			if self.BaseRotation < -360 then self.BaseRotation = self.BaseRotation + 360 end
			self:ManipulateBoneAngles(1, Angle(self.BaseRotation, 0, 0))
			self:ManipulateBoneAngles(10, Angle(self.BaseRotation, 0, 0))
			self:ManipulateBoneAngles(17, Angle(self.BaseRotation, 0, 0))
			self:ManipulateBoneAngles(9, Angle(self.BaseRotation, 0, 0)) 
			self:ManipulateBoneAngles(8, Angle(self.BaseRotation * 2, 0, 0)) -- center
		end
	end
	
	return true
end


function ENT:Think()

	self:NextThink(CurTime())
	local reverse = self:GetReverse()
	local color = reverse and self.FUNNEL_REVERSE_COLOR or self.FUNNEL_COLOR
	local dir = reverse and -1 or 1
	local angle = reverse and -90 or 90
	
	self.BaseClass.Think( self )
	
	-- Skip this tick if exursion funnel is disabled and removing effect if possible
	if not self:GetEnable() then
		-- if self.TA_FunnelUpdate.lastPos != Vector() or self.TA_FunnelUpdate.lastAngle != Angle() then
			-- self.TA_FunnelUpdate.lastPos = Vector()
			-- self.TA_FunnelUpdate.lastAngle = Angle()
				
			-- -- Removing effects
			-- self:SetupTrails( )
		-- end

		return
	end
	
	local passagesPoints = LIB_APERTURE:GetAllPortalPassages(self:GetPos(), self:GetForward(), nil, self)
	local handleEntities = { }
	
	for k, v in pairs(passagesPoints) do
		
		local tractorBeamHullFinder = util.TraceHull({
			start = v.startpos,
			endpos = v.endpos,
			ignoreworld = true,
			filter = function(ent)
				if ent == self then return false end
				if not ent.TA_Ignore and (ent:GetClass() == "prop_portal" or ent:IsPlayer() or ent:IsNPC() 
						or IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled()) then 
					table.insert( handleEntities, ent:EntIndex(), ent )
					ent.TA_TravelingInBeamDir = ( v.endpos - v.startpos ):GetNormalized()
					ent.TA_TravelingInBeamPos = v.startpos
					
					return false
				end
				
				return true
			end,
			mins = -Vector(1, 1, 1) * self.FUNNEL_WITDH,
			maxs = Vector(1, 1, 1) * self.FUNNEL_WITDH,
			mask = MASK_SHOT_HULL
		})
	end
	
	-- Handling entities in field 
	for k,v in pairs(handleEntities) do
	
		if not IsValid( v ) then continue end
		
		-- Removing entity from table if it still in funnel
		self.TA_TractorBeamLeavedEntities[k] = nil
		
		local centerPos = IsValid(v:GetPhysicsObject()) and v:LocalToWorld(v:GetPhysicsObject():GetMassCenter()) or v:GetPos()
		local paintBarrerRollValue = CurTime() * 4 + v:EntIndex() * 10
		local offset = v:GetClass() == "ent_paint_puddle" and Vector(0, math.cos(paintBarrerRollValue), math.sin(paintBarrerRollValue)) * 50 or Vector()
		-- Getting 2d dir to closest point to tractor beam
		local WTL = WorldToLocal(centerPos, Angle(), v.TA_TravelingInBeamPos, v.TA_TravelingInBeamDir:Angle())
		WTL = Vector(WTL.x, 0, 0)
		
		local min, max = v:WorldSpaceAABB()
		local entRadius = min:Distance(max) / 3
		
		local LTW = LocalToWorld(WTL, Angle(), v.TA_TravelingInBeamPos, v.TA_TravelingInBeamDir:Angle())
		local tractorBeamMovingSpeed = self.FUNNEL_MOVE_SPEED * dir

		-- Handling entering into Funnel
		if not v.TA_TractorBeamEnter then
			v.TA_TractorBeamEnter = true
			
			if v:IsPlayer() or v:IsNPC() then
				if v:IsPlayer() then v:EmitSound( "TA.TractorBeamEnter" ) end
			elseif IsValid(v:GetPhysicsObject()) then
				local vPhysObject = v:GetPhysicsObject()
				vPhysObject:EnableGravity(false)
			end
		end
		
		if v:IsPlayer() or v:IsNPC() then
			if v:IsPlayer() then
				-- Player moving while in the funnel
				local movingDir = Vector()
				
				if v:KeyDown(IN_FORWARD) then movingDir = movingDir + Vector(1, 0, 0) end
				if v:KeyDown(IN_BACK) then movingDir = movingDir - Vector(1, 0, 0) end
				if v:KeyDown(IN_MOVELEFT) then movingDir = movingDir + Vector(0, 1, 0) end
				if v:KeyDown(IN_MOVERIGHT) then movingDir = movingDir - Vector(0, 1, 0) end
				
				-- Slowdown player in the funnel when they moving
				if ( v:KeyDown( IN_FORWARD ) 
					or v:KeyDown( IN_BACK ) 
					or v:KeyDown( IN_MOVERIGHT ) 
					or v:KeyDown( IN_MOVELEFT ) ) then
					tractorBeamMovingSpeed = 0
				end

				-- Removing player forward/back funnel moving possibilities
				local ply_moving = movingDir * 100
				ply_moving:Rotate(v:EyeAngles())
				
				local ply_moving_cutted_local = WorldToLocal( v.TA_TravelingInBeamPos + ply_moving, Angle( ), v.TA_TravelingInBeamPos, v.TA_TravelingInBeamDir:Angle() )
				ply_moving_cutted_local = Vector( 0, ply_moving_cutted_local.y, ply_moving_cutted_local.z )
				local ply_moving = LocalToWorld( ply_moving_cutted_local, Angle( ), v.TA_TravelingInBeamPos, v.TA_TravelingInBeamDir:Angle() ) - v.TA_TravelingInBeamPos
				
				local vPhysObject = v:GetPhysicsObject()
				
				v:SetVelocity(v.TA_TravelingInBeamDir * tractorBeamMovingSpeed + (LTW - centerPos + ply_moving) * 2 - v:GetVelocity())
			else
				v:SetVelocity(v.TA_TravelingInBeamDir * tractorBeamMovingSpeed + (LTW - centerPos) * 2 - v:GetVelocity())
			end
			
		elseif IsValid(v:GetPhysicsObject()) then
			local vPhysObject = v:GetPhysicsObject()
			offset:Rotate( v.TA_TravelingInBeamDir:Angle() )
			vPhysObject:SetVelocity(v.TA_TravelingInBeamDir * tractorBeamMovingSpeed + offset + (LTW - (centerPos + vPhysObject:GetMassCenter())) - v:GetVelocity() / 10)
		end
	end
	
	self:CheckForLeave()
	self.TA_TractorBeamLeavedEntities = handleEntities		
	
	local color = self:GetReverse() and self.FUNNEL_REVERSE_COLOR or self.FUNNEL_COLOR
	local angle = self:GetReverse() and -1 or 1
	local adding = self:GetReverse() and 320 or 0
	
	-- Handling changes position or angles
	if self.TA_FunnelUpdate.lastPos != self:GetPos() or self.TA_FunnelUpdate.lastAngle != self:GetAngles() then
		self.TA_FunnelUpdate.lastPos = self:GetPos()
		self.TA_FunnelUpdate.lastAngle = self:GetAngles()
		self:SetupTrails()
	end

	return true
end

function ENT:CheckForLeave()

	if not self.TA_TractorBeamLeavedEntities then return end
	
	for k,v in pairs(self.TA_TractorBeamLeavedEntities) do
		if not IsValid(v) then break end
		
		if v:IsPlayer() or v:IsNPC() then
			if v:IsPlayer() then
				v:StopSound("TA.TractorBeamEnter")
			end
		else v:GetPhysicsObject():EnableGravity(true) end
		
		v.TA_TractorBeamEnter = false
	end
end

function ENT:SetupTrails()
	
	local trailWidth = 150
	local trailWidthEnd = 0
	
	if IsValid(self.TA_Trail1) then self.TA_Trail1:Remove() end
	if IsValid(self.TA_Trail2) then self.TA_Trail2:Remove() end
	if IsValid(self.TA_Trail3) then self.TA_Trail3:Remove() end
	
	if self:GetEnable() then
		local reverse = self:GetReverse()
		local color = reverse and self.FUNNEL_REVERSE_COLOR or self.FUNNEL_COLOR
		local material = reverse and "trails/beam_hotred_add_oriented.vmt" or "trails/beam_hotblue_add_oriented.vmt"
		
		self.TA_Trail1 = util.SpriteTrail(self, 1, color, false, trailWidth, trailWidthEnd, 1, 1 / ( trailWidth + trailWidthEnd ) * 0.5, material)
		self.TA_Trail2 = util.SpriteTrail(self, 3, color, false, trailWidth, trailWidthEnd, 1, 1 / ( trailWidth + trailWidthEnd ) * 0.5, material) 
		self.TA_Trail3 = util.SpriteTrail(self, 4, color, false, trailWidth, trailWidthEnd, 1, 1 / ( trailWidth + trailWidthEnd ) * 0.5, material) 
	end
end

-- function ENT:TriggerInput(iname, value)
	-- if not WireAddon then return end
	
	-- if iname == "Enable") then self:ToggleEnable(tobool( value)) end
	-- if iname == "Reverse") then self:ToggleReverse(tobool(value)) end
-- end

-- function ENT:ToggleEnable(bDown)

	-- if self:GetStartEnabled() then bDown = not bDown end

	-- self:SetEnable( bDown )
	
	-- if ( self:GetEnable( ) ) then
	
		-- self:EmitSound( "TA.TractorBeamStart" )
		-- self:EmitSound( "TA.TractorBeamLoop" )

		-- if ( self:GetReverse() ) then
			-- APERTURESCIENCE:PlaySequence( self, "back", 1.5 )
		-- else
			-- APERTURESCIENCE:PlaySequence( self, "forward", 1.5 )
		-- end
		
	-- else
		-- self:StopSound( "TA.TractorBeamLoop" )
		-- self:EmitSound( "TA.TractorBeamEnd" )

		-- APERTURESCIENCE:PlaySequence( self, "idle", 1.0 )
	
		-- self:CheckForLeave()
	-- end
	
-- end

-- function ENT:ToggleReverse( bDown )

	-- if ( self:GetStartReversed() ) then bDown = !bDown end
	-- self:SetReverse( bDown )
	-- self:SetupTrails( )
	
	-- if ( self:GetEnable() ) then
		-- if ( self:GetReverse() ) then
			-- APERTURESCIENCE:PlaySequence( self, "back", 2.0 )
		-- else
			-- self.TA_FunnelUpdate = { }
			-- APERTURESCIENCE:PlaySequence( self, "forward", 2.0 )
		-- end		
	-- end
	
-- end
function ENT:BuildDupeInfo()

end

function ENT:OnRemove()
	self:CheckForLeave()
	self:StopSound("TA.TractorBeamLoop")
end
