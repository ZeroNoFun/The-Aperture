AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "PaintRadius")
	self:NetworkVar("Int", 1, "PaintType")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/aperture/paint_blob.mdl")
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetNotSolid(true)
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		self.TA_PrevPos = self:GetPos()
	end
end

function ENT:PaintGel(pos, normal, radius)
	local paintType = self:GetPaintType()
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetNormal(normal)
	effectdata:SetRadius(self:GetPaintRadius())
	effectdata:SetColor(paintType)
	
	if radius >= 150 then
		self:EmitSound("TA:PaintSplatBig")
		util.Effect("paint_bomb_effect", effectdata)
	else
		self:EmitSound("TA:PaintSplat")
		util.Effect("paint_splat_effect", effectdata)
	end
	
	local color = LIB_APERTURE:PaintTypeToColor(paintType)
	
	local paintDat = {
		paintType = paintType,
		radius = radius,
		hardness = 0.6,
		color = color
	}
	if paintType == PORTAL_PAINT_WATER then
		LIB_PAINT.PaintSplat(pos + normal, paintDat, true)
	else
		LIB_PAINT.PaintSplat(pos + normal, paintDat, false)
	end
	
	-- handling entities around splat
	local findResult = ents.FindInSphere(pos, radius)
	
	for k,v in pairs(findResult) do
		if v:GetClass() != self:GetClass() and v.IsAperture and not v:IsPlayer() then
			local center = v:GetPhysicsObject() and v:LocalToWorld(v:GetPhysicsObject():GetMassCenter()) or v:GetPos()
			local trace = util.TraceLine({
				start = self:GetPos(),
				endpos = center,
				filter = function(ent) if ent:GetClass() != self:GetClass() and ent != v then return true end end
			})
			if trace.Hit then continue end
			
			if paintType == PORTAL_PAINT_WATER then
				LIB_APERTURE:ClearPaintedEntity(v)
			else
				LIB_APERTURE:PaintEntity(v, paintType)
			end
			
			-- extinguish if paint type is water
			if paintType == PORTAL_PAINT_WATER and v:IsOnFire() then v:Extinguish() end
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()

	self:NextThink(CurTime() + 0.1)
	
	-- blob animation
	if CLIENT then
		local rotation = (CurTime() + self:EntIndex() * 10) * 4
		local scale = Vector(1 + math.cos(rotation) / 4, 1 + math.sin(rotation) / 4, 1) * self:GetPaintRadius() / 150
		local mat = Matrix()
		mat:Scale(scale)
		self:EnableMatrix("RenderMultiply", mat)

		self:SetAngles(Angle(rotation * 10, rotation * 20, 0))
		
		-- no more client side
		return true
	end
	
	-- removing puddle when it is under water
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
		effectdata:SetRadius(self:GetPaintRadius())
		effectdata:SetColor(self:GetPaintType())
		util.Effect("paint_splat_effect", effectdata)

		effectdata:SetOrigin(traceWater.HitPos)
		effectdata:SetScale(self:GetPaintRadius() / 10)

		util.Effect("WaterSplash", effectdata)
		self:Remove()
	end	
	
	local trace = util.TraceLine({
		start = self.TA_PrevPos,
		endpos = self:GetPos(),
		ignoreworld = true,
		filter = function(ent)
			if ent:GetClass() == "prop_portal" then return true end
		end
	})
	local traceEnt = trace.Entity
	
	if not IsValid(traceEnt) or IsValid(traceEnt) and traceEnt:GetClass() != "prop_portal" and not IsValid(traceEnt:GetNWBool( "Potal:Other")) then
		trace = util.TraceLine({
			start = self.TA_PrevPos,
			endpos = self:GetPos(),
			filter = function(ent)
				if ent.IsAperture and ent != self:GetOwner() then return true end
			end
		})
		
		traceEnt = trace.Entity
		if trace.HitSky then 
			self:Remove()
			return
		end
	end

	self.TA_PrevPos = self:GetPos()
	if trace.Hit then
		if IsValid(traceEnt) and traceEnt:GetClass() == "prop_portal" then 
			self:NextThink(CurTime() + 0.5)
			self:SetPos(traceEnt:GetNWEntity("Potal:Other"):GetPos())
			self.TA_PrevPos = traceEnt:GetNWEntity("Potal:Other"):GetPos() + traceEnt:GetNWEntity("Potal:Other"):GetForward() * 50
			self:GetPhysicsObject():SetVelocity(traceEnt:GetNWEntity("Potal:Other"):GetForward() * 1000)
		end
		
		if not IsValid(traceEnt) or IsValid(traceEnt) and traceEnt:GetClass() != "prop_portal" then
			self:SetPos(trace.HitPos + trace.HitNormal)
			self:SetNoDraw(true)
			self:GetPhysicsObject():EnableMotion(false)
			self:PaintGel(trace.HitPos, trace.HitNormal, self:GetPaintRadius())

			timer.Simple(1, function() if IsValid(self) then self:Remove() end end)
			self:NextThink(CurTime() + 10)
		end
	elseif trace.Fraction == 0 or not util.IsInWorld(self:GetPos()) then self:Remove() return end
	
	return true
end
