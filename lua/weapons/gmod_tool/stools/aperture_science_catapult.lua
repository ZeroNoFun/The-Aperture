TOOL.Category = "Aperture science"
TOOL.Name = "Aerial Faith Plate"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "model" ] = "models/props/faith_plate.mdl"

cleanup.Register( "aperture_faith_plate" )

if CLIENT then

	//language.Add("faith_plate", "Aerial Faith Plate")
	language.Add("tool.faith_plate.name", "Aerial Faith Plate")
	language.Add("Tool.faith_plate.desc", "Creates Aerial Faith Plate")
	language.Add("Tool.faith_plate.0", "Left click to place")
	
end // CLIENT

if SERVER then

	function TOOL:LeftClick( trace )
		
		if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
		
		if ( self.GASL_Cooldown ) then
			
			local model = self:GetClientInfo( "model" )
			
			if ( !util.IsValidModel( model ) ) then return false end
			
			local ent = ents.Create( "prop_fate_plate" )
			if ( !IsValid( ent ) ) then return false end
			
			ent:SetPos( trace.HitPos + trace.HitNormal * 5 )
			ent:SetModel( model )
			ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			ent:SetAngles( ent:LocalToWorldAngles( Angle( 0, 0, 0 ) ) )
			ent:Spawn()
			
			self.AFP_Cooldown = ent

			undo.Create( "Aerial Faith Plate" )
				undo.AddEntity( ent )
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()
			
		else
			
			if ( !self.AFP_Cooldown ) then return false end
			
			self.AFP_Cooldown.AFP_LandingPoint = trace.HitPos			
			self.AFP_Cooldown.AFP_LaunchHight = 1000
			
		end

		self.GASL_Cooldown = !self.GASL_Cooldown
		
		return true
	end

	function TOOL:RightClick( trace )
	
	
	
	end
	 
end // SERVER

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Name", { Text = "#tool.faith_plate.name", Description = "#tool.faith_plate.desc" } )
	CPanel:AddControl( "PropSelect", { Label = "#tool.faith_plate.model", ConVar = "faith_plate_model", Models = list.Get( "FaithPanelModels" ), Height = 0 } )

end


function TOOL:Holster()

	self.GASL_Cooldown = true
	self.AFP_Cooldown = NULL

end

list.Set( "FaithPanelModels", "models/props/faith_plate.mdl", {} )
list.Set( "FaithPanelModels", "models/props/faith_plate_128.mdl", {} )