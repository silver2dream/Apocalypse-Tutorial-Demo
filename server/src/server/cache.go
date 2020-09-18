package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"server/conf"
	data "server/data"
	"strings"
	"time"

	"github.com/go-redis/redis"
)

var redisConn *redis.Client

const userInfoPrefix = "userinfo_"
const tokenKeyPrefix = "token_"

// init redis connection pool
func initRedisConn(conf *conf.TCPConf) error {
	redisConn = redis.NewClient(&redis.Options{
		Addr:     conf.Redis.Addr,
		Password: conf.Redis.Passwd,
		DB:       conf.Redis.Db,
		PoolSize: conf.Redis.Poolsize,
	})
	if redisConn == nil {
		return errors.New("Failed to call redis.NewClient")
	}

	_, err := redisConn.Ping().Result()
	if err != nil {
		msg := fmt.Sprintf("Failed to ping redis, err:%s", err.Error())
		return errors.New(msg)
	}
	return nil
}

// cleanup
func closeCache() {
	redisConn.Close()
}

// get cached userinfo
func getPlayerCacheInfo(account string) (data.Player, error) {
	redisKey := userInfoPrefix + account
	val, err := redisConn.Get(redisKey).Result()
	var player data.Player
	if err != nil {
		return player, err
	}
	err = json.Unmarshal([]byte(val), &player)
	return player, err
}

// set cached userinfo
func setPlayerCacheInfo(player data.Player) error {
	redisKey := userInfoPrefix + player.Account
	val, err := json.Marshal(player)
	if err != nil {
		return err
	}
	expired := time.Second * time.Duration(config.Redis.Cache.Userexpired)
	_, err = redisConn.Set(redisKey, val, expired).Result()
	return err
}

// get token info
func getTokenInfo(token string) (data.Player, error) {
	redisKey := tokenKeyPrefix + token
	val, err := redisConn.Get(redisKey).Result()
	var player data.Player
	if err != nil {
		return player, err
	}
	err = json.Unmarshal([]byte(val), &player)
	return player, err
}

// set cached userinfo
func setTokenInfo(player data.Player, token string) error {
	redisKey := tokenKeyPrefix + token
	val, err := json.Marshal(player)
	if err != nil {
		return err
	}
	expired := time.Second * time.Duration(config.Redis.Cache.Tokenexpired)
	_, err = redisConn.Set(redisKey, val, expired).Result()
	return err
}

// update cached userinfo, if failed, try to delete it from cache
func updateCachedUserinfo(player data.Player) error {
	err := setPlayerCacheInfo(player)
	if err != nil {
		redisKey := userInfoPrefix + player.Account
		redisConn.Del(redisKey).Result()
	}
	return err
}

// delete token cache info
func delTokenInfo(token string) error {
	redisKey := tokenKeyPrefix + token
	_, err := redisConn.Del(redisKey).Result()
	return err
}

func getAllAccounts() []string {
	keys, _ := redisConn.Keys("*").Result()
	acts := make([]string, len(keys))
	for _, key := range keys {
		parts := strings.Split(key, userInfoPrefix)
		acts = append(acts, parts[1])
	}
	return acts
}
