local TileMap = class("TileMap", function()
	local tilemap="map/isometric_grass_and_water.tmx"
    return ccexp.TMXTiledMap:create(tilemap)
end)

local Npc = import("..models.Npc")
local Astar = import("..algorithm.Astar")

local BLOCK = 0
local LUA_SPECIAL = 1

function TileMap:ctor()
	self.pathMap={}
    self:init()
	self.astar = Astar:create()
end

function TileMap:init()

		self.mapSize = self:getMapSize()
		self.halfMapWidth = self.mapSize.width * 0.5
		self.mapHeight = self.mapSize.height
		self.tileWidth = self:getTileSize().width
		self.tileHeight = self:getTileSize().height

		self.layer = self:getLayer("BaseLayer")
		self.obstacle = self:getLayer("Obstacle")
			:setVisible(false)

		local objectLayer = self:getObjectGroup("GameObjects")
		local startPoint = objectLayer:getObject("StartPoints")
		local npcModel = objectLayer:getObject("Npc")

		-- --local npc = cc.Sprite:create("map/NPC2.png")
		-- local nodespace = self:getWorldPosFromCoord(cc.p(17,4))
		local nodespace = self:getWorldPosFromCoord(cc.p(0,24))
		npcModel.pos = nodespace
		local npc = Npc:create(npcModel)
		npc:addTo(self)
		--npc:setPosition(nodespace)
		npc:setAnchorPoint(cc.p(0,0))
		
		
		local size = self.mapSize
		local index = 1
		for i = 0, size.width -1,1 do
			for j = 0, size.height -1 , 1 do
				self.pathMap[index] = {}
				self.pathMap[index].x = i
				self.pathMap[index].y = j
				if self.obstacle:getTileAt(cc.p(i,j)) ~= nil then
					self.pathMap[index].vaild = 0
				else
					self.pathMap[index].vaild = 1
				end
				index = index + 1
			end
		end
end

function TileMap:DetectMove(pos,playerPos)
	local coord = self:getCoordFromWolrdPos(pos,playerPos)
	local index = self:getIndexFromCoord(coord)
	--print("pos:%d,%d",pos.x,pos.y)
	if self.pathMap[index] == nil then
		return false
	end

	if self.pathMap[index].vaild ~= BLOCK then
		return true
	end

	return false
end

function TileMap:getCoordFromWolrdPos(pos,playerPos)
	if(pos~=playerPos) then
		local defalutCamPos = cc.p(display.width/2, display.height/2)
		local offset = cc.pSub(playerPos, defalutCamPos)
		pos = cc.pAdd(pos, offset)
	end
	
	local mapPos = cc.p(self:getPositionX(), self:getPositionY())
	local calPos = cc.pSub(pos, mapPos)
	local tilePosDiv = cc.p(calPos.x / self.tileWidth, calPos.y /self.tileHeight)
	local inverseTileY = self.mapHeight - tilePosDiv.y
	local coordX = math.floor(inverseTileY + tilePosDiv.x - self.halfMapWidth) + 1
	local coordY = math.floor(inverseTileY - tilePosDiv.x + self.halfMapWidth) + 1
	coordX = self:clamp(coordX, 0, self.mapSize.width-1)
	coordY = self:clamp(coordY, 0, self.mapSize.height-1)
	return cc.p(coordX,coordY)
end

function TileMap:getWorldPosFromCoord(coord)
	local tilePosDiv = cc.p(0,0)
    tilePosDiv.y = self.mapHeight - (coord.x + coord.y)/2;
    tilePosDiv.x = (coord.x - coord.y)/2 + self.halfMapWidth;

	local pos = cc.p(0,0)
    pos.x = tilePosDiv.x * self.tileWidth;
    pos.y = tilePosDiv.y * self.tileHeight + self.tileHeight/2;

	local mapPos = cc.p(self:getPositionX(), self:getPositionY())

    return cc.pAdd(mapPos,pos);
end

function TileMap:clamp(v, minValue,maxValue)
	if v < minValue then
        return minValue
    end
    if( v > maxValue) then
        return maxValue
    end
    return v 
end

function TileMap:pathFinding(pos , newPos)
	local start = self:getCoordFromWolrdPos(pos,pos)
	local goal = self:getCoordFromWolrdPos(newPos,pos)
	local startIdx = self:getIndexFromCoord(start)
	local goalIdx = self:getIndexFromCoord(goal)

	-- print(string.format("start:%d,%d",start.x,start.y))
	-- print(string.format("goal:%d,%d",goal.x,goal.y))
	local ignore = true -- ignore cached paths
	local path = self.astar:path( self.pathMap[startIdx], self.pathMap[goalIdx], self.pathMap, ignore, handler(self, self.valid_node_func) )
	--local path = self.astar45:getPath(Grid:create(start),Grid:create(goal),false)

	if not path then
		print ( "No valid path found" )
	else
		-- for i, node in ipairs ( path ) do
		-- 	print ( "Step " .. i .. " >> " .. node.x..node.y )
		-- end
		print(" has path ")
	end

	return path
end

function TileMap:valid_node_func(node, neighbor )
	local MAX_DIST = math.sqrt( 2 )
	if neighbor.vaild == 0 then return false end

	if self.astar:distance( node.x, node.y, neighbor.x, neighbor.y ) <= MAX_DIST then
		return true
	end

	return false
end

function TileMap:getIndexFromCoord(coord)
	local index = (coord.x * self.mapHeight + coord.y) + LUA_SPECIAL 
	return index
end

function TileMap:getCoordFromIndex(index)
	index = index - LUA_SPECIAL
	local x = math.floor(index/self.mapHeight)
	local y = index % self.mapHeight
	return cc.p(x,y)
end

return TileMap