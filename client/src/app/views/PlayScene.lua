
local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)
local World = import(".World")
local ChatScene = import(".ChatScene")
local Typewriter = import("..views.Typewriter")

function PlayScene:onCreate()
    GameInstance.World = World:create()
        :start()
        :addTo(self)
        --:addEventListener(GameView.events.PLAYER_DEAD_EVENT, handler(self, self.onPlayerDead))
    
    GameInstance.Chat = ChatScene:create()
    --:setPositionZ(-cc.Director:getInstance():getZEye()/4)
    --:ignoreAnchorPointForPosition(false)
    :setGlobalZOrder(3000)
    :addTo(self)

    GameInstance.Dialog = Typewriter:create()
    :setGlobalZOrder(3000)
    :addTo(self)
    :setVisible(false)
    
end

return PlayScene