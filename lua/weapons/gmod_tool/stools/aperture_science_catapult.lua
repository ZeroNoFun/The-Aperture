TOOL.Category = "Aperture Science"
TOOL.Name = "Aerial Faith Plate"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "model" ] = "models/props/faith_plate.mdl"
TOOL.ClientConVar[ "startenabled" ] = "0"

cleanup.Register( "aperture_science_catapult" )

if ( CLIENT ) then

	language.Add( "aperture_science_catapult", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.name", "Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.desc", "Creates Aerial Faith Plate" )
	language.Add( "tool.aperture_science_catapult.0", "Left click to place" )
	language.Add( "tool.aperture_science_catapult.description", "Makes Aperture Aerial Faith Plate that can launch things in the air" )
	language.Add( "tool.aperture_science_catapult.startenabled", "Start Enabled" )
	
end

function TOOL:LeftClick( trace )
	

	if ( CLIENT ) then return true end
	
	if ( !IsValid( self.GASL_Catapult ) ) then
			
		-- Ignore if place target is Alive
		if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then return false end

		if ( !APERTURESCIENCE.ALLOWING.catapult && !self:GetOwner():IsSuperAdmin() ) then MsgC( Color( 255, 0, 0 ), "This tool is disabled" ) return end
		
		if ( APERTURESCIENCE:GASLStuff( trace.Entity ) ) then return false end
		
		local ply = self:GetOwner()
		local model = self:GetClientInfo( "model" )
		local toggle = self:GetClientNumber( "toggle" )
		local keyenable = self:GetClientNumber( "keyenable" )
		local startenabled = self:GetClientNumber( "startenabled" )
		
		local catapult = MakeCatapult( ply, model, trace.HitPos + trace.HitNormal * 5, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, toggle, keyenable )
		self.GASL_Catapult = catapult
		self.GASL_CatapultPos = trace.HitPos
		self.GASL_CatapultNormal = trace.HitNormal
		
	else
	
		self.GASL_Catapult:SetLandingPoint( trace.HitPos )
		self.GASL_Catapult:SetLaunchHeight( trace.HitPos:Distance( self.GASL_Catapult:GetPos() ) / 4 )
		self.GASL_Catapult = nil
		
	end

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
	
	catapult:SetStartEnabled( tobool( startenabled ) )
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
		self.GASL_PointerGrab:CalculateTrajectoryForceAng()
		self.GASL_PointerGrab = nil

	else
	
		if ( !APERTURESCIENCE.ALLOWING.catapult && !self:GetOwner():IsSuperAdmin() ) then MsgC( Color( 255, 0, 0 ), "This tool is disabled" ) return end
		
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
	ent:SetAngles( ang + Angle( 90, 0, 0 ) )

	ent:SetNoDraw( false )

end

function TOOL:Think()
	
	local mdl = self:GetClientInfo( "model" )
	if ( !util.IsValidModel( mdl ) || IsValid( self.GASL_PointerGrab ) ) then self:ReleaseGhostEntity() else

		if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
			self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
		end

		self:UpdateGhostCatapult( self.GhostEntity, self:GetOwner() )
	end
	
	if ( CLIENT ) then return end
	
	-- rotating catapult
	if ( IsValid( self.GASL_Catapult ) ) then
		
		local normal = self.GASL_CatapultNormal
		normal = Vector( math.Round( normal.x ), math.Round( normal.y ), math.Round( normal.z ) )
		
		if ( normal == Vector( 0, 0, 1 ) || normal == Vector( 0, 0, -1 ) ) then
		
			local aimPos = self:GetOwner():GetEyeTrace().HitPos
			local localAimPos = WorldToLocal( self.GASL_CatapultPos, self.GASL_CatapultNormal:Angle() + Angle( 90, 0, 0 ), aimPos, Angle() )
			local localAng = localAimPos:Angle()
			localAng = Angle( 0, math.Round( localAng.y / 90 ) * 90 + 180, 0 )
			
			self.GASL_Catapult:SetAngles( self.GASL_CatapultNormal:Angle() + Angle( 90, localAng.y, 0 ) )
			
		end
		
	end

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

function TOOL:DrawHUD()

	cam.Start3D()
	
		local ply = LocalPlayer()

		for i, catapult in pairs( ents.FindByClass( "ent_catapult" ) ) do
			
			-- Draw trajectory if player holding air faith plate tool
			if ( catapult:GetLandPoint() == Vector() || catapult:GetLaunchHeight() == 0 ) then continue end
			
			local startpos = catapult:GetPos()
			local endpos = catapult:GetLandPoint()
			local height = catapult:GetLaunchHeight()
			local middlepos = ( startpos + endpos ) / 2
			local prevBeamPos = startpos

			-- Drawing land target
			render.SetMaterial( Material( "signage/mgf_overlay_bullseye" ) )
			render.DrawQuadEasy( endpos, Vector( 0, 0, 1 ), 80, 80, Color( 255, 255, 255 ), 0 )
			
			-- Drawing trajectory
			render.SetMaterial( Material( "effects/trajectory_path" ) )
			local amount = math.max( 4, startpos:Distance( endpos ) / 200 )
			
			local Iterrations = 20
			
			local timeofFlight = catapult:GetTimeOfFlight()
			local launchVector = catapult:GetLaunchVector()

			local dTime = timeofFlight / ( Iterrations )
			local dVector = launchVector * dTime
			
			local point = catapult:GetPos()
			local Gravity = math.abs( physenv.GetGravity().z ) * timeofFlight / ( Iterrations - 1 )
			
			for i = 1, Iterrations do
			
				point = point + dVector
				dVector = dVector - Vector( 0, 0, Gravity * dTime )
				
				render.DrawBeam( prevBeamPos, point, 120, 0, 1, Color( 255, 255, 255 ) )
				prevBeamPos = point

			end
			
			-- Drawing height point
			render.SetMaterial( Material( "sprites/sent_ball" ) )
			render.DrawSprite( middlepos + Vector( 0, 0, height ), 32, 32, Color( 255, 255, 0 ) ) 
		end
		
	cam.End3D()
end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_catapult.description" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_catapult_model", Models = list.Get( "CatapultModels" ), Height = 1 } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_catapult.startenabled", Command = "aperture_science_catapult_startenabled" } )
	
end

list.Set( "CatapultModels", "models/props/faith_plate.mdl", {} )
list.Set( "CatapultModels", "models/props/faith_plate_128.mdl", {} )