local ChatItem = class("ChatItem",ccui.Layout)

function ChatItem:ctor(type,size,nikcname,msg,pic)
	self:setContentSize(size)
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	-- self:setBackGroundColor(cc.c3b(0,0,255))
	-- self:setOpacity(180)

	self.IsInContainer = false

	local img = ccui.ImageView:create()
	img:loadTexture(pic)
	if type== 1 then
		img:setPosition(cc.p(349,146))
	else
		img:setPosition(cc.p(52,153))
	end
	img:addTo(self)

	local name = ccui.Text:create()
	name:setString(nikcname)
	name:setFontSize(20)
	name:setFontName("title_tw.ttf")
	name:setTextColor(cc.c3b(0,0,255))
	name:setPosition(cc.p(250,172))
	if type== 1 then
		name:setTextColor(cc.c3b(0,0,255))
		name:setPosition(cc.p(250,172))
	else
		name:setTextColor(cc.c3b(100,100,0))
		name:setPosition(cc.p(140,172))
	end
	name:addTo(self)
	

	local message = ccui.Text:create()
	message:setString(msg)
	message:setTextColor(cc.c3b(0,0,0))
	message:setFontSize(14)
	message:setFontName("msjh.ttc")
	if type== 1 then
		message:setPosition(cc.p(230,100))
	else
		message:setPosition(cc.p(180,100))
	end
	
	message:setTextAreaSize(cc.size(141,120))
	message:addTo(self)
end

return ChatItem