package main

import (
	"fmt"

	"github.com/golang/protobuf/proto"

	data "server/data"
	pb "server/proto"
)

type MissionService struct {
	Task
}

func NewMissionService() ITask {
	ls := &MissionService{}
	ls.SetReqTag([]byte("k_1005"))
	ls.SetResTag([]byte("k_1006"))
	return ls
}

func (m *MissionService) Execute(packet *pb.Packet) string {
	if !m.isResponsibility(packet.GetTag()) {
		return m.next.Execute(packet)
	}

	req := &pb.MissionReq{}
	proto.Unmarshal(packet.Data, req) //save data len 20~24

	mission := &data.Mission{
		ID:      req.GetId(),
		Account: req.GetAccount(),
		Status:  1,
	}

	db.Create(&mission)

	res := &pb.MissionRes{
		Id:     req.Id,
		Status: pb.Int32(1),
	}
	data, _ := proto.Marshal(res)
	fmt.Println(res)
	return m.Pack(data)
}
