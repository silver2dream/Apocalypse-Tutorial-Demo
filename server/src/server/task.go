package main

import (
	"bytes"
	pb "server/proto"
	"time"
)

type ITask interface {
	Execute(packet *pb.Packet) string
	SetNext(task ITask)
}

type Task struct {
	packet *pb.Packet
	next   ITask
	reqTag []byte
	resTag []byte
}

func (t *Task) SetReqTag(tag []byte) {
	t.reqTag = tag
}

func (t *Task) SetResTag(tag []byte) {
	t.resTag = tag
}

func (t *Task) isResponsibility(tag []byte) bool {
	if bytes.Compare(t.reqTag, tag) == 0 {
		return true
	}

	return false
}

func (t *Task) SetNext(next ITask) {
	t.next = next
}

func (t *Task) Pack(data []byte) string {

	writeBuf := bytes.NewBuffer(nil)
	resPack := new(pb.Packet)
	resPack.VersionLen = 2
	resPack.Version = []byte("V1")
	resPack.TagLen = 6
	resPack.Tag = []byte(t.resTag)
	resPack.Timestamp = uint32(time.Now().Unix())
	resPack.DataLen = uint32(len(data))
	resPack.Data = data
	resPack.Pack(writeBuf)

	return string(writeBuf.Bytes())
}
