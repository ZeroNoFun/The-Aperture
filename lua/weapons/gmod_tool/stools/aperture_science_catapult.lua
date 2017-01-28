TOOL.Category = "Aperture Science"
TOOL.Name = "Aerial Faith Plate"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "model" ] = "models/props/faith_plate.mdl"

cleanup.Register( "aperture_science_catapult" )

if ( CLIENT ) then

	language.Add( "aperture_science_catapult", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.name", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.desc", "Creates Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.0", "Left click to place" )
	language.Add( "tool.aperture_science_catapult.description", "Makes Aperture Aerial Faith Plate that can launch things in the air" )
	language.Add( "tool.aperture_science_catapult.enable", "Enable" )
	language.Add( "tool.aperture_science_catapult.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )
	
	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end

	if ( CLIENT ) then return true end

	if ( self.GASL_MakePoint && !self.GASL_Catapult:IsValid() ) then
	
		self.GASL_MakePoint = false
		self.GASL_Catapult = NULL
		
	end
	
	if ( self.GASL_MakePoint == nil ) then
	
		self.GASL_MakePoint = false
		self.GASL_Catapult = NULL
		
	end
	
	if ( !self.GASL_MakePoint ) then
		
		local model = self:GetClientInfo( "model" )
		
		if ( !util.IsValidModel( model ) ) then return false end
		
		local ent = ents.Create( "prop_catapult" )
		if ( !IsValid( ent ) ) then return false end
		
		ent:SetPos( trace.HitPos + trace.HitNormal * 5 )
		ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
		ent:SetAngles( ent:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
		ent:Spawn()
		ent:SetModel( model )

		self.GASL_Catapult = ent

		undo.Create( "Aerial Faith Plate" )
			undo.AddEntity( ent )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
	else
	
		self.GASL_Catapult:SetLandPoint( trace.HitPos )
		self.GASL_Catapult:SetLaunchHeight( trace.HitPos:Distance( self.GASL_Catapult:GetPos() ) / 4 )
		
	end

	self.GASL_MakePoint = !self.GASL_MakePoint
	
	return true
	
end

function TOOL:RightClick( trace )
	
	if ( CLIENT ) then return end
	
	if ( self.GASL_PointerGrab ) then
	
		if ( self.GASL_PointerGrab:IsValid() ) then
			self.GASL_PointerGrab.GASL_CatapultUpdate = Vector()
		end
		
		self.GASL_PointerGrab = nil
	
	else
	
		local PointerCaptureRadius = 20
		
		for k, catapult in pairs( ents.FindByClass( "prop_catapult" ) ) do
		
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

	if ( self.GASL_PointerGrab ) then
		
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

end


function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_catapult.description" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_catapult_model", Models = list.Get( "CatapultModels" ), Height = 1 } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_catapult.enable", Command = "aperture_science_catapult_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_catapult.toggle", Command = "aperture_science_catapult_toggle" } )

end

list.Set( "CatapultModels", "models/props/faith_plate.mdl", {} )
list.Set( "CatapultModels", "models/props/faith_plate_128.mdl", {} )