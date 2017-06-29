AddCSLuaFile( )

if ( SERVER ) then
	SWEP.Weight                     = 4
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if ( CLIENT ) then
	//SWEP.WepSelectIcon 		= surface.GetTextureID("weapons/portalgun_inventory")
	SWEP.PrintName          = "Paint Gun"
	SWEP.Author             = "CrishNate"
	SWEP.Purpose            = "Shoot Different Gels"
	SWEP.ViewModelFOV       = 45
	SWEP.Instructions       = "Left/Right Mouse shoot gel, Reload change gel types"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.CSMuzzleFlashes    = false

end

SWEP.HoldType			= "shootgun"
SWEP.EnableIdle			= false	
SWEP.BobScale 			= 0
SWEP.SwayScale 			= 0

SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Aperture Science"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/v_aperture_paintgun.mdl" 
SWEP.WorldModel 		= "models/weapons/w_aperture_paintgun.mdl"

SWEP.ViewModelFlip 		= false

SWEP.Delay              = .5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo				= "none"

SWEP.RunBob = 0.5
SWEP.RunSway = 2.0

SWEP.HoldenProp			= false
SWEP.NextAllowedPickup	= 0
SWEP.UseReleased		= true
SWEP.PickupSound		= nil
SWEP.IsShooting			= false
SWEP.HUDAnimation		= 0
SWEP.HUDSmoothCursor	= 0

local BobTime = 0
local BobTimeLast = CurTime()

local SwayAng = nil
local SwayOldAng = Angle()
local SwayDelta = Angle()

function SWEP:Initialize()

	print(123)
	if CLIENT then
		self.CursorEnabled = false
		
		return
	end

	util.AddNetworkString("TA_NW_PaintGun_SwitchPaint")
	util.AddNetworkString("TA_NW_PaintGun_Holster")
	
	self:SetNWInt("TA:firstPaintType", PORTAL_PAINT_BOUNCE)
	self:SetNWInt("TA:secondPaintType", PORTAL_PAINT_SPEED)

	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:ViewModelDrawn(viewModel) 
	self.Owner:SetNWEntity("TA:ViewModel", viewModel)
	local firstPaintType = self:GetNWInt("TA:firstPaintType")
	local secondPaintType = self:GetNWInt("TA:secondPaintType")
end

function SWEP:Holster(wep)
	
	if not IsFirstTimePredicted() then return end
	if SERVER then
		net.Start("TA_NW_PaintGun_Holster")
			net.WriteEntity(self.Owner)
		net.Send(self.Owner)
	end

	if CLIENT then
		local viewModel = self.Owner:GetNWEntity("TA:ViewModel")

		if IsValid(viewModel) then
			viewModel:SetSubMaterial(3, Material(""))
			viewModel:SetSubMaterial(2, Material(""))
		end
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local firstPaintType = self:GetNWInt("TA:firstPaintType")
	self:MakePaintBlob(firstPaintType)
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	
	local secondPaintType = self:GetNWInt("TA:secondPaintType")
	self:MakePaintBlob(secondPaintType)
end

function SWEP:Reload()
	return
end

local function ConvectTo360( angle )
	if angle < 0 then return 360 + angle end
	return angle
end

function SWEP:DrawHUD()
	
	local animation = self.HUDAnimation
	local firstPaintType = self:GetNWInt("TA:firstPaintType")
	local secondPaintType = self:GetNWInt("TA:secondPaintType")
	
	local cursorX, cursorY = input.GetCursorPos()
	local curpos = Vector(cursorX - ScrW() / 2, cursorY - ScrH() / 2)
	local angle = math.atan2(curpos.x, curpos.y) * 180 / math.pi
	local offsetY = 200
	local imgSize = 64 * animation
	local pointerSize = 80 * animation
	local paintCount = PORTAL_PAINT_COUNT
	local separating = 50
	local selectCircleAddictionSize = 5
	local roundDegTo = 360 / paintCount
	
	local roundAngle = math.Round((angle - 90) / roundDegTo) * roundDegTo
	local selectionDeg = math.Round(ConvectTo360(-angle + 90) / roundDegTo) * roundDegTo
	if selectionDeg == 360 then selectionDeg = 0 end
	
	if LocalPlayer():KeyDown(IN_RELOAD) then
		if animation < 1 then self.HUDAnimation = math.min(1, animation + FrameTime() * 2) end
		
		if not self.CursorEnabled then
			self.CursorEnabled = true
			gui.EnableScreenClicker(true)
		end
	else
		if animation > 0 then self.HUDAnimation = math.max(0, animation - FrameTime() * 2) end
		
		if self.CursorEnabled then
			self.CursorEnabled = false
			gui.EnableScreenClicker(false)
		end
	end
	
	if animation != 0 then
		
		for i = 1,paintCount  do
			local Deg = roundDegTo * (i - 1)
			local Radian = Deg * math.pi / 180
			local rotAnim = math.pi * (1 - animation)
			
			local WheelRad = imgSize * (1 + paintCount * (paintCount / 50))
			local Cos = math.cos(Radian + rotAnim)
			local Sin = math.sin(Radian + rotAnim)

			local XPos = ScrW() / 2 + (Cos * WheelRad - imgSize / 2) * animation
			local YPos = ScrH() / 2 + (Sin * WheelRad - imgSize / 2) * animation
			
			if selectionDeg == Deg and LocalPlayer():KeyDown(IN_RELOAD) then
				if firstPaintType != i and secondPaintType != i then
					if input.IsMouseDown(MOUSE_LEFT) then
						net.Start("TA_NW_PaintGun_SwitchPaint")
							net.WriteString("first")
							net.WriteInt(i, 8)
						net.SendToServer()
					elseif input.IsMouseDown(MOUSE_RIGHT) then
						net.Start("TA_NW_PaintGun_SwitchPaint")
							net.WriteString("second")
							net.WriteInt(i, 8)
						net.SendToServer()
					end
				end
			end
			
			local AddingSize = 0
			local DrawColor = Color( 150, 150, 150 )
			local DrawHalo = false
			
			if ( i == firstPaintType ) then
				DrawColor = Color( 0, 200, 255 )
				DrawHalo = true
			elseif i == secondPaintType then 
				DrawColor = Color( 255, 200, 0 )
				DrawHalo = true
			elseif selectionDeg == Deg and animation == 1 then 
				DrawColor = Color( 255, 255, 255 )
				DrawHalo = true 
			end
		
			surface.SetDrawColor( DrawColor )

			if animation == 1 then
				if selectionDeg == Deg then AddingSize = 20 end
				
				local PaintName = LIB_APERTURE:PaintTypeToName(i) 
				surface.SetFont("Default")
				surface.SetTextColor(DrawColor)

				local TextW, TextH = surface.GetTextSize(PaintName)
				local TextRadius = (TextW + TextH) / 2
				local TextOffsetX = Cos * (imgSize + TextRadius / 2) + imgSize / 2 - TextW / 2
				local TextoffsetY = Sin * (imgSize + TextRadius / 2) + imgSize / 2 - TextH / 2
				surface.SetTextPos(XPos + TextOffsetX, YPos + TextoffsetY)
				surface.DrawText(PaintName)
			end

			if DrawHalo then
				surface.SetMaterial(Material( "vgui/paint_type_select_circle"))
				surface.DrawTexturedRect( 
					XPos - selectCircleAddictionSize - AddingSize / 2
					, YPos - selectCircleAddictionSize - AddingSize / 2
					, imgSize + selectCircleAddictionSize * 2 + AddingSize
					, imgSize + selectCircleAddictionSize * 2 + AddingSize
				)
			end

			surface.SetDrawColor(Color( 255, 255, 255))
			surface.SetMaterial(Material( "vgui/paint_type_back"))
			surface.DrawTexturedRect(XPos - AddingSize / 2, YPos - AddingSize / 2, imgSize + AddingSize, imgSize + AddingSize)
			
			surface.SetDrawColor(LIB_APERTURE:PaintTypeToColor(i))
			surface.SetMaterial(Material("vgui/paint_icon"))
			surface.DrawTexturedRect(XPos - AddingSize / 2, YPos - AddingSize / 2, imgSize + AddingSize, imgSize + AddingSize)
			
		end
		
		self.HUDSmoothCursor =  math.ApproachAngle(self.HUDSmoothCursor, selectionDeg, FrameTime() * 500)
		
		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(Material( "vgui/hud/paint_type_select_arrow"))
		surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, pointerSize, pointerSize, -self.HUDSmoothCursor - 90)
	end
end

if SERVER then
	net.Receive( "TA_NW_PaintGun_SwitchPaint", function(len, ply)
		local mouse = net.ReadString()
		local paintType = net.ReadInt(8)
		
		if mouse == "first" then ply:GetActiveWeapon():SetNWInt("TA:firstPaintType", paintType) end
		if mouse == "second" then ply:GetActiveWeapon():SetNWInt("TA:secondPaintType", paintType) end
	end)
end

function SWEP:OnRemove()

	if CLIENT then
		if self.CursorEnabled then
			self.CursorEnabled = false
			gui.EnableScreenClicker(false)
		end
		
		local ViewModel = self.Owner:GetNWEntity( "TA:ViewModel" )
		if IsValid(ViewModel) then
			ViewModel:SetSubMaterial(3, Material(""))
			ViewModel:SetSubMaterial(2, Material(""))
		end
	end
	
	return true
end

function SWEP:MakePaintBlob(paintType)

	if timer.Exists("TA_Player_ShootingPaint"..self.Owner:EntIndex()) then return end
	timer.Create("TA_Player_ShootingPaint"..self.Owner:EntIndex(), 0.01, 1, function() end)
	
	if not paintType then return end

	local ownerEyeAngles = self.Owner:EyeAngles()
	local ownerSpeed = self.Owner:GetVelocity()
	local offset = Vector(25, -30, -30)
	offset:Rotate(ownerEyeAngles)
	local ownerShootPos = self.Owner:GetShootPos() + offset
	local forward = ownerEyeAngles:Forward()
	local traceForce = util.QuickTrace(ownerShootPos, forward * 1000, self.Owner)
	local force = traceForce.HitPos:Distance(ownerShootPos)
	
	-- Randomize makes random size between maxsize and minsize by selected procent
	local randSize = math.Rand(LIB_APERTURE.GEL_MINSIZE, (LIB_APERTURE.GEL_MAXSIZE + LIB_APERTURE.GEL_MINSIZE) / 2)
	local paint = LIB_APERTURE:MakePaintBlob(paintType, ownerShootPos, forward * math.max(100, math.min(200, force - 100)) * 8 + VectorRand() * 100 + ownerSpeed, randSize)
	
	if not IsValid(paint) then return end
	if IsValid(self.Owner) and self.Owner:IsPlayer() then paint:SetOwner(self.Owner) end
	
end