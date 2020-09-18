package world

import (
	data "server/data"
	"sync"

	"github.com/jinzhu/gorm"
)

var once sync.Once

var (
	instance *World
)

func New() *World {
	once.Do(func() {
		instance = new(World)
	})

	return instance
}

type World struct {
	//Map     IMap
	Players map[int32]data.Player
	db      *gorm.DB
}
