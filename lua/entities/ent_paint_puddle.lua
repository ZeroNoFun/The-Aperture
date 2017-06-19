AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "GelRadius")

end

function ENT:Initialize()

	if SERVER then
		self:SetModel("models/gasl/portal_gel_bubble.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetNotSolid(true)
		
		self.GASL_GelType = PORTAL_GEL_NONE
		self.GASL_PrevPos = self:GetPos()
	end
	
end

function ENT:PaintGel(pos, normal, radius)

	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetNormal(normal)
	effectdata:SetRadius(self:GetGelRadius())
	effectdata:SetColor(self.GASL_GelType)
	
	if radius >= 150 then
		self:EmitSound("GASL.GelSplatBig")
		util.Effect("paint_bomb_effect", effectdata)
	else
		self:EmitSound("GASL.GelSplat")
		util.Effect("paint_splat_effect", effectdata)
	end
	
	local color = APERTURESCIENCE:PaintTypeToColor(self.GASL_GelType)
	if self.GASL_GelType == PORTAL_GEL_WATER then
		
	else
		PaintSplat(self.GASL_GelType, pos + normal, radius, color)
	end
	
	// handling props around splat
	local findResult = ents.FindInSphere(pos, radius)
	
	for k, v in pairs(findResult) do
	
		if APERTURESCIENCE:IsValidEntity(v) and not v:IsPlayer() then
			if not APERTURESCIENCE.GELLED_ENTITIES[v] or v.GASL_GelledType and v.GASL_GelledType != self.GASL_GelType then
				
				local center = v:GetPhysicsObject() and v:LocalToWorld(v:GetPhysicsObject():GetMassCenter()) or v:GetPos()
				
				local trace = util.TraceLine({
					start = self:GetPos(),
					endpos = center,
					filter = function(ent) if ent:GetClass() != "ent_paint_puddle" and ent != v then return true end end
				})
				if trace.Hit then continue end

				-- Reseting physics material
				if v.GASL_PrevPhysMaterial then
					v:GetPhysicsObject():SetMaterial( v.GASL_PrevPhysMaterial )
					v.GASL_PrevPhysMaterial = nil
				end
				
				if self.GASL_GelType != 4 then
					
					v.GASL_GelledType = self.GASL_GelType
					if self.GASL_GelType != PORTAL_GEL_BOUNCE and APERTURESCIENCE.GELLED_ENTITIES[ v ] then APERTURESCIENCE.GELLED_ENTITIES[ v ] = nil end
					
					// adding properties to the entities
					if !v.GASL_PrevPhysMaterial then
					
						// painting entity
						if self.GASL_GelType != PORTAL_GEL_WATER then APERTURESCIENCE:PaintProp(v, self.GASL_GelType) end
						
						if self.GASL_GelType == PORTAL_GEL_BOUNCE then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							v:GetPhysicsObject():SetMaterial("metal_bouncy")
							APERTURESCIENCE.GELLED_ENTITIES[ v ] = v
							
						elseif self.GASL_GelType == PORTAL_GEL_SPEED then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							v:GetPhysicsObject():SetMaterial("gmod_ice")
							
						elseif self.GASL_GelType == PORTAL_GEL_STICKY then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							APERTURESCIENCE.GELLED_ENTITIES[v] = v
						end
					end
					
				else
					// clearing properties from the entities
					APERTURESCIENCE.GELLED_ENTITIES[v] = nil
					APERTURESCIENCE:ClearPaintProp(v)
					v.GASL_GelledType = nil
				end
			
			end
			
			// extinguish if gel is water
			if self.GASL_GelType == PORTAL_GEL_WATER and v:IsOnFire() then
				v:Extinguish()
			end
		end
	end

end

function ENT:DrawTranslucent()
	
	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink(CurTime() + 0.1)
	

	// puddle animation
	if CLIENT then
		local rotation = ( CurTime() + self:EntIndex() * 10 ) * 4
		local scale = Vector(1 + math.cos(rotation) / 4, 1 + math.sin(rotation) / 4, 1) * (self:GetGelRadius() / 110)
		local mat = Matrix()
		mat:Scale(scale)
		self:EnableMatrix("RenderMultiply", mat)

		self:SetAngles(Angle(rotation * 10, rotation * 20, 0))
		
		// no more client side
		return true
	end
	
	// removing puddle when it is under water
	if self:WaterLevel() == 3 then
	
		local traceWater = util.TraceLine({
			start = self:GetPos() + Vector(0, 0, 50),
			endpos = self:GetPos(),
			mask = MASK_WATER,
			collisiongroup = COLLISION_GROUP_DEBRIS
		})

		local effectdata = EffectData()
		effectdata:SetOrigin(traceWater.HitPos)
		effectdata:SetNormal(Vector(0, 0, 1))
		effectdata:SetRadius(self:GetGelRadius())
		effectdata:SetColor(self.GASL_GelType)
		util.Effect("paint_splat_effect", effectdata)

		effectdata:SetOrigin(traceWater.HitPos)
		effectdata:SetScale(self:GetGelRadius() / 10)

		util.Effect("WaterSplash", effectdata)
		self:Remove()
	end	
	
	local trace = util.TraceLine({
		start = self.GASL_PrevPos,
		endpos = self:GetPos(),
		ignoreworld = true,
		filter = function(ent)
			if ent:GetClass() == "prop_portal" then return true end
		end
	})
	local traceEnt = trace.Entity
	
	if !IsValid(traceEnt) or IsValid(traceEnt) and traceEnt:GetClass() != "prop_portal" and !IsValid(traceEnt:GetNWBool( "Potal:Other")) then
		trace = util.TraceLine({
			start = self.GASL_PrevPos,
			endpos = self:GetPos(),
			filter = function(ent)
				if (APERTURESCIENCE:IsValidEntity(ent) or APERTURESCIENCE:IsValidStaticEntity( ent )) and ent != self:GetOwner() then return true end
			end
		})
		
		traceEnt = trace.Entity
		if trace.HitSky then 
			self:Remove()
			return
		end
	end

	if trace.Hit then
		if IsValid(traceEnt) and traceEnt:GetClass() == "prop_portal" then self:NextThink(CurTime() + 0.5) end
		if !IsValid(traceEnt) or IsValid(traceEnt) and traceEnt:GetClass() != "prop_portal" then
			self:SetPos(trace.HitPos + trace.HitNormal)
			self:SetColor(Color(0, 0, 0, 0))
			self:GetPhysicsObject():EnableMotion(false)
			self:PaintGel(trace.HitPos, trace.HitNormal, self:GetGelRadius())

			timer.Simple(1, function() if IsValid( self ) then self:Remove() end end)
			self:NextThink(CurTime() + 10)
		end
	elseif trace.Fraction == 0 or not util.IsInWorld(self:GetPos()) then self:Remove() return end
	self.GASL_PrevPos = self:GetPos()
	
	return true
end
