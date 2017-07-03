AddCSLuaFile()

if not LIB_APERTURE then return end

local PROP_INFO = {}

PROP_INFO.NAME = "Reflection ube"
PROP_INFO.DESC = "Reflection cube"
PROP_INFO.ENT = "portal_reflection_box"
PROP_INFO.MODEL = "models/props/reflection_cube.mdl"

LIB_APERTURE:RegisterProp(PROP_INFO)