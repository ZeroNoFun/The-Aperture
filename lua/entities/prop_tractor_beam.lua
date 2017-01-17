AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Tractor Beam"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

function ENT:Initialize()

	if SERVER then

		self:SetModel("models/props/tractor_beam_emitter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

	end // SERVER

	if CLIENT  then
		
	end // CLIENT
	
	self.hard_light_bridge_update = 0
end

function ENT:Draw()

	self:DrawModel()
	
	local bridge_trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(10000, 0, 0)),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local funnel_width = 60
	local totalDistance = self:GetPos():Distance(bridge_trace.HitPos)
	
	local mat_bridge = Material("effects/projected_wall")
	local mat_bridge_border = Material("effects/bluelaser1")
	local mat_sprite = Material("sprites/gmdm_pickups/light")
	
	if (totalDistance != self.hard_light_bridge_update) then
		self.hard_light_bridge_update = totalDistance
		
		local min, max = self:GetRenderBounds() 
		self:SetRenderBounds(min, max + Vector(totalDistance, 0, 0))
	end

	render.SetColorMaterial()
	render.DrawBox( self:LocalToWorld(Vector(totalDistance / 2, 0, 0)), self:LocalToWorldAngles(Angle(0, 0, 0)), -Vector(totalDistance / 2, funnel_width, funnel_width), Vector(totalDistance / 2, funnel_width, funnel_width), Color(255, 255, 255, 100), false)
	
end

function ENT:Think()

	//self:NextThink(CurTime() + 1)

	if SERVER then
		
		local bridge_trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:LocalToWorld(Vector(10000, 0, 0)),
			filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
		} )
		
		local trace_entities = { }
		local funnel_width = 60
		local bridge_trace_finder = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:LocalToWorld(Vector(10000, 0, 0)),
			filter = function( ent ) 
				if (ent == self) then return false end

				if ( ent:IsPlayer() or ent:IsNPC() or ent:GetPhysicsObject() ) then 
					table.insert(trace_entities, table.Count(trace_entities) + 1, ent)
					return false 
				end
			end,
			mins = -Vector( funnel_width, funnel_width, funnel_width ),
			maxs = Vector( funnel_width, funnel_width, funnel_width ),
			mask = MASK_SHOT_HULL
		} )
		
		local totalDistance = self:GetPos():Distance(bridge_trace.HitPos)

		for k, v in pairs(trace_entities) do
			if (not v:IsValid()) then break end
			
			local WTL = self:WorldToLocal(v:GetPos())
			WTL = Vector(WTL.x, 0, 0)
			
			local LTW = self:LocalToWorld(WTL)
			
			if (v:IsPlayer() or v:IsNPC()) then
				v:SetVelocity(self:GetForward() * 100 + (LTW - v:GetPos()) * 2 - v:GetVelocity())
			elseif (v:GetPhysicsObject()) then
				local vPhysObject = v:GetPhysicsObject()
				vPhysObject:SetVelocity(self:GetForward() * 100 + (LTW -v:LocalToWorld(vPhysObject:GetMassCenter())) - v:GetVelocity() / 10)
				vPhysObject:EnableGravity(false)
			end
		end
		
		
		if (totalDistance != self.hard_light_bridge_update) then
			self.hard_light_bridge_update = totalDistance
			
		end
		
	end // SERVER

	if CLIENT then
		
	end // CLIENT
end

if SERVER then
	
end
