local AIController = class("AIController")

function AIController:ctor(world)
    self.world = world

    self.moveQueue = {}
    self.queueIdx = 1

    cc.bind(self, "event")
    GameInstance.AddEvent(GameInstance.EVENTS.SIMULATOR_PLAYER_MOVE, handler(self,self.move))
end

local directMap = {
    -0.19509,
    0.19509,
    0.55557,
    0.83147,
    0.98079
}

local xAxis = cc.p(-1,0)
local yAxis = cc.p(0,-1)

function AIController:calDirect(newPos)
    local playerPos = self.pawn:getModel():getPosition()
    local u = cc.p(newPos.x-playerPos.x, newPos.y-playerPos.y)
    local uNormalize = cc.pNormalize(u)
    local xDot = cc.pDot(xAxis, uNormalize)
    local yDot = cc.pDot(yAxis, uNormalize)
    local uLen = math.abs(xDot)
    local finalIdx = 0
    local base = 8
    for idx, v in ipairs(directMap) do
        if( uLen > v) then finalIdx = idx - 1 end
    end

    if xDot > 0 and yDot < 0 then
        finalIdx = base - finalIdx
    elseif xDot < 0  and yDot < 0 then
        finalIdx = base + finalIdx
    elseif xDot < 0 and yDot > 0 then
        finalIdx = (2 * base - finalIdx) % 16
    end
    return finalIdx
end

function AIController:setPawn(pawn)
    self.pawn = pawn
end

function AIController:step(dt)
    if self.pawn:isArrive() and self.moveQueue ~= nil and #self.moveQueue > 0 then 
        local newPos = GameInstance.Map:getWorldPosFromCoord(self.moveQueue[self.queueIdx])
        newPos = cc.pAdd(newPos, cc.p(0,16))
        self.faceIdx = self:calDirect(newPos)
        self.pawn:start(cc.p(newPos.x,newPos.y), self.faceIdx)
        table.remove(self.moveQueue,self.queueIdx)
    end 
    self.pawn:step(dt)
end

function AIController:move(event)
    self.moveQueue = GameInstance.Map:pathFinding( self.pawn:getModel():getPosition(),cc.p(event.x, event.y))
end

return AIController