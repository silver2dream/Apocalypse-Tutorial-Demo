local AnimationBlueprint = import("..animation.AnimationBlueprint")
local Pawn = class("Pawn", function(pawnModel)
    local animBP = AnimationBlueprint:create(pawnModel)
    local sprite = animBP:getSpriteCache()
    sprite.animBP = animBP
    return sprite
end)

function Pawn:ctor(pawnModel)
    self.model = pawnModel
end

function Pawn:getModel()
    return self.model
end

function Pawn:start(destination, direction)
    self.model:setDestination(destination)
    self.animBP:setDirection(direction)
    return self
end

function Pawn:step(dt)
    self.model:step(dt)
    self.animBP:step(dt)
    self:updatePosition()
    return self
end

function Pawn:updatePosition()
    local pos = self.model:getPosition()
    self:move(pos)
    if self.camera ~= nil then
        self.camera:move(pos)
    end
end

function Pawn:attach(camera)
    self.camera = camera
    self.camera:move(self.model:getPosition())
end

function Pawn:isArrive()
    return self.animBP:canIdleTransition()
end

function Pawn:getID()
    return self.model.key
end

return Pawn