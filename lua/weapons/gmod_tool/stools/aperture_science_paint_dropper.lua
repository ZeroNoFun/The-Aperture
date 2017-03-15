TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_paint_dropper.name"

TOOL.ClientConVar[ "paint_type" ] = "1"
TOOL.ClientConVar[ "paint_radius" ] = "50"
TOOL.ClientConVar[ "paint_flow_type" ] = "10"
TOOL.ClientConVar[ "paint_launch_speed" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	language.Add( "tool.aperture_science_paint_dropper.name", "Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.desc", "Creates Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.0", "Left click to use" )
	language.Add( "tool.aperture_science_paint_dropper.paintType", "Gel Type" )
	language.Add( "tool.aperture_science_paint_dropper.paintFlowType", "Gel Flow Type" )
	language.Add( "tool.aperture_science_paint_dropper.paintLaunchSpeed", "Gel Launch Speed" )
	language.Add( "tool.aperture_science_paint_dropper.startenabled", "Start Enabled" )
	
end

local function FlowTypeToInfo( flowType )

	local flowTypeToInfo = {
		[1] = { amount = 96, radius = 50 },
		[2] = { amount = 97, radius = 75 },
		[3] = { amount = 98, radius = 120 },
		[4] = { amount = 10, radius = 200 },
		[5] = { amount = 80, radius = 1 }
	}
	
	return flowTypeToInfo[ flowType ]

end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then return false end

	if ( CLIENT ) then return true end
	
	if ( !APERTURESCIENCE.ALLOWING.paint && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	
	local startenabled = self:GetClientNumber( "startenabled" )
	local paintType = self:GetClientNumber( "paint_type" )
	local paintFlowType = self:GetClientNumber( "paint_flow_type" )
	local paintLaunchSpeed = self:GetClientNumber( "paint_launch_speed" )
	
	local paint_dropper = MakePaintDropper( ply, trace.HitPos, trace.HitNormal:Angle() - Angle( 90, 0, 0 ), paintType, paintFlowType, paintLaunchSpeed, startenabled )
	
	return true
	
end

if ( SERVER ) then

	function MakePaintDropper( pl, pos, ang, paintType, paintFlowType, paintLaunchSpeed, startenabled )
		
		local FlowInfo = FlowTypeToInfo( paintFlowType )
		
		local paint_dropper = ents.Create( "ent_paint_dropper" )
		paint_dropper:SetPos( pos )
		paint_dropper:SetAngles( ang )
		paint_dropper:SetMoveType( MOVETYPE_NONE )
		paint_dropper:Spawn()
		paint_dropper.Owner = pl
		
		paint_dropper:SetPaintType( paintType )
		paint_dropper:SetPaintRadius( FlowInfo.radius )
		paint_dropper:SetPaintAmount( FlowInfo.amount )
		paint_dropper:SetPaintLaunchSpeed( paintLaunchSpeed )
		
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
			local paintType = self:GetClientNumber( "paint_type" )
			self.GhostEntity:SetSkin( paintType )
		end

		self:UpdateGhostCatapult( self.GhostEntity, self:GetOwner() )
	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_paint_dropper.desc" } )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_paint_dropper.paintType", "aperture_science_paint_dropper_paint_type" )
	combobox:AddChoice( "Repulsion", 1 )
	combobox:AddChoice( "Propulsion", 2 )
	combobox:AddChoice( "Conversion", 3 )
	combobox:AddChoice( "Cleansing", 4 )
	combobox:AddChoice( "Adhesion", 5 )
	combobox:AddChoice( "Reflection", 6 )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_paint_dropper.paintFlowType", "aperture_science_paint_dropper_paint_flow_type" )
	combobox:AddChoice( "Light", 1 )
	combobox:AddChoice( "Medium", 2 )
	combobox:AddChoice( "Hard", 3 )
	combobox:AddChoice( "Bomb", 4 )
	combobox:AddChoice( "Drip", 5 )
	
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.paintLaunchSpeed", "aperture_science_paint_dropper_paint_launch_speed", 0, APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED )

	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_paint_dropper.startenabled", Command = "aperture_science_paint_dropper_startenabled" } )

end