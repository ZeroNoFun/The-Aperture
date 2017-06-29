AddCSLuaFile()

if not LIB_APERTURE then return end

--============= Cleanser Gel ==============

PORTAL_PAINT_WATER = PORTAL_PAINT_COUNT + 1

local PAINT_INFO = {}

PAINT_INFO.COLOR 	= Color(255, 255, 255)
PAINT_INFO.NAME		= "Cleanser" 

if SERVER then

end -- SERVER

LIB_APERTURE:CreateNewPaintType(PORTAL_PAINT_WATER, PAINT_INFO)
