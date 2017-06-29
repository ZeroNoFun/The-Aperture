--Local vars--
local c_Ghost = nil
local Inited = false
local waspressed = false

local meta = FindMetaTable( "Player" )
AccessorFunc( meta, "player_mode", "InEditor", FORCE_BOOL )
--Local vars

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

--Net receiving--
net.Receive("PlayerInit", function(len, ply) CInit(ply) end)
--Net receiving--

--Hooks--
hook.Add( "PlayerTick", "Tick", CTick )
--Hooks--

--Commands--
concommand.Add( "aperture_mapmaker", ChangeMode )
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