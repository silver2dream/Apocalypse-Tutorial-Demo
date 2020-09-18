
local Actor = class("Actor")

Actor.Type = {
    LOCAL_PLAYER = 0,
    SIMULATOR_PLAYER = 1,
    NPC = 2,
    ENEMY = 3,
    ITEM = 4
}

Actor.Role = {
    WIZARD = 1
}

function Actor:ctor()
    self.position = cc.p(0,0)
    self.rotation = 0
    self.type = nil
    self.dist = 0
    self.destination = cc.p(0,0)
    self.speed = 1
end

function Actor:getType()
    return self.type
end

function Actor:getPosition()
    return self.position
end

function Actor:getRotation()
    return self.rotation
end

function Actor:getDist()
    return self.dist
end

function Actor:setDestination(destination)
    self.destination = cc.pNormalize(cc.pSub(destination, self.position))
    self.dist = cc.pGetDistance(self.position, destination)
end

local fixedDeltaTime = 1.0 / 60.0
function Actor:step(dt)
    if self.dist <= 0 then return self end
    local deltaVector = cc.pMul(self.destination, self.speed * (dt / fixedDeltaTime))
    self.position = cc.pAdd(self.position, deltaVector)
    self.dist = self.dist - cc.pGetLength(deltaVector)
    return self
end

return Actor