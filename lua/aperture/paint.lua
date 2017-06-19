AddCSLuaFile()
	
-- ================================ PAINT STUFF ============================
LIB_APERTURE.PAINT_QUALITY		= 1
LIB_APERTURE.PAINT_TYPES = {}

PORTAL_PAINT_NONE 		= 0
PORTAL_PAINT_COUNT		= 0

ORIENTATION_DEFAULT 	= Vector(0, 0, 1)

APERTURESCIENCE.GEL_BOX_SIZE 			= 64
APERTURESCIENCE.GEL_MAXSIZE 			= 150
APERTURESCIENCE.GEL_MINSIZE 			= 40
APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED 	= 1000

-- APERTURESCIENCE.GEL_SPEED_COLOR 		= Color(255, 100, 0)
-- APERTURESCIENCE.GEL_PORTAL_COLOR 		= Color(150, 150, 150)
-- APERTURESCIENCE.GEL_WATER_COLOR 		= Color(200, 230, 255)
-- APERTURESCIENCE.GEL_STICKY_COLOR 		= Color(125, 25, 220)
-- APERTURESCIENCE.GEL_REFLECTION_COLOR 	= Color(255, 255, 255)

APERTURESCIENCE.GELLED_ENTITIES 		= { }
APERTURESCIENCE.CONNECTED_PAINTS 		= { }

function NormalFlipZeros(normal)
	local lower = 0.000001
	if math.abs(normal.x) < lower then normal.x = 0 end
	if math.abs(normal.y) < lower then normal.y = 0 end
	if math.abs(normal.z) < lower then normal.z = 0 end
end

function DegreeseBetween(vector1, vector2)
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

			-- fixing player's roll if orientation is default
			if playerAng != eyeAngles then
				local angOffset = eyeAngles - playerAng
				
				playerEyeAngle.p = math.max(-88, math.min(88, playerEyeAngle.p))
				if playerEyeAngle.y > 360 then playerEyeAngle.y = playerEyeAngle.y - 360 end
				if playerEyeAngle.y < -360 then playerEyeAngle.y = playerEyeAngle.y + 360 end
				
				ply:SetNWAngle("TA:PlayerEyeAngle", playerEyeAngle + angOffset)
				playerAng = eyeAngles
				ply:SetNWAngle("TA:PlayerAng", playerAng)
			end
			
			-- player camera changing orientation
			if ply.TA_Current_Ang and ply.TA_New_Ang and ply.TA_Camera_Ang_Offset then
				local currentAng = ply.TA_Current_Ang
				local newAng = ply.TA_New_Ang
				local cameraAngOffset = ply.TA_Camera_Ang_Offset
				local maxDegreese = ply.TA_MaxDegreese
				
				local _, offsetAngle = WorldToLocal(Vector(), newAng, Vector(), currentAng)
				offsetAngle = offsetAngle * FrameTime() * 10
				_, offsetAngle = LocalToWorld(Vector(), offsetAngle, Vector(), currentAng)
				currentAng = offsetAngle
				ply.TA_Current_Ang = currentAng
				
				local _, camAng = LocalToWorld(Vector(), cameraAngOffset, Vector(), currentAng)
				
				ply:SetEyeAngles(camAng)
				
				local result = DegreeseBetween(currentAng:Forward(), newAng:Forward())
				if result < 1 then
					ply.TA_Current_Ang = nil
					local _, camOffAng = LocalToWorld(Vector(), Angle(0, 0, 0), Vector(), newAng)
					ply:SetNWAngle("TA:PrevOrientationAng", camOffAng)
					ply:SetNWAngle("TA:PlayerEyeAngle", cameraAngOffset)
				end
			else
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

function APERTURESCIENCE:GetPaintInfo(startpos, dir, ignoreGelledProps, excludeNormalDifferents, sufraceNormalToCompare)
	local paintInfo, point = LIB_PAINT.GetPaintInfo(startpos, dir)
	if not paintInfo then return nil end
	
	return paintInfo.paintType, paintInfo.normal, point
end

-- Assigning new paint type
function LIB_APERTURE:CreateNewPaintType(index, info)
	PORTAL_PAINT_COUNT = PORTAL_PAINT_COUNT + 1
	LIB_APERTURE.PAINT_TYPES[index] = info
end

-- Loading paint types
local paint_types = file.Find("aperture/paint_types/*.lua", "LUA")
for _, plugin in ipairs(paint_types) do
	include("aperture/paint_types/" .. plugin)
end

function APERTURESCIENCE:PaintTypeToColor(paintType)
	return LIB_APERTURE.PAINT_TYPES[paintType].COLOR
end

function APERTURESCIENCE:PaintTypeToName(index)
	return LIB_APERTURE.PAINT_TYPES[index].NAME
end

if SERVER then

function PlayerChangeOrient(ply, orientation, paintHitPos)
	
	-- Handling changing orientation
	local currentOrient = ply:GetNWVector("TA:Orientation")
	local playerHeight = ply:GetModelRadius()
	local plyOrientCenter = ply:GetPos() + currentOrient * playerHeight / 2
	local orientPlyRad = orientation * playerHeight
	local plyAngle = ply:EyeAngles()
	if not paintHitPos then _, _, paintHitPos = APERTURESCIENCE:GetPaintInfo(plyOrientCenter, -orientPlyRad) end
	
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

function PlayerUnStuck(ply)
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
	-- if traceHullForward.StartSolid and traceHullBack.StartSolid then
		-- offset = offset + Vector(nearestOffset.x, 0, 0)
	-- end

	if traceHullRight.Hit and not traceHullRight.StartSolid then
		offset = offset - Vector(0, traceHullRight.Fraction * obbmax.y * 4, 0)
	end
	if traceHullLeft.Hit and not traceHullLeft.StartSolid then
		offset = offset + Vector(0, traceHullLeft.Fraction * obbmax.y * 4, 0)
	end
	-- if traceHullRight.StartSolid and traceHullLeft.StartSolid then
		-- offset = offset + Vector(0, nearestOffset.y, 0)
	-- end
	
	ply:SetPos(ply:GetPos() + offset)
	
	-- print(traceHullForward.Fraction, traceHullRight.Fraction, traceHullLeft.Fraction, traceHullBack.Fraction, traceHullUp.Fraction)
	-- print(traceHullForward.StartSolid, traceHullRight.StartSolid, traceHullLeft.StartSolid, traceHullBack.StartSolid, traceHullUp.StartSolid)
	-- print(traceHullForward.Hit, traceHullRight.Hit, traceHullLeft.Hit, traceHullBack.Hit, traceHullUp.Hit)
end

end -- SERVER

-- no more client side
if ( CLIENT ) then return end

function APERTURESCIENCE:PaintProp( ent, paintType )
	
	local paint_model = ent.GASL_ENT_PAINT
	
	if ( IsValid( paint_model ) ) then
		paint_model:SetColor( APERTURESCIENCE:PaintTypeToColor( paintType ) )
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
	
	paint_model:SetColor( APERTURESCIENCE:PaintTypeToColor( paintType ) )
	
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
	
	local color = APERTURESCIENCE:PaintTypeToColor(paintType)
	local ent = ents.Create("ent_paint_puddle")
	
	if not IsValid( ent ) then return end
	
	ent:SetPos(pos)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:Spawn()
	ent:GetPhysicsObject():EnableCollisions(false)
	ent:GetPhysicsObject():Wake()
	ent:SetColor(color)
	if paintType == PORTAL_PAINT_WATER then ent:SetMaterial("models/gasl/portal_gel_bubble/gel_water") end
	ent:GetPhysicsObject():SetVelocity(velocity)

	ent.GASL_GelType = paintType
	ent:SetGelRadius(radius)
	
	return ent
end

hook.Add("Think", "TA:HandlingGel", function()	

	for i,ply in pairs(player.GetAll()) do

		-- assigning variables
		if ply:GetNWVector("TA:Orientation") == Vector() then ply:SetNWVector("TA:Orientation", ORIENTATION_DEFAULT) end
		if not ply:GetNWVector("TA:OrientationWalk") then ply:SetNWVector("TA:OrientationWalk", Vector(0, 0, 0)) end
		if not ply.TA_Player_PrevOrient then ply.TA_Player_PrevOrient = Angle() end
		if not ply.TA_LastTimeOnPaint then ply.TA_LastTimeOnPaint = 0 end
		
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
		local paintType, paintNormal, paintHitPos = APERTURESCIENCE:GetPaintInfo(ply:GetPos() + orientation * playerHeight / 2, dir)

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
		
		-- Converting player moving direction in world orientation in to current orientation
		local plyOrientCenter = ply:GetPos() + orientation * playerHeight / 2
		local orientationAng = orientation:Angle() + Angle(90, 0, 0)
		local _, localangle = WorldToLocal(Vector(), eyeAngle, Vector(), orientationAng)
		localangle = Angle(0, localangle.yaw, 0)
		local _, worldangle = LocalToWorld(Vector(), localangle, Vector(), orientationAng)
		moveDirection:Rotate(worldangle)
		
		local orientationMove = moveDirection * speed / 50
		
		-- Checking for paint infront of player current position
		-- if doesn't found then tring to do this againg but with conner on floor
		local paintTypeFront, paintNormalFront, paintHitPosFront = APERTURESCIENCE:GetPaintInfo(plyOrientCenter, moveDirection * 40)
		if not paintTypeFront then
			local traceForwardFloor = util.QuickTrace(ply:GetPos() + orientation * 5, moveDirection * playerHeight / 2, ply)
			local traceForwardFloorDown = util.QuickTrace(traceForwardFloor.HitPos, -orientation * 20, ply)
			paintTypeFront, paintNormalFront, paintHitPosFront = APERTURESCIENCE:GetPaintInfo(traceForwardFloorDown.HitPos, -moveDirection * playerHeight / 2)
		end
	
		if paintTypeFront then
			paintType 		= paintTypeFront
			paintNormal 	= paintNormalFront
			paintHitPos 	= paintHitPosFront
		end
		
		local paintInfo = LIB_APERTURE.PAINT_TYPES[paintType]
		
		-- Changing player's orientation if player moving towards to painted wall
		if  paintTypeFront == PORTAL_PAINT_STICKY and not timer.Exists("TA:Player_Changed"..ply:EntIndex()) then
			paintType 		= paintTypeFront
			orientation 	= paintNormalFront
			paintNormal 	= paintNormalFront
			paintHitPos 	= paintHitPosFront
			PlayerChangeOrient(ply, orientation, paintHitPos)
		end
		
		-- Handling player exiting gel
		if not paintType and (ply.TA_PrevPaintType and ply.TA_PrevPaintType != PORTAL_PAINT_NONE) 
			and (ply.TA_LastTimeOnPaint and CurTime() > ply.TA_LastTimeOnPaint + 0.1) then
			local prevPaintInfo = LIB_APERTURE.PAINT_TYPES[ply.TA_PrevPaintType]

			prevPaintInfo:OnExit(ply)
			
			ply.TA_LastTimeOnPaint = 0
			ply.TA_PrevPaintType = PORTAL_PAINT_NONE
		end

		-- Skip if paint doesn't found
		if not paintType then
			continue
		end
		NormalFlipZeros(paintNormal)
		
		-- Handling player entering gel
		if APERTURESCIENCE:IsPlayerOnGround(ply) then
			if ply.TA_PrevPaintType != paintType and paintType and paintType != PORTAL_PAINT_NONE and ply.TA_PrevPaintType and ply.TA_PrevPaintType != PORTAL_PAINT_NONE then
				local prevPaintInfo = LIB_APERTURE.PAINT_TYPES[ply.TA_PrevPaintType]
				if paintInfo.OnChangeTo then paintInfo:OnChangeTo(ply, ply.TA_PrevPaintType, paintNormal) end
				if prevPaintInfo.OnChangeFrom then prevPaintInfo:OnChangeFrom(ply, paintType, paintNormal) end
			end
			
			if not ply.TA_LastTimeOnPaint or ply.TA_LastTimeOnPaint == 0 then
				paintInfo:OnEnter(ply, paintNormal)
			end
			
			ply.TA_PrevPaintType = paintType
			ply.TA_LastTimeOnPaint = CurTime()
		end
				
		-- Footsteps sounds
		if APERTURESCIENCE:IsPlayerOnGround(ply) and not timer.Exists("TA_GelFootsteps"..ply:EntIndex())
			and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_MOVELEFT)) then
			ply:EmitSound("GASL.GelFootsteps")

			local tick = ply:KeyDown(IN_SPEED) and 0.2 or 0.4
			timer.Create("TA_GelFootsteps"..ply:EntIndex(), tick, 1, function() end)
		end
		
		paintInfo:Think(ply, paintNormal, orientationMove)
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

		if v.GASL_GelledType == PORTAL_PAINT_BOUNCE then
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
		
		if v.GASL_GelledType == PORTAL_PAINT_STICKY then
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