
// ================================ PAINT STUFF ============================

PORTAL_GEL_NONE 		= 0
PORTAL_GEL_BOUNCE 		= 1
PORTAL_GEL_SPEED 		= 2
PORTAL_GEL_PORTAL 		= 3
PORTAL_GEL_WATER 		= 4
PORTAL_GEL_STICKY 		= 5
PORTAL_GEL_REFLECTION 	= 6

PORTAL_GEL_COUNT		= 6

APERTURESCIENCE.GEL_BOX_SIZE 			= 74.9
APERTURESCIENCE.GEL_MAXSIZE 			= 150
APERTURESCIENCE.GEL_MINSIZE 			= 40
APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED 	= 1000

APERTURESCIENCE.GEL_BOUNCE_COLOR 		= Color( 50, 125, 255 )
APERTURESCIENCE.GEL_SPEED_COLOR 		= Color( 255, 100, 0 )
APERTURESCIENCE.GEL_PORTAL_COLOR 		= Color( 200, 200, 200 )
APERTURESCIENCE.GEL_WATER_COLOR 		= Color( 200, 230, 255 )
APERTURESCIENCE.GEL_STICKY_COLOR 		= Color( 75, 0, 125 )
APERTURESCIENCE.GEL_REFLECTION_COLOR 	= Color( 250, 250, 250 )

APERTURESCIENCE.GELLED_ENTITIES 	= { }
APERTURESCIENCE.CONNECTED_PAINTS 	= { }

function APERTURESCIENCE:GetColorByGelType( paintType )

	local color = Color( 0, 0, 0 )
	if ( paintType == PORTAL_GEL_BOUNCE ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( paintType == PORTAL_GEL_SPEED ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	if ( paintType == PORTAL_GEL_PORTAL ) then color = APERTURESCIENCE.GEL_PORTAL_COLOR end
	if ( paintType == PORTAL_GEL_WATER ) then color = APERTURESCIENCE.GEL_WATER_COLOR end
	if ( paintType == PORTAL_GEL_STICKY ) then color = APERTURESCIENCE.GEL_STICKY_COLOR end
	if ( paintType == PORTAL_GEL_REFLECTION ) then color = APERTURESCIENCE.GEL_REFLECTION_COLOR end

	return color
	
end


function APERTURESCIENCE:PaintTypeToName( index )
	
	local indexToName = {
		[PORTAL_GEL_BOUNCE] = "Repulsion"
		, [PORTAL_GEL_SPEED] = "Propulsion"
		, [PORTAL_GEL_PORTAL] = "Conversion"
		, [PORTAL_GEL_WATER] = "Cleansing"
		, [PORTAL_GEL_STICKY] = "Adhesion"
		, [PORTAL_GEL_REFLECTION] = "Reflection"
	}
	
	return indexToName[ index ]
	
end

// no more client side
if ( CLIENT ) then return end

function APERTURESCIENCE:CheckForGel( startpos, dir, ignoreGelledProps )
	
	if ( ignoreGelledProps == nil ) then ignoreGelledProps = false end
	
	local paintedProp = false
	
	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		ignoreworld = true,
		filter = function( ent )
			if ( ent:GetClass() == "env_portal_paint" || !ignoreGelledProps && ent.GASL_GelledType ) then return true end
		end
	} )
	
	if ( !IsValid( trace.Entity ) ) then return NULL end
	
	local paintType = PORTAL_GEL_NONE
	local normal = Vector()
	
	local hitPosLoc = trace.Entity:WorldToLocal( trace.HitPos )
	
	if ( trace.Entity:GetClass() == "env_portal_paint" ) then
		paintType = trace.Entity:GetGelType()
		normal = trace.Entity:GetUp()
	else
		paintType = trace.Entity.GASL_GelledType
		normal = trace.HitNormal
	end
	
	return trace.Entity, paintType, normal
	
end

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

function APERTURESCIENCE:MakePaintPuddle( paintType, pos, radius )
	
	local ent = ents.Create( "ent_paint_puddle" )
	
	if ( !IsValid( ent ) ) then return end
	
	ent:SetPos( pos )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()

	ent:GetPhysicsObject():EnableCollisions( false )
	ent:GetPhysicsObject():Wake()

	ent.GASL_GelType = paintType
	ent:SetGelRadius( radius )
	
	local color = APERTURESCIENCE:GetColorByGelType( paintType )
	ent:SetColor( color )
	if ( paintType == PORTAL_GEL_WATER ) then ent:SetMaterial( "models/gasl/portal_gel_bubble/gel_water" ) end

	return ent
	
end