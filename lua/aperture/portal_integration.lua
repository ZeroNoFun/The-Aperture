AddCSLuaFile()

if not LIB_APERTURE then print("Error: Aperture lib does not exit!!!") return end

LIB_APERTURE.MAX_PASSAGES = 256
local PORTAL_RADIUS = 50

-- ================================ PORTAL INTEGRATION ============================

-- Fixed Find in cone
function LIB_APERTURE:FindInCone(startpos, dir, height, degrese)
	local tbl = {}
	local rad = math.rad(degrese)
	dir:Normalize()
	local endpos = startpos + dir * height
	local h1 = height / math.cos(math.rad(degrese))
	local radius = math.sqrt(h1 * h1 - height * height)
	local min = startpos - Vector(1, 1, 1) * radius
	local max = endpos + Vector(1, 1, 1) * radius
	LIB_MATH_TA:FixMinMax(min, max)
	
	local entities = ents.FindInBox(min, max)
	for k,v in ipairs(entities) do
		local center = IsValid(v:GetPhysicsObject()) and v:LocalToWorld(v:GetPhysicsObject():GetMassCenter()) or v:GetPos()
		local dir2v = center - startpos
		dir2v:Normalize()
		local ang = math.deg(math.acos(dir:Dot(dir2v)))
		
		if ang > 0 and ang < degrese then
			table.insert(tbl, v)
		end
	end
	return tbl
end

-- Rotating vector relative to portals
function LIB_APERTURE:GetPortalRotateVector(vec, portal, flip)
	if not IsValid(portal) then return end
	if not portal:IsLinked() then return end
	local portalOther = portal:GetOther()
	if not IsValid(portalOther) then return end
	local vec = vec and vec or Vector()
	local ang = Angle()
	vec = WorldToLocal(vec, Angle(), Vector(), portal:GetAngles())
	local pang = flip and portalOther:LocalToWorldAngles(Angle(0, 180, 0)) or portalOther:GetAngles()
	return LocalToWorld(vec, Angle(), Vector(), pang)
end

-- Transforming pos, ang from enter portal relative to exit portal
function LIB_APERTURE:GetPortalTransform(pos, ang, portal, flip)
	if not IsValid(portal) then return end
	if not portal:IsLinked() then return end
	local portalOther = portal:GetOther()
	if not IsValid(portalOther) then return end
	local pos = pos and pos or Vector()
	local ang = ang and ang or Angle()
	local pang = flip and portalOther:LocalToWorldAngles(Angle(0, 180, 0)) or portalOther:GetAngles()
	pos, ang = WorldToLocal(pos, ang, portal:GetPos(), portal:GetAngles())
	return LocalToWorld(pos, ang, portalOther:GetPos(), pang)
end

-- Mathing Entity and Table of models or entities
local function MathEntityAndTable(ent, entTable)
	if not istable(entTable) then return false end
	for k,v in pairs(entTable) do
		if isentity(v) then
			if ent == v then return true end
		end
		if ent:GetModel() == v then return true end
	end
	return false
end

function LIB_APERTURE:GetAllPortalPassagesAng(pos, angle, maxLength, ignore, ignoreEntities, ignoreAlive)
	local exitportal
	local prevPos = pos
	local prevAng = angle
	local passagesInfo = {}
	local passages = 0
	local trace = {}
	repeat
		local hitPortal = true
		local direction = prevAng:Forward()
		trace = util.TraceLine({
			start = prevPos,
			endpos = prevPos + direction * LIB_MATH_TA.HUGE,
			filter = function(ent)
				if ent != ignore and not MathEntityAndTable(ent, ignore)
					and not ignoreEntities 
					and ent:GetClass() != "prop_portal"
					and (not ignoreAlive or (ent:IsPlayer() or ent:IsNPC())) then return true end
			end
		})
		table.insert(passagesInfo, {
			startpos = prevPos,
			endpos = trace.HitPos,
			angles = prevAng,
			exitportal = exitportal,
		})
		
		-- Portal loop if trace hit portal
		for k,v in pairs(ents.FindByClass("prop_portal")) do
			if v != exitPortal then
				local pos = v:WorldToLocal(trace.HitPos)
				
				if pos.x > -30 and pos.x < 10
					and pos.y > -30 and pos.y < 30
					and pos.z > -45 and pos.z < 45 then
					if IsValid(v:GetNWEntity("Potal:Other")) then
						local otherPortal = v:GetNWEntity("Potal:Other")
						
						localPos = v:WorldToLocal(trace.HitPos)
						localAng = v:WorldToLocalAngles(prevAng)
						localPos = Vector(0, -localPos.y, localPos.z)
						localAng = localAng + Angle(0, 180, 0)
						
						prevPos = otherPortal:LocalToWorld(localPos)
						prevAng = otherPortal:LocalToWorldAngles(localAng)
						hitPortal = false
						passagesInfo[#passagesInfo].enterportal = v
						exitportal = otherPortal
						break
					end
				end
			end
		end
		
		passages = passages + 1
		if passages >= LIB_APERTURE.MAX_PASSAGES then break end
	until hitPortal
	
	return passagesInfo, trace
end

function LIB_APERTURE:GetAllPortalPassages(pos, dir, maxLength, ignore, ignoreEntities)
	local angle = dir:Angle()
	return LIB_APERTURE:GetAllPortalPassagesAng(pos, angle, maxLength, ignore, ignoreEntities)
end

--[[
	Here's some function that is used for turrets
	
	Return closest alive entity in specific cone, even if it seen throw portal
	This function is recursive!
]]
local function RFindClosestAliveInSphereIncludingPortalPassages(entities, startpos, length, degrese, portal, distance)
	local distance = distance and distance or 0
	local dist = -1
	local ent
	local point = Vector()
	
	for k,v in pairs(entities) do
		local pos = v:GetPos()
		
		if IsValid(portal) then
			local p = WorldToLocal(pos, Angle(), portal:GetPos(), portal:GetAngles())
			if p.x < 0 then continue end
		end
		
		local d = pos:Distance(startpos)
		-- if found portal then do recursive find
		if v:GetClass() == "prop_portal" and v != portal and v:IsLinked() then
			local dir1 = (pos - startpos)
			local portalOther = v:GetOther()
			dir1:Normalize()
			local startp = LIB_APERTURE:GetPortalTransform(startpos, nil, v, true)
			dir1 = LIB_APERTURE:GetPortalRotateVector(dir1, v, true)
			
			local h1 = math.sqrt(PORTAL_RADIUS * PORTAL_RADIUS + d * d)
			local deg = math.deg(math.acos(d / h1))
			-- Entity(1):SetPos(startp + dir1 * length / 2)
			if not degrese or deg < degrese then degrese = deg end
			
			local entits = LIB_APERTURE:FindInCone(startp, dir1, length, degrese)
			local e, p, d = RFindClosestAliveInSphereIncludingPortalPassages(entits, startp, length, degrese, portalOther, d)
			
			if IsValid(e) and (dist == -1 or dist > d) then
				-- fliping portal angle
				local vang = v:LocalToWorldAngles(Angle(0, 180, 0))
				point = LocalToWorld(p, Angle(), v:GetPos(), vang)
				dist = d
				ent = e
			end
		end
		
		if ((v:IsPlayer() and v:Alive() and not LIB_APERTURE:GetAIIgnorePlayers()) or v:IsNPC() and v:Health() > 0) and (dist == -1 or dist > d) then
			-- local center = IsValid(v:GetBone) and v:LocalToWorld(v:GetPhysicsObject():GetMassCenter()) or v:GetPos()
			local center = v:LocalToWorld(v:OBBCenter())
			point = IsValid(portal) and portal:WorldToLocal(center) or center
			dist = d
			ent = v
		end
	end
	
	return ent, point, dist + distance
end

--[[
	Return closest alive entity in specific radius, even if it seen throw portal
]]
function LIB_APERTURE:FindClosestAliveInSphereIncludingPortalPassages(startpos, radius)
	local entities = ents.FindInSphere(startpos, radius)
	return RFindClosestAliveInSphereIncludingPortalPassages(entities, startpos, radius)
end

--[[
	Return closest alive entity in specific cone, even if it seen throw portal
]]
function LIB_APERTURE:FindClosestAliveInConeIncludingPortalPassages(startpos, dir, length, degrese)
	local entities = LIB_APERTURE:FindInCone(startpos, dir, length, degrese)
	return RFindClosestAliveInSphereIncludingPortalPassages(entities, startpos, length, degrese)
end