
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local ChatScene = import(".ChatScene")
local Typewriter = import(".Typewriter")

function MainScene:onCreate()

    -- local chat = ChatScene:create()
    -- :addTo(self)

    -- local typewriter = Typewriter:create()
    -- :addTo(self)

    -- local startButton = cc.MenuItemImage:create("/ui/start.png","/ui/start.png")
    --     :onClicked(function()
    --         typewriter.isStart = true
    --         typewriter:setVisible(true)
    --         print("~~~")
    --     end)
    -- cc.Menu:create(startButton)
    --     :move(display.cx, display.cy)
    --     :addTo(self)

    -- local node = cc.CSLoader:createNode("Chat.csb")
	-- :addTo(self)
	
	-- self.openChat = node:getChildByName("OpenChat")
    -- self.openChat:addClickEventListener(function(sender, eventType)
    --     self.chatPanel:setVisible(true)
    --     print("~~~~~~~~~~~")
    -- end)

	-- self.chatPanel = node:getChildByName("ChatPanel")
	-- self.chatPanel:setVisible(false)



    --add background image
    -- display.newSprite("/ui/background.png")
    --     :move(display.center)
    --     :addTo(self)

    -- maybe can add game logo
    -- local startButton = cc.MenuItemImage:create("/ui/start.png","/ui/start.png")
    --     :onClicked(function()
    --         --start connect
    --         local serverinfo = {
    --             socket_domain = "127.0.0.1",
    --             socket_port = "8000"
    --         }
    --         GameInstance.Network:startSocket(serverinfo)
    --     end)
    -- cc.Menu:create(startButton)
    --     :move(display.cx+10, display.cy - 170)
    --     :addTo(self)


    local node = cc.CSLoader:createNode("Login.csb")
    :addTo(self)

    self.evEdit = ccui.EditBox:create(cc.size(300,200),"res/chat_private_bg.png")
    self.evEdit:setPosition(cc.p(-500,-500))
    self.evEdit:setFontSize(30)
    self.evEdit:setFontColor(cc.c3b(255,255,255))
    self.evEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND ) 
    self.evEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 
    self.evEdit:registerScriptEditBoxHandler(handler(self,self.accountEditboxHandle))
    self.evEdit:addTo(self)

    self.pdEdit = ccui.EditBox:create(cc.size(300,200),"res/chat_private_bg.png")
    self.pdEdit:setPosition(cc.p(-500,-500))
    self.pdEdit:setFontSize(30)
    self.pdEdit:setFontColor(cc.c3b(255,255,255))
    self.pdEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND ) 
    self.pdEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) 
    self.pdEdit:registerScriptEditBoxHandler(handler(self,self.pwdEditboxHandle))
    self.pdEdit:addTo(self)

    self.accountTextField = node:getChildByName("Account")
    self.accountTextField:addClickEventListener(function(sender, eventType) 
        self.evEdit:touchDownAction(self.evEdit, ccui.TouchEventType.ended)
    end)

    self.pwdField = node:getChildByName("Password")
    self.pwdField:addClickEventListener(function(sender, eventType) 
        self.pdEdit:touchDownAction(self.pdEdit, ccui.TouchEventType.ended)
    end)

    local loginButton = node:getChildByName("Login")
    loginButton:addClickEventListener(function(sender, eventType) 
        local data ={
            serverinfo = {
                socket_domain = "127.0.0.1",
                socket_port = "8000"
            },
                logininfo ={
                account = self.accountTextField:getString(),
                pwd = self.pwdField:getString(),
                name = "Guest"..math.random(1000)
            }
        }
        GameInstance.Network:startSocket(data)
    end)    

    GameInstance.AddEvent("EnterScene",  handler(self,self.enterScene))

end

function MainScene:accountEditboxHandle(eventName, sender)
    if eventName == "changed" then
        self.accountTextField:setString(self.evEdit:getText())
    end
end

function MainScene:pwdEditboxHandle(eventName, sender)
    if eventName == "changed" then
        self.pwdField:setString(self.pdEdit:getText())
    end
end

function MainScene:enterScene()
    self:getApp():enterScene("PlayScene")
end

return MainScene
