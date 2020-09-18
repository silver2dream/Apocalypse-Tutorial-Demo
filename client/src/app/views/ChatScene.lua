local ChatScene = class("ChatScene", cc.load("mvc").ViewBase)
local ChatItem = import(".ChatItem")

local SELF_MESSAGE = 1
local OTHER_MESSAGE = 2

function ChatScene:onCreate()
	self.messageType = GameInstance.MESSAGE_TYPE.Normal
	self.normalMessageBuf ={}
	self.battleMessageBuf ={}

	local node = cc.CSLoader:createNode("Chat.csb")
	:addTo(self)
	
	self.openChat = node:getChildByName("OpenChat")
	self.openChat:addClickEventListener(function(sender, eventType)
		self.chatPanel:setVisible(true)
		self.openChat:setVisible(false)
	end)

	self.chatPanel = node:getChildByName("ChatPanel")
	self.chatPanel:setVisible(false)

	self.closeBtn = self.chatPanel:getChildByName("Close")
	self.closeBtn:addClickEventListener(function(sender, eventType)
		self.chatPanel:setVisible(false)
		self.openChat:setVisible(true)
	end)

	self.battleChan = self.chatPanel:getChildByName("BattleChat")
	self.battleChanBtn = self.chatPanel:getChildByName("BattleChatBtn")
	self.battleChanBtn:setEnabled(true)
	self.battleChanBtn:addClickEventListener(function(sender, eventType)
		self.battleChanBtn:setEnabled(false)
		self.normalChanBtn:setEnabled(true)
		self.battleChanList:setVisible(true)
		self.normalChanList:setVisible(false)
		self.messageType = GameInstance.MESSAGE_TYPE.Battle
	end)
	self.battleChanList = self.battleChan:getChildByName("BattleChatList")
	self.battleChanList:setVisible(false)

	self.normalChan = self.chatPanel:getChildByName("NormalChat")
	self.normalChanBtn = self.chatPanel:getChildByName("NormalChatBtn")
	self.normalChanBtn:setEnabled(false)
	self.normalChanBtn:addClickEventListener(function(sender, eventType)
		self.battleChanBtn:setEnabled(true)
		self.normalChanBtn:setEnabled(false)
		self.battleChanList:setVisible(false)
		self.normalChanList:setVisible(true)
		self.messageType = GameInstance.MESSAGE_TYPE.Normal
	end)
	self.normalChanList = self.normalChan:getChildByName("NormalChatList")
	
	self.Message = node:getChildByName("SelfMessagePanel")

	self.sendBtn = self.chatPanel:getChildByName("Send")
	self.sendBtn:addClickEventListener(function(sender, eventType)
		--self.nickname = GameInstance.PlayerModel.getName()
		GameInstance.Network:send({protoName="ChatReq",param = { Id = GameInstance.PlayerModel:getId(), Type = self.messageType, Name=GameInstance.PlayerModel:getName(), Message = self.textField:getString()}})
		self.textField:setString("")
	end)

	-- local testBtn = cc.MenuItemImage:create("/ui/start.png","/ui/start.png")
    --     :onClicked(function()
	-- 		GameInstance.Network:send({protoName="ChatReq",param = { Id = "8888", Type = self.messageType, Name="Ash", Message = self.textField:getString()}})
    --     end)
    -- cc.Menu:create(testBtn)
    --     :move(display.cx+200, display.cy - 170)
	-- 	:addTo(self)
		
	self.textField = self.chatPanel:getChildByName("ChatTextField")
	self.textField:addClickEventListener(function(sender, eventType) 
	self.messageEdit:touchDownAction(self.messageEdit, ccui.TouchEventType.ended)
	end)

	self.messageEdit = ccui.EditBox:create(cc.size(300,200),"res/chat_private_bg.png")
	self.messageEdit:setPosition(cc.p(-500,-500))
	self.messageEdit:setFontSize(30)
	self.messageEdit:setFontColor(cc.c3b(255,255,255))
	self.messageEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND ) 
	self.messageEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 
	self.messageEdit:registerScriptEditBoxHandler(handler(self,self.messageEditboxHandle))
	self.messageEdit:addTo(self)

	cc.bind(self, "event")
    GameInstance.AddEvent(GameInstance.EVENTS.RECV_MESSAGE, handler(self,self.recvMessage))
end

function ChatScene:showMessage()
	local size = cc.size(400,200)
	
	local messageBuf = {}
	local chatList = {}
	if self.messageType == GameInstance.MESSAGE_TYPE.Normal then
		messageBuf = self.normalMessageBuf
		chatList = self.normalChanList
	else
		messageBuf = self.battleMessageBuf
		chatList = self.battleChanList
	end

	for i=1, #messageBuf, 1 do
		if messageBuf[i].IsInContainer == false then
			messageBuf[i]:addTo(chatList)
			messageBuf[i].IsInContainer = true
		end
		messageBuf[i]:setPosition( cc.p(0, size.height * (#messageBuf-i) + size.height/2 ))
	end
end

function ChatScene:messageEditboxHandle(eventName, sender)
	if eventName == "changed" then
        self.textField:setString(self.messageEdit:getText())
    end
end

function ChatScene:recvMessage(event)
	local data = event.data
	local item = self:createItem(data)
	if data.Type == GameInstance.MESSAGE_TYPE.Normal then
		table.insert(self.normalMessageBuf,item)
	else
		table.insert(self.battleMessageBuf,item)
	end
	self:showMessage()
end

function ChatScene:createItem(data)
	if data.Id ~= GameInstance.PlayerModel:getId() then
		return ChatItem:create(OTHER_MESSAGE, self.Message:getContentSize(), data.Name, data.Message, "itemicon/36005.png")
	end
	return ChatItem:create(SELF_MESSAGE, self.Message:getContentSize(), data.Name, data.Message, "itemicon/36007.png")
end

return ChatScene