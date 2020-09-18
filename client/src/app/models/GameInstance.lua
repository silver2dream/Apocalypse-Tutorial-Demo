local Network = import("..Network.Network")
local World = import("..views.World")


cc.exports.GameInstance = {}

GameInstance.FIXED_Z = 538
GameInstance.MESSAGE_TYPE = {
    Normal = 1,
    Battle = 2,
}

GameInstance.EVENTS = {
    LOCAL_PLAYER_MOVE = "LOCAL_PLAYER_MOVE",
    SIMULATOR_PLAYER_MOVE = "SIMULATOR_PLAYER_MOVE",
    SOCKET_DATA = "SOCKET_DATA",
    RECV_MESSAGE = "RECV_MESSAGE",
    DIALOG = "DIALOG"
}

GameInstance.PlayerModel = {}
GameInstance.AIControllerMap = {}
GameInstance.AIModelGroup = {}

GameInstance.Network = Network:create()
--GameInstance.World = World:create()
--GameInstance.PlayerController = PlayerController:create(GameInstance.World)

cc.bind(GameInstance, "event")
GameInstance.AddEvent = function(event, handler)
    GameInstance:addEventListener(event, handler) 
end

GameInstance.DispatchEvent = function(event)
    GameInstance:dispatchEvent({name= event.name, data=event.data})
end

--GameInstance:addEventListener("PlayerMove", handler(self, self.processBuffer))

