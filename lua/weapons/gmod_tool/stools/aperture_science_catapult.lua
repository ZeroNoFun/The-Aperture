TOOL.Category = "Aperture Science"
TOOL.Name = "Aerial Faith Plate"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "model" ] = "models/props/faith_plate.mdl"
TOOL.ClientConVar[ "keyenable" ] = "42"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

cleanup.Register( "aperture_science_catapult" )

if ( CLIENT ) then

	language.Add( "aperture_science_catapult", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.name", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.desc", "Creates Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.0", "Left click to place" )
	language.Add( "tool.aperture_science_catapult.description", "Makes Aperture Aerial Faith Plate that can launch things in the air" )
	language.Add( "tool.aperture_science_catapult.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_catapult.enable", "Enable" )
	language.Add( "tool.aperture_science_catapult.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )
	
	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end

	if ( CLIENT ) then return true end
	
	if ( self.GASL_MakePoint && ( !self.GASL_Catapult || self.GASL_Catapult && !self.GASL_Catapult:IsValid() ) ) then
	
		self.GASL_MakePoint = false
		self.GASL_Catapult = NULL
		
	end
	
	if ( self.GASL_MakePoint == nil ) then
	
		self.GASL_MakePoint = false
		self.GASL_Catapult = NULL
		
	end
	
	if ( !self.GASL_MakePoint ) then
		
		local ply = self:GetOwner()
		local model = self:GetClientInfo( "model" )
		local toggle = self:GetClientNumber( "toggle" )
		local keyenable = self:GetClientNumber( "keyenable" )
		local startenabled = self:GetClientNumber( "startenabled" )
		
		local catapult = MakeCatapult( ply, model, trace.HitPos + trace.HitNormal * 5, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, toggle, keyenable )
		self.GASL_Catapult = catapult
		
	else
	
		self.GASL_Catapult:SetLandingPoint( trace.HitPos )
		self.GASL_Catapult:SetLaunchHeight( trace.HitPos:Distance( self.GASL_Catapult:GetPos() ) / 4 )
		
	end

	self.GASL_MakePoint = !self.GASL_MakePoint
	
	return true
	
end

function MakeCatapult( pl, model, pos, ang, startenabled, toggle, key_enable )
	
	if ( !util.IsValidModel( model ) ) then return false end
	
	local catapult = ents.Create( "ent_catapult" )
	if ( !IsValid( catapult ) ) then return false end
	
	catapult:SetPos( pos )
	catapult:SetAngles( ang )
	catapult:Spawn()
	catapult:SetModel( model )
	catapult:SetSkin( 1 )
	
	catapult.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_catapult_enable", catapult, 1 )
	catapult.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_catapult_disable", catapult, 1 )
	catapult:SetStartEnabled( tobool( startenabled ) )
	catapult:SetToggle( tobool( toggle ) )
	catapult:ToggleEnable( false )

	undo.Create( "Aerial Faith Plate" )
		undo.AddEntity( catapult )
		undo.SetPlayer( pl )
	undo.Finish()
	
	return catapult
	
end

function TOOL:RightClick( trace )
	
	if ( CLIENT ) then return end
	
	if ( IsValid( self.GASL_PointerGrab ) ) then
	
		self.GASL_PointerGrab.GASL_CatapultUpdate = Vector()
		
		//print( self.GASL_PointerGrab:GetLaunchHeight() )
		
		self.GASL_PointerGrab:CalculateTrajectoryForceAng()
		self.GASL_PointerGrab = nil

	else
	
		local PointerCaptureRadius = 20
		
		for k, catapult in pairs( ents.FindByClass( "ent_catapult" ) ) do
		
			-- Break if Pointer allready grabbed
			if ( self.GASL_PointerGrab ) then break end
			
			local owner = self:GetOwner()
			local heightPointerPos = ( catapult:GetPos() + catapult:GetLandPoint() ) / 2 + Vector( 0, 0, catapult:GetLaunchHeight() )
			local playerToHeightPointerDist = heightPointerPos:Distance( owner:GetShootPos() )
			
			if ( ( owner:GetShootPos() + owner:EyeAngles():Forward() * playerToHeightPointerDist ):Distance( heightPointerPos ) < PointerCaptureRadius ) then
			
				self.GASL_PointerGrab = catapult
			
			end
			
		end
		
	end
		
	return true
	
end

function TOOL:Think()

	if ( CLIENT ) then return end

	if ( !IsValid( self.GASL_PointerGrab ) ) then return end
	
	local catapult = self.GASL_PointerGrab
	
	local owner = self:GetOwner()
	local heightPointerPos = ( catapult:GetPos() + catapult:GetLandPoint() ) / 2
	local playerToHeightPointerDist = Vector( heightPointerPos.x, heightPointerPos.y, 0 ):Distance( Vector( owner:GetShootPos().x, owner:GetShootPos().y, 0 ) )
	local height = playerToHeightPointerDist * math.tan( -owner:EyeAngles().pitch * math.pi / 180 ) + ( owner:GetShootPos().z - ( catapult:GetPos().z + catapult:GetLandPoint().z ) / 2 )
	
	catapult:SetLaunchHeight( math.max( 100, height ) )

	if ( !self.GASL_PointerGrab:IsValid() ) then
		self.GASL_PointerGrab.GASL_CatapultUpdate = Vector()
		self.GASL_PointerGrab = nil
	end

end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_catapult.description" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_catapult_model", Models = list.Get( "CatapultModels" ), Height = 1 } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_catapult.startenabled", Command = "aperture_science_catapult_startenabled" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_catapult.enable", Command = "aperture_science_catapult_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_catapult.toggle", Command = "aperture_science_catapult_toggle" } )

end

list.Set( "CatapultModels", "models/props/faith_plate.mdl", {} )
list.Set( "CatapultModels", "models/props/faith_plate_128.mdl", {} )