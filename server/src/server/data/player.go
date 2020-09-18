package data

// Player gorm player object
type Player struct {
	ID       int32   `gorm:"type:int"`
	Name     string  `gorm:"type:varchar(128)"`
	Account  string  `gorm:"type:varchar(32);primary key;unique;not null"`
	Password string  `gorm:"type:varchar(32);not null"`
	X        float32 `gorm:"type:float;"`
	Y        float32 `gorm:"type:float;"`
}

// TableName gorm use this to get tablename
// NOTE : it only works int where caulse
func (p Player) TableName() string {
	// var value int
	// for _, c := range []rune(p.Account) {
	// 	value = value + int(c)
	// }
	return "player" //fmt.Sprintf("userinfo_tab_%d", value%20)
}

func (p Player) IsExist() bool {
	if len(p.Account) > 0 {
		return true
	}
	return false
}

// for table
// func GetTableName(account string) string {
// 	// var value int
// 	// for _, c := range []rune(account) {
// 	// 	value = value + int(c)
// 	// }
// 	return "player" //fmt.Sprintf("userinfo_tab_%d", value%20)
// }

// IPlayer is the player interface
type IPlayer interface {
	GetName() string
	GetPosition() (float32, float32)
	SetPosition(float32, float32)
}

// GetName will return player's name
func (p *Player) GetName() string {
	return p.Name
}

// GetPosition will return player's pos
func (p *Player) GetPosition() (float32, float32) {
	return p.X, p.Y
}

// SetPosition can set player's pos
func (p *Player) SetPosition(x float32, y float32) {
	p.X = x
	p.Y = y
}
