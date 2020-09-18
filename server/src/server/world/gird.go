package world

type IGrid interface {
	IsBocking() bool
}

type Grid struct {
	birckType int32
}

func (g *Grid) IsBlocking() bool {
	if g.birckType != 0 {
		return false
	}
	return true
}
