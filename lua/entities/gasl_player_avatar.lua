AddCSLuaFile( )

ENT.Type = "anim"
ENT.Spawnable = false
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/humans/group03/male_02.mdl"

util.PrecacheModel( ENT.Model )

if ( CLIENT ) then

	function ENT:Draw()

		local ply = self:GetNWEntity( "Player" )

		self.GetPlayerColor = function()
			if ( IsValid( ply ) && ply.GetPlayerColor ) then
				return ply:GetPlayerColor()
			else
				return Vector( 1, 1, 1 )
			end
		end

		if ( LocalPlayer() != ply || LocalPlayer():GetViewEntity() != ply ) then
			self:DrawModel()
		end
	end

	function ENT:DrawTranslucent()
		self:Draw()
	end
	
	return

end

function ENT:Initialize()

	self:DrawShadow( false )
	self:SetModel( self.Model )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )

end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end

function ENT:Think()

	self:NextThink( CurTime() )

	local ply = self:GetNWEntity( "Player" )
	local EyeAngle = ply:EyeAngles()
	local Orientation = ply:GetNWVector( "TA:Orientation" )
	local OrientAng = Orientation:Angle() + Angle( 90, 0, 0 )
	
	local _, localangle = WorldToLocal( Vector(), EyeAngle, Vector(), OrientAng )
	localangle = Angle( 0, localangle.yaw, 0 )
	local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), OrientAng )

	self:SetPos( ply:GetPos() )
	self:SetAngles( worldangle )
	
	local sequence = ACT_TRANSITION 
	
	if ( ply:KeyDown( IN_FORWARD ) ) then
		if ( ply:KeyDown( IN_FORWARD ) ) then sequence = ACT_RUN end
	end
	
	if ( !self.LastSequence || self.LastSequence != sequence ) then
		self:ResetSequence( sequence )
		self:SetSequence( sequence )
		self.LastSequence = sequence
	end
	
	return true

end

function ENT:SetPlayer( pl )

	pl:SetNWEntity( "TA:Avatar", self )
	self:SetNWEntity( "Player", pl )

	if ( IsValid( pl ) && pl:IsPlayer() ) then

		self.Model = pl:GetModel()
		util.PrecacheModel( self.Model )
		self:SetModel( self.Model )
		self:SetSkin( pl:GetSkin() )
		self.GetPlayerColor = function() return pl:GetPlayerColor() end

		for i = 0, pl:GetNumBodyGroups() - 1 do self:SetBodygroup( i, pl:GetBodygroup( i ) ) end

		-- Player color
	end

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )

end
