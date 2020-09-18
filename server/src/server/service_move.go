package main

import (
	"github.com/golang/protobuf/proto"

	pb "server/proto"
)

type MoveService struct {
	Task
}

func NewMoveService() ITask {
	ms := &MoveService{}
	ms.SetReqTag([]byte("k_0001"))
	ms.SetResTag([]byte("k_0002"))
	return ms
}

func (m *MoveService) Execute(packet *pb.Packet) string {
	if !m.isResponsibility(packet.GetTag()) {
		return m.next.Execute(packet)
	}

	req := &pb.MoveReq{}
	proto.Unmarshal(packet.Data, req) //save data len 20~24

	//world := World.instance

	//world.Detect(0)

	t := pb.Int32(0)
	if req.GetID() != "abc1234" {
		t = pb.Int32(1)
	}

	res := &pb.MoveRes{
		ID:   req.ID,
		Type: t,
		X:    req.X,
		Y:    req.Y,
	}
	data, _ := proto.Marshal(res)
	return m.Pack(data)
}
