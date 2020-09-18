

local Npc = class("Npc",function()
    return display.newSprite()
end)

function Npc:ctor(data)
    self:setTexture(data.pic)
    self:setPosition(data.pos)

    self.drama = data.drama
    local npcListener = cc.EventListenerTouchOneByOne:create()
    npcListener:registerScriptHandler(handler(self, self.onNpcTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(npcListener, self)
end

function Npc:onNpcTouchBegan()
  print("~~~~~~~~~~~onNpcTouchBegan~~~~~~~~~~~")
  print(self.drama)
  GameInstance.DispatchEvent({name=GameInstance.EVENTS.DIALOG, data ={drama = self.drama }})
  print("~~~~~~~~~~~onNpcTouchBegan~~~~~~~~~~~")
end

return Npc