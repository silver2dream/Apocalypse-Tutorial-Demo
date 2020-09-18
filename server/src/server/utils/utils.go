package utils

import (
	"crypto/sha1"
	"encoding/hex"
)

// GenerateToken return encrypt token of string
func GenerateToken(account string) string {
	h := sha1.New()
	h.Write([]byte(account))
	bs := h.Sum(nil)
	Token := hex.EncodeToString(bs)
	return Token
}
