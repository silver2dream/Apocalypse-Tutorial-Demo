package main

import (
	"fmt"

	"github.com/golang/protobuf/proto"

	pb "server/proto"
)

type ChatService struct {
	Task
}

func NewChatService() ITask {
	ls := &ChatService{}
	ls.SetReqTag([]byte("k_1003"))
	ls.SetResTag([]byte("k_1004"))
	return ls
}

func (m *ChatService) Execute(packet *pb.Packet) string {
	if !m.isResponsibility(packet.GetTag()) {
		return m.next.Execute(packet)
	}

	req := &pb.ChatReq{}
	proto.Unmarshal(packet.Data, req) //save data len 20~24

	res := &pb.ChatRes{
		Id:      req.Id,
		Type:    req.Type,
		Name:    req.Name,
		Message: req.Message,
	}
	data, _ := proto.Marshal(res)
	fmt.Println(res)
	return m.Pack(data)
}
