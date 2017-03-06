function EFFECT:Init( data )

	self.Start = data:GetOrigin()
	self.Direction = data:GetNormal()
	self.Color = data:GetColor()
	self.Radius = math.max( 0.6, data:GetRadius() / 100 )
	
	local color = APERTURESCIENCE:GetColorByGelType( self.Color )
	
	self.Emitter = ParticleEmitter( self.Start )
	
	for i = 1, math.max( 2, data:GetRadius() / 10 ) do
	
		local vec = VectorRand()
		vec = Vector( vec.x, vec.y, vec.z + 3 )
		vec:Rotate( self.Direction:Angle() + Angle( 90, 0, 0 ) )
		
		local p = self.Emitter:Add( "effects/splash2", self.Start + vec )

		p:SetDieTime( math.Rand( 0.3, 0.4 ) )
		p:SetStartAlpha( math.random( 100, 200 ) )
		p:SetEndAlpha( 0 )
		p:SetStartSize( math.Rand( 20, 40 ) * self.Radius )
		p:SetEndSize( math.Rand( 40, 80 ) * self.Radius )
		p:SetRoll( 0 )
		p:SetRollDelta( 0 )
		p:SetVelocity( vec * 50 * self.Radius + self.Direction * math.Rand( 25, 50 ) )
		p:SetGravity( Vector( 0, 0, -500 ) )
		p:SetColor( color.r, color.g, color.b )
		p:SetCollide( true )
		
	end
	
	for i = 1, math.max( 5, data:GetRadius() / 5 ) do
	
		local vec = VectorRand()
		vec = Vector( vec.x, vec.y, vec.z + 1 )
		vec:Rotate( self.Direction:Angle() + Angle( 90, 0, 0 ) )
		
		local p = self.Emitter:Add( "particle/paintblobs/paint_blob"..math.random( 1, 2 ), self.Start + vec )
		local size = math.random( 10, 20 ) * self.Radius
		
		p:SetDieTime( math.Rand( 0.8, 1 ) )
		p:SetStartAlpha( 255 )
		p:SetEndAlpha( 255 )
		p:SetStartSize( size )
		p:SetEndSize( 0 )
		p:SetRoll( math.Rand( 0, 360 ) )
		p:SetRollDelta( math.Rand( -3, 3 ) )
		p:SetVelocity( vec * 120 * self.Radius + self.Direction * math.Rand( 200, 250 ) )
		p:SetGravity( Vector( 0, 0, -800 ) )
		p:SetColor( color.r, color.g, color.b )
		p:SetCollide( true )
		
	end
	
	self.Emitter:Finish()
	
end

function EFFECT:Think()

	return
	
end

function EFFECT:Render()

end
