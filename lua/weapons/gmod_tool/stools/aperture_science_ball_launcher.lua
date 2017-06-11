TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_ball_launcher.name"

if (CLIENT) then
	language.Add( "tool.aperture_science_ball_launcher.name", "Ball launcher" )
	language.Add( "tool.aperture_science_ball_launcher.desc", "Creates ball launcher" )
	language.Add( "tool.aperture_science_ball_launcher.0", "Left click to use" )
end

function MakeBallLauncher( ply, pos, ang )
	local ent = ents.Create( "ent_ball_launcher" )
	if (not IsValid(ent)) then return end
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	if (IsValid(ply)) then
		ply:AddCleanup( "ball_launcher", ent )
		ply:AddCount( "ball_launcher", ent )
	end
	return ent
end	


function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	local pos = trace.HitPos + trace.HitNormal / 2
	local ang = trace.HitNormal:Angle()
	if SERVER then local ent = MakeBallLauncher(ply, pos, ang) end
	undo.Create( "Ball launcher" )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()
	return true, ent
end


function TOOL:UpdateGhostWallProjector( ent, ply )
	if (not IsValid(ent)) then return end
	local trace = ply:GetEyeTrace()
	if (not trace.Hit or trace.Entity and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or APERTURESCIENCE:GASLStuff(trace.Entity))) then
		ent:SetNoDraw( true )
		return
	end
	local CurPos = ent:GetPos()
	local pos = trace.HitPos + trace.HitNormal / 2
	local ang = trace.HitNormal:Angle()
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetNoDraw( false )
end

function TOOL:Think()
	local mdl = "models/props/combine_ball_launcher.mdl"
	if (!util.IsValidModel(mdl)) then self:ReleaseGhostEntity() return end
	if (not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end
	self:UpdateGhostWallProjector(self.GhostEntity, self:GetOwner())
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

end