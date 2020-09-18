local Typewriter = class("Typewriter",cc.load("mvc").ViewBase)

local PlaySpeed = 3

function Typewriter:onCreate()
	self.template =  cc.CSLoader:createNode("Dialog.csb")
	:addTo(self)

	self.action = cc.CSLoader:createTimeline("Dialog.csb")
	self.template:runAction(self.action)
	self.action:gotoFrameAndPlay(0, true)

	self.npcPanel = self.template:getChildByName("NpcPanel")
	self.heroPanel = self.template:getChildByName("HeroPanel")
	self.backgroundPanel = self.template:getChildByName("BackgroundPanel")
	self.context = self.backgroundPanel:getChildByName("Context")
	self.cotinue = self.backgroundPanel:getChildByName("Cotinue")

	self.accept = self.backgroundPanel:getChildByName("Accept")
	self.accept:addClickEventListener(function(sender, eventType) 
		local MissionReq = {
		Id = self.missionId,
		Account = GameInstance.PlayerModel:getId(),
	}
		self.isStart = false
		self.cancle:setVisible(false)
		GameInstance.Network:send({protoName="MissionReq", param = MissionReq})
	end)

	self.cancle = self.backgroundPanel:getChildByName("Cancle")
	self.cancle:addClickEventListener(function(sender, eventType) 
		self:reset()
    end)    

	-- local scheduler = cc.Director:getInstance():getScheduler()
	-- self.processID = scheduler:scheduleScriptFunc(handler(self,self.print), 0.1, false)

	-- local npcListener = cc.EventListenerTouchOneByOne:create()
    -- npcListener:registerScriptHandler(handler(self, self.onNpcTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN )
    -- local eventDispatcher = self:getEventDispatcher()
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(npcListener, self)

	GameInstance.AddEvent(GameInstance.EVENTS.DIALOG, handler(self,self.show))
end

function Typewriter:reset()
	self.context:setString("")
	self.cotinue:setVisible(false)

	self.accept:setVisible(false)
	self.cancle:setVisible(false)

	self.txtLen = PlaySpeed

	self.isStart = false
	self.isAccept = false
	self:setVisible(false)
end

function Typewriter:onNpcTouchBegan()
	if self.isStart then return end
	print("~~~~~~~~~")
	self.isStart = true
	self.curPart = self.curPart + 1
	self.txtLen = PlaySpeed
	self.cotinue:setVisible(false)

	if self.status == 1 then 
		self:setVisible(false)
	end
end

function Typewriter:print()
	if self.isStart == false or self.isWaitAnswer then return end
	
	local str  = self:sub(self.message[self.curPart],1,self.txtLen)
	self.context:setString(str)
	self.txtLen = self.txtLen + PlaySpeed
	
	if self.txtLen > #self.message[self.curPart] + 3 then
		self.cotinue:setVisible(true)
		self.isStart = false

		if self.curPart >= self.totalPart then
			self.isWaitAnswer = true
			self.accept:setVisible(true)
			self.cancle:setVisible(true)
			self.cotinue:setVisible(false)
		end
	end
end

function Typewriter:chSize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

function Typewriter:sub(str, startChar, numChars)
    if str == nil then
        return ""
    end
	local startIndex = 1
    if (startChar==nil) then
		startChar = 1;
    end
    if (numChars==nil) then
		numChars =15;
    end;

    local allChars = numChars

	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + self:chSize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex
    while currentIndex <= numChars and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + self:chSize(char)
	end

    if numChars < #str then
        return str:sub(startIndex, currentIndex - 1).."..."
    else
        return str:sub(startIndex, currentIndex - 1)
    end

end

function Typewriter:show(event)
	self.missionId = event.data.drama 
	local drama = require("app.drama."..event.data.drama )
	
	self.status = GameInstance.PlayerModel:getMissionStatus(self.missionId)
	self.message = drama[self.status]
	self:setVisible(true)
	self.isStart = true
	self.isWaitAnswer = false
	self.totalPart = #self.message
	self.curPart = 1

	if self.status == 1 then
		self.accept:setVisible(false)
		self.cancle:setVisible(false)
		self.cotinue:setVisible(true)
	end
end

return Typewriter