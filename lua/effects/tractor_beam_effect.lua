
function EFFECT:Init( data )

	self.Start = data:GetOrigin()
	self.Direction = data:GetNormal()
	if (!self.Emitter) then
	self.Emitter = ParticleEmitter(self.Start)
	end
	
	local p = self.Emitter:Add( "sprites/light_glow02_add", self.Start )

	p:SetDieTime(math.random(1, 2))
	p:SetStartAlpha(math.random(0, 50))
	p:SetEndAlpha(255)
	p:SetStartSize(math.random(10, 20))
	p:SetEndSize(0)
	p:SetVelocity(self.Direction * 50)
	p:SetGravity(Vector(0, 0, 0))
	p:SetColor(math.random(0, 50), 100 + math.random(0, 55), 200 + math.random(0, 50))
	p:SetCollide(true)
	
	self.Emitter:Finish()
end

function EFFECT:Think()
	return
end

function EFFECT:Render()
	
end