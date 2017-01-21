AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.Editable		= true
ENT.PrintName		= "Tractor Beam"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

local tractor_beam_objects_move_speed = 150

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos
	local SpawnAng = tr.HitNormal:Angle()
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if SERVER then

		self:SetModel("models/props/tractor_beam_emitter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		self.tractorBeamFields = { }
	end // SERVER

	if CLIENT  then
		self.particleEmitter = ParticleEmitter(self:GetPos())
		self.particleEffectTime = 0
	end // CLIENT
	
	APERTURESCIENCE:PlaySequence( self, "tractor_beam_rotation" )
	
	self.tractorBeamUpdate = { }
end

function ENT:Draw()

	self:DrawModel()
	
	local tractorBeamTrace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(10000, 0, 0)),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local funnel_width = 60
	local totalDistance = self:GetPos():Distance(tractorBeamTrace.HitPos)
	
	local mat_bridge = Material("effects/projected_wall")
	local mat_bridge_border = Material("effects/bluelaser1")
	local mat_sprite = Material("sprites/gmdm_pickups/light")
	
	--[[ 
		Handling changes position or angles 
	]]
	if ( self.tractorBeamUpdate.lastPos != self:GetPos() or self.tractorBeamUpdate.lastAngle != self:GetAngles() ) then
		self.tractorBeamUpdate.lastPos = self:GetPos()
		self.tractorBeamUpdate.lastAngle = self:GetAngles()
		
		local min, max = self:GetRenderBounds() 
		self:SetRenderBounds(min, max + Vector(totalDistance, 0, 0))
	end
	
	--[[ 
		Tractor beam particle effect 
	]]
	local effectWidth = 60
	local mult = 1.2
	
	if (CurTime() > self.particleEffectTime) then
		self.particleEffectTime = CurTime() + 0.1
		
		for i = 0, 1, 0.1 do 
			for k = 1, 3 do 
				local cossinValues = CurTime() * mult + ((math.pi * 2) / 3) * k
				local multWidth = i * effectWidth
				local localVec = Vector(10, math.cos(cossinValues) * multWidth, math.sin(cossinValues) * multWidth)
				local particlePos = self:LocalToWorld(localVec) + VectorRand() * 5
				
				local p = self.particleEmitter:Add("sprites/light_glow02_add", particlePos)
				p:SetDieTime(math.random(1, 2) * ((0 - i) / 2 + 1))
				p:SetStartAlpha(math.random(0, 50))
				p:SetEndAlpha(255)
				p:SetStartSize(math.random(10, 20))
				p:SetEndSize(0)
				p:SetVelocity(self:GetForward() * 100 + VectorRand() * 5)
				p:SetGravity(VectorRand() * 5)
				p:SetColor(math.random(0, 50), 100 + math.random(0, 55), 200 + math.random(0, 50))
				p:SetCollide(true)
			end
		end
		
		local randDist = math.min(totalDistance - funnel_width, math.max(funnel_width, math.random(0, totalDistance)))
		local randVecNormalized = VectorRand()
		randVecNormalized:Normalize()
		
		local particlePos = self:LocalToWorld(Vector(randDist, 0, 0) + randVecNormalized * funnel_width)
		
		local p = self.particleEmitter:Add("sprites/light_glow02_add", particlePos)
		p:SetDieTime(math.random(3, 5))
		p:SetStartAlpha(math.random(0, 50))
		p:SetEndAlpha(255)
		p:SetStartSize(math.random(1, 5))
		p:SetEndSize(0)
		p:SetVelocity(self:GetForward() * 150)
		
		p:SetColor(math.random(0, 50), 100 + math.random(0, 55), 200 + math.random(0, 50))
		p:SetCollide(true)
	end
end

function ENT:Think()

	self:NextThink(CurTime() + 0.1)

if SERVER then
	
	local plate_length = 428.5
		
	local effectdata = EffectData()
	effectdata:SetOrigin(self:LocalToWorld(Vector(0, 0, 10)))
	effectdata:SetNormal(self:GetUp())

	local tractorBeamTrace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(10000, 0, 0)),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance(tractorBeamTrace.HitPos)
	
	local tractorBeamEntities = { }
	local funnel_width = 60
	local tractorBeamHullFinder = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(totalDistance, 0, 0)),
		ignoreworld = true,
		filter = function( ent ) 
			if (ent == self) then return false end
			

			if (not ent.ApertureScienceStuffIgnore 
				and (ent:IsPlayer() or ent:IsNPC() or ent:GetPhysicsObject())) then 
				
				table.insert(tractorBeamEntities, table.Count(tractorBeamEntities) + 1, ent)
				return false 
			end
		end,
		mins = -Vector( funnel_width, funnel_width, funnel_width ),
		maxs = Vector( funnel_width, funnel_width, funnel_width ),
		mask = MASK_SHOT_HULL
	} )
	
	--[[ 
		Handling entities in field 
	]]
	
	for k, v in pairs(tractorBeamEntities) do
		if (not v:IsValid()) then break end
		
		local WTL = self:WorldToLocal(v:GetPos())
		local min, max = v:WorldSpaceAABB()
		local entRadius = min:Distance(max)
		
		WTL = Vector(WTL.x, 0, 0)
		
		local LTW = self:LocalToWorld(WTL)
		local tractorBeamMovingSpeed = tractor_beam_objects_move_speed * math.min(1, (totalDistance - (WTL.x + 50)) / 50)
		
		if (v:IsPlayer() or v:IsNPC()) then
			if (v:IsPlayer()) then

				local forward, back, right, left, up, down
				
				if (v:KeyDown(IN_FORWARD)) then forward = 1 else forward = 0 end
				if (v:KeyDown(IN_BACK)) then back = 1 else back = 0 end
				if (v:KeyDown(IN_MOVERIGHT)) then right = 1 else right = 0 end
				if (v:KeyDown(IN_MOVELEFT)) then left = 1 else left = 0 end
				if (v:KeyDown(IN_JUMP)) then up = 1 else up = 0 end
				if (v:KeyDown(IN_DUCK)) then down = 1 else down = 0 end

				local ply_moving = Vector(forward - back, left - right, up - down) * 100
				ply_moving:Rotate(v:EyeAngles())
				
				local ply_moving_cutted_local = self:WorldToLocal(self:GetPos() + ply_moving)
				ply_moving_cutted_local = Vector(0, ply_moving_cutted_local.y, ply_moving_cutted_local.z)
				local ply_moving = self:LocalToWorld(ply_moving_cutted_local) - self:GetPos()
				
				v:SetVelocity(self:GetForward() * tractorBeamMovingSpeed + (LTW - v:GetPos() + ply_moving) * 2 - v:GetVelocity())
			else
				v:SetVelocity(self:GetForward() * tractor_beam_objects_move_speed + (LTW - v:GetPos()) * 2 - v:GetVelocity())
			end
		elseif (v:GetPhysicsObject()) then
			local vPhysObject = v:GetPhysicsObject()
			vPhysObject:SetVelocity(self:GetForward() * tractor_beam_objects_move_speed + (LTW -v:LocalToWorld(vPhysObject:GetMassCenter())) - v:GetVelocity() / 10)
			vPhysObject:EnableGravity(false)
		end
	end
	
	--[[ 
		Handling changes position or angles 
	]]
	
	if (self.tractorBeamUpdate.lastPos != self:GetPos() or self.tractorBeamUpdate.lastAngle != self:GetAngles()) then
		self.tractorBeamUpdate.lastPos = self:GetPos()
		self.tractorBeamUpdate.lastAngle = self:GetAngles()

		--[[ 
			Spawning field effect 
		]]
		
		for k, v in pairs(self.tractorBeamFields) do
			if (v:IsValid()) then v:Remove() end
		end
		
		local addingDist = 0
		
		while (totalDistance > addingDist) do
		
			local ent = ents.Create("prop_physics")
			ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
			ent:SetPos(self:LocalToWorld(Vector(addingDist, 0, -1)))
			ent:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
			ent:Spawn()
			ent.ApertureScienceStuffIgnore = true
			
			ent:DrawShadow(false)
			ent:SetModel("models/tractor_beam_field/tractor_beam_field.mdl")
			
			local physEnt = ent:GetPhysicsObject()
			physEnt:EnableMotion(false)
			physEnt:EnableCollisions(false)
			table.insert(self.tractorBeamFields, table.Count(self.tractorBeamFields) + 1, ent)

			addingDist = addingDist + plate_length
			
		end
	end

end // SERVER

if CLIENT then

end // CLIENT

	return true
end

if SERVER then

	--[[ 
		Deleting field effect 
	]]
	function ENT:OnRemove()
		for k, v in pairs(self.tractorBeamFields) do
			if (v:IsValid()) then v:Remove() end
		end
	end

end // SERVER

