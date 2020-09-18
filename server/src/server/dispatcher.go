package main

import (
	"errors"
	pb "server/proto"
)

type IServiceDispatcher interface {
	Execute(packet *pb.Packet) (string, error)
	Add(task ITask)
}

type ServiceDispatcher struct {
	container []ITask
}

func NewServiceDispatcher() IServiceDispatcher {
	sd := &ServiceDispatcher{}
	return sd
}

func (s *ServiceDispatcher) Add(newTask ITask) {
	max := len(s.container)
	if max > 0 {
		prevIdx := max - 1
		prevTask := s.container[prevIdx]
		prevTask.SetNext(newTask)
	}
	s.container = append(s.container, newTask)
}

func (s *ServiceDispatcher) Execute(packet *pb.Packet) (string, error) {
	if len(s.container) < 1 {
		return "", errors.New("container has no task")
	}

	return s.container[0].(ITask).Execute(packet), nil
}
