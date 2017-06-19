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

SWEP.HoldType			= "crossbow"
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

-- if ( CLIENT ) then

	-- /*---------------------------------------------------------
	   -- Name: CalcViewModelView
	   -- Desc: Overwrites the default GMod v_model system.
	-- ---------------------------------------------------------*/

	-- local sin, abs, pi, clamp, min = math.sin, math.abs, math.pi, math.Clamp, math.min
	-- function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)

		-- local pPlayer = self.Owner

		-- local CT = CurTime()
		-- local FT = FrameTime()

		-- local RunSpeed = pPlayer:GetRunSpeed()
		-- local Speed = clamp(pPlayer:GetVelocity():Length2D(), 0, RunSpeed)

		-- local BobCycleMultiplier = Speed / pPlayer:GetRunSpeed()

		-- BobCycleMultiplier = (BobCycleMultiplier > 1 and min(1 + ((BobCycleMultiplier - 1) * 0.2), 5) or BobCycleMultiplier)
		-- BobTime = BobTime + (CT - BobTimeLast) * (Speed > 0 and (Speed / pPlayer:GetWalkSpeed()) or 0)
		-- BobTimeLast = CT
		-- local BobCycleX = sin(BobTime * 0.5 % 1 * pi * 2) * BobCycleMultiplier
		-- local BobCycleY = sin(BobTime % 1 * pi * 2) * BobCycleMultiplier

		-- oldPos = oldPos + oldAng:Right() * (BobCycleX * 1.5)
		-- oldPos = oldPos
		-- oldPos = oldPos + oldAng:Up() * BobCycleY/2

		-- SwayAng = oldAng - SwayOldAng
		-- if abs(oldAng.y - SwayOldAng.y) > 180 then
			-- SwayAng.y = (360 - abs(oldAng.y - SwayOldAng.y)) * abs(oldAng.y - SwayOldAng.y) / (SwayOldAng.y - oldAng.y)
		-- else
			-- SwayAng.y = oldAng.y - SwayOldAng.y
		-- end
		-- SwayOldAng.p = oldAng.p
		-- SwayOldAng.y = oldAng.y
		-- SwayAng.p = math.Clamp(SwayAng.p, -3, 3)
		-- SwayAng.y = math.Clamp(SwayAng.y, -3, 3)
		-- SwayDelta = LerpAngle(clamp(FT * 5, 0, 1), SwayDelta, SwayAng)
		
		-- return oldPos + oldAng:Up() * SwayDelta.p + oldAng:Right() * SwayDelta.y + oldAng:Up() * oldAng.p / 90 * 2, oldAng
	-- end

-- end

function SWEP:Initialize()

	self.CursorEnabled = false
	
	self:SetNWInt( "GASL:FirstPaint", 1 )
	self:SetNWInt( "GASL:SecondPaint", 2 )

	self:SetWeaponHoldType( self.HoldType )
	
end

-- local function IndexToMaterial( index )
	
	-- local indexToMaterial = {
		-- [PORTAL_PAINT_BOUNCE] = "models/weapons/v_models/aperture_paintgun/blue_paint"
		-- , [PORTAL_PAINT_SPEED] = "models/weapons/v_models/aperture_paintgun/red_paint"
		-- , [PORTAL_PAINT_PORTAL] = "models/weapons/v_models/aperture_paintgun/white_paint"
		-- , [PORTAL_PAINT_WATER] = "models/gasl/PORTAL_PAINT_bubble/gel_water"
		-- , [PORTAL_PAINT_STICKY] = "models/weapons/v_models/aperture_paintgun/purple_paint"
		-- , [PORTAL_PAINT_REFLECTION] = "models/weapons/v_models/aperture_paintgun/white_paint"
	-- }
	
	-- return indexToMaterial[ index ]
	
-- end

function SWEP:ViewModelDrawn( ViewModel ) 
	
	self.Owner:SetNWEntity( "GASL:ViewModel", ViewModel )
	local firstPaint = self:GetNWInt( "GASL:FirstPaint" )
	local secondPaint = self:GetNWInt( "GASL:SecondPaint" )

	-- ViewModel:SetSubMaterial( 3, IndexToMaterial( firstPaint ) )
	-- ViewModel:SetSubMaterial( 2, IndexToMaterial( secondPaint ) )
	
end

function SWEP:Holster( wep )
	
	if not IsFirstTimePredicted() then return end

	if ( SERVER ) then
		net.Start( "GASL_NW_PaintGun_Holster" )
			net.WriteEntity( self.Owner )
		net.Send( self.Owner )
	end

	if ( CLIENT ) then
	
		local ViewModel = self.Owner:GetNWEntity( "GASL:ViewModel" )

		if ( IsValid( ViewModel ) ) then
			ViewModel:SetSubMaterial( 3, Material( "" ) )
			ViewModel:SetSubMaterial( 2, Material( "" ) )
		end
		
	end
	
	return true
	
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

local function ConvectTo360( angle )
	if angle < 0 then return 360 + angle end
	return angle
end

function SWEP:DrawHUD()
	
	local animation = self.HUDAnimation
	local firstPaint = self:GetNWInt( "GASL:FirstPaint" )
	local secondPaint = self:GetNWInt( "GASL:SecondPaint" )
	
	local CursorX, CursorY = input.GetCursorPos()
	local curpos = Vector( CursorX - ScrW() / 2, CursorY - ScrH() / 2 )
	local angle = math.atan2( curpos.x, curpos.y ) * 180 / math.pi
	local OffsetY = 200
	local ImgSize = 64 * animation
	local PointerSize = 80 * animation
	local GelCount = PORTAL_PAINT_COUNT
	local Separating = 50
	local SelectCircleAddictionSize = 5
	local roundDegTo = 360 / GelCount
	
	local roundAngle = math.Round( ( angle - 90 ) / roundDegTo ) * roundDegTo
	local selectionDeg = math.Round( ConvectTo360( -angle + 90 ) / roundDegTo ) * roundDegTo
	if ( selectionDeg == 360 ) then selectionDeg = 0 end
	
	if ( LocalPlayer():KeyDown( IN_RELOAD ) ) then
		if ( animation < 1 ) then self.HUDAnimation = math.min( 1, animation + FrameTime() * 2 ) end
		
		if ( !self.CursorEnabled ) then
			self.CursorEnabled = true
			gui.EnableScreenClicker( true )
		end
	else
		if ( animation > 0 ) then self.HUDAnimation = math.max( 0, animation - FrameTime() * 2 ) end
		
		if ( self.CursorEnabled ) then
			self.CursorEnabled = false
			gui.EnableScreenClicker( false )
		end
	end
	
	if ( animation != 0 ) then
		
		for i = 1, GelCount  do
		
			//local OffsetX = -( ImgSize + Separating ) * GelCount / 2 + ( i - 1 ) * ( ImgSize + Separating ) + Separating / 2
			local Deg = roundDegTo * ( i - 1 )
			local Radian = Deg * math.pi / 180
			local rotAnim = math.pi * ( 1 - animation )
			
			local WheelRad = ImgSize * ( 1 + GelCount * ( GelCount / 50 ) )
			local Cos = math.cos( Radian + rotAnim )
			local Sin = math.sin( Radian + rotAnim )

			local XPos = ScrW() / 2 + ( Cos * WheelRad - ImgSize / 2 ) * animation
			local YPos = ScrH() / 2 + ( Sin * WheelRad - ImgSize / 2 ) * animation
			
			if ( selectionDeg == Deg and LocalPlayer():KeyDown( IN_RELOAD )  ) then

				if ( firstPaint != i and secondPaint != i ) then
				
					if ( input.IsMouseDown( MOUSE_LEFT ) ) then
						net.Start( "GASL_NW_PaintGun_SwitchPaint" )
							net.WriteString( "first" )
							net.WriteInt( i, 8 )
						net.SendToServer()
					elseif ( input.IsMouseDown( MOUSE_RIGHT ) ) then
						net.Start( "GASL_NW_PaintGun_SwitchPaint" )
							net.WriteString( "second" )
							net.WriteInt( i, 8 )
						net.SendToServer()
					end
					
				end
			end
			
			local AddingSize = 0
			local DrawColor = Color( 150, 150, 150 )
			local DrawHalo = false
		
			if ( i == firstPaint ) then
				DrawColor = Color( 0, 200, 255 )
				DrawHalo = true
			elseif ( i == secondPaint ) then 
				DrawColor = Color( 255, 200, 0 )
				DrawHalo = true
			elseif ( selectionDeg == Deg and animation == 1 ) then 
				DrawColor = Color( 255, 255, 255 )
				DrawHalo = true 
			end
		
			surface.SetDrawColor( DrawColor )

			if ( animation == 1 ) then
				
				if ( selectionDeg == Deg ) then
					AddingSize = 20
				end
				
				local PaintName = APERTURESCIENCE:PaintTypeToName( i ) 
				surface.SetFont( "Default" )
				surface.SetTextColor( DrawColor )

				local TextW, TextH = surface.GetTextSize( PaintName )
				local TextRadius = ( TextW + TextH ) / 2
				local TextOffsetX = Cos * ( ImgSize + TextRadius / 2 ) + ImgSize / 2 - TextW / 2
				local TextOffsetY = Sin * ( ImgSize + TextRadius / 2 ) + ImgSize / 2 - TextH / 2
				surface.SetTextPos( XPos + TextOffsetX, YPos + TextOffsetY )
				surface.DrawText( PaintName )

			end

			if ( DrawHalo ) then
				surface.SetMaterial( Material( "vgui/paint_type_select_circle" ) )
				surface.DrawTexturedRect( 
					XPos - SelectCircleAddictionSize - AddingSize / 2
					, YPos - SelectCircleAddictionSize - AddingSize / 2
					, ImgSize + SelectCircleAddictionSize * 2 + AddingSize
					, ImgSize + SelectCircleAddictionSize * 2 + AddingSize
				)
			end

			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.SetMaterial( Material( "vgui/paint_type_back" ) )
			surface.DrawTexturedRect( XPos - AddingSize / 2, YPos - AddingSize / 2, ImgSize + AddingSize, ImgSize + AddingSize )
			
			surface.SetDrawColor( APERTURESCIENCE:PaintTypeToColor( i ) )
			surface.SetMaterial( Material( "vgui/paint_icon" ) )
			surface.DrawTexturedRect( XPos - AddingSize / 2, YPos - AddingSize / 2, ImgSize + AddingSize, ImgSize + AddingSize )
			
		end
		
		self.HUDSmoothCursor =  math.ApproachAngle( self.HUDSmoothCursor, selectionDeg, FrameTime() * 500 )
		
		surface.SetDrawColor( Color( 255, 255, 255 ) )
		surface.SetMaterial( Material( "vgui/hud/paint_type_select_arrow" ) )
		surface.DrawTexturedRectRotated( ScrW() / 2, ScrH() / 2, PointerSize, PointerSize, -self.HUDSmoothCursor - 90 )
	end

end

if ( SERVER ) then
	
	util.AddNetworkString( "GASL_NW_PaintGun_SwitchPaint" )
	util.AddNetworkString( "GASL_NW_PaintGun_Holster" )

	net.Receive( "GASL_NW_PaintGun_SwitchPaint", function( len, pl )

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

-- if ( CLIENT ) then

	-- net.Receive( "GASL_NW_PaintGun_Holster", function( len, pl )
		
		-- local pl = net.ReadEntity()

		-- if ( IsValid( pl ) ) then
			-- local ViewModel = pl:GetNWEntity( "GASL:ViewModel" )

			-- if ( IsValid( ViewModel ) ) then
				-- ViewModel:SetSubMaterial( 3, Material( "" ) )
				-- ViewModel:SetSubMaterial( 2, Material( "" ) )
			-- end
		-- end
		
	-- end )
	
	-- net.Receive( 'PAINTGUN_PICKUP_PROP', function()
		-- local self = net.ReadEntity()
		-- local ent = net.ReadEntity()
		
		-- if !IsValid( ent ) then
			-- --Drop it.
			-- if self.PickupSound then
				-- self.PickupSound:Stop()
				-- self.PickupSound = nil
				-- EmitSound( Sound( 'player/object_use_stop_01.wav' ), self:GetPos(), 1, CHAN_AUTO, 0.4, 100, 0, 100 )
			-- end
			-- if self.ViewModelOverride then
				-- self.ViewModelOverride:Remove()
			-- end
		-- else
			-- --Pick it up.
			-- if !self.PickupSound and CLIENT then
				-- self.PickupSound = CreateSound( self, 'player/object_use_lp_01.wav' )
				-- self.PickupSound:Play()
				-- self.PickupSound:ChangeVolume( 0.5, 0 )
			-- end
			
			-- -- self.ViewModelOverride = true
			
			-- self.ViewModelOverride = ClientsideModel(self.ViewModel,RENDERGROUP_OPAQUE)
			-- self.ViewModelOverride:SetPos(EyePos()-LocalPlayer():GetForward()*(self.ViewModelFOV/5))
			-- self.ViewModelOverride:SetAngles(EyeAngles())
			-- self.ViewModelOverride.AutomaticFrameAdvance = true
			-- self.ViewModelOverride.startCarry = false
			-- -- self.ViewModelOverride:SetParent(self.Owner)
			-- function self.ViewModelOverride.PreDraw(vm)
				-- vm:SetColor(Color(255,255,255))
				-- local oldorigin = EyePos() -- -EyeAngles():Forward()*10
				-- local pos, ang = self:CalcViewModelView(vm,oldorigin,EyeAngles(),vm:GetPos(),vm:GetAngles())
				-- return pos, ang
			-- end
			
		-- end
		
		-- self.HoldenProp = ent
	-- end )

-- end

-- if SERVER then
	-- util.AddNetworkString( 'PAINTGUN_PICKUP_PROP' )

	-- hook.Add( 'AllowPlayerPickup', 'PaintgunPickup', function( ply, ent )
		-- if IsValid( ply:GetActiveWeapon() ) and IsValid( ent ) and ply:GetActiveWeapon():GetClass() == 'aperture_paintgun' then --and (table.HasValue( pickable, ent:GetModel() ) or table.HasValue( pickable, ent:GetClass() )) then
			-- return false
		-- end
	-- end )
-- end

-- hook.Add("Think", "Paintgun Holding Item", function()
	-- for k, v in pairs(player.GetAll())do
		
		-- local Weap = v:GetActiveWeapon()
		
		-- if IsValid( Weap.HoldenProp ) and SERVER
			-- and Weap.HoldenProp:GetModel() == "models/props/reflection_cube.mdl" then
			
			-- local Angles = Weap.HoldenProp:GetAngles()
			
			-- Weap.HoldenProp:SetAngles( Angle( 0, v:EyeAngles().y, 0 ) )
			
		-- end

		-- if v:KeyDown(IN_USE) then
				
			-- if( Weap.UseReleased ) then end
			-- if Weap.NextAllowedPickup and Weap.NextAllowedPickup < CurTime() and Weap.UseReleased then
				-- Weap.UseReleased = false
				-- if IsValid( Weap.HoldenProp ) then
					-- Weap:OnDroppedProp()
				-- end
			-- end
			
		-- else
			-- Weap.UseReleased = true
		-- end
	-- end
	
-- end)

-- function SWEP:Think()
	
	-- -- -- HOLDING FUNC
	
	-- if SERVER then
		-- if self.Owner:KeyDown( IN_USE ) and self.UseReleased then
			-- self.UseReleased = false
			-- if self.NextAllowedPickup < CurTime() and !IsValid(self.HoldenProp) then
			
				-- local ply = self.Owner
				-- self.NextAllowedPickup = CurTime() + 0.4

				-- local tr = util.TraceLine( { 
					-- start = ply:EyePos(),
					-- endpos = ply:EyePos() + ply:GetForward() * 150,
					-- filter = ply
				-- } )
					
				-- --PICKUP FUNC
				-- if IsValid( tr.Entity ) then
					-- if tr.Entity.isClone then tr.Entity = tr.Entity.daddyEnt end
					-- local entsize = ( tr.Entity:OBBMaxs() - tr.Entity:OBBMins() ):Length() / 2
					-- if entsize > 45 then return end
					-- if !IsValid( self.HoldenProp ) and tr.Entity:GetMoveType() != 2 then
						-- if !self:PickupProp( tr.Entity ) then
							-- self:EmitSound( 'player/object_use_failure_01.wav' )
							-- //self:SendWeaponAnim( ACT_VM_DRYFIRE )
						-- end
					-- end
				-- end
				
				-- --PICKUP THROUGH PORTAL FUNC
				-- --TODO
				
			-- end
		-- end
		
		-- if IsValid(self.HoldenProp) and (!self.HoldenProp:IsPlayerHolding() or self.HoldenProp.Holder != self.Owner) then
			-- self:OnDroppedProp()
		-- elseif self.HoldenProp and not IsValid(self.HoldenProp) then
			-- self:OnDroppedProp()
		-- end

	-- end

	-- if CLIENT and self.EnableIdle then return end
	
	-- -- no more client side
	-- if ( CLIENT ) then return end
	
	-- if self.idledelay and CurTime() > self.idledelay then
		-- self.idledelay = nil
		-- //self:SendWeaponAnim(ACT_VM_IDLE)
	-- end

	-- if ( self.Owner:KeyDown( IN_ATTACK ) || self.Owner:KeyDown( IN_ATTACK2 ) ) then
		-- if ( !self.IsShooting ) then
			-- self.Owner:EmitSound( "GASL.GelFlow" )
			-- self.IsShooting = true
		-- end
	-- elseif( self.IsShooting ) then
		-- self.Owner:StopSound( "GASL.GelFlow" )
		-- self.IsShooting = false
	-- end

-- end

-- function SWEP:PickupProp( ent )
	-- if true then
		-- if self.Owner:GetGroundEntity() == ent then return false end
		
		-- if ent:GetModel() == "models/props/reflection_cube.mdl" then
			
			-- local Angles = ent:GetAngles()
			
			-- ent:SetAngles( Angle( 0, self.Owner:EyeAngles().y, 0 ) )
			
		-- end
		
		-- --Take it from other players.
		-- if ent:IsPlayerHolding() and ent.Holder and ent.Holder:IsValid() then
			-- ent.Holder:GetActiveWeapon():OnDroppedProp()
		-- end
		
		-- self.HoldenProp = ent
		-- ent.Holder = self.Owner
		
		-- --Rotate it first
		-- local angOffset = hook.Call("GetPreferredCarryAngles",GAMEMODE,ent) 
		-- if angOffset then
			-- ent:SetAngles(self.Owner:EyeAngles() + angOffset)
		-- end
		
		-- --Pick it up.
		-- self.Owner:PickupObject(ent)
		
		-- //self:SendWeaponAnim( ACT_VM_DEPLOY )
		
		-- if SERVER then
			-- net.Start( 'PAINTGUN_PICKUP_PROP' )
				-- net.WriteEntity( self )
				-- net.WriteEntity( ent )
			-- net.Send( self.Owner )
		-- end
		-- return true
	-- end
	-- return false
-- end

-- function SWEP:OnDroppedProp()

	-- if not self.HoldenProp then return end
		
	-- //self:SendWeaponAnim(ACT_VM_RELEASE)
	-- if SERVER then
		-- self.Owner:DropObject()
	-- end
	
	-- self.HoldenProp.Holder = nil
	-- self.HoldenProp = nil
	-- if SERVER then
		-- net.Start( 'PAINTGUN_PICKUP_PROP' )
			-- net.WriteEntity( self )
			-- net.WriteEntity( NULL )
		-- net.Send( self.Owner )
	-- end
-- end

function SWEP:OnRemove( )

	if ( CLIENT ) then
	
		if( self.CursorEnabled ) then
			self.CursorEnabled = false
			gui.EnableScreenClicker( false )
		end
		
		local ViewModel = self.Owner:GetNWEntity( "GASL:ViewModel" )
		
		if ( IsValid( ViewModel ) ) then
			ViewModel:SetSubMaterial( 3, Material( "" ) )
			ViewModel:SetSubMaterial( 2, Material( "" ) )
		end
		
	end
	
	return true
	
end

-- local GravityLight,GravityBeam = Material("sprites/light_glow02_add"),Material("particle/bendibeam")
-- local GravitySprites = {
	-- {bone = "ValveBiped.Arm1_C", pos = Vector(-1.25 ,-0.10, 1.06), size = { x = 0.02, y = 0.02 }},
	-- {bone = "ValveBiped.Arm2_C", pos = Vector(0.10, 1.25, 1.00), size = { x = 0.02, y = 0.02 }},
	-- {bone = "ValveBiped.Arm3_C", pos = Vector(0.10, 1.25, 1.05), size = { x = 0.02, y = 0.02 }}
-- }
-- local inx = -1
-- function SWEP:DrawPickupEffects(ent)
	
	-- //Draw the lights
	-- local lightOrigins = {}
	-- local col = Color( 200, 255, 220, 255 )
	
	-- for k,v in pairs(GravitySprites) do
		-- local bone = ent:LookupBone(v.bone)

		-- if (!bone) then return end
		
		-- local pos, ang = Vector(0,0,0), Angle(0,0,0)
		-- local m = ent:GetBoneMatrix(0)
		-- if (m) then
			-- pos, ang = m:GetTranslation(), m:GetAngles()
		-- end
		
		-- if ( k == 1 ) then
			-- pos = pos + ang:Right() * 42 - ang:Forward() * 15.5 + ang:Up() * 26
		-- elseif( k == 2 ) then
			-- pos = pos + ang:Right() * 42 - ang:Forward() * 12 + ang:Up() * 20
		-- elseif( k == 3 ) then
			-- pos = pos + ang:Right() * 40 - ang:Forward() * 15 + ang:Up() * 17
		-- end

		-- if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
			-- ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			-- ang.r = -ang.r // Fixes mirrored models
		-- end
			
		-- if (!pos) then continue end
		
		-- local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		-- local _sin = math.abs( math.sin( CurTime() * ( 0.1 ) * math.Rand(1,3))); //math.sinwave( 25, 3, true )
		
		-- render.SetMaterial(GravityLight)
		
		-- for loops = 1, 5 do
			-- render.DrawSprite(drawpos, v.size.x*300+_sin, v.size.y*300+_sin, col)
		-- end
		
		-- lightOrigins[k] = drawpos
			
	-- end
	
	
	-- //Draw the beams and center sprite.
	-- local bone = ent:GetBoneMatrix(0)
	-- local endpos,ang = bone:GetTranslation(),bone:GetAngles()
	-- endpos = endpos + ang:Right() * 40 - ang:Forward() * 15 + ang:Up() * 17

	-- local _sin = math.abs( math.sin( 1+CurTime( ) * 3 ) ) * 1
	-- local _sin1 = math.sin( 1+CurTime( ) * 4 + math.pi / 2 + _sin * math.pi ) * 2
	-- local _sin2 = math.sin( 1+CurTime( ) * 4 + _sin * math.pi ) * 2
	-- endpos = endpos + ang:Up()*6 + ang:Right()*-1.8
	
	-- render.DrawSprite(endpos, 20+_sin * 4, 20+_sin* 4, col)
	
	-- render.SetMaterial(GravityBeam)
	-- render.DrawBeam(lightOrigins[1],endpos,4 + _sin2,-CurTime( ),-CurTime( ) + 1,Color(200,150,255,255))
	-- render.DrawBeam(lightOrigins[2],endpos,4 + _sin1,-CurTime( ) / 2,-CurTime( ) / 2 + 1,Color(200,150,255,255))
	-- render.DrawBeam(lightOrigins[3],endpos,4 + _sin1,-CurTime( ) / 2,-CurTime( ) / 2 + 1,Color(200,150,255,255))

-- end

function SWEP:MakePuddle(paintType)

	if timer.Exists("TA_Player_ShootingPaint"..self.Owner:EntIndex()) then return end
	timer.Create("TA_Player_ShootingPaint"..self.Owner:EntIndex(), 0.01, 1, function() end)
	
	if not paintType then return end

	local ownerEyeAngles = self.Owner:EyeAngles()
	local offset = Vector(25, -30, -30)
	offset:Rotate(ownerEyeAngles)
	local ownerShootPos = self.Owner:GetShootPos() + offset
	local forward = ownerEyeAngles:Forward()
	local traceForce = util.QuickTrace(ownerShootPos, forward * 1000, self.Owner)
	local force = traceForce.HitPos:Distance(ownerShootPos)
	
	-- Randomize makes random size between maxsize and minsize by selected procent
	local randSize = math.Rand(APERTURESCIENCE.GEL_MINSIZE, (APERTURESCIENCE.GEL_MAXSIZE + APERTURESCIENCE.GEL_MINSIZE) / 2)
	local paint = APERTURESCIENCE:MakePaintPuddle(paintType, ownerShootPos, forward * math.max(100, math.min(200, force - 100)) * 8 + VectorRand() * 100, randSize)

	if IsValid(self.Owner) and self.Owner:IsPlayer() then paint:SetOwner(self.Owner) end
	
end