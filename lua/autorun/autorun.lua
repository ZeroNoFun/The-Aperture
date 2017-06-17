AddCSLuaFile( "aperture/main.lua" )
AddCSLuaFile( "autorun/cl_gaslcontrolpanel.lua" )
AddCSLuaFile("map_maker/map_maker.lua")
AddCSLuaFile("map_maker/map_maker_include.lua")

include( "aperture/main.lua" )
include("map_maker/map_maker.lua")
include("map_maker/map_maker_include.lua")

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop( "862644776" ) // Workshop download
end



