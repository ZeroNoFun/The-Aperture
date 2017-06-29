TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_tractor_beam.name"

TOOL.ClientConVar["startenabled"] = "0"
TOOL.ClientConVar["startreversed"] = "0"

if CLIENT then
	language.Add("tool.aperture_science_tractor_beam.name", "Exursion Funnel")
	language.Add("tool.aperture_science_tractor_beam.desc", "Makes Exursion Funnel")
	language.Add("tool.aperture_science_tractor_beam.0", "Left click to place")
	language.Add("tool.aperture_science_tractor_beam.enable", "Enable")
	language.Add("tool.aperture_science_tractor_beam.reverse", "Reverse")
	language.Add("tool.aperture_science_tractor_beam.startenabled", "Start Enabled")
	language.Add("tool.aperture_science_tractor_beam.startreversed", "Start Reversed")
	language.Add("tool.aperture_science_tractor_beam.toggle", "Toggle")
end

if SERVER then

	function MakeTractorBeam(ply, pos, ang, startenabled, startreversed, data)
		if IsValid(pl) and not pl:CheckLimit("tractor_beams") then return false end
		local ent = ents.Create("ent_tractor_beam")
		if not IsValid(ent) then return end
		
		duplicator.DoGeneric(ent, data)

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetStartEnabled(tobool(startenabled))
		ent:SetStartReversed(tobool(startreversed))
		ent:Spawn()
		ent.startenabled = startenabled
		ent.startreversed = startreversed
		
		if tobool(startenabled) then ent:ToggleEnable(false) end
		if tobool(startreversed) then ent:ToggleReverse(false) end

		if ( IsValid( ply ) ) then
			ply:AddCleanup( "tractor_beams", ent )
			ply:AddCount( "tractor_beams", ent )
		end
		
		return ent
	end
	
	duplicator.RegisterEntityClass("ent_tractor_beam", MakeTractorBeam, "startenabled", "startreversed", "data")
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if trace.Entity and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	//if not APERTURESCIENCE.ALLOWING.tractor_beam and not self:GetOwner():IsSuperAdmin() then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber("startenabled")
	local startreverse = self:GetClientNumber("startreversed")
	local Pos = trace.HitPos + trace.HitNormal * 31
	local Ang = trace.HitNormal:Angle() + Angle(90, 0, 0)
	
	local ent = MakeTractorBeam(ply, Pos, Ang, startenabled, startreverse)
	
	undo.Create("Exursion Funnel")
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()

	return true, ent
	
end

function TOOL:UpdateGhostWallProjector(ent, ply)
	if not IsValid(ent) then return end

	local trace = ply:GetEyeTrace()
	if not trace.Hit or trace.Entity and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity.IsAperture) then
		ent:SetNoDraw( true )
		return
	end
	
	local curPos = ent:GetPos()
	local pos = trace.HitPos + trace.HitNormal * 31
	local ang = trace.HitNormal:Angle() + Angle( 90, 0, 0 )

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetNoDraw(false)

end

function TOOL:Think()
	local mdl = "models/gasl/tractor_beam_128.mdl"
	if not util.IsValidModel(mdl) then self:ReleaseGhostEntity() return end

	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != mdl then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostWallProjector(self.GhostEntity, self:GetOwner())
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Description = "#tool.aperture_science_tractor_beam.desc"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_science_tractor_beam.startenabled", Command = "aperture_science_tractor_beam_startenabled"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_science_tractor_beam.startreversed", Command = "aperture_science_tractor_beam_startreversed"})
end