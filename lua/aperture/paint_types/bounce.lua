AddCSLuaFile()

if not LIB_APERTURE then return end

--============= Repulsion Gel ==============

PORTAL_PAINT_BOUNCE = PORTAL_PAINT_COUNT + 1

local PAINT_INFO = {}

PAINT_INFO.COLOR 	= Color(50, 125, 255)
PAINT_INFO.NAME		= "Repulsion" 

if SERVER then

-- When player step in paint
function PAINT_INFO:OnEnter(ply, normal)
	ply:EmitSound("GASL.GelBounceEnter")
end

-- When player step out paint
function PAINT_INFO:OnExit(ply)
	ply:EmitSound("GASL.GelBounceExit")
end

-- When player step from other type to this
function PAINT_INFO:OnChangeTo(ply, oldType, normal)
	if oldType == PORTAL_PAINT_SPEED then
		PAINT_INFO:OnJump(ply, normal)
	end
end

-- When player step from this type to other
function PAINT_INFO:OnChangeFrom(ply, newType, normal)
end

-- When player jump
function PAINT_INFO:OnJump(ply, normal)
	ply:SetVelocity(Vector(0, 0, 400))
	ply:EmitSound("GASL.GelBounce")
end

-- Handling paint
function PAINT_INFO:Think(ply, normal)
	local plyVelocity = ply:GetVelocity()
	
	-- skip if player stand on the ground
	-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
	if not APERTURESCIENCE:IsPlayerOnGround(ply) and not ply:KeyDown(IN_DUCK) then
		local WTL = WorldToLocal(plyVelocity, Angle(), Vector(), normal:Angle() + Angle(90, 0, 0))
		WTL = Vector(0, 0, math.max( math.abs( WTL.z ) * 2, 800 ) )
		local LTW = LocalToWorld(WTL, Angle(), Vector(), normal:Angle() + Angle(90, 0, 0))
		LTW.z = math.max(200, LTW.z / 2 )
		
		ply:SetVelocity(LTW + Vector(0, 0, math.abs(ply:GetVelocity().z)))
		ply:EmitSound("GASL.GelBounce")
	end
end


-- Handling painted entity
function PAINT_INFO:EntityThink(ent)
end

end -- SERVER

LIB_APERTURE:CreateNewPaintType(PORTAL_PAINT_BOUNCE, PAINT_INFO)
