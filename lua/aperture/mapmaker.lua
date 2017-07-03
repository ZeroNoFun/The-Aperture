--Local vars--
local c_Ghost = nil
local Inited = false
local waspressed = false

local meta = FindMetaTable( "Player" )
AccessorFunc( meta, "player_mode", "InEditor", FORCE_BOOL )
--Local vars

--APERTURE--
LIB_APERTURE.MAP_PROPS = {}

function LIB_APERTURE:RegisterProp(prop)
table.insert(LIB_APERTURE.MAP_PROPS, prop)
end

local map_props = file.Find("aperture/mapmaker_props/*.lua", "LUA")
for _, plugin in ipairs(map_props) do
	include("mapmaker_props/" .. plugin)
end

--APERTURE--

function MapmakerInit(ply)
c_Ghost = ents.CreateClientProp()
c_Ghost:Spawn()
c_Ghost:DrawShadow(false)
c_Ghost:SetRenderMode(RENDERMODE_TRANSALPHA)
Inited = true
end

function ChangeMode(ply)
if not Inited then MapmakerInit(ply) end

ply:SetInEditor(not ply:GetInEditor())
if not ply:GetInEditor() then GUI_DISPOSE() end
local alpha = (ply:GetInEditor() and 1 or 0) * 190
c_Ghost:SetColor(Color(c_Ghost:GetColor().r, c_Ghost:GetColor().g, c_Ghost:GetColor().b, alpha))
end

function GetMousePressed(key)
if input.WasMousePressed(key) and waspressed == false then
waspressed = true
return true
elseif not input.WasMousePressed(key) then
waspressed = false
return false
end
end

function CTick(ply)
if not ply:GetInEditor() then return end

if Inited and not IsValid(c_Ghost) then MapmakerInit(ply) end

local tr = util.TraceLine( {
	start = ply:GetShootPos(),
	endpos = ply:GetShootPos() + ply:GetAimVector() * 10000,
	filter = ply
} )

c_Ghost:SetModel(GetConVar("aperture_mapmaker_prop"):GetString())
c_Ghost:SetPos(LIB_APERTURE:SnapToGrid(tr, 128, 25))

if GetMousePressed(107) then
net.Start("PlaceProp")
net.SendToServer()
end
end

local selector_frame = nil

function GUI()
GUI_SELECTOR()
end

function GUI_DISPOSE()
if IsValid(selector_frame) then selector_frame:Close() end
end

function GUI_SELECTOR()
selector_frame = vgui.Create( "DFrame" )
selector_frame:SetPos( 5, 5 )
selector_frame:SetSize( 500, 500 )
selector_frame:SetTitle( "Selector" )
selector_frame:SetVisible( true )
selector_frame:SetDraggable( true )
selector_frame:ShowCloseButton( true )
selector_frame:MakePopup()

for k, v in pairs(LIB_APERTURE.MAP_PROPS) do
print(v.name)
local Panel = vgui.Create( "DPanel", selector_frame )
Panel:SetPos( 105 * (k - 1), 20 )
Panel:SetSize( 100, 100 )

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize(100, 100)
icon:SetModel( v.MODEL )
local mn, mx = icon.Entity:GetRenderBounds()
local size = 0
size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

icon:SetFOV( 45 )
icon:SetCamPos( Vector( size, size, size ) )
icon:SetLookAt( ( mn + mx ) * 0.5 )

icon.DoClick = function()
 local selected_prop = GetConVar( "aperture_mapmaker_prop" )
 selected_prop:SetString(v.MODEL) 
end
end
end


--Net receiving--
net.Receive("PlayerInit", function(len, ply) CInit(ply) end)
--Net receiving--

--Hooks--
hook.Add( "PlayerTick", "Tick", CTick )
--Hooks--

--Commands--
concommand.Add( "aperture_mapmaker", ChangeMode )
concommand.Add( "aperture_mapmaker_gui", GUI )
--Commands

--CVars--
CreateClientConVar( "aperture_mapmaker_prop", "models/aperture/panel.mdl", true, true, "Changes current prop model. Feel free to use any model you need." )
--CVars

if CLIENT then return end

function Init(ply)
ply:SetInEditor(false)
end

function PlaceProp(ply)
local tr = util.TraceLine( {
	start = ply:GetShootPos(),
	endpos = ply:GetShootPos() + ply:GetAimVector() * 10000,
	filter = ply
} )

local prop = ents.Create( "gmod_button" )
prop:SetModel(ply:GetInfo("aperture_mapmaker_prop"))
prop:SetPos(LIB_APERTURE:SnapToGrid(tr, 128, 25))
prop:Spawn()

undo.Create("mapmaker_prop")
 undo.AddEntity(prop)
 undo.SetPlayer(ply)
undo.Finish()

end

--Net receiving--
net.Receive("PlaceProp", function(len, ply) PlaceProp(ply) end)
--Net receiving--

--Hooks--
hook.Add( "PlayerInitialSpawn", "InitPlayer", Init )
--Hooks--

--Message precaching--
util.AddNetworkString("PlayerInit")
util.AddNetworkString("PlaceProp")
--Message precaching--