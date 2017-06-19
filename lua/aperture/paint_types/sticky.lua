AddCSLuaFile()

if not LIB_APERTURE then return end

--============= Adhesion Gel ==============

PORTAL_PAINT_STICKY = PORTAL_PAINT_COUNT + 1

local PAINT_INFO = {}

PAINT_INFO.COLOR 	= Color(125, 25, 220)
PAINT_INFO.NAME		= "Adhesion" 

if SERVER then

-- When player step in paint
function PAINT_INFO:OnEnter(ply, normal)
	local orientation = ply:GetNWVector("TA:Orientation")
	if DegreeseBetween(normal, orientation) > 1 then PlayerChangeOrient(ply, normal) end

	ply:EmitSound("GASL.GelStickEnter")
end

-- When player step out paint
function PAINT_INFO:OnExit(ply)
	local orientation = ply:GetNWVector("TA:Orientation")
	if orienation != ORIENTATION_DEFAULT then
		PlayerUnStuck(ply)
		PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
	end
	
	ply:EmitSound("GASL.GelStickExit")
end

-- When player step from other type to this
function PAINT_INFO:OnChangeTo(ply, oldType, normal)
end

-- When player step from this type to other
function PAINT_INFO:OnChangeFrom(ply, newType, normal)
	local orientation = ply:GetNWVector("TA:Orientation")
	if orientation != ORIENTATION_DEFAULT then
		ply:EmitSound("GASL.GelStickExit")

		orientation = ORIENTATION_DEFAULT
		paintNormal = orientation
		PlayerUnStuck(ply)
		PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
	end
end

-- Handling paint
function PAINT_INFO:Think(ply, normal, orientationMove)

	local playerHeight = ply:OBBMaxs().z
	local plyWidth = ply:OBBMaxs().x
	
	local orientation = ply:GetNWVector("TA:Orientation")
	local orienationWalk = ply:GetNWVector("TA:OrientationWalk")
	local orientationAng = orientation:Angle() + Angle(90, 0, 0)

	-- if player stand on sticky paint
	if orienationWalk != Vector() and orientation != ORIENTATION_DEFAULT then
		
		local playerCenter = ply:GetPos() + orientation * playerHeight / 2
		local boxSize = Vector(1, 1, 1)
		local traceForward = util.TraceHull({
			start = playerCenter,
			endpos = playerCenter + orientationAng:Forward() * plyWidth,
			mins = -boxSize,
			maxs = boxSize,
			filter = ply,
		})
		local traceBack = util.TraceHull({
			start = playerCenter,
			endpos = playerCenter - orientationAng:Forward() * plyWidth,
			mins = -boxSize,
			maxs = boxSize,
			filter = ply,
		})
		local traceRight = util.TraceHull({
			start = playerCenter,
			endpos = playerCenter + orientationAng:Right() * plyWidth,
			mins = -boxSize,
			maxs = boxSize,
			filter = ply,
		})
		local traceLeft = util.TraceHull({
			start = playerCenter,
			endpos = playerCenter - orientationAng:Right() * plyWidth,
			mins = -boxSize,
			maxs = boxSize,
			filter = ply,
		})
		
		boxSize = Vector(plyWidth, plyWidth, 1)
		local traceForwardFloor = util.QuickTrace(ply:GetPos() + orientation * 5, Vector(0, 0, plyWidth / 4), ply)
		local traceForwardFloorDown = util.QuickTrace(traceForwardFloor.HitPos, -orientation * 6, ply)
		local traceForwardFloorBack = util.TraceHull({
			start = traceForwardFloorDown.HitPos,
			endpos = traceForwardFloorDown.HitPos - Vector(0, 0, plyWidth / 4),
			mins = -boxSize,
			maxs = boxSize,
			filter = ply,
			collisiongroup = COLLISION_GROUP_DEBRIS,
		})
		
		if not traceForwardFloor.Hit and not traceForwardFloorDown.Hit
			and traceForwardFloorBack.Hit and traceForwardFloorBack.Fraction > 0 and DegreeseBetween(ORIENTATION_DEFAULT, traceForwardFloorBack.HitNormal) < 25
			and DegreeseBetween(ORIENTATION_DEFAULT, orientation) > 45 then
			
			-- Step on conner
			ply:SetPos(traceForwardFloorBack.HitPos)
			ply:SetVelocity(Vector(0, 0, 100))
			orientation = ORIENTATION_DEFAULT
			paintNormal = orientation
			PlayerUnStuck(ply)
			PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
		else
			-- Normalization orientation
			if ply:KeyPressed(IN_JUMP) then
				
				-- Jump out paint
				PlayerUnStuck(ply)
				PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
				ply:SetVelocity(orientation * ply:GetJumpPower())
			else
				-- Pseudo collision
				if traceForward.Hit then orientationMove = orientationMove - orientationAng:Forward() * (1 - traceForward.Fraction) * plyWidth end
				if traceBack.Hit then orientationMove = orientationMove + orientationAng:Forward() * (1 - traceBack.Fraction) * plyWidth end
				if traceRight.Hit then orientationMove = orientationMove - orientationAng:Right() * (1 - traceRight.Fraction) * plyWidth end
				if traceLeft.Hit then orientationMove = orientationMove + orientationAng:Right() * (1 - traceLeft.Fraction) * plyWidth end
				local walk = orienationWalk + orientationMove
				
				ply:SetNWVector("TA:OrientationWalk", walk)
				ply:SetPos(walk)
				ply:SetVelocity(-ply:GetVelocity())
			end
		end
	end
end

-- Handling painted entity
function PAINT_INFO:EntityThink(ent)
end

end -- SERVER

LIB_APERTURE:CreateNewPaintType(PORTAL_PAINT_STICKY, PAINT_INFO)
