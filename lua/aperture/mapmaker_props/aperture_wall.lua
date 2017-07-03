AddCSLuaFile()

if not LIB_APERTURE then return end

local PROP_INFO = {}

PROP_INFO.NAME = "Wall"
PROP_INFO.DESC = "Simple wall"
PROP_INFO.ENT = "ent_wall"
PROP_INFO.MODEL = "models/aperture/panel.mdl"

LIB_APERTURE:RegisterProp(PROP_INFO)