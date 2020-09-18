FROM centos:7

ENV GOROOT /usr/local/go
ENV GOPATH /data/go
ENV PATH $GOROOT/bin:$PATH

#-------Necessary Tool--------------
RUN yum install -y git make curl automake autoconf libtool gcc gcc-c++ wget

#-------Golang and Package--------------
RUN curl -s -o go.tar.gz https://dl.google.com/go/go1.14.linux-amd64.tar.gz
RUN tar --remove-files -C /usr/local/ -zxf go.tar.gz
RUN mkdir -p /data/go

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.12.3/protobuf-all-3.12.3.tar.gz
RUN tar -C /usr/local/ -zxf protobuf-all-3.12.3.tar.gz

#-------Workdir--------------
ADD . /project
WORKDIR /project/src

CMD /usr/sbin/init