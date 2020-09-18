local Wizard = class("Wizard")

local IMAGE_FILENAMES = "player/wizard"
local SAMPLES_FORMATE = "d%02d_f0%02d_%s.png"

local SAMPLES = {
    15,
    7
}

local ANIMATE_GRAPH = {
	"idle",
	"move" 
}

local FRAME_IN_TIME = {
	0.15,
	0.08
}

local DEFAULT_ANIMATE_TITLE = "wizard"
local DEFAULT_FRAME = "d00_f000_idle.png"


function Wizard:ctor()
	self.animateGraph = {}
	self.animateGraph.animation = {}

	local dataFileName = IMAGE_FILENAMES..".plist"
	local imageFileName = IMAGE_FILENAMES..".png"
	display.loadSpriteFrames(dataFileName, imageFileName)
	local spriteFrame = display.newSpriteFrame(DEFAULT_FRAME)
	self.sprite = display.newSprite(spriteFrame)
	for idx, animate in ipairs(ANIMATE_GRAPH) do
		for i = 0, 15 do
			local frames = {}
			for j = 0, SAMPLES[idx] do
				local pngName = string.format(SAMPLES_FORMATE, i, j, animate)
				local frame = display.newSpriteFrame(pngName)
				frames[#frames + 1] = frame
			end
			
			local animation = display.newAnimation(frames, FRAME_IN_TIME[idx])
			local name = string.format( "%s_%s_%d", DEFAULT_ANIMATE_TITLE, animate, i)
			display.setAnimationCache(name, animation)
			--print(name)
		end
		self.animateGraph.animation[animate] = string.format( "%s_%s", DEFAULT_ANIMATE_TITLE, animate)
	end
end

function Wizard:getAnimateGraph()
	self.animateGraph.machineState = {
		{
			name = "idle",
            nextState = "move",
            animName = self.animateGraph.animation["idle"],
		},
		{
			name = "move",
            nextState = "idle",
            animName = self.animateGraph.animation["move"],
        }
	}

	return self.animateGraph
end

function Wizard:getSpriteCache()
	return self.sprite
end

return Wizard