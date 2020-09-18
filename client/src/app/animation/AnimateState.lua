local AnimateState = class("AniamteState")

function AnimateState:ctor(data, animBP)
    self.animName= data.animName
    self.animBP = animBP
    self.nextState = data.nextState
    self.transition = data.transition
    self.isPlay = false
end

function AnimateState:setTransition(transition)
    self.transition = transition
end

function AnimateState:updateDirection()
    self.isPlay = false
    self:startLoop()
end

function AnimateState:step(dt)
    if self.transition == nil then return end

    if self.transition:canTransition() then
        self.isPlay = false
        self.animBP:setState(self.nextState)
    else
        self:startLoop()
    end
end

function AnimateState:startLoop()
    if self.animBP.spriteCache == nil then return end
    if self.isPlay == true then return end

    self.animation = string.format( "%s_%d", self.animName, self.animBP.direction)
    self.animBP.spriteCache:stopAllActions()
    self.animBP.spriteCache:playAnimationForever(display.getAnimationCache(self.animation))
    self.isPlay = true
end

return AnimateState