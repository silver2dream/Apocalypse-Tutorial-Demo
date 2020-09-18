import os
import subprocess
import shutil

clientDistFile =r"../client/proto.pb"
protoDir = r"../server/src/server/proto"
proto = r".proto"

result = [f for f in os.listdir(protoDir) if f.endswith(proto)]

subprocess.call(["protoc", "-I=../server/src/server/proto","--go_out=../server/src/server/proto", ["{a} ".format(a=f) for f in result]])
subprocess.call(["protoc", "-I=../server/src/server/proto","-o proto.pb", ["{a} ".format(a=f) for f in result]])
shutil.move(" proto.pb",clientDistFile)