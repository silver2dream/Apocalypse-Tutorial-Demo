package main

import (
	"crypto/sha1"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"net"
	"strings"

	data "server/data"
	pb "server/proto"
	world "server/world"
)

// INetwork is interface
type INetwork interface {
	Start(potocalType string, ip string) error
	RegistService(newTask ITask)
}

// Network is a include socket and session class
type Network struct {
	sessions   map[string]*Session
	send       chan string
	recv       chan *pb.Packet
	dispatcher IServiceDispatcher
}

// New is Network's constructor
func initNetwork() INetwork {
	nw := &Network{
		sessions:   make(map[string]*Session),
		send:       make(chan string, 65535),
		recv:       make(chan *pb.Packet, 65535),
		dispatcher: NewServiceDispatcher(),
	}
	return nw
}

//Start is server start to liseten
func (n *Network) Start(potocalType string, ip string) error {
	sock, err := net.Listen(potocalType, ip)
	if err != nil {
		return err
	}

	defer sock.Close()
	log.Println("Wait for clients")

	var players []data.Player
	db.Find(&players)
	for _, player := range players {
		setPlayerCacheInfo(player)
	}

	world.New()
	n.process()

	for {
		conn, err := sock.Accept()
		if err != nil {
			return err
		}
		log.Println(conn.RemoteAddr().String(), potocalType, "connect success")
		n.addToSessions(conn)
		defer conn.Close()
	}
}

func (n *Network) process() {
	go func() {
		for {
			select {
			case packet := <-n.recv:
				fmt.Println(packet.String())
				binaryStr, err := n.dispatcher.Execute(packet)
				if err != nil {
					log.Println(err)
				}

				for _, sess := range n.sessions {
					sess.messageRecv <- binaryStr
				}
			}
		}
	}()
}

func (n *Network) addToSessions(conn Connect) error {
	if conn == nil {
		return errors.New("conn is null")
	}

	sess := &Session{
		conn:        conn,
		messageSend: n.recv,
		messageRecv: make(chan string, 65535),
	}

	if sess == nil {
		return errors.New("create new session fail")
	}

	ip := conn.RemoteAddr().String()
	identity := n.getSessionIdentity(ip)
	n.sessions[identity] = sess
	sess.Start()

	return nil
}

func (n *Network) getSessionIdentity(ip string) string {
	ipinfo := strings.Split(ip, ":")
	ip = ipinfo[0]
	fmt.Println(ip)
	h := sha1.New()
	h.Write([]byte(ip))
	bs := h.Sum(nil)
	identity := hex.EncodeToString(bs)
	return identity
}

func (n *Network) RegistService(newTask ITask) {
	n.dispatcher.Add(newTask)
}
