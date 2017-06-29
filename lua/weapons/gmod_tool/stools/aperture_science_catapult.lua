TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_catapult.name"

TOOL.ClientConVar[ "startenabled" ] = "0"

if CLIENT then
	language.Add("tool.aperture_science_catapult.name", "Catapult")
	language.Add("tool.aperture_science_catapult.desc", "Makes Catapult (Plate of Faith)")
	language.Add("tool.aperture_science_catapult.0", "Left click to place")
	language.Add("tool.aperture_science_catapult.enable", "Enable")
	language.Add("tool.aperture_science_catapult.startenabled", "Start Enabled")
end

if SERVER then

	function MakeCatapult(ply, pos, ang, startenabled, data)
		if IsValid(pl) and not pl:CheckLimit("tractor_beams") then return false end
		local ent = ents.Create("ent_catapult")
		if not IsValid(ent) then return end
		
		duplicator.DoGeneric(ent, data)

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetStartEnabled(tobool(startenabled))
		ent:Spawn()
		ent.startenabled = startenabled
		
		if (tobool(startenabled)) then ent:ToggleEnable(false) end

		if ( IsValid( ply ) ) then
			ply:AddCleanup( "catapults", ent )
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

	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber("startenabled")
	local Pos = trace.HitPos + trace.HitNormal * 31
	local Ang = trace.HitNormal:Angle() + Angle(90, 0, 0)
	
	local ent = MakeCatapult(ply, Pos, Ang, startenabled)
	
	undo.Create("Catapult")
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
	local mdl = "models/aperture/faith_plate_128.mdl"
	if not util.IsValidModel(mdl) then self:ReleaseGhostEntity() return end

	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != mdl then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostWallProjector(self.GhostEntity, self:GetOwner())
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Description = "#tool.aperture_science_catapult.desc"})
	CPanel:AddControl("CheckBox", {Label = "#tool.aperture_science_tractor_beam.startenabled", Command = "aperture_science_tractor_beam_startenabled"})
end