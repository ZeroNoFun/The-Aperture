AddCSLuaFile()

if not LIB_APERTURE then return end

--============= Repulsion Gel ==============

PORTAL_PAINT_BOUNCE = PORTAL_PAINT_COUNT + 1

local PAINT_INFO = {}

PAINT_INFO.COLOR 	= Color(50, 135, 355)
PAINT_INFO.NAME		= "Repulsion" 

if SERVER then

local function Bounce(ply, normal)
	ply:SetVelocity(normal * 400)
	ply:EmitSound("TA:PlayerBounce")
end

-- When player step in paint
function PAINT_INFO:OnEnter(ply, normal)
	if LIB_MATH_TA:DegreeseBetween(normal, ORIENTATION_DEFAULT) > 35 then return end
	
	ply:EmitSound("TA:PaintBounceEnter")
end

-- When player step out paint
function PAINT_INFO:OnExit(ply, normal)
	if LIB_MATH_TA:DegreeseBetween(normal, ORIENTATION_DEFAULT) > 35 then return end
	
	ply:EmitSound("TA:PaintBounceExit")
end

-- When player step from other type to this
function PAINT_INFO:OnChangeTo(ply, oldType, normal)
	if LIB_MATH_TA:DegreeseBetween(normal, ORIENTATION_DEFAULT) > 35 then return end
	
	if oldType == PORTAL_PAINT_SPEED then
		Bounce(ply, normal)
	end
end

-- When player step from this type to other
function PAINT_INFO:OnChangeFrom(ply, newType, normal)
end

-- Handling player landing
function PAINT_INFO:OnLanding(ply, normal, speed)
	local plyVelocity = ply:GetVelocity()
	
	-- skip if player stand on the ground
	-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
	if not ply:KeyDown(IN_DUCK) then
		local WTL = WorldToLocal(plyVelocity, Angle(), Vector(), normal:Angle() + Angle(90, 0, 0))
		WTL = Vector(0, 0, math.max(math.abs(WTL.z), 400))
		local LTW = LocalToWorld(WTL, Angle(), Vector(), normal:Angle() + Angle(90, 0, 0))
		LTW.z = math.max(200, LTW.z / 2)
		
		ply:SetVelocity(LTW + Vector(0, 0, LTW.z))
		ply:EmitSound("TA:PlayerBounce")
	end
end

-- Handling fall damage
function PAINT_INFO:OnGetFallDamage(ply, speed)
	-- Fall damage reduction to zero
	return 0
end

-- Handling key presses
function PAINT_INFO:OnButtonPressed(ply, normal, key)
	if LIB_MATH_TA:DegreeseBetween(normal, ORIENTATION_DEFAULT) > 35 then return end
	
	if key == IN_JUMP then Bounce(ply, normal) end
end

-- Handling painted entity
function PAINT_INFO:EntityThink(ent)
end

end -- SERVER

LIB_APERTURE:CreateNewPaintType(PORTAL_PAINT_BOUNCE, PAINT_INFO)
