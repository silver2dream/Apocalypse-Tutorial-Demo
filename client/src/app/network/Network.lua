local Network = class("Network", cc.load("mvc").ModelBase)
local Player = import("..models.Player")
local ByteArray = import("..network.ByteArray")
local pb = import("pb")
pb.loadfile "proto.pb"

local HEADER_SIZE = 24

local PROTO_TAG = {
    ["MoveReq"] = "k_0001",
    ["MoveRes"] = "k_0002",
    ["LoginReq"] = "k_1000",
    ["LoginRes"] = "k_1001",
    ["ChatReq"] = "k_1003",
    ["ChatRes"] = "k_1004",
    ["MissionReq"] = "k_1005",
    ["MissionRes"] = "k_1006",
}

function Network:ctor()
    self.serverInfo = nil
    self.socketTable = {}
    self.serverTime = 0
    self.isLogined = false
    self.sendTaskList = {}
    self:init()
end

function Network:init()
    self.recvBuffer = ''
    local scheduler = cc.Director:getInstance():getScheduler()
    self.processID = scheduler:scheduleScriptFunc(handler(self,self.step), 0.1, false)
end

function Network:step(dt)
    self:processSocketIO()
end

function Network:processSocketIO()
    if not self.isConnected then
        return
    end
    self:processInput()
    self:processOutput()
end

function Network:processInput()
    local reads = socket.select({self.tcp}, nil, 0);
    if #reads > 0 then
        local recvData, recvError, recvParticialData = self.tcp:receive(2048)
        if recvError ~= "closed" then
            if recvData then
                print("---recvData")
                self.recvBuffer = self.recvBuffer..recvData
            elseif recvParticialData then
                print("---recvParticialData")
                self.recvBuffer = self.recvBuffer..recvParticialData
            end
        else
            return
        end

        local len = string.len(self.recvBuffer)
        if len == 0 then
            return
        end

        if len < HEADER_SIZE then
            print("header not full")
            return
        end

        --解析 bodysize
        local ba = ByteArray.new()
        ba:writeBuf(self.recvBuffer)
        ba:setPos(1)
        local version = ba:readStringUInt()
        local tag = ba:readStringUInt()
        local timestamp = ba:readUInt()
        local bodysize = ba:readUInt()
        print("bodysize:"..bodysize)
        print("recvBuffer:".. string.len(self.recvBuffer))
        if string.len(self.recvBuffer) < HEADER_SIZE + bodysize then
            print("body not full")
            return 
        end

        local data = ba:readBuf(bodysize)
        local totalsize = ba:getLen()
        print("totalsize:"..totalsize)
        
        self.recvBuffer = string.sub(self.recvBuffer, totalsize + 1)
        self:processBuffer({tag = tag, data = data})
    end
end

function Network:processBuffer(message)
    local pdata = nil
    if message.tag == "k_1001" then
        pdata = pb.decode("proto.LoginRes", message.data)

        --add Player
        local tmpUserData = {
            role = 1,
            position = cc.p(pdata.Player.X, pdata.Player.Y),
            key = pdata.Player.TokenID,
            name = pdata.Player.Name,
            missions = pdata.Player.Missions,
        }
        GameInstance.PlayerModel = Player:create(tmpUserData)

        if pdata.OtherPlayers~=nil then
            for i=1,#pdata.OtherPlayers,1 do
                local other = pdata.OtherPlayers[i]
                local tmpAI = {
                    role = 1,
                    position = cc.p(other.X, other.Y),
                    key = other.TokenID
                }
                local tmpModel = Player:create(tmpAI)
                table.insert(GameInstance.AIModelGroup, tmpModel)
            end
        end
        GameInstance.DispatchEvent({name="EnterScene"})
    elseif message.tag == "k_0002" then
        pdata = pb.decode("proto.MoveRes", message.data)

        local posX = pdata.X
        local posY = pdata.Y
        print(pdata.Type)
        if pdata.Type == 0 then
            GameInstance.DispatchEvent({name=GameInstance.EVENTS.LOCAL_PLAYER_MOVE, data={x=posX, y= posY}})
        else
            GameInstance.AIControllerMap[pdata.ID]:move({x=posX, y= posY})
        end
    elseif message.tag == "k_1004" then
        pdata = pb.decode("proto.ChatRes", message.data)
        dump(pdata)
        GameInstance.DispatchEvent({name=GameInstance.EVENTS.RECV_MESSAGE, data=pdata})
    elseif message.tag == "k_1006" then
        pdata = pb.decode("proto.MissionRes", message.data)
        dump(pdata)
        GameInstance.PlayerModel:setMissionStatus(pdata)
        GameInstance.DispatchEvent({name=GameInstance.EVENTS.DIALOG, data =pdata})
    end
    print("--message.tag --:"..message.tag )
    print(require "serpent".block(pdata))
end

function Network:processOutput()
    if self.sendTaskList and #self.sendTaskList > 0 then
        local data = self.sendTaskList[#self.sendTaskList]
        if data then
            local len, err = self.tcp:send(data)
            print(err)
            if len~=nil and len == #data then
                table.remove(self.sendTaskList, #self.sendTaskList)
            end
        end
    end
end

function Network:startSocket(data)
    self.serverInfo = data.serverinfo
    self.loginInfo = data.logininfo
    self.tcp = socket.tcp()
    self.tcp:settimeout(0)
    
    if self.tcp:connect(data.serverinfo.socket_domain, data.serverinfo.socket_port) ==1 then
        print("socket connected")
    else
        self.isConnected = true
        local LoginReq = {
            Account = self.loginInfo.account,
            Password =self.loginInfo.pwd,
            Name = self.loginInfo.name,
        }
        self:send({protoName="LoginReq", param = LoginReq})
    end
end

function Network:send(data)
    local name = data.protoName
    local data = pb.encode("proto."..name, data.param)
    print("encode:"..data)
    print("datalen:"..#data)

    local v = "V1"
    local key = PROTO_TAG[name]
    local ba = ByteArray.new()
    ba:writeStringUInt(v)
    ba:writeStringUInt(key)
    ba:writeUInt(os.time())
    ba:writeStringUInt(data)
    ba:setPos(1)
    print("ba.getLength:", ba:getLen())
    print("key:len:", #key)

    local pack = ba:getPack()
    table.insert(self.sendTaskList, 1 ,pack)
    
end

function Network:onDisconnect()
    print("---- seeee ----")
end

return Network