TOOL.Tab 		= "Aperture"
TOOL.Category 	= "Puzzle elements"
TOOL.Name 		= "#tool.aperture_wall_projector.name"

TOOL.ClientConVar["keyenable"] = "45"
TOOL.ClientConVar["startenabled"] = "0"
TOOL.ClientConVar["toggle"] = "0"
TOOL.ClientConVar["paint_type"] = "1"
TOOL.ClientConVar["paint_radius"] = "50"
TOOL.ClientConVar["paint_flow_type"] = "10"
TOOL.ClientConVar["paint_launch_speed"] = "0"

local PAINT_MAX_LAUNCH_SPEED = 1000

if CLIENT then
	language.Add("tool.aperture_wall_projector.name", "Hard Light Bridge")
	language.Add("tool.aperture_wall_projector.desc", "A Hard Light Bridge used to make a bridges between surfaces")
	language.Add("tool.aperture_wall_projector.0", "Left click to place")
	language.Add("tool.aperture_wall_projector.enable", "Enable")
	language.Add("tool.aperture_wall_projector.startenabled", "Enabled")
	language.Add("tool.aperture_wall_projector.startenabled.help", "Hard Light Bridge will be enabled when placed")
	language.Add("tool.aperture_wall_projector.toggle", "Toggle")
end

if SERVER then

	function MakeWallProjector(ply, pos, ang, key_enable, startenabled, toggle, data)
		local ent = ents.Create("ent_wall_projector")
		if not IsValid(ent) then return end
		
		duplicator.DoGeneric(ent, data)

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
			ply:AddCleanup("#tool.aperture_wall_projector.name", ent)
		end
		
		return ent
	end
	
	duplicator.RegisterEntityClass("ent_wall_projector", MakeWallProjector, "pos", "ang", "key_enable", "startenabled", "toggle", "data")
end

function TOOL:LeftClick( trace )
	-- Ignore if place target is Alive
	//if ( trace.Entity and ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then return false end

	if CLIENT then return true end
	
	-- if not APERTURESCIENCE.ALLOWING.paint and not self:GetOwner():IsSuperAdmin() then self:GetOwner():PrintMessageHUD_PRINTTALK, "This tool is disabled" return end

	local ply = self:GetOwner()
	
	local key_enable = self:GetClientNumber("keyenable")
	local startenabled = self:GetClientNumber("startenabled")
	local toggle = self:GetClientNumber("toggle")
	
	local pos = trace.HitPos
	local ang = trace.HitNormal:Angle()
	
	local ent = MakeWallProjector(ply, pos, ang, key_enable, startenabled, toggle)
		
	undo.Create("Hard Light Bridge")
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
	local mdl = "models/props/wall_emitter.mdl"
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
	CPanel:AddControl("Header", {Description = "#tool.aperture_wall_projector.desc"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_wall_projector.startenabled", Command = "aperture_wall_projector_startenabled", Help = true})
	CPanel:AddControl("Numpad", {Label = "#tool.aperture_wall_projector.enable", Command = "aperture_wall_projector_keyenable"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_wall_projector.toggle", Command = "aperture_wall_projector_toggle"})
end