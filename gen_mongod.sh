#!/bin/bash

p=
s=
g=
d= 
while getopts "s:p:d:g:" arg; do
  case $arg in
    s)  
        s=$OPTARG
        ;;
    p)
        p=$OPTARG  
        ;;
    d)
        d=$OPTARG  
        ;;
    g)
        g=$OPTARG  
        ;;
  esac
done

if [ ! -n "$s" ]; then
  echo "通过 -s 指定复制集名称"
  exit 1 
fi

if [ ! -n "$p" ]; then
  echo "通过 -p 指定端口"
  exit 1 
fi

if [ ! -n "$g" ]; then
  echo "通过 -g 指定 mongo 缓存大小"
  exit 1 
fi

if [ ! -n "$d" ]; then
  echo "通过 -d 指定 data 储存路径"
  exit 1 
fi



# 生成 docker-compsoe
echo "version: '3.1'
services:
  mongod:
    image: mongo:6.0.1
    restart: always
    ulimits:
      nproc: 64000 # 进程/线程数
      memlock: # 内存大小
        soft: -1
        hard: -1
      nofile: # 打开文件
        soft: 64000
        hard: 64000
    user: '${UID}'
    ports:
     - ${p}:27017
    volumes:
     - ${d}/data/db:/data/db
     - ./mongo.conf:/etc/mongo.conf
     - ./mongo.key:/etc/mongo/mongo.key
     - /usr/share/zoneinfo:/usr/share/zoneinfo
     - ./run.sh:/data/run.sh 
    command: bash /data/run.sh
networks:
  default:
    external:
      name: mongo_cluster"  >  docker-compose.yml


#  生成 mongo.key
echo "0zv69BNP6XiTJvVb8zCbxndpdINYYMNKj2IvVdSpvgLCmtVJ3pEWrZR9gNb6eFez
ctttPZf7R8eo5Mx4cTZNNkXwY59RVAH5wbX2kLziR25eg6cFedoUyqsu/jKMW63f
W35vFg=="  > mongo.key


# 生成 mongo.conf
echo "storage:
  dbPath: /data/db
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: ${g}

systemLog:
  destination: file
  logAppend: true
  path: /data/db/mongod.log

net:
  bindIpAll: true
  port: 27017
  maxIncomingConnections: 5000

sharding:
   clusterRole: shardsvr

replication:
  replSetName: ${s}

security:
  keyFile: /etc/mongo/mongo.key
  authorization: enabled" > mongo.conf

# 生成 Mongo 执行脚本
echo "#!/bin/bash

mkdir -p /data/db

chmod 600 /etc/mongo/mongo.key

echo 'Mongod Server Starting'

mongod --config /etc/mongo.conf" > run.sh

# 生成目录
mkdir -p ${d}/data/db


docker network create mongo_cluster
echo "Init Mongod Down"