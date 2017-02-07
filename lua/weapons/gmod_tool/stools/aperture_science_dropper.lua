TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_dropper.name"

TOOL.ClientConVar[ "keydrop" ] = "42"
TOOL.ClientConVar[ "respawn" ] = "0"
TOOL.ClientConVar[ "drop_type" ] = "1"
TOOL.ClientConVar[ "startdroped" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_dropper", "Dropper" )
	language.Add( "tool.aperture_science_dropper.name", "Dropper" )
	language.Add( "tool.aperture_science_dropper.desc", "Creates Dropper" )
	language.Add( "tool.aperture_science_dropper.0", "Left click to use" )
	language.Add( "tool.aperture_science_dropper.dropType", "Drop Type" )
	language.Add( "tool.aperture_science_dropper.startdroped", "Drop when Disabled" )
	language.Add( "tool.aperture_science_dropper.drop", "Drop" )
	language.Add( "tool.aperture_science_dropper.respawn", "Respawn on it lost" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	local key_drop = self:GetClientNumber( "keydrop" )
	local respawn = self:GetClientNumber( "respawn" )
	local dropType = self:GetClientNumber( "drop_type" )
	local startdroped = self:GetClientNumber( "startdroped" )

	local dropper = MakeDropper( ply, trace.HitPos + trace.HitNormal * 85, trace.HitNormal:Angle() - Angle( 90, 0, 0 ), dropType, startdroped, respawn, key_drop )
	
	return true
	
end

if ( SERVER ) then

	function MakeDropper( pl, pos, ang, drop_type, startdroped, respawn, key_drop )
		
		local dropper = ents.Create( "env_dropper" )
		dropper:SetPos( pos )
		dropper:SetAngles( ang )
		dropper:SetMoveType( MOVETYPE_NONE )
		dropper:Spawn()

		dropper.NumDrop = numpad.OnDown( pl, key_drop, "aperture_science_dropper_drop", dropper, 1 )

		dropper:SetDropType( drop_type )
		if ( tobool( startdroped ) ) then dropper:Drop() end
		
		dropper:SetOwner( pl )

		undo.Create( "Dropper" )
			undo.AddEntity( dropper )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return dropper
		
	end
	
end

function TOOL:UpdateGhostLaserField( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || trace.HitNormal != Vector( 0, 0, -1 ) || trace.Entity && ( trace.Entity:GetClass() == "ent_LaserField" || trace.Entity:IsPlayer() ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	local ang = trace.HitNormal:Angle()
	local pos = trace.HitPos
	local skip, rAng = LocalToWorld( Vector(), Angle( 0, 0, 0 ), Vector(), ang )

	ent:SetPos( pos )
	ent:SetAngles( rAng )

	ent:SetNoDraw( false )

end

function TOOL:Think()

	if ( !util.IsValidModel( "models/props_backstage/item_dropper.mdl" ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) ) then
		self:MakeGhostEntity( "models/props_backstage/item_dropper.mdl", Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostLaserField( self.GhostEntity, self:GetOwner() )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_dropper.desc" } )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_dropper.dropType", "aperture_science_dropper_drop_type" )
	combobox:AddChoice( "Weighted Cube", 0 )
	combobox:AddChoice( "Companion Cube", 1 )
	combobox:AddChoice( "Weighted Sphere", 2 )
	combobox:AddChoice( "Reflector Cube", 3 )
	combobox:AddChoice( "Franken Cube", 4 )
	combobox:AddChoice( "Bombs", 5 )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_dropper.startdroped", Command = "aperture_science_dropper_startdroped" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_dropper.respawn", Command = "aperture_science_dropper_respawn" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_dropper.drop", Command = "aperture_science_dropper_keydrop" } )

end