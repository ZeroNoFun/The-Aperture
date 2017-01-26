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
	
end

function TOOL:LeftClick( trace )
	
	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end

	if ( CLIENT ) then return true end

	if ( self.GASL_MakePoint && !self.GASL_Catapult:IsValid() ) then
	
		self.GASL_MakePoint = false
		self.GASL_Catapult = NULL
		
		return false
		
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

end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Name", { Text = "#tool.aperture_science_catapult.name", Description = "#tool.aperture_science_catapult.desc" } )
	CPanel:AddControl( "PropSelect", { Label = "#tool.aperture_science_catapult.model", ConVar = "aperture_science_catapult_model", Models = list.Get( "CatapultModels" ), Height = 1 } )

end

list.Set( "CatapultModels", "models/props/faith_plate.mdl", {} )
list.Set( "CatapultModels", "models/props/faith_plate_128.mdl", {} )