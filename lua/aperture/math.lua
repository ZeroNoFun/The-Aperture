AddCSLuaFile()

LIB_MATH_TA = {}
LIB_MATH_TA.EPSILON = 0.00001
LIB_MATH_TA.HUGE = 100000

-- Converting coordinate to grid ignoring z on normal
function LIB_MATH_TA:ConvertToGridOnSurface(pos, angle, radius, zRound)
	local WTL = WorldToLocal(pos, Angle(), Vector(), angle)
	
	if zRound == 0 then
		WTL = Vector(math.Round(WTL.x / radius) * radius, math.Round(WTL.y / radius) * radius, WTL.z)
	else
		WTL = Vector(math.Round(WTL.x / radius) * radius, math.Round(WTL.y / radius) * radius, math.Round(WTL.z / zRound) * zRound)
	end
	pos = LocalToWorld(WTL, Angle(), Vector(), angle)
	
	return pos
end

-- Converting vector to a grid
function LIB_MATH_TA:ConvertToGrid(pos, size)
	local gridPos = Vector(
		math.Round(pos.x / size) * size, 
		math.Round(pos.y / size) * size, 
		math.Round(pos.z / size) * size)
		
	return gridPos
end

-- if angles angle less then EPSILON equal that angle to zero
function LIB_MATH_TA:AnglesToZeroz(angle)
	if math.abs(angle.p) < LIB_MATH_TA.EPSILON then angle.p = 0 end
	if math.abs(angle.y) < LIB_MATH_TA.EPSILON then angle.y = 0 end
	if math.abs(angle.r) < LIB_MATH_TA.EPSILON then angle.r = 0 end
end

-- if normal coordinate less then EPSILON equal that coordinate to zero
function LIB_MATH_TA:NormalFlipZeros(normal)
	if math.abs(normal.x) < LIB_MATH_TA.EPSILON then normal.x = 0 end
	if math.abs(normal.y) < LIB_MATH_TA.EPSILON then normal.y = 0 end
	if math.abs(normal.z) < LIB_MATH_TA.EPSILON then normal.z = 0 end
end

function LIB_MATH_TA:DegreeseBetween(vector1, vector2)
	LIB_MATH_TA:NormalFlipZeros(vector1)
	LIB_MATH_TA:NormalFlipZeros(vector2)
	
	if vector1 == vector2 then return 0 end
	local dot = vector1:Dot(vector2)
	return math.deg(math.acos(dot))
end
