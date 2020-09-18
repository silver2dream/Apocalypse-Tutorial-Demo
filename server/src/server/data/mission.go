package data

// Player gorm player object
type Mission struct {
	ID      int32  `gorm:"type:int"`
	Account string `gorm:"type:varchar(32);primary key;"`
	Status  int32  `gorm:"type:int"`
}

// TableName gorm use this to get tablename
// NOTE : it only works int where caulse
func (m Mission) TableName() string {
	return "mission" //fmt.Sprintf("userinfo_tab_%d", value%20)
}

// for table
// func GetTableName(account string) string {
// 	return "mission" //fmt.Sprintf("userinfo_tab_%d", value%20)
// }

// IPlayer is the player interface
type IMission interface {
	GetAccount() string
	GetId() int32
	SetPosition() int32
}

// GetName will return player's name
func (m *Mission) GetAccount() string {
	return m.Account
}

// GetPosition will return player's pos
func (m *Mission) GetId() int32 {
	return m.ID
}

// SetPosition can set player's pos
func (m *Mission) GetStatus() int32 {
	return m.Status
}
