package world

// const grass = 0
// const obstacle = 1
// const otherPlayer = 2

// const gridSize = 32.0

// type IMap interface {
// 	Detect(x float32, y float32) bool
// }

// type Map struct {
// 	GridSlice []IGrid
// }

// func newMap() IMap {
// 	m := &Map{
// 		GridSlice: make([]IGrid, 2048),
// 	}

// 	m.loadGrid()
// 	return m
// }

// func (m *Map) loadGrid() {
// 	for idx := 0; idx < len(m.GridSlice); idx++ {
// 		m.GridSlice[idx] = 0
// 	}
// }

// func (m *Map) Detect(Idx int32) bool {
// 	if grid, found := m.GridSlice[idx]; found {
// 		return grid.IsBlocking()
// 	}
// }
