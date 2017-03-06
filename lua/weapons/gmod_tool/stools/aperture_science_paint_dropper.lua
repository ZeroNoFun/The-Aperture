TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_paint_dropper.name"

TOOL.ClientConVar[ "gel_type" ] = "1"
TOOL.ClientConVar[ "gel_radius" ] = "50"
TOOL.ClientConVar[ "gel_randomize_size" ] = "0"
TOOL.ClientConVar[ "gel_amount" ] = "10"
TOOL.ClientConVar[ "gel_launch_speed" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_paint_dropper", "Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.name", "Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.desc", "Creates Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.0", "Left click to use" )
	language.Add( "tool.aperture_science_paint_dropper.gelType", "Gel Type" )
	language.Add( "tool.aperture_science_paint_dropper.gelRad", "Gel Radius" )
	language.Add( "tool.aperture_science_paint_dropper.gelRandomizeSize", "Gel Randomize Size" )
	language.Add( "tool.aperture_science_paint_dropper.gelAmount", "Gel Amount" )
	language.Add( "tool.aperture_science_paint_dropper.gelLaunchSpeed", "Gel Launch Speed" )
	language.Add( "tool.aperture_science_paint_dropper.startenabled", "Start Enabled" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then return false end

	if ( CLIENT ) then return true end
	
	if ( !APERTURESCIENCE.ALLOWING.paint && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	
	local gelType = self:GetClientNumber( "gel_type" )
	local gelRad = self:GetClientNumber( "gel_radius" )
	local gelRandomizeSize = self:GetClientNumber( "gel_randomize_size" )
	local gelAmount = self:GetClientNumber( "gel_amount" )
	local gelLaunchSpeed = self:GetClientNumber( "gel_launch_speed" )
	local startenabled = self:GetClientNumber( "startenabled" )

	local paint_dropper = MakePaintDropper( ply, trace.HitPos, trace.HitNormal:Angle() - Angle( 90, 0, 0 ), gelType, gelRad, gelAmount, gelRandomizeSize, gelLaunchSpeed, startenabled )
	
	return true
	
end

if ( SERVER ) then

	function MakePaintDropper( pl, pos, ang, gelType, gelRad, gelAmount, gelRandomizeSize, gelLaunchSpeed, startenabled )
		
		local paint_dropper = ents.Create( "ent_paint_dropper" )
		paint_dropper:SetPos( pos )
		paint_dropper:SetAngles( ang )
		paint_dropper:SetMoveType( MOVETYPE_NONE )
		paint_dropper:Spawn()
		paint_dropper.Owner = pl
		
		paint_dropper:SetGelType( gelType )
		paint_dropper:SetGelRadius( gelRad )
		paint_dropper:SetGelRandomizeSize( gelRandomizeSize )
		paint_dropper.GASL_GelAmount = gelAmount
		paint_dropper.GASL_GelLaunchSpeed = gelLaunchSpeed
		
		paint_dropper:SetStartEnabled( tobool( startenabled ) )
		paint_dropper:ToggleEnable( false )

		undo.Create( "Gel Dropper" )
			undo.AddEntity( paint_dropper )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return paint_dropper
		
	end
	
end

function TOOL:UpdateGhostCatapult( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsNPC() || trace.Entity:IsPlayer() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	local ang = trace.HitNormal:Angle()
	local pos = trace.HitPos

	ent:SetPos( pos + trace.HitNormal * 5 )
	ent:SetAngles( ang - Angle( 90, 0, 0 ) )

	ent:SetNoDraw( false )

end

function TOOL:RightClick( trace )

end

function TOOL:Think()

	local mdl = "models/props_ingame/paint_dropper.mdl"
	if ( !util.IsValidModel( mdl ) || IsValid( self.GASL_PointerGrab ) ) then self:ReleaseGhostEntity() else

		if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
			self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
		end
		
		if ( IsValid( self.GhostEntity ) ) then
			local gelType = self:GetClientNumber( "gel_type" )
			self.GhostEntity:SetSkin( gelType )
		end

		self:UpdateGhostCatapult( self.GhostEntity, self:GetOwner() )
	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_paint_dropper.desc" } )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_paint_dropper.gelType", "aperture_science_paint_dropper_gel_type" )
	combobox:AddChoice( "Repulsion", 1 )
	combobox:AddChoice( "Propulsion", 2 )
	combobox:AddChoice( "Conversion", 3 )
	combobox:AddChoice( "Cleansing", 4 )
	combobox:AddChoice( "Adhesion Gel", 5 )
		
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelRad", "aperture_science_paint_dropper_gel_radius", APERTURESCIENCE.GEL_MINSIZE, APERTURESCIENCE.GEL_MAXSIZE )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelRandomizeSize", "aperture_science_paint_dropper_gel_randomize_size", 0, 100 )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelAmount", "aperture_science_paint_dropper_gel_amount", 1, 100 )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelLaunchSpeed", "aperture_science_paint_dropper_gel_launch_speed", 0, 1000 )

	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_paint_dropper.startenabled", Command = "aperture_science_paint_dropper_startenabled" } )

end