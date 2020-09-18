local Actor = import(".Actor")
local Role = import(".Role")

local Player = class("Player", Actor)

function Player:ctor(userData)
    Player.super.ctor(self)

    local roleBuilder = Role:create()
    self.role =  roleBuilder:build(userData.role)
    self.key = userData.key
    self.position = userData.position
    self.name = userData.name

    self.missionMap = {}
    -- if  userData.missions~=nil or #userData.missions >0 then 
    --     for _, mission in ipairs(userData.missions) do
    --         self.missionMap[mission.Id] = mission.Status
    --     end
    -- end

    self.type = Actor.Type.LOCAL_PLAYER
    self.speed = 2
    
end

function Player:getType()
    return self.type
end

function Player:getRole()
    return self.role
end

function Player:getId()
    return self.key
end

function Player:getName()
    return self.name
end

function Player:getMissionStatus(id)
    local status = self.missionMap[id]
    if status == nil then return 0 end
    return status
end

function Player:setMissionStatus(data)
    self.missionMap[data.Id] = data.Status
end

return Player