local status = {
}

status.Notyet = 0
status.Doing = 1
status.Reward = 2
status.Finish = 3
status.Cancle = 4

local drama =  {
	[status.Notyet] = {
		"羅素: 勇者，你終於來了，我在這深淵沼澤已等待許久，",
		"羅素: 你是否願意接下拯救世界的任務 ?",
	},
	[status.Doing] = {
		"羅素: 快去完成你的使命吧!",
	},
	[status.Reward] = {
		"羅素: 接受我得祝福吧，勇者。",
	},
	[status.Finish] = {
		"羅素: 感謝你為世界所做的貢獻!",
	},
	[status.Cancle] = {
		"羅素: 這樣嗎? 真是可惜...",
	}
	
}
return drama