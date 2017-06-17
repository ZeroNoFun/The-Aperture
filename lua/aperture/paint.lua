
-- ================================ PAINT STUFF ============================
APERTURESCIENCE.GEL_QUALITY		= 1

PORTAL_GEL_NONE 		= 0
PORTAL_GEL_BOUNCE 		= 1
PORTAL_GEL_SPEED 		= 2
PORTAL_GEL_PORTAL 		= 3
PORTAL_GEL_WATER 		= 4
PORTAL_GEL_STICKY 		= 5
PORTAL_GEL_REFLECTION 	= 6

PORTAL_GEL_COUNT		= 6

ORIENTATION_DEFAULT 	= Vector(0, 0, 1)

APERTURESCIENCE.GEL_BOX_SIZE 			= 64
APERTURESCIENCE.GEL_MAXSIZE 			= 150
APERTURESCIENCE.GEL_MINSIZE 			= 40
APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED 	= 1000

APERTURESCIENCE.GEL_BOUNCE_COLOR 		= Color(50, 125, 255)
APERTURESCIENCE.GEL_SPEED_COLOR 		= Color(255, 100, 0)
APERTURESCIENCE.GEL_PORTAL_COLOR 		= Color(150, 150, 150)
APERTURESCIENCE.GEL_WATER_COLOR 		= Color(200, 230, 255)
APERTURESCIENCE.GEL_STICKY_COLOR 		= Color(125, 25, 220)
APERTURESCIENCE.GEL_REFLECTION_COLOR 	= Color(255, 255, 255)

APERTURESCIENCE.GELLED_ENTITIES 	= { }
APERTURESCIENCE.CONNECTED_PAINTS 	= { }


function APERTURESCIENCE:GetColorByGelType(paintType)
	local color = Color(0, 0, 0)
	if paintType == PORTAL_GEL_BOUNCE then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if paintType == PORTAL_GEL_SPEED then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	if paintType == PORTAL_GEL_PORTAL then color = APERTURESCIENCE.GEL_PORTAL_COLOR end
	if paintType == PORTAL_GEL_WATER then color = APERTURESCIENCE.GEL_WATER_COLOR end
	if paintType == PORTAL_GEL_STICKY then color = APERTURESCIENCE.GEL_STICKY_COLOR end
	if paintType == PORTAL_GEL_REFLECTION then color = APERTURESCIENCE.GEL_REFLECTION_COLOR end

	return color
end

function APERTURESCIENCE:PaintTypeToName(index)
	local indexToName = {
		[PORTAL_GEL_BOUNCE] = "Repulsion"
		, [PORTAL_GEL_SPEED] = "Propulsion"
		, [PORTAL_GEL_PORTAL] = "Conversion"
		, [PORTAL_GEL_WATER] = "Cleansing"
		, [PORTAL_GEL_STICKY] = "Adhesion"
		, [PORTAL_GEL_REFLECTION] = "Reflection"
	}
	
	return indexToName[index]
end

local function NormalFlipZeros(normal)
	local lower = 0.000001
	if math.abs(normal.x) < lower then normal.x = 0 end
	if math.abs(normal.y) < lower then normal.y = 0 end
	if math.abs(normal.z) < lower then normal.z = 0 end
end

local function DegreeseBetween(vector1, vector2)
	NormalFlipZeros(vector1)
	NormalFlipZeros(vector2)
	
	if vector1 == vector2 then return 0 end
	local dot = vector1:Dot(vector2)
	return math.deg(math.acos(dot))
end

if CLIENT then

	local function ChangeCamerOrientation(ply, angleFrom, angleTo, plyCamera)
		ply.TA_Current_Ang = angleFrom
		ply.TA_New_Ang = angleTo
		ply.TA_RotateIt = 0
		ply.TA_MaxDegreese = degreese
		local _, angOffset = WorldToLocal(Vector(), plyCamera, Vector(), angleFrom)
		angOffset = Angle(angOffset.p, angOffset.y, 0)
		ply.TA_Camera_Ang_Offset = angOffset
	end

	-- STICKY gel camera orientation
	hook.Add("Think", "TA:StickCamerOrient", function()
		local ply = LocalPlayer()
		local eyeAngles = ply:EyeAngles()
		if not ply:GetNWVector("TA:PrevOrientation") then ply:SetNWVector("TA:PrevOrientation", Vector()) end
		if not ply:GetNWAngle("TA:PrevOrientationAng" ) then ply:SetNWAngle("TA:PrevOrientationAng", Vector(0, 0, 1):Angle()) end
		if not ply:GetNWAngle("TA:PlayerAng" ) then ply:SetNWAngle("TA:PlayerAng", eyeAngles) end
		if not ply:GetNWAngle("TA:PlayerEyeAngle" ) then ply:SetNWAngle("TA:PlayerEyeAngle", eyeAngles) end

		local newEyeAngle = Angle()
		local orientation = ply:GetNWVector("TA:Orientation")
		local prevOrientation = ply:GetNWVector("TA:PrevOrientation")
		local playerEyeAngle = ply:GetNWAngle("TA:PlayerEyeAngle")
		local prevOrientationAng = ply:GetNWAngle("TA:PrevOrientationAng")
		local orientationAng = orientation:Angle() + Angle(90, 0, 0)

		-- rotating camera by roll if player orientation is default
		
		if orientation == ORIENTATION_DEFAULT then
		
			if math.abs(playerEyeAngle.r) > 0.1 then
				playerEyeAngle.r = math.ApproachAngle(playerEyeAngle.r, 0, FrameTime() * math.min(playerEyeAngle.r * 10, 160))
			elseif playerEyeAngle.r != 0 then
				playerEyeAngle.r = 0
			end
		end
		
		-- checking for changing orientation
		if orientation != prevOrientation then

			local _, angleFrom = WorldToLocal(Vector(), (-orientation):Angle(), Vector(), prevOrientationAng)
			angleFrom = Angle(0, angleFrom.yaw, 0)
			_, angleFrom = LocalToWorld(Vector(), angleFrom, Vector(), prevOrientationAng)
			
			local _, angleTo = WorldToLocal(Vector(), prevOrientation:Angle(), Vector(), orientationAng)
			angleTo = Angle(0, angleTo.yaw, 0)
			_, angleTo = LocalToWorld(Vector(), angleTo, Vector(), orientationAng)
			
			ChangeCamerOrientation(ply, angleFrom, angleTo, eyeAngles)
		end
		
		ply:SetNWVector("TA:PrevOrientation", orientation)
		
		if newEyeAngle != eyeAngles then
			local playerAng = ply:GetNWAngle("TA:PlayerAng")

			if playerAng != eyeAngles then
				local angOffset = eyeAngles - playerAng
				
				playerEyeAngle.p = math.max(-88, math.min(88, playerEyeAngle.p))
				if playerEyeAngle.y > 360 then playerEyeAngle.y = playerEyeAngle.y - 360 end
				if playerEyeAngle.y < -360 then playerEyeAngle.y = playerEyeAngle.y + 360 end
				
				ply:SetNWAngle("TA:PlayerEyeAngle", playerEyeAngle + angOffset)
				playerAng = eyeAngles
				ply:SetNWAngle("TA:PlayerAng", playerAng)
			end
			
			//local cameraOffset = prevOrientationAng + angleOffset
			
			
			if ply.TA_Current_Ang and ply.TA_New_Ang and ply.TA_Camera_Ang_Offset then
				local currentAng = ply.TA_Current_Ang
				local newAng = ply.TA_New_Ang
				local cameraAngOffset = ply.TA_Camera_Ang_Offset
				local maxDegreese = ply.TA_MaxDegreese
				
				local pitchDif = math.AngleDifference(currentAng.p, newAng.p)
				local yawDif = math.AngleDifference(currentAng.y, newAng.y)
				local rollDif = math.AngleDifference(currentAng.r, newAng.r)
				
				local _, offsetAngle = WorldToLocal(Vector(), newAng, Vector(), currentAng)
				offsetAngle = Angle(offsetAngle.p / 10, offsetAngle.y / 10, offsetAngle.r / 10)
				_, offsetAngle = LocalToWorld(Vector(), offsetAngle, Vector(), currentAng)
				currentAng = offsetAngle
				-- currentAng.p = math.ApproachAngle(currentAng.p, newAng.p, FrameTime() * math.max(1, math.min(math.abs(pitchDif) * 10, 150)))
				-- currentAng.y = math.ApproachAngle(currentAng.y, newAng.y, FrameTime() * math.max(1, math.min(math.abs(yawDif) * 10, 150)))
				-- currentAng.r = math.ApproachAngle(currentAng.r, newAng.r, FrameTime() * math.max(1, math.min(math.abs(rollDif) * 10, 150)))
				ply.TA_Current_Ang = currentAng
				
				local _, camAng = LocalToWorld(Vector(), cameraAngOffset, Vector(), currentAng)
				
				ply:SetEyeAngles(camAng)
				//print(camAng, newAng, currentAng, cameraAngOffset)
				
				local result = DegreeseBetween(currentAng:Forward(), newAng:Forward())
				
				if result < 1 then
					ply.TA_Current_Ang = nil
					local _, camOffAng = LocalToWorld(Vector(), Angle(0, 0, 0), Vector(), newAng)
					ply:SetNWAngle("TA:PrevOrientationAng", camOffAng)
					ply:SetNWAngle("TA:PlayerEyeAngle", cameraAngOffset)
				end
			else
				-- ply:SetNWAngle("TA:PrevOrientationAng", orientation:Angle() + Angle(90, 0, 0))
				-- prevOrientationAng = ply:GetNWAngle("TA:PrevOrientationAng")
				-- -- if DegreeseBetween(orientation, prevOrientation) > 10 then
					-- -- print(WTL3)
					-- -- ChangeCamerOrientation(ply, WTL1, WTL2, eyeAngles)
					
					-- -- -- local c_Model = ents.CreateClientProp()
					-- -- -- c_Model:SetPos( ply:GetPos() )
					-- -- -- c_Model:SetAngles(orientationAng)
					-- -- -- c_Model:SetColor(Color(0, 255, 0))
					-- -- -- c_Model:SetModel( "models/props_junk/Wheebarrow01a.mdl" )
					-- -- -- c_Model:Spawn()
				-- -- end
				
				-- -- prevOrientationAng.p = math.ApproachAngle(prevOrientationAng.p, orientationAng.p, FrameTime() * 150)
				-- -- prevOrientationAng.y = math.ApproachAngle(prevOrientationAng.y, orientationAng.y, FrameTime() * 150)
				-- -- prevOrientationAng.r = math.ApproachAngle(prevOrientationAng.r, orientationAng.r, FrameTime() * 150)
				-- -- ply:SetNWAngle("TA:PrevOrientationAng", prevOrientationAng)

				_, newEyeAngle = LocalToWorld(Vector(), playerEyeAngle, Vector(), prevOrientationAng)
				
				local plyAng = -ply:GetAngles()
				local _, orientAngToPly = WorldToLocal(Vector(), plyAng, Vector(), prevOrientationAng)

				-- changing cam orientation when player is have different orientation or roll is inccorect
				if orientation != ORIENTATION_DEFAULT or orientation == ORIENTATION_DEFAULT and math.abs(ply:EyeAngles().r) > 0.1 then
					ply:SetEyeAngles(newEyeAngle)
					ply:SetNWAngle("TA:PlayerAng", newEyeAngle)
				end
			end
		end
	end )
end

function APERTURESCIENCE:IsPlayerOnGround( ply )
	local orientation = ply:GetNWVector("TA:Orientation")
	return orientation and orientation != Vector(0, 0, 1) or ply:IsOnGround()
end

function APERTURESCIENCE:InvertNormal(normal)
	if normal.x != 0 then normal.x = normal.x * -1 end
	if normal.y != 0 then normal.y = normal.y * -1 end
	if normal.z != 0 then normal.z = normal.z * -1 end
end

function APERTURESCIENCE:CheckForGel( startpos, dir, ignoreGelledProps, excludeNormalDifferents, sufraceNormalToCompare )
	
	local gelInfo, point = CheckForGel(startpos, dir)
	if not gelInfo then return nil end
	
	return gelInfo.paintType, gelInfo.normal, point
	
end

-- no more client side
if ( CLIENT ) then return end

function APERTURESCIENCE:PaintProp( ent, paintType )
	
	local paint_model = ent.GASL_ENT_PAINT
	
	if ( IsValid( paint_model ) ) then
		paint_model:SetColor( APERTURESCIENCE:GetColorByGelType( paintType ) )
		return
	end
	
	paint_model = ents.Create( "prop_physics" )
	if ( !IsValid( paint_model ) ) then return end
	
	paint_model:SetModel( ent:GetModel() )
	paint_model:SetPos( ent:GetPos() )
	paint_model:SetAngles( ent:GetAngles() )
	paint_model:SetParent( ent )
	paint_model:PhysicsInit( SOLID_NONE )
	paint_model:SetMoveType( MOVETYPE_NONE )
	paint_model:Spawn()
	paint_model:SetNotSolid( true )
	paint_model:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	paint_model:SetColor( APERTURESCIENCE:GetColorByGelType( paintType ) )
	
	local mats = paint_model:GetMaterials()
	for mInx, mat in pairs( mats ) do
		paint_model:SetSubMaterial( mInx - 1, "paint/prop_paint" )
	end
	
	paint_model.GASL_Ignore = true
	ent.GASL_ENT_PAINT = paint_model

end

function APERTURESCIENCE:ClearPaintProp( ent )

	local paint_model = ent.GASL_ENT_PAINT

	if ( !IsValid( paint_model ) ) then return end
	paint_model:Remove()
	
end

function APERTURESCIENCE:MakePaintPuddle(paintType, pos, velocity, radius)
	
	local color = APERTURESCIENCE:GetColorByGelType(paintType)
	local ent = ents.Create("ent_paint_puddle")
	
	if not IsValid( ent ) then return end
	
	ent:SetPos(pos)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:Spawn()
	ent:GetPhysicsObject():EnableCollisions(false)
	ent:GetPhysicsObject():Wake()
	ent:SetColor(color)
	if paintType == PORTAL_GEL_WATER then ent:SetMaterial("models/gasl/portal_gel_bubble/gel_water") end
	ent:GetPhysicsObject():SetVelocity(velocity)

	ent.GASL_GelType = paintType
	ent:SetGelRadius(radius)
	
	return ent
end

local function PlayerChangeOrient(ply, orientation, paintHitPos)
	
	-- Handling changing orientation
	local currentOrient = ply:GetNWVector("TA:Orientation")
	local playerHeight = ply:GetModelRadius()
	local plyOrientCenter = ply:GetPos() + currentOrient * playerHeight / 2
	local orientPlyRad = orientation * playerHeight
	local plyAngle = ply:EyeAngles()
	if not paintHitPos then _, _, paintHitPos = APERTURESCIENCE:CheckForGel(plyOrientCenter, -orientPlyRad) end
	
	-- changing camera orientation
	ply:SetCurrentViewOffset(Vector(orientPlyRad.x, orientPlyRad.y, 0))
	ply:SetViewOffset(Vector(0, 0, orientPlyRad.z))
	ply:SetNWVector("TA:Orientation", orientation)
	
	-- creating avatar if orientation is not default
	if orientation != currentOrient then
		local avatar = ply:GetNWEntity("TA:Avatar")
		if orientation == ORIENTATION_DEFAULT then
			local color = ply:GetColor()
			color.a = 255
			ply:SetColor(color)
			ply:SetRenderMode(RENDERMODE_NORMAL)

			if IsValid(avatar) then ply:GetNWEntity("TA:Avatar"):Remove() end
		elseif not IsValid(avatar) then
			local color = ply:GetColor()
			local avatar = ents.Create("gasl_player_avatar")
			color.a = 0

			ply:SetColor(color)
			ply:SetRenderMode(RENDERMODE_TRANSALPHA)
			if !IsValid(avatar) then return end
			avatar:SetPlayer(ply)
			avatar:SetPos(ply:GetPos())
			avatar:SetAngles(orientation:Angle() + Angle(90, 0, 0))
			avatar:Spawn()
		end
	end
	if not paintHitPos then return end
	ply:SetNWVector("TA:OrientationWalk", paintHitPos)
	ply:SetPos(paintHitPos)
	ply:SetVelocity(-ply:GetVelocity())

	-- cooldown for ability to change
	timer.Create("TA:Player_Changed"..ply:EntIndex(), 1, 1, function() end)
end

local function PlayerUnStuck(ply)
	local orientation = ply:GetNWVector("TA:Orientation")
	local offset = Vector()
	local nearestPoint = ply:NearestPoint(ply:GetPos() - orientation * ply:GetModelRadius() * 2) 
	local nearestOffset = (ply:GetPos() - nearestPoint)
	local obbmax = ply:OBBMaxs()
	local obbmin = ply:OBBMaxs()
	local pos = ply:GetPos() + Vector(0, 0, nearestOffset.z)

	local traceHullRight = util.TraceHull({
		start = pos - Vector(0, obbmax.y, 0),
		endpos = pos + Vector(0, obbmax.y, 0),
		mins = Vector(obbmin.x, -1, obbmin.z),
		maxs = Vector(obbmax.x, 1, obbmax.z),
		filter = ply,
	})
	
	local traceHullLeft = util.TraceHull({
		start = pos + Vector(0, obbmax.y, 0),
		endpos = pos - Vector(0, obbmax.y, 0),
		mins = Vector(obbmin.x, -1, obbmin.z),
		maxs = Vector(obbmax.x, 1, obbmax.z),
		filter = ply,
	})
	
	local traceHullForward = util.TraceHull({
		start = pos - Vector(obbmax.x, 0, 0),
		endpos = pos + Vector(obbmax.x, 0, 0),
		mins = Vector(-1, obbmin.y, obbmin.z),
		maxs = Vector(1, obbmax.y, obbmax.z),
		filter = ply,
	})
	
	local traceHullBack = util.TraceHull({
		start = pos + Vector(obbmax.x, 0, 0),
		endpos = pos - Vector(obbmax.x, 0, 0),
		mins = Vector(-1, obbmin.y, obbmin.z),
		maxs = Vector(1, obbmax.y, obbmax.z),
		filter = ply,
	})
	
	-- Offsetting
	offset = offset + Vector(0, 0, nearestOffset.z)

	if traceHullForward.Hit and not traceHullForward.StartSolid then
		offset = offset - Vector(traceHullForward.Fraction * obbmax.x * 4, 0, 0)
	end
	if traceHullBack.Hit and not traceHullBack.StartSolid then
		offset = offset + Vector(traceHullBack.Fraction * obbmax.x * 4, 0, 0)
	end
	if traceHullForward.StartSolid and traceHullBack.StartSolid then
		offset = offset + Vector(nearestOffset.x, 0, 0)
	end

	if traceHullRight.Hit and not traceHullRight.StartSolid then
		offset = offset - Vector(0, traceHullRight.Fraction * obbmax.y * 4, 0)
	end
	if traceHullLeft.Hit and not traceHullLeft.StartSolid then
		offset = offset + Vector(0, traceHullLeft.Fraction * obbmax.y * 4, 0)
	end
	if traceHullRight.StartSolid and traceHullLeft.StartSolid then
		offset = offset + Vector(0, nearestOffset.y, 0)
	end
	
	ply:SetPos(ply:GetPos() + offset)
	
	-- print(traceHullForward.Fraction, traceHullRight.Fraction, traceHullLeft.Fraction, traceHullBack.Fraction, traceHullUp.Fraction)
	-- print(traceHullForward.StartSolid, traceHullRight.StartSolid, traceHullLeft.StartSolid, traceHullBack.StartSolid, traceHullUp.StartSolid)
	-- print(traceHullForward.Hit, traceHullRight.Hit, traceHullLeft.Hit, traceHullBack.Hit, traceHullUp.Hit)
end

hook.Add("Think", "TA:HandlingGel", function()	

	for i,ply in pairs(player.GetAll()) do

		-- assigning variables
		if ply:GetNWVector("TA:Orientation") == Vector() then ply:SetNWVector("TA:Orientation", ORIENTATION_DEFAULT) end
		if not ply:GetNWVector("TA:OrientationWalk") then ply:SetNWVector("TA:OrientationWalk", Vector(0, 0, 0)) end
		if not ply.TA_Player_PrevOrient then ply.TA_Player_PrevOrient = Angle() end

		local orientation 	= ply:GetNWVector("TA:Orientation")
		local eyeAngle 		= ply:EyeAngles()
		local dir 			= Vector()
		local playerHeight 	= ply:GetModelRadius()
		
		-- Checking if player stands or hitting paint
		if APERTURESCIENCE:IsPlayerOnGround(ply) or orientation != ORIENTATION_DEFAULT then 
			dir = -orientation * (playerHeight + 50)
		else
			local velocity = ply:GetVelocity()
			dir = (Vector(0, 0, -0.5) + velocity:GetNormalized()) * velocity:Length()
			if dir:Length() > playerHeight then dir = dir:GetNormalized() * playerHeight end
		end
		local paintType, paintNormal, paintHitPos = APERTURESCIENCE:CheckForGel(ply:GetPos() + orientation * playerHeight / 2, dir)

		-- Getting player moving speed
		local speed = ply:GetWalkSpeed()
		if ply:KeyDown(IN_WALK) then speed = ply:GetWalkSpeed() / 2 end
		if ply:KeyDown(IN_SPEED) then speed = ply:GetRunSpeed() end
		speed = speed * FrameTime() * 50
		
		-- Getting player moving direction
		local moveDirection = Vector(0, 0, 0)
		if ply:KeyDown(IN_FORWARD) then moveDirection.x = 1 end
		if ply:KeyDown(IN_BACK) then moveDirection.x = -1 end
		if ply:KeyDown(IN_MOVELEFT) then moveDirection.y = 1 end
		if ply:KeyDown(IN_MOVERIGHT) then moveDirection.y = -1 end
		moveDirection:Normalize() 

		-- Converting player moving direction in world orientation in to current orientation on sticky paint
		local plyOrientCenter = ply:GetPos() + orientation * playerHeight / 2
		local orientAng = orientation:Angle() + Angle(90, 0, 0)
		local _, localangle = WorldToLocal(Vector(), eyeAngle, Vector(), orientAng)
		localangle = Angle(0, localangle.yaw, 0)
		local _, worldangle = LocalToWorld(Vector(), localangle, Vector(), orientAng)
		moveDirection:Rotate(worldangle)

		-- Checking for paint infront of player current position
		-- if doesn't found then tring to do this againg but with conner on floor
		local paintTypeFront, paintNormalFront, paintHitPosFront = APERTURESCIENCE:CheckForGel(plyOrientCenter, moveDirection * 40)

		if not paintTypeFront then
			local traceForwardFloor = util.QuickTrace(ply:GetPos() + orientation * 5, moveDirection * playerHeight / 2, ply)
			local traceForwardFloorDown = util.QuickTrace(traceForwardFloor.HitPos, -orientation * 20, ply)
			paintTypeFront, paintNormalFront, paintHitPosFront = APERTURESCIENCE:CheckForGel(traceForwardFloorDown.HitPos, -moveDirection * playerHeight / 2)
		end
		
		-- Changing player's orientation if player moving towards to painted wall
		if  paintTypeFront == PORTAL_GEL_STICKY and not timer.Exists("TA:Player_Changed"..ply:EntIndex()) then
			paintType 		= paintTypeFront
			orientation 	= paintNormalFront
			paintNormal 	= paintNormalFront
			paintHitPos 	= paintHitPosFront
			PlayerChangeOrient(ply, orientation, paintHitPos)
		end
		
		-- Handling player exiting gel
		if not paintType and ply.GASL_LastStandingGelType and CurTime() > ply.GASL_LastTimeOnGel + 0.1 then
			if ply.GASL_LastStandingGelType == PORTAL_GEL_BOUNCE then ply:EmitSound("GASL.GelBounceExit") end
			if ply.GASL_LastStandingGelType == PORTAL_GEL_SPEED then ply:EmitSound("GASL.GelSpeedExit") end
			if ply.GASL_LastStandingGelType == PORTAL_GEL_STICKY then
				ply:EmitSound("GASL.GelStickExit")

				if orientation != ORIENTATION_DEFAULT then
					orientation = ORIENTATION_DEFAULT
					paintNormal = orientation
					PlayerUnStuck(ply)
					PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
				end
			end

			ply.GASL_LastTimeOnGel = 0
			ply.GASL_LastStandingGelType = 0
		end
		
		if paintType != PORTAL_GEL_STICKY and orientation != ORIENTATION_DEFAULT then
			ply:EmitSound("GASL.GelStickExit")

			orientation = ORIENTATION_DEFAULT
			paintNormal = orientation
			PlayerUnStuck(ply)
			PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
		end

		-- Normalization orientation
		-- if (not paintType and ply.GASL_LastTimeOnGel and CurTime() > (ply.GASL_LastTimeOnGel + 0.25) or paintType and paintType != PORTAL_GEL_STICKY) and orientation != ORIENTATION_DEFAULT then
			-- local offset = orientation * (orientation - Vector( 0, 0, 1 )):Length() * playerHeight / 1.5
			-- local traceFloor = util.QuickTrace(ply:GetPos() + offset, Vector(0, 0, -playerHeight), ply)
			-- offset = offset - Vector(0, 0, traceFloor.Fraction * playerHeight)
			-- ply:SetPos(ply:GetPos() + offset)
			
			-- orientation = ORIENTATION_DEFAULT
			-- paintNormal = orientation
			-- PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
		-- end

		-- Skip if paint doesn't found
		if not paintType then
			continue
		end
		NormalFlipZeros(paintNormal)
		
		-- Footsteps sounds
		if APERTURESCIENCE:IsPlayerOnGround(ply) and not timer.Exists("TA_GelFootsteps"..ply:EntIndex())
			and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_MOVELEFT)) then
			ply:EmitSound("GASL.GelFootsteps")

			local tick = ply:KeyDown(IN_SPEED) and 0.2 or 0.4
			timer.Create("TA_GelFootsteps"..ply:EntIndex(), tick, 1, function() end)
		end
		
		-- Handling player entering gel
		if APERTURESCIENCE:IsPlayerOnGround(ply) then
			if not ply.GASL_LastTimeOnGel or ply.GASL_LastTimeOnGel == 0 then
				if paintType == PORTAL_GEL_BOUNCE then ply:EmitSound("GASL.GelBounceEnter") end
				if paintType == PORTAL_GEL_SPEED then ply:EmitSound("GASL.GelSpeedEnter") end
				if paintType == PORTAL_GEL_STICKY then
					ply:EmitSound("GASL.GelStickEnter")
					if DegreeseBetween(paintNormal, orientation) > 1 then PlayerChangeOrient(ply, paintNormal) end
				end
				
				-- Doesn't change if player ran on repulsion paint when he was on propulsion paint
				if paintType != PORTAL_GEL_BOUNCE or ply.GASL_LastStandingGelType != PORTAL_GEL_SPEED or plyVelocity:Length() < 10 then
					ply.GASL_LastStandingGelType = paintType
				end
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		end
		
		-- if player stand on repulsion paint
		if paintType == PORTAL_GEL_BOUNCE and not ply:KeyDown(IN_DUCK) then
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
			if !APERTURESCIENCE:IsPlayerOnGround(ply) or ply.GASL_LastStandingGelType == PORTAL_GEL_SPEED and plyVelocity:Length() > 400 then
				local WTL = WorldToLocal(plyVelocity, Angle(), Vector(), paintNormal:Angle() + Angle(90, 0, 0))
				WTL = Vector(0, 0, math.max( math.abs( WTL.z ) * 2, 800 ) )
				local LTW = LocalToWorld(WTL, Angle(), Vector(), paintNormal:Angle() + Angle(90, 0, 0))
				LTW.z = math.max(200, LTW.z / 2 )
				
				ply:SetVelocity(LTW + Vector(0, 0, math.abs( ply:GetVelocity().z)))
				ply:EmitSound("GASL.GelBounce")
			end
		end
		
		-- if player stand on propulsion paint
		if paintType == PORTAL_GEL_SPEED then
			local plyVelocity = ply:GetVelocity()

			if not ply.GASL_GelPlayerVelocity or ply.GASL_GelPlayerVelocity:Length() == math.huge then ply.GASL_GelPlayerVelocity = Vector() end
			if plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
			
			-- When player moving towards it will increese speed
			if ply:KeyDown(IN_FORWARD) then
				ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector(ply:GetForward().x, ply:GetForward().y, 0) * 30
			end
			
			ply:SetVelocity(Vector(ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0) * FrameTime() * 40)
			ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
		end
		
		-- if player stand on sticky paint
		if paintType == PORTAL_GEL_STICKY and ply:GetNWVector("TA:OrientationWalk") != Vector() then
			local localPos = ply:GetNWVector("TA:OrientationWalk")
			
			if localPos != Vector() and orientation != ORIENTATION_DEFAULT then
				local stickyMoveDirection = moveDirection * speed / 50
				local plyWidth = 30
				
				local playerCenter = ply:GetPos() + orientation * playerHeight / 2
				local boxSize = Vector(1, 1, 1)
				local traceForward = util.TraceHull({
					start = playerCenter,
					endpos = playerCenter + orientAng:Forward() * plyWidth,
					mins = -boxSize,
					maxs = boxSize,
					filter = ply,
				})
				local traceBack = util.TraceHull({
					start = playerCenter,
					endpos = playerCenter - orientAng:Forward() * plyWidth,
					mins = -boxSize,
					maxs = boxSize,
					filter = ply,
				})
				local traceRight = util.TraceHull({
					start = playerCenter,
					endpos = playerCenter + orientAng:Right() * plyWidth,
					mins = -boxSize,
					maxs = boxSize,
					filter = ply,
				})
				local traceLeft = util.TraceHull({
					start = playerCenter,
					endpos = playerCenter - orientAng:Right() * plyWidth,
					mins = -boxSize,
					maxs = boxSize,
					filter = ply,
				})
				
				boxSize = Vector(plyWidth, plyWidth, 1)
				local traceForwardFloor = util.QuickTrace(ply:GetPos() + orientation * 5, Vector(0, 0, plyWidth / 4), ply)
				local traceForwardFloorDown = util.QuickTrace(traceForwardFloor.HitPos, -orientation * 6, ply)
				local traceForwardFloorBack = util.TraceHull({
					start = traceForwardFloorDown.HitPos,
					endpos = traceForwardFloorDown.HitPos - Vector(0, 0, plyWidth / 4),
					mins = -boxSize,
					maxs = boxSize,
					filter = ply,
					collisiongroup = COLLISION_GROUP_DEBRIS,
				})
				
				if not traceForwardFloor.Hit and not traceForwardFloorDown.Hit
					and traceForwardFloorBack.Hit and traceForwardFloorBack.Fraction > 0 and DegreeseBetween(ORIENTATION_DEFAULT, traceForwardFloorBack.HitNormal) < 25
					and DegreeseBetween(ORIENTATION_DEFAULT, orientation) > 45 then
					
					-- Step on conner
					ply:SetPos(traceForwardFloorBack.HitPos)
					ply:SetVelocity(Vector(0, 0, 100))
					orientation = ORIENTATION_DEFAULT
					paintNormal = orientation
					PlayerUnStuck(ply)
					PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
				else
					-- Normalization orientation
					if ply:KeyDown(IN_JUMP) then
						
						-- Jump out paint
						PlayerUnStuck(ply)
						PlayerChangeOrient(ply, ORIENTATION_DEFAULT)
						ply:SetVelocity(orientation * ply:GetJumpPower())
					else
						-- Pseudo collision
						if traceForward.Hit then stickyMoveDirection = stickyMoveDirection - orientAng:Forward() * (1 - traceForward.Fraction) * plyWidth end
						if traceBack.Hit then stickyMoveDirection = stickyMoveDirection + orientAng:Forward() * (1 - traceBack.Fraction) * plyWidth end
						if traceRight.Hit then stickyMoveDirection = stickyMoveDirection - orientAng:Right() * (1 - traceRight.Fraction) * plyWidth end
						if traceLeft.Hit then stickyMoveDirection = stickyMoveDirection + orientAng:Right() * (1 - traceLeft.Fraction) * plyWidth end
						local walk = localPos + stickyMoveDirection
						
						ply:SetNWVector("TA:OrientationWalk", walk)
						ply:SetPos(walk)
						ply:SetVelocity(-ply:GetVelocity())
					end
				end
			end
		end
	end
	
	-- Handling paintled entities
	for k, v in pairs(APERTURESCIENCE.GELLED_ENTITIES) do
	
		-- skip and remove if entity is not exist
		if not IsValid(v) then
			APERTURESCIENCE.GELLED_ENTITIES[k] = nil
			continue
		end

		-- skip if props is freezed or it is holding by the player
		if IsValid(v:GetPhysicsObject()) and !v:GetPhysicsObject():IsMotionEnabled() or v:IsPlayerHolding() then continue end
		
		local vPhys = v:GetPhysicsObject()
		local dir = vPhys:GetVelocity() / 10
		
		local trace = util.TraceEntity({
			start = v:GetPos()
			, endpos = v:GetPos() + dir
			, filter = v 
		}, v)

		if v.GASL_GelledType == PORTAL_GEL_BOUNCE then
			if trace.Hit then
				v:EmitSound("GASL.GelBounceProp")
				-- makes negative z for local hitnormal
				local WTL = WorldToLocal(vPhys:GetVelocity(), Angle(), Vector(), trace.HitNormal:Angle() + Angle(90, 0, 0))
				WTL.z = math.max( -WTL.z, 400 )
				WTL = WTL + VectorRand() * 100
				local LTW = LocalToWorld(WTL, Angle(), Vector(), trace.HitNormal:Angle() + Angle(90, 0, 0))
				
				vPhys:SetVelocity(LTW)
				v:GetPhysicsObject():AddAngleVelocity(VectorRand() * 400)
			end
		end
		
		if v.GASL_GelledType == PORTAL_GEL_STICKY then
			if trace.Hit and (not IsValid(trace.Entity) or IsValid(trace.Entity) and not IsValid(constraint.Find(v, trace.Entity, "Weld", 0, 0))) then
				timer.Simple(dir:Length() / 1000, function()
					if IsValid(v) and IsValid(v:GetPhysicsObject()) then
						if trace.HitWorld then
							v:GetPhysicsObject():EnableMotion( false )
						elseif IsValid(trace.Entity) then
							constraint.Weld(v, trace.Entity, 0, trace.PhysicsBone, 5000, collision == 0, false)
						end
					end
				end )
			end
		end
	end

end )