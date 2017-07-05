TOOL.Tab 		= "Aperture"
TOOL.Category 	= "Puzzle elements"
TOOL.Name 		= "#tool.aperture_catapult.name"
TOOL.CatapultPlaced = nil
TOOL.CatapultPos = nil
TOOL.CatapultAng = nil

TOOL.ClientConVar["model"] = "models/props/laser_emitter.mdl"
TOOL.ClientConVar["keyenable"] = "45"
TOOL.ClientConVar["startenabled"] = "0"
TOOL.ClientConVar["toggle"] = "0"

if CLIENT then
	language.Add("tool.aperture_catapult.name", "Areial Faith Plate")
	language.Add("tool.aperture_catapult.desc", "The Areial Faith Plate will catapult player's to choosen location")
	language.Add("tool.aperture_catapult.0", "Left click to place")
	language.Add("tool.aperture_catapult.enable", "Enable")
	language.Add("tool.aperture_catapult.startenabled", "Start Enabled")
end

if SERVER then

	function MakeCatapult(ply, pos, ang, key_enable, startenabled, toggle, data)
		local ent = ents.Create("ent_catapult")
		if not IsValid(ent) then return end
		
		duplicator.DoGeneric(ent, data)

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetStartEnabled(tobool(startenabled))
		ent:Spawn()
		
		if tobool(startenabled) then ent:ToggleEnable(false) end

		if IsValid(ply) then
			ply:AddCleanup("#tool.aperture_catapult.name", ent )
			ply:AddCount( "catapults", ent )
		end
		
		return ent
	end
	
	duplicator.RegisterEntityClass("ent_catapult", MakeCatapult, "startenabled", "data")
end

function TOOL:LeftClick( trace )
	-- Ignore if place target is Alive
	if trace.Entity and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	-- if not APERTURESCIENCE.ALLOWING.tractor_beam and not self:GetOwner():IsSuperAdmin() then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	if self.CatapultPlaced then
		local ply = self:GetOwner()
		local model = self:GetClientInfo("model")
		local key_enable = self:GetClientNumber("keyenable")
		local startenabled = self:GetClientNumber("startenabled")
		local toggle = self:GetClientNumber("toggle")
		local pos = self.CatapultPos
		local ang = self.CatapultAng
		
		local ent = MakeCatapult(ply, pos, ang, startenabled)

		self.CatapultPlaced = false

		undo.Create("#tool.aperture_catapult.name")
			undo.AddEntity(ent)
			undo.SetPlayer(ply)
		undo.Finish()

		return true, ent
	else
		self.CatapultPos = trace.HitPos + trace.HitNormal * 10
		self.CatapultAng = trace.HitNormal:Angle() + Angle(90, 0, 0)
		self.CatapultPlaced = true
	end
end

function TOOL:RightClick( trace )
	if self.CatapultPlaced then
		self.CatapultPlaced = false
	end

	print(self.CatapultPos)
end

function TOOL:UpdateGhostWallProjector(ent, ply)
	if not IsValid(ent) then return end

	local trace = ply:GetEyeTrace()
	if not trace.Hit or trace.Entity and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity.IsAperture) then
		ent:SetNoDraw( true )
		return
	end
	
	local pos = Vector(0, 0, 0)
	if self.CatapultPlaced then pos = self.CatapultPos else pos = trace.HitPos + trace.HitNormal * 10 end
	local ang = trace.HitNormal:Angle() + Angle( 90, 0, 0 )

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetNoDraw(false)
end

function TOOL:Think()
	local mdl = "models/aperture/faith_plate_128.mdl"
	if not util.IsValidModel(mdl) then self:ReleaseGhostEntity() return end

	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != mdl then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostWallProjector(self.GhostEntity, self:GetOwner())
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Description = "#tool.aperture_catapult.desc"})
	CPanel:AddControl("PropSelect", {Label = "#tool.aperture_catapult.model", ConVar = "aperture_catapult_model", Models = list.Get("PortalCatapultModels"), Height = 0})
	CPanel:AddControl("Numpad", {Label = "#tool.aperture_catapult.enable", Command = "aperture_catapult_keyenable"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_catapult.startenabled", Command = "aperture_catapult_startenabled"})
end

list.Set("PortalCatapultModels", "models/aperture/faith_plate_128.mdl", {})