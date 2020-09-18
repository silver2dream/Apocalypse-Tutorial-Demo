local AnimateState = import(".AnimateState")
local Transition = import(".Transition")

local AnimationBlueprint = class("AnimationBlueprint")

local DEFAULT_DIRECTION = 0

function AnimationBlueprint:ctor(model)
    self.model = model
    self.role = model:getRole()
    self.spriteCache =  self.role:getSpriteCache()
    self.animateEvent = {
        handler(self, self.canMoveTransition),
        handler(self, self.canIdleTransition)
    }
    self.animteState={}
    local animateGraph = self.role:getAnimateGraph()
    for idx, state in ipairs(animateGraph.machineState) do
        self.animteState[state.name] = AnimateState:create(state, self)
        self.animteState[state.name]:setTransition(Transition:create(self.animateEvent[idx]))
    end
    self.direction = DEFAULT_DIRECTION
    self.currentState = self.animteState["idle"]
    self.moveRemain = self.model:getDist()
end

function AnimationBlueprint:step(dt)
    self:updateParam()
    self.currentState:step(dt)
end

function AnimationBlueprint:setDirection(direction)
    if self.direction == direction then return end

    self.direction = direction
    self.currentState:updateDirection()
end

function AnimationBlueprint:setState(newState)
    self.currentState = self.animteState[newState]
end

function AnimationBlueprint:updateParam()
    self.moveRemain = self.model:getDist()
end

function AnimationBlueprint:canMoveTransition()
    return self.moveRemain > 0
end

function AnimationBlueprint:canIdleTransition()
    return self.moveRemain <=0
end

function AnimationBlueprint:getSpriteCache()
    return self.spriteCache
end

return AnimationBlueprint