local PlayerController = class("PlayerController")

function PlayerController:ctor(world)
    self.world = world

    self.listener = cc.EventListenerKeyboard:create()
    self.listener:registerScriptHandler(handler(self, self.onKeyPressed), cc.Handler.EVENT_KEYBOARD_PRESSED)
    self.listener:registerScriptHandler(handler(self, self.onKeyReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self.world)

    self.tochLayer =  display.newLayer()
    :onTouch(handler(self, self.onTouch))
    :addTo(self.world)

    self.camera = cc.Camera:createPerspective(60,display.width/display.height,0,1000)
    self.camera:setCameraFlag(2)
    self.camera:setGlobalZOrder(10)
    local cameraOldPos = cc.Camera:getDefaultCamera():getPosition3D()
    local cameraPos = cc.Vertex3F(display.width/2,display.height/2,cameraOldPos.z)
    self.camera:setPosition3D(cameraPos)
    self.camera:addTo(self.world.actorsNode)
    GameInstance.camera = self.camera

    self.moveQueue = {}
    self.queueIdx = 1

    cc.bind(self, "event")

    GameInstance.AddEvent(GameInstance.EVENTS.LOCAL_PLAYER_MOVE, handler(self,self.move))
end

function PlayerController:onKeyPressed(keyCode, event)
    -- w
    if keyCode == 146 then
        local p = GameInstance.Map:getWorldPosFromCoord(cc.p(0,23))
        GameInstance.Network:send({protoName="MoveReq",param = { ID = "abc123456", X = p.x, Y = p.y}})
    -- s
    elseif keyCode == 142 then
        local p = GameInstance.Map:getWorldPosFromCoord(cc.p(24,24))
        self:onTouch({x=p.x,y=p.y})
    -- a
    elseif keyCode == 124 then
        local p = GameInstance.Map:getWorldPosFromCoord(cc.p(0,24))

        local path = GameInstance.Map:pathFinding( cc.p(500,600),p)
        --self:onTouch({x=p.x,y=p.y})
    -- d
    elseif keyCode == 127 then
        local p = GameInstance.Map:getWorldPosFromCoord(cc.p(24,0))
        self:onTouch({x=p.x,y=p.y})

        local x = math.max(p.x, display.width / 2)
        local y = math.max(p.y, display.height / 2)
        x =  math.max(x, (25 * 64) - display.width / 2)
        y =  math.max(y, (25 * 32) - display.height / 2)
        local actualPosition = cc.p(x, y)

        local centerOfView = cc.p(display.width / 2, display.height / 2);
        local viewPoint = cc.pSub(centerOfView - actualPosition)
        GameInstance.Map:setPosition(viewPoint)
    end
end

function PlayerController:onKeyReleased(keyCode, event)
    
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

function PlayerController:onTouch(event)
    if self.pawn == nil then return end
    
    local nodespace = GameInstance.Map:convertToNodeSpace(event)
    local canMove = GameInstance.Map:DetectMove(nodespace,self.pawn:getModel():getPosition())
    if canMove == false then return end
    
    GameInstance.Network:send({protoName="MoveReq",param = { ID = "abc1234", X = event.x, Y = event.y}})
    --GameInstance.DispatchEvent({name=GameInstance.EVENTS.LOCAL_PLAYER_MOVE, data={x=event.x, y= event.y}})
end

function PlayerController:calDirect(newPos)
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

function PlayerController:setPawn(pawn)
    self.pawn = pawn
    self.pawn:attach(self.camera)
end

function PlayerController:step(dt)
    if self.pawn:isArrive() and self.moveQueue ~= nil and #self.moveQueue > 0 then 
        local newPos = GameInstance.Map:getWorldPosFromCoord(self.moveQueue[self.queueIdx])
        newPos = cc.pAdd(newPos, cc.p(0,16))
        self.faceIdx = self:calDirect(newPos)
        self.pawn:start(cc.p(newPos.x,newPos.y), self.faceIdx)
        table.remove(self.moveQueue,self.queueIdx)
    end 
    self.pawn:step(dt)
end

function PlayerController:move(event)
    --self.pawn:start(cc.p(event.data.x, event.data.y), self.faceIdx)
    self.moveQueue = GameInstance.Map:pathFinding( self.pawn:getModel():getPosition(),cc.p(event.data.x, event.data.y))
end

return PlayerController