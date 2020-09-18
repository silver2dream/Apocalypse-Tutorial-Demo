#!/bin/bash

set -e

cd server
go build server
./server -c conf/server.yaml