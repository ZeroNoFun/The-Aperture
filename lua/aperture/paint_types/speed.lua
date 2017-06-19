AddCSLuaFile()

if not LIB_APERTURE then return end

--============= Propulsion Gel ==============

PORTAL_PAINT_SPEED = PORTAL_PAINT_COUNT + 1

local PAINT_INFO = {}

PAINT_INFO.COLOR 	= Color(255, 100, 0)
PAINT_INFO.NAME		= "Propulsion" 

if SERVER then

-- When player step in paint
function PAINT_INFO:OnEnter(ply, normal)
	ply:EmitSound("GASL.GelSpeedEnter")
end

-- When player step out paint
function PAINT_INFO:OnExit(ply)
	ply:EmitSound("GASL.GelSpeedExit")
end

-- When player step from other type to this
function PAINT_INFO:OnChangeTo(ply, oldType, normal)
end

-- When player step from this type to other
function PAINT_INFO:OnChangeFrom(ply, newType, normal)
end

-- Handling paint
function PAINT_INFO:Think(ply, normal)
	local plyVelocity = ply:GetVelocity()

	if not ply.GASL_GelPlayerVelocity or ply.GASL_GelPlayerVelocity:Length() == math.huge then ply.GASL_GelPlayerVelocity = Vector() end
	if plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
	
	-- When player moving towards it will increese speed
	if ply:KeyDown(IN_FORWARD) then
		ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector(ply:GetForward().x, ply:GetForward().y, 0) * 30
	end
	
	ply:SetVelocity(Vector(ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0) * FrameTime() * 40)
	ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
end

-- Handling painted entity
function PAINT_INFO:EntityThink(ent)
end

end -- SERVER

LIB_APERTURE:CreateNewPaintType(PORTAL_PAINT_SPEED, PAINT_INFO)
