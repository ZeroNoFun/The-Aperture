TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_item_dropper.name"

TOOL.ClientConVar[ "model" ] = "models/props/switch001.mdl"
TOOL.ClientConVar[ "respawn" ] = "0"
TOOL.ClientConVar[ "drop_type" ] = "1"
TOOL.ClientConVar[ "dropatstart" ] = "0"

if ( CLIENT ) then

	language.Add( "tool.aperture_science_item_dropper.name", "Dropper" )
	language.Add( "tool.aperture_science_item_dropper.desc", "Creates Dropper" )
	language.Add( "tool.aperture_science_item_dropper.0", "Left click to use" )
	language.Add( "tool.aperture_science_item_dropper.dropType", "Drop Type" )
	language.Add( "tool.aperture_science_item_dropper.dropatstart", "Drop when Place" )
	language.Add( "tool.aperture_science_item_dropper.respawn", "Respawn on it lost" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end

	if ( !APERTURESCIENCE.ALLOWING.item_dropper && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local normal = trace.HitNormal
	normal = Vector( math.Round( normal.x ),  math.Round( normal.y ),  math.Round( normal.z ) )
	if ( normal != Vector( 0, 0, -1 ) || APERTURESCIENCE:GASLStuff( trace.Entity ) ) then return end
	
	local ply = self:GetOwner()
	local respawn = self:GetClientNumber( "respawn" )
	local dropType = self:GetClientNumber( "drop_type" )
	local dropatstart = self:GetClientNumber( "dropatstart" )

	local dropper = MakeDropper( ply, trace.HitPos + trace.HitNormal * 85, trace.HitNormal:Angle() - Angle( 90, 0, 0 ), dropType, dropatstart, respawn, key_drop )
	
	return true
	
end

if ( SERVER ) then

	function MakeDropper( pl, pos, ang, drop_type, dropatstart, respawn )
		
		local dropper = ents.Create( "ent_item_dropper" )
		dropper:SetPos( pos )
		dropper:SetAngles( ang )
		dropper:SetMoveType( MOVETYPE_NONE )
		dropper:Spawn()
		dropper:SetRespawn( tobool( respawn ) )
		dropper:SetDropType( drop_type )
		
		if ( tobool( dropatstart ) ) then timer.Simple( 1.0, function() if ( IsValid( dropper ) ) then dropper:Drop() end end ) end

		undo.Create( "Dropper" )
			undo.AddEntity( dropper )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return dropper
		
	end
	
end

function TOOL:UpdateGhostItemDropper( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	local normal = trace.HitNormal
	normal = Vector( math.Round( normal.x ),  math.Round( normal.y ),  math.Round( normal.z ) )
	
	if ( !trace.Hit || normal != Vector( 0, 0, -1 ) 
		|| trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return
	end
	
	local CurPos = ent:GetPos()

	local ang = trace.HitNormal:Angle() - Angle( 90, 0, 0 )
	local pos = trace.HitPos
	
	ent:SetPos( pos + trace.HitNormal * 85)
	ent:SetAngles( ang )
	ent:SetNoDraw( false )

end

function TOOL:Think()

	local mdl = "models/prop_backstage/item_dropper.mdl"
	if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostItemDropper( self.GhostEntity, self:GetOwner() )

end


function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_item_dropper.desc" } )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_item_dropper.dropType", "aperture_science_item_dropper_drop_type" )
	combobox:AddChoice( "Weighted Cube", 0 )
	combobox:AddChoice( "Companion Cube", 1 )
	combobox:AddChoice( "Weighted Sphere", 2 )
	combobox:AddChoice( "Reflector Cube", 3 )
	combobox:AddChoice( "Franken Cube", 4 )
	combobox:AddChoice( "Bombs", 5 )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_item_dropper.dropatstart", Command = "aperture_science_item_dropper_dropatstart" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_item_dropper.respawn", Command = "aperture_science_item_dropper_respawn" } )

end