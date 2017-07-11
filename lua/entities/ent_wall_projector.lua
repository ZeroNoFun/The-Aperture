AddCSLuaFile( )
DEFINE_BASECLASS("base_aperture_ent")

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED

ENT.PrintName 		= "Hard Light Bridge"
ENT.IsAperture 		= true
ENT.IsConnectable 	= true

local BRIDGE_WIDTH	= 36
local WALL_MODEL_SIZE = 125

if WireAddon then
	ENT.WireDebugName = ENT.PrintName
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Enable")
	self:NetworkVar("Bool", 1, "Toggle")
	self:NetworkVar("Bool", 2, "StartEnabled")
end


function ENT:Enable(enable)
	if self:GetEnable() != enable then
		if enable then
			self:EmitSound("TA:WallEmiterEnabledNoises")
		else
			self:StopSound("TA:WallEmiterEnabledNoises")
		end
		
		self:SetEnable(enable)
	end
end

function ENT:EnableEX(enable)
	if self:GetToggle() then
		if enable then
			self:Enable(not self:GetEnable())
		end
		return true
	end
	
	if self:GetStartEnabled() then enable = !enable end
	self:Enable(enable)
end

function ENT:Initialize()

	self.BaseClass.Initialize(self)
	
	if SERVER then
		self:SetModel("models/props/wall_emitter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		
		if self:GetStartEnabled() then self:Enable(true) end
		self.ProjectedWalls = {}

		if not WireAddon then return end
		self.Inputs = Wire_CreateInputs(self, {"Enable"})
	end

	if CLIENT then
		
	end
end

function ENT:Think()
	if CLIENT then return end

	self:NextThink(CurTime() + 0.1)
	
	local penetrateVal = 0
	local passagesPoints = LIB_APERTURE:GetAllPortalPassagesAng(self:GetPos(), self:GetAngles(), nil, self, true)
	
	local requireToSpawn = #passagesPoints
	for k,v in pairs(passagesPoints) do
		local distance = v.startpos:Distance(v.endpos)
		local offsetV = penetrateVal == 0 and 0 or WALL_MODEL_SIZE - penetrateVal
		requireToSpawn = requireToSpawn + math.floor((distance + offsetV) / WALL_MODEL_SIZE)
		penetrateVal = math.ceil(distance / WALL_MODEL_SIZE) * WALL_MODEL_SIZE - distance + penetrateVal
		if penetrateVal > WALL_MODEL_SIZE then penetrateVal = penetrateVal - WALL_MODEL_SIZE end
		if penetrateVal < 0 then penetrateVal = penetrateVal + WALL_MODEL_SIZE end
	end
	
	if #self.ProjectedWalls != requireToSpawn or not self:GetEnable() then
		for k, v in pairs(self.ProjectedWalls) do v:Remove() end
		self.ProjectedWalls = { }
	end
	if self:GetEnable() then
		self.PassagesDat = passagesPoints
		
		penetrateVal = 0
		local itterator = 0
		for k,v in pairs(passagesPoints) do
			local direction = (v.endpos - v.startpos):GetNormalized()
			local angles = v.angles
			local distance = v.startpos:Distance(v.endpos)
			local offsetV = penetrateVal == 0 and 0 or WALL_MODEL_SIZE - penetrateVal
			for i = 0,(distance + offsetV), WALL_MODEL_SIZE do
				itterator = itterator + 1
				local pos = v.startpos + (i - offsetV) * direction
				if table.Count(self.ProjectedWalls) != requireToSpawn then
					local wall = ents.Create("prop_physics")
					wall:SetPos(pos)
					wall:SetAngles(angles)
					wall:SetModel("models/aperture/wall.mdl")
					wall:Spawn()
					wall:GetPhysicsObject():EnableMotion(false)
					wall.isClone = true
					table.insert(self.ProjectedWalls, wall)
				else
					local wall = self.ProjectedWalls[itterator]
					wall:SetPos(pos)
					wall:SetAngles(angles)
				end
			end
			
			penetrateVal = math.ceil(distance / WALL_MODEL_SIZE) * WALL_MODEL_SIZE - distance + penetrateVal
			if penetrateVal > WALL_MODEL_SIZE then penetrateVal = penetrateVal - WALL_MODEL_SIZE end
			if penetrateVal < 0 then penetrateVal = penetrateVal + WALL_MODEL_SIZE end
			
			-- effect impact		
			//if not timer.Exists("TA:LaserSparksEffect"..self:EntIndex()) then 
				local effectdata = EffectData()
				effectdata:SetOrigin(v.endpos)
				effectdata:SetAngles(v.angles)
				effectdata:SetRadius(30)
				effectdata:SetEntity(v.enterportal)
				util.Effect("wall_projector_impact_effect", effectdata)
				if IsValid(v.exitportal) then
					effectdata:SetOrigin(v.startpos)
					effectdata:SetEntity(v.exitportal)
					effectdata:SetAngles(v.angles + Angle(0, 180, 0))
					util.Effect("wall_projector_impact_effect", effectdata)
				end
			//end
		end
		
		//if not timer.Exists("TA:LaserSparksEffect"..self:EntIndex()) then
		//	timer.Create( "TA:LaserSparksEffect"..self:EntIndex(), 0.05, 1, function() end )
		//end
	end
	
	return true
end

function ENT:Drawing()
	if not self:GetEnable() then return end
	
	render.OverrideDepthEnable(true, false)
	render.SetLightingMode(2)
	local passagesPoints = LIB_APERTURE:GetAllPortalPassagesAng(self:GetPos(), self:GetAngles(), nil, self, true)
	for k,v in pairs(passagesPoints) do
		local offset = Vector(0, 1, 0) * BRIDGE_WIDTH
		offset:Rotate(v.angles)
		
		render.SetMaterial(Material("effects/projected_wall_rail")) 
		render.DrawBeam(v.startpos + offset, v.endpos + offset, 30, 1, v.startpos:Distance(v.endpos) / 50, Color(255, 255, 255))
		render.DrawBeam(v.startpos - offset, v.endpos - offset, 30, 1, v.startpos:Distance(v.endpos) / 50, Color(255, 255, 255))
	end
	render.OverrideDepthEnable(false, false)
	render.SetLightingMode(0)
end

-- function ENT:Draw()

	-- self:DrawModel()
	
	-- if ( !self:GetEnable() ) then return end

	-- local BridgeDrawWidth = 35
	-- local BorderBeamWidth = 10
	
	-- local MatBridge = Material( "effects/projected_wall" )
	-- local MatBridgeBorder = Material( "effects/projected_wall_rail" )
	-- local MatSprite = Material( "sprites/gmdm_pickups/light" )

	-- local trace = util.TraceLine( {
		-- start = self:GetPos(),
		-- endpos = self:LocalToWorld( Vector( 10000, 0, 0 ) ),
		-- filter = function( ent ) if ( ent == self || ent:GetClass() == "player" || ent:GetClass() == "prop_physics" ) then return false end end
	-- } )
	
	-- local totalDistance = self:GetPos():Distance( trace.HitPos )
	
	-- if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() || self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
		-- self.GASL_BridgeUpdate.lastPos = self:GetPos()
		-- self.GASL_BridgeUpdate.lastAngle = self:GetAngles()
		
		-- local min, max = self:GetRenderBounds() 
		-- max = max + Vector( totalDistance, 0, 0 )
		-- self.GASL_RenderBounds = { mins = min, maxs = max }
		
	-- end

	-- render.SetMaterial( MatBridgeBorder )
	-- render.DrawBeam( self:LocalToWorld( Vector( 0, BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
	-- render.DrawBeam( self:LocalToWorld( Vector( 0, -BridgeDrawWidth, 0 ) ), self:LocalToWorld( Vector( totalDistance, -BridgeDrawWidth, 0 ) ), BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )

-- end

-- function ENT:Think()
	
	-- self:NextThink(CurTime() + 0.1)
	
	-- self.BaseClass.Think( self )
	
	-- if ( CLIENT ) then return end
	
	-- -- Skip this tick if exursion funnel is disabled and removing effect if possible
	-- if ( !self:GetEnable() ) then
		
		-- if ( self.GASL_BridgeUpdate.lastPos || self.GASL_BridgeUpdate.lastAngle ) then
				-- self.GASL_BridgeUpdate.lastPos = nil
				-- self.GASL_BridgeUpdate.lastAngle = nil
			
			-- -- Removing effects
			-- self:ClearAllData( )

		-- end

		-- return
	-- end
	
	-- for k, v in pairs( self.GASL_EntitiesEffects ) do
	-- for k2, v2 in pairs( v ) do
		-- if v2:IsValid() then v2:RemoveAllDecals() end
	-- end
	-- end
	
	-- return true
-- end

-- no more client side
if ( CLIENT ) then return end

function ENT:TriggerInput(iname, value)
	if not WireAddon then return end

	if iname == "Enable" then self:Enable(tobool(value)) end
end

numpad.Register("WallProjector_Enable", function(pl, ent, keydown)
	if not IsValid(ent) then return false end
	ent:EnableEX(keydown)
	return true
end)

function ENT:OnRemove()
	self:StopSound("TA:WallEmiterEnabledNoises")
	for k,v in pairs(self.ProjectedWalls) do v:Remove() end
end
