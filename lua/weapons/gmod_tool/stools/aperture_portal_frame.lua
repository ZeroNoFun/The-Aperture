TOOL.Tab 		= "Aperture"
TOOL.Category 	= "Puzzle elements"
TOOL.Name 		= "#tool.aperture_portal_frame.name"

TOOL.ClientConVar["keyenable"] = "45"
TOOL.ClientConVar["startenabled"] = "0"
TOOL.ClientConVar["model"] = "models/props/portal_emitter.mdl"
TOOL.ClientConVar["toggle"] = "0"

if CLIENT then
	language.Add("tool.aperture_portal_frame.name", "Portal Emitter")
	language.Add("tool.aperture_portal_frame.desc", "A Portal Emitter used to make a bridges between surfaces")
	language.Add("tool.aperture_portal_frame.0", "Left click to place")
	language.Add("tool.aperture_portal_frame.enable", "Enable")
	language.Add("tool.aperture_portal_frame.startenabled", "Enabled")
	language.Add("tool.aperture_portal_frame.startenabled.help", "Portal Emitter will spawn portal when placed")
	language.Add("tool.aperture_portal_frame.toggle", "Toggle")
end

if SERVER then

	function MakePortalFrame(ply, pos, ang, model, key_enable, startenabled, toggle, data)
		local ent = ents.Create("ent_portal_frame")
		if not IsValid(ent) then return end
		
		duplicator.DoGeneric(ent, data)

		ent:SetModel(model)
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetMoveType(MOVETYPE_NONE)
		ent.Owner = ply
		ent:SetStartEnabled(tobool(startenabled))
		ent:SetToggle(tobool(toggle))
		ent:Spawn()
		
		-- initializing numpad inputs
		ent.NumDown = numpad.OnDown(ply, key_enable, "WallProjector_Enable", ent, true)
		ent.NumUp = numpad.OnUp(ply, key_enable, "WallProjector_Enable", ent, false)

		-- saving data
		local ttable = {
			key_enable = key_enable,
			ply = ply,
			startenabled = startenabled,
			toggle = toggle,
		}

		table.Merge(ent:GetTable(), ttable)

		if IsValid(ply) then
			ply:AddCleanup("#tool.aperture_portal_frame.name", ent)
		end
		
		return ent
	end
	
	duplicator.RegisterEntityClass("ent_portal_frame", MakePortalFrame, "pos", "ang", "model", "key_enable", "startenabled", "toggle", "data")
end

function TOOL:LeftClick( trace )
	-- Ignore if place target is Alive
	//if ( trace.Entity and ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then return false end

	if CLIENT then return true end
	
	-- if not APERTURESCIENCE.ALLOWING.paint and not self:GetOwner():IsSuperAdmin() then self:GetOwner():PrintMessageHUD_PRINTTALK, "This tool is disabled" return end

	local ply = self:GetOwner()
	local model = self:GetClientInfo("model")
	local key_enable = self:GetClientNumber("keyenable")
	local startenabled = self:GetClientNumber("startenabled")
	local toggle = self:GetClientNumber("toggle")
	
	local pos = trace.HitPos
	local ang = trace.HitNormal:Angle()
	
	local ent = MakePortalFrame(ply, pos, ang, model, key_enable, startenabled, toggle)
		
	undo.Create("Portal Emitter")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	
	return true, ent
end

function TOOL:UpdateGhostWallProjector(ent, ply)
	if not IsValid(ent) then return end

	local trace = ply:GetEyeTrace()
	if not trace.Hit or trace.Entity and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity.IsAperture) then
		ent:SetNoDraw(true)
		return
	end
	
	local curPos = ent:GetPos()
	local pos = trace.HitPos
	local ang = trace.HitNormal:Angle()

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetNoDraw(false)
end

function TOOL:RightClick( trace )

end

function TOOL:Think()
	local mdl = self:GetClientInfo("model")
	if not util.IsValidModel(mdl) then self:ReleaseGhostEntity() return end

	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != mdl then
		self:MakeGhostEntity(mdl, Vector(0, 0, 0), Angle(0, 0, 0))
	end
	
	if IsValid(self.GhostEntity) then
		local paintType = self:GetClientNumber("paint_type")
		self.GhostEntity:SetSkin(paintType)
	end

	self:UpdateGhostWallProjector(self.GhostEntity, self:GetOwner())
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl("Header", {Description = "#tool.aperture_portal_frame.desc"})
	CPanel:AddControl("PropSelect", {ConVar = "aperture_portal_frame_model", Models = list.Get("PortalFrameModels"), Height = 3})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_portal_frame.startenabled", Command = "aperture_portal_frame_startenabled", Help = true})
	CPanel:AddControl("Numpad", {Label = "#tool.aperture_portal_frame.enable", Command = "aperture_portal_frame_keyenable"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_portal_frame.toggle", Command = "aperture_portal_frame_toggle"})
end

list.Set("PortalFrameModels", "models/props/autoportal_frame/autoportal_frame.mdl", {})
list.Set("PortalFrameModels", "models/props/portal_emitter.mdl", {})