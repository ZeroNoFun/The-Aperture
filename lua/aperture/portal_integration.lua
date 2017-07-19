AddCSLuaFile()

if not LIB_APERTURE then print("Error: Aperture lib does not exit!!!") return end

LIB_APERTURE.MAX_PASSAGES = 256

-- ================================ PORTAL INTEGRATION ============================

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

function LIB_APERTURE:GetAllPortalPassagesAng(pos, angle, maxLength, ignore, ignoreEntities)
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
					and not ent:IsPlayer() 
					and not ent:IsNPC() then return true end
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
		if passages >= LIB_APERTURE.MAX_PASSAGES then print(123) break end
	until hitPortal
	
	return passagesInfo, trace
end

function LIB_APERTURE:GetAllPortalPassages(pos, dir, maxLength, ignore, ignoreEntities)
	local angle = dir:Angle()
	return LIB_APERTURE:GetAllPortalPassagesAng(pos, angle, maxLength, ignore, ignoreEntities)
end