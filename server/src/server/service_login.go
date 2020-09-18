package main

import (
	"fmt"

	"github.com/golang/protobuf/proto"

	data "server/data"
	pb "server/proto"
)

type LoginService struct {
	Task
}

func NewLoginService() ITask {
	ls := &LoginService{}
	ls.SetReqTag([]byte("k_1000"))
	ls.SetResTag([]byte("k_1001"))
	return ls
}

func (m *LoginService) Execute(packet *pb.Packet) string {
	if !m.isResponsibility(packet.GetTag()) {
		return m.next.Execute(packet)
	}

	req := &pb.LoginReq{}
	proto.Unmarshal(packet.Data, req) //save data len 20~24

	var player data.Player
	player, _ = getPlayerCacheInfo(req.GetAccount())
	if !player.IsExist() {
		player, _ = getDbPlayerInfo(req.GetAccount())
		if !player.IsExist() {
			player = data.Player{Name: req.GetName(), Account: req.GetAccount(), Password: req.GetPassword()}
			player.X = 224
			player.Y = 464
			db.Create(&player)
			setPlayerCacheInfo(player)
		}
	}

	var missions []data.Mission
	var pbMissions []*pb.Mission
	db.Where("account = ?", req.GetAccount()).Find(&missions)
	for _, mission := range missions {
		m := &pb.Mission{
			Id:     pb.Int32(mission.GetId()),
			Status: pb.Int32(mission.GetStatus()),
		}
		pbMissions = append(pbMissions, m)
	}

	pbPlayer := &pb.Player{
		TokenID:  pb.String(player.Account),
		Name:     pb.String(player.Name),
		X:        pb.Float32(player.X),
		Y:        pb.Float32(player.Y),
		Missions: pbMissions,
	}

	var otherPlayers []*pb.Player
	for _, key := range getAllAccounts() {
		fmt.Println(key)
		otherCache, _ := getPlayerCacheInfo(key)
		if !otherCache.IsExist() {
			continue
		}

		otherPlayer := &pb.Player{
			TokenID: pb.String(otherCache.Account),
			Name:    pb.String(otherCache.Name),
			X:       pb.Float32(otherCache.X),
			Y:       pb.Float32(otherCache.Y),
		}
		fmt.Println(otherCache.Name)
		otherPlayers = append(otherPlayers, otherPlayer)
	}

	res := &pb.LoginRes{
		Player:       pbPlayer,
		OtherPlayers: otherPlayers,
	}
	data, _ := proto.Marshal(res)
	return m.Pack(data)
}
