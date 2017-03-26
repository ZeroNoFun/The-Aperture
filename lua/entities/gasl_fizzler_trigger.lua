DEFINE_BASECLASS( "base_brush" )

ENT.Spawnable		= false
ENT.AdminOnly		= false

ENT.DoNotDuplicate = true

function ENT:Initialize()
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	
	self:SetNoDraw( true )
	self:SetNotSolid( true )
	
	self.DoNotDuplicate = true
	self.Parent = self:GetParent()
	
	-- if !IsValid( self.Parent ) then
		-- self:Remove()
	-- end
	
	self.InTrigger = {}
	self.CheckTrace = {}
	self.CheckTraceParams = {}

	self.CheckTraceParams.output = self.CheckTrace
	self.CheckTraceParams.filter = function( ent )
		if ( !IsValid( self ) ) then return false end
		if ( !IsValid( ent ) ) then return false end

		if ( ent == self ) then return false end
		if ( ent:IsWorld() ) then return true end
		return true
	end
end

function ENT:OnReloaded()
	self:Remove()
end

function ENT:OnRemove()
	self:Reset()

	if IsValid( self.Parent ) then
		self.Parent:Remove()
	end
end

local function Box(min, max)
	local tab = {
		Vector(min.x, min.y, min.z),
		Vector(min.x, min.y, max.z),
		Vector(min.x, max.y, min.z),
		Vector(min.x, max.y, max.z),

		Vector(max.x, min.y, min.z),
		Vector(max.x, min.y, max.z),
		Vector(max.x, max.y, min.z),
		Vector(max.x, max.y, max.z)
	}

	return tab
end

function ENT:Reset()
	for k,v in pairs(self.InTrigger or {}) do
		if !IsValid(k) then
			continue
		end

		self:EndTouch( k )
	end

	self.InTrigger = {}
end

function ENT:SetBounds( minpos, maxpos )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )

	self:SetCollisionBounds( minpos, maxpos )
	//self:SetNotSolid( true )
	
	self.minpos = minpos
	self.maxpos = maxpos
	
end

function ENT:DoCheckTrace( endpos )
	self.CheckTraceParams.start = self:GetPos()
	self.CheckTraceParams.endpos = endpos
	
	util.TraceLine( self.CheckTraceParams )	
	return self.CheckTrace.Hit
end

function ENT:CleanUpList()
	for k,v in pairs(self.InTrigger or {}) do
		if IsValid(k) then
			continue
		end

		self.InTrigger[k] = nil
	end
end

function ENT:Filter( ent )
	if ( !IsValid( ent ) ) then return false end
	if ( !IsValid( self ) ) then return false end	
	if ( !APERTURESCIENCE:IsValidEntity( ent ) ) then return false end

	return true
end

function ENT:StartTouch( ent )
	if !IsValid(self.Parent) then return end

	if self.InTrigger[ent] then return end
	if !self:Filter( ent ) then return end

	print( ent )
	local tr = self:GetTouchTrace()
	//if self:DoCheckTrace( tr.HitPos ) then return end

	self.Parent:HandleEntityInField( ent )
end

function ENT:EndTouch( ent )
	if !IsValid(self.Parent) then return end
	if !self.Parent.Active then return end

	if !self.InTrigger[ent] then return end
	if !self:Filter( ent ) then return end

	for k,v in pairs(self.InTrigger or {}) do
		return
	end
end

function ENT:Touch( ent )
	//self:EmitSound( "ambient/explosions/explode_" .. math.random( 1, 9 ) .. ".wav" )
	self:StartTouch( ent )
end