AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "gasl_base_ent"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Respawn" )
	self:NetworkVar( "Int", 1, "DropType" )

end

if ( CLIENT ) then
	
	function ENT:Think()
		
		self.BaseClass.Think( self )
	
	end
	
end

function ENT:DropTypeToInfo( )

	local dropTypeToinfo = {
		[0] = { model = "models/portal_custom/metal_box_custom.mdl", class = "prop_physics" },
		[1] = { model = "models/portal_custom/metal_box_custom.mdl", class = "prop_physics", skin = 1 },
		[2] = { model = "models/props_gameplay/mp_ball.mdl", class = "prop_physics" },
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

function ENT:CreateItem()

	local info = self:DropTypeToInfo()
	
	local item = ents.Create( info.class )
	if ( info.model ) then item:SetModel( info.model ) end
	item:SetPos( self:LocalToWorld( Vector( 0, 0, 120 ) ) )
	item:SetAngles( self:GetAngles() )
	item:SetMoveType( MOVETYPE_NONE )
	item:Spawn()
	item:GetPhysicsObject():EnableMotion( false )
	if ( info.skin ) then item:SetSkin( info.skin ) end
	if ( info.class == "prop_monster_box" ) then item.GASL_Monsterbox_cubemode = true end
	if ( info.class == "ent_portal_bomb" ) then item.GASL_Bomb_disabled = true end
	self.GASL_ItemDropper_LastSpawnedItem = item
	self.GASL_ItemDropper_Fall = 0
	
	return item
	
end

function ENT:Initialize()
	
	self:SetModel( "models/props_backstage/item_dropper.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableCollisions( false )
	self:DrawShadow( false )
	
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Drop" } )
	
end


function ENT:Think()
	
	self.BaseClass.Think( self )

	self:NextThink( CurTime() + 0.01 )
	
	-- skip if item dropper allready drops item
	if ( timer.Exists( "GASL_ItemDroper"..self:EntIndex() ) ) then return true end

	-- if item is missing spawn another
	if ( !IsValid( self.GASL_ItemDropper_LastSpawnedItem ) ) then
		local item = self:CreateItem()
		if ( !IsValid( self.GASL_ItemDropper_LastDropperItem ) ) then self.GASL_ItemDropper_LastDropperItem = item end
	end
	
	if ( !IsValid( self.GASL_ItemDropper_LastDropperItem ) ) then
		self:Drop()
	end

	local lastSpawnedItem = self.GASL_ItemDropper_LastSpawnedItem
	local itemfall = self.GASL_ItemDropper_Fall
	
	-- Epic fall animation
	local FallZ = 120
	if ( itemfall < FallZ ) then
		self.GASL_ItemDropper_Fall = itemfall + math.max( 3, itemfall / 20 )
	elseif( itemfall > FallZ ) then self.GASL_ItemDropper_Fall = FallZ end
	lastSpawnedItem:SetPos( self:LocalToWorld( Vector( 0, 0, 100 - itemfall ) ) )
	
	return true
	
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end

	if ( iname == "Drop" && tobool( value ) ) then self:Drop() end
	
end

function ENT:Drop()

	-- skip if item dropper allready drops item
	if ( timer.Exists( "GASL_ItemDroper"..self:EntIndex() ) ) then return end
	
	APERTURESCIENCE:PlaySequence( self, "item_dropper_open", 1.0 )
	self:SetSkin( 1 )
	self:EmitSound( "GASL.ItemDropperOpen" )
	
	-- Droping item
	timer.Simple( 0.5, function()
	
		local lastSpawnedItem = self.GASL_ItemDropper_LastSpawnedItem
		local lastSpawnedItemPhys = lastSpawnedItem:GetPhysicsObject()
		lastSpawnedItemPhys:EnableMotion( true )
		lastSpawnedItemPhys:Wake()
		if ( lastSpawnedItem:GetClass() == "ent_portal_bomb" ) then lastSpawnedItem.GASL_Bomb_disabled = false end
		self.GASL_ItemDropper_LastSpawnedItem = nil
		self.GASL_ItemDropper_LastDropperItem = lastSpawnedItem
		
	end )

	-- Droping close iris
	timer.Simple( 1.5, function()
	
		if ( !IsValid( self ) ) then return end
		
		APERTURESCIENCE:PlaySequence( self, "item_dropper_close", 1.0 )
		self:SetSkin( 0 )
		self:EmitSound( "GASL.ItemDropperClose" )	
	
	end )

	-- Spawn new item
	timer.Create( "GASL_ItemDroper"..self:EntIndex(), 2.5, 1, function()
	
		if ( !IsValid( self ) ) then return end
		
		self:CreateItem()
		self.GASL_ItemDropper_Fall = 0

	end )
	
end

numpad.Register( "aperture_science_dropper_drop", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then
		-- dissolve old entitie
		if ( IsValid( ent.GASL_ItemDropper_LastDropperItem ) && ent.GASL_ItemDropper_LastDropperItem != ent.GASL_ItemDropper_LastSpawnedItem ) then 
			APERTURESCIENCE:DissolveEnt( ent.GASL_ItemDropper_LastDropperItem )
		end
		ent:Drop( )
	end
	
	return true

end )

function ENT:OnRemove()

	if ( IsValid( self.GASL_ItemDropper_LastSpawnedItem ) ) then self.GASL_ItemDropper_LastSpawnedItem:Remove() end
	if ( IsValid( self.GASL_ItemDropper_LastDropperItem ) ) then self.GASL_ItemDropper_LastDropperItem:Remove() end

end
