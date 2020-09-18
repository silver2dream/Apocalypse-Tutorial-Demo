package main

import (
	"flag"
	"log"
	"math/rand"
	"os"
	conf "server/conf"
	"time"
)

var config conf.TCPConf
var Server INetwork

func init() {
	var confFile string
	flag.StringVar(&confFile, "c", "../conf/tcpserver.yaml", "config file")
	flag.Parse()

	err := conf.ConfParser(confFile, &config)
	if err != nil {
		log.Fatalf("parser config failed:", err.Error())
		os.Exit(-1)
	}

	// init redis
	err = initRedisConn(&config)
	if err != nil {
		log.Fatalf("initRedisConn failed:", err.Error())
		os.Exit(-1)
	}

	// init db
	err = initDbConn(&config)
	if err != nil {
		log.Fatalf("initDbConn failed:", err.Error())
		os.Exit(-1)
	}
	log.Println("init successfully!")

	// start server
	Server = initNetwork()
	Server.RegistService(NewLoginService())
	Server.RegistService(NewMoveService())
	Server.RegistService(NewChatService())
	Server.RegistService(NewMissionService())
}

func finalize() {
	closeCache()
	closeDB()
}

func main() {
	defer finalize()

	// generate random seed global
	rand.Seed(time.Now().UTC().UnixNano())

	if Server != nil {
		err := Server.Start("tcp", "0.0.0.0:8000")
		if err != nil {
			log.Println(err)
		}
	}

	finish := make(chan bool)
	<-finish
}
