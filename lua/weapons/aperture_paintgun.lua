AddCSLuaFile( )

SWEP.Weight = 3
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.PrintName = "Paint Gun"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Category = "Aperture Science"
 
SWEP.Purpose = "Shoot gel"
SWEP.Instructions = "Mouse 1 to spawn shoot gel Mouse 2 to select gel type"
SWEP.ViewModelFOV = 45
SWEP.ViewModel = "models/weapons/v_aperture_paintgun.mdl" 
SWEP.WorldModel = "models/weapons/w_aperture_paintgun.mdl"

SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true

function SWEP:Initialize()

	self.CursorEnabled = false
	
	self:SetNWInt( "GASL:FirstPaint", 1 )
	self:SetNWInt( "GASL:SecondPaint", 2 )
	
end

local function IndexToName( index )
	
	local indexToName = {
		[PORTAL_GEL_BOUNCE] = "models/weapons/v_models/aperture_paintgun/blue_paint"
		, [PORTAL_GEL_SPEED] = "models/weapons/v_models/aperture_paintgun/red_paint"
		, [PORTAL_GEL_PORTAL] = "models/weapons/v_models/aperture_paintgun/white_paint"
		, [PORTAL_GEL_WATER] = "models/gasl/portal_gel_bubble/gel_water"
		, [PORTAL_GEL_STICKY] = "models/weapons/v_models/aperture_paintgun/purple_paint"
	}
	
	return indexToName[ index ]
	
end

function SWEP:ViewModelDrawn( ViewModel ) 
	local firstPaint = self:GetNWInt( "GASL:FirstPaint" )
	local secondPaint = self:GetNWInt( "GASL:SecondPaint" )

	//ViewModel:SetSubMaterial( 3, IndexToName( firstPaint ) )
	//ViewModel:SetSubMaterial( 2, IndexToName( secondPaint ) )
	
end

function SWEP:PrimaryAttack()
	if ( CLIENT ) then return end
	
	local firstPaint = self:GetNWInt( "GASL:FirstPaint" )
	self:MakePuddle( firstPaint )
	
end

function SWEP:SecondaryAttack()
	if ( CLIENT ) then return end
	
	local secondPaint = self:GetNWInt( "GASL:SecondPaint" )
	self:MakePuddle( secondPaint )
	
end

function SWEP:Reload()
	return
end

function SWEP:DrawHUD()
	
	if ( LocalPlayer():KeyDown( IN_RELOAD ) ) then
		
		local firstPaint = self:GetNWInt( "GASL:FirstPaint" )
		local secondPaint = self:GetNWInt( "GASL:SecondPaint" )

		if ( !self.CursorEnabled ) then
			self.CursorEnabled = true
			gui.EnableScreenClicker( true )
		end

		local CursorX, CursorY = input.GetCursorPos()
		local OffsetY = 200
		local ImgSize = 64
		local GelCount = 5
		local Separating = 50
		local SelectCircleAddictionSize = 5
		
		for i = 1, GelCount  do
		
			local OffsetX = -( ImgSize + Separating ) * GelCount / 2 + ( i - 1 ) * ( ImgSize + Separating ) + Separating / 2
			local XPos = ScrW() / 2 + OffsetX
			local YPos = ScrH() / 2 - OffsetY
			
			if ( Vector( XPos + ImgSize / 2, YPos + ImgSize / 2 ):Distance( Vector( CursorX, CursorY ) ) < ImgSize / 2 ) then
				if ( firstPaint != i && secondPaint != i ) then
				
					if ( input.IsMouseDown( MOUSE_LEFT ) ) then
						net.Start( "GASL_NW_PaintGun" )
							net.WriteString( "first" )
							net.WriteInt( i, 8 )
						net.SendToServer()
					end
					
					if ( input.IsMouseDown( MOUSE_RIGHT ) ) then
						net.Start( "GASL_NW_PaintGun" )
							net.WriteString( "second" )
							net.WriteInt( i, 8 )
						net.SendToServer()
					end
					
				end
			end

			if ( i == firstPaint || i == secondPaint ) then
				surface.SetDrawColor( Color( 0, 255, 0 ) )
				surface.SetMaterial( Material( "vgui/paint_type_select_circle" ) )
				surface.DrawTexturedRect( XPos - SelectCircleAddictionSize, YPos - SelectCircleAddictionSize, ImgSize + SelectCircleAddictionSize * 2, ImgSize + SelectCircleAddictionSize * 2 )
			end

			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.SetMaterial( Material( "vgui/paint_type_back" ) )
			surface.DrawTexturedRect( XPos, YPos, ImgSize, ImgSize )
			
			surface.SetDrawColor( APERTURESCIENCE:GetColorByGelType( i ) )
			surface.SetMaterial( Material( "vgui/paint_icon" ) )
			surface.DrawTexturedRect( XPos, YPos, ImgSize, ImgSize )
			
		end
		
	elseif( self.CursorEnabled ) then
		self.CursorEnabled = false
		gui.EnableScreenClicker( false )
	end

end

if ( SERVER ) then

	net.Receive( "GASL_NW_PaintGun", function( len, pl )

		if ( IsValid( pl ) and pl:IsPlayer() ) then
			local mouse = net.ReadString()
			local paintType = net.ReadInt( 8 )
			
			if ( mouse == "first" ) then
				pl:GetActiveWeapon():SetNWInt( "GASL:FirstPaint", paintType )
			end
			
			if ( mouse == "second" ) then
				pl:GetActiveWeapon():SetNWInt( "GASL:SecondPaint", paintType )
			end
			
		end
		
	end )
	
end

function SWEP:OnRemove( )

	if ( CLIENT ) then
	
		if( self.CursorEnabled ) then
			self.CursorEnabled = false
			gui.EnableScreenClicker( false )
		end
		
	end
	
end

function SWEP:MakePuddle( gel_type )

	if ( timer.Exists( "GASL_Player_ShootingPaint"..self.Owner:EntIndex() ) ) then return end
	timer.Create( "GASL_Player_ShootingPaint"..self.Owner:EntIndex(), 0.01, 1, function() end )
	
	if gel_type <= 0 then return end

	local OwnerShootPos = self.Owner:GetShootPos()
	local OwnerEyeAngles = self.Owner:EyeAngles()
	local forward = OwnerEyeAngles:Forward()
	local traceForce = util.QuickTrace( OwnerShootPos, forward * 1000, self.Owner )
	local force = traceForce.HitPos:Distance( OwnerShootPos )
	
	-- Randomize makes random size between maxsize and minsize by selected procent
	local randSize = math.Rand( 1, -1 )
	local rad = math.max( APERTURESCIENCE.GEL_MINSIZE, math.min( APERTURESCIENCE.GEL_MAXSIZE, randSize * 200 ) )

	local paint = APERTURESCIENCE:MakePaintPuddle( gel_type, OwnerShootPos, rad )
	paint:GetPhysicsObject():SetVelocity( forward * math.max( 0, force - 100 ) * 4 )

	if ( IsValid( self.Owner ) && self.Owner:IsPlayer() ) then paint:SetOwner( self.Owner ) end
	
end