function EFFECT:Init( data )

	self.Start = data:GetOrigin()
	self.Direction = data:GetNormal()
	self.Color = data:GetColor()
	
	local color = Color( 0, 0, 0 )
	
	if ( self.Color == 1 ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( self.Color == 2 ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	
	self.Emitter = ParticleEmitter( self.Start )
	
	for i = 1, 10 do
	
		local vec = VectorRand()
		vec = Vector( vec.x, vec.y, vec.z + 3 )
		vec:Rotate( self.Direction:Angle() + Angle( 90, 0, 0 ) )
		
		local p = self.Emitter:Add( "effects/splash3", self.Start + vec )

		p:SetDieTime( math.random( 0.8, 1 ) )
		p:SetStartAlpha( math.random( 100, 200 ) )
		p:SetEndAlpha( 0 )
		p:SetStartSize( math.random( 3, 5 ) * 20 )
		p:SetEndSize( 0 )
		p:SetRoll( 0 )
		p:SetRollDelta( 0 )
		p:SetVelocity( vec * 50 )
		p:SetGravity( Vector( 0, 0, -500 ) )
		p:SetColor( color.r, color.g, color.g )
		p:SetCollide( true )
		
	end
	
	for i = 1, 20 do
	
		local vec = VectorRand()
		vec = Vector( vec.x, vec.y, vec.z + 2 )
		vec:Rotate( self.Direction:Angle() + Angle( 90, 0, 0 ) )
		
		local p = self.Emitter:Add( "particle/paintblobs/paint_blob_sheet_1", self.Start + vec )

		p:SetDieTime( math.random( 0.4, 0.5 ) )
		p:SetStartAlpha( math.random( 200, 255 ) )
		p:SetEndAlpha( 0 )
		p:SetStartSize( math.random( 10, 20 ) )
		p:SetEndSize( 0 )
		p:SetRoll( math.Rand( 0, 360 ) )
		p:SetRollDelta( math.Rand( -3, 3 ) )
		p:SetVelocity( vec * 100 )
		p:SetGravity( Vector( 0, 0, -500 ) )
		p:SetColor( color.r, color.g, color.g )
		p:SetCollide( true )
		
	end
	
	self.Emitter:Finish()
	
end

function EFFECT:Think()

	return
	
end

function EFFECT:Render()

end
