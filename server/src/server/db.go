package main

import (
	"errors"
	"fmt"
	"server/conf"

	data "server/data"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

var db *gorm.DB

// init conn
func initDbConn(config *conf.TCPConf) error {
	conninfo := fmt.Sprintf("%s:%s@(%s)/%s?charset=utf8&parseTime=true", config.Db.User, config.Db.Passwd, config.Db.Host, config.Db.Db)
	var err error
	db, err = gorm.Open("mysql", conninfo) //gorm.Open("mysql", conninfo)
	if err != nil {
		msg := fmt.Sprintf("Failed to connect to db '%s', err: %s", conninfo, err.Error())
		return errors.New(msg)
	}

	db.DB().SetMaxIdleConns(config.Db.Conn.Maxidle)
	db.DB().SetMaxOpenConns(config.Db.Conn.Maxopen)
	db.LogMode(true)
	return nil
}

// cleanup
func closeDB() {
	db.Close()
}

// query
func getDbPlayerInfo(account string) (data.Player, error) {
	var quser data.Player
	//db.Table(data.GetTableName(account)).Where(&data.Player{Account: account}).First(&quser)
	db.Table(quser.TableName()).Where(&data.Player{Account: account}).First(&quser)
	if quser.Account == "" {
		return quser, fmt.Errorf("user(%s) not exists", account)
	}
	return quser, nil
}

// update nickname
// func updateDbNickname(account, name string) int64 {
// 	return db.Table(data.GetTableName(account)).Model(&data.Player{}).Where("`account` = ?", account).Updates(data.Player{Name: name}).RowsAffected
// }
