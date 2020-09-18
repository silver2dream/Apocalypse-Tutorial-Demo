local World = class("World", cc.load("mvc").ViewBase)
local Map = import("..models.TileMap")
local PlayerController = import(".PlayerController")
local AIController = import(".AIController")
local Player = import("..models.Player")
local Pawn = import(".Pawn")


function World:start()
    self:scheduleUpdate(handler(self, self.step))
    return self
end

function World:stop()
    self:unscheduleUpdate()
    return self
end

function World:step(dt)
    self.playerController:step(dt)
    self:updateAI(dt)
end

function World:onCreate()
    --add HelloWorld label
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    --     :move(display.cx, display.cy + 200)
    --     :addTo(self)

    --add map
    self.map = Map:create()
    :addTo(self)
    :setCameraMask(2)
    :setGlobalZOrder(-10)
    GameInstance.Map = self.map

    --add actor node
    self.actorsNode = display.newNode():addTo(self)
    
    local Player = Pawn:create(GameInstance.PlayerModel)
        :addTo(self.actorsNode)
        :setCameraMask(2)
    self.playerController = PlayerController:create(self)
    self.playerController:setPawn(Player)

    --add other player
    for idx, aiModel in pairs(GameInstance.AIModelGroup) do
        local aiPlayer = Pawn:create(aiModel)
        :addTo(self.actorsNode)
        :setCameraMask(2)

        local AIController = AIController:create(self)
        AIController:setPawn(aiPlayer)
        GameInstance.AIControllerMap[aiModel.key] = AIController
    end

    -- bind the "event" component
    cc.bind(self, "event")
end

function World:updateAI(dt)
    for idx,ai in pairs( GameInstance.AIControllerMap) do
        ai:step(dt)
    end
end

function World:onCleanup()
    self:removeAllEventListeners()
end

return World