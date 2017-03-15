AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "gasl_base_ent"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Respawn" )
	self:NetworkVar( "Int", 1, "DropType" )

end

if ( CLIENT ) then
	
	function ENT:Initialize()
	
		self.BaseClass.Initialize( self )
		
	end
	
	function ENT:Think()
		
		self.BaseClass.Think( self )
	
	end
	
end

function ENT:DropTypeToInfo( )

	local dropTypeToinfo = {
		[0] = { model = "models/portal_custom/metal_box_custom.mdl", class = "prop_physics" },
		[1] = { model = "models/portal_custom/metal_box_custom.mdl", class = "prop_physics", skin = 1 },
		[2] = { model = "models/portal_custom/metal_ball_custom.mdl", class = "prop_physics" },
		[3] = { model = "models/props/reflection_cube.mdl", class = "prop_physics" },
		[4] = { class = "prop_monster_box" },
		[5] = { class = "ent_portal_bomb" }
	}
	
	return dropTypeToinfo[ self:GetDropType() ]
	
end

function ENT:Draw()
	
	self:DrawModel()
	
end

-- No more client side
if ( CLIENT ) then return end

function ENT:Initialize()
	
	self.BaseClass.Initialize( self )

	self:SetModel( "models/prop_backstage/item_dropper.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )
	self:DrawShadow( false )
	
	self:AddInput( "Enable", function( value )
		if ( tobool( value ) ) then self:Drop() end
	end )

	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Drop" } )
	
end

function ENT:Think()
	
	self.BaseClass.Think( self )

	self:NextThink( CurTime() + 0.1 )
	
	-- skip if item dropper allready drops item
	if ( timer.Exists( "GASL_ItemDroper_Reset"..self:EntIndex() ) ) then return true end

	-- if item inside dropper was missing spawing another one
	if ( !IsValid( self.GASL_ItemDropper_LastSpawnedItem ) ) then
		local item = self:CreateItem()
		if ( !IsValid( self.GASL_ItemDropper_LastDropperItem ) ) then self.GASL_ItemDropper_LastDropperItem = item end
	end
	
	-- if item is missing spawn another and if this function enabled
	if ( !IsValid( self.GASL_ItemDropper_LastDropperItem ) && self:GetRespawn() ) then
		self:Drop()
	end
	
	-- Epic fall animation
	local FallZ = 120
	local StartZ = 80
	local lastSpawnedItem = self.GASL_ItemDropper_LastSpawnedItem
	
	if ( !self.GASL_ItemDropper_Fall ) then self.GASL_ItemDropper_Fall = 0 end
	if ( !IsValid( lastSpawnedItem ) ) then return end
	
	local itemfall = self.GASL_ItemDropper_Fall

	if ( itemfall < FallZ ) then
		self:NextThink( CurTime() )
		self.GASL_ItemDropper_Fall = itemfall + math.max( 3, itemfall / 20 )
	elseif( itemfall > FallZ ) then self.GASL_ItemDropper_Fall = FallZ end
	lastSpawnedItem:SetPos( self:LocalToWorld( Vector( 0, 0, math.max( -20, StartZ - itemfall ) ) ) )
	
	return true
	
end

function ENT:CreateItem()

	local info = self:DropTypeToInfo()
	
	local item = ents.Create( info.class )
	if ( !IsValid( item ) ) then return end
	
	if ( info.model ) then item:SetModel( info.model ) end
	item:SetPos( self:LocalToWorld( Vector( 0, 0, 120 ) ) )
	item:SetAngles( self:GetAngles() )
	item:Spawn()
	if ( IsValid( item:GetPhysicsObject() ) ) then item:GetPhysicsObject():EnableMotion( false ) end
	constraint.NoCollide( item, self, 0, 0 )
	
	if ( info.skin ) then item:SetSkin( info.skin ) end
	if ( info.class == "prop_monster_box" ) then item.GASL_Monsterbox_cubemode = true end
	if ( info.class == "ent_portal_bomb" ) then item.GASL_Bomb_disabled = true end
	self.GASL_ItemDropper_LastSpawnedItem = item
	self.GASL_ItemDropper_Fall = 0
	
	return item
	
end

function ENT:Drop()

	-- skip if item dropper allready drops item
	if ( timer.Exists( "GASL_ItemDroper_Reset"..self:EntIndex() ) ) then return end
	
	-- dissolve old entitie
	if ( IsValid( self.GASL_ItemDropper_LastDropperItem ) && self.GASL_ItemDropper_LastDropperItem != self.GASL_ItemDropper_LastSpawnedItem ) then 
		APERTURESCIENCE:DissolveEnt( self.GASL_ItemDropper_LastDropperItem )
	end

	APERTURESCIENCE:PlaySequence( self, "item_dropper_open", 1.0 )
	self:SetSkin( 1 )
	self:EmitSound( "GASL.ItemDropperOpen" )
	
	-- Droping item
	timer.Simple( 0.5, function()
	
		if ( !IsValid( self.GASL_ItemDropper_LastSpawnedItem ) ) then return end
		local lastSpawnedItem = self.GASL_ItemDropper_LastSpawnedItem
		
		if ( !IsValid( lastSpawnedItem:GetPhysicsObject() ) ) then return end
		local lastSpawnedItemPhys = lastSpawnedItem:GetPhysicsObject()
		
		lastSpawnedItemPhys:EnableMotion( true )
		lastSpawnedItemPhys:Wake()
		
		if ( lastSpawnedItem:GetClass() == "ent_portal_bomb" ) then lastSpawnedItem.GASL_Bomb_disabled = false end
		self.GASL_ItemDropper_LastSpawnedItem = nil
		self.GASL_ItemDropper_LastDropperItem = lastSpawnedItem
		
	end )

	-- Close iris
	timer.Simple( 1.5, function()
	
		if ( !IsValid( self ) ) then return end
		
		APERTURESCIENCE:PlaySequence( self, "item_dropper_close", 1.0 )
		self:SetSkin( 0 )
		self:EmitSound( "GASL.ItemDropperClose" )	
	
	end )

	-- Spawn new item
	timer.Create( "GASL_ItemDroper_Reset"..self:EntIndex(), 2.5, 1, function()
	
		if ( !IsValid( self ) ) then return end
		
		self:CreateItem()
		self.GASL_ItemDropper_Fall = 0

	end )
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end

	if ( iname == "Drop" && tobool( value ) ) then self:Drop() end
	
end

function ENT:OnRemove()

	if ( IsValid( self.GASL_ItemDropper_LastSpawnedItem ) ) then self.GASL_ItemDropper_LastSpawnedItem:Remove() end
	if ( IsValid( self.GASL_ItemDropper_LastDropperItem ) ) then self.GASL_ItemDropper_LastDropperItem:Remove() end
	
	timer.Remove( "GASL_ItemDroper_Reset"..self:EntIndex() )

end
