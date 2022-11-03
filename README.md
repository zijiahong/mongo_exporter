# Mongodb Exporter
## 说明
根据以下表格搭建 mongo 复制集和 mongo_exporter,往复制集的某个节点写入 10w 数据,观察 grafana 中数据的变化。

mongod1	            192.168.88.185:3810	
mongod2	            192.168.88.186:3810	
mongod3	            192.168.88.187:3810	
prometheus	        192.168.88.185:39090	
grafana	            192.168.88.185:33000	
mongo_exporter1	    192.168.88.185:13810	
mongo_exporter2	    192.168.88.186:13810	
mongo_exporter3	    192.168.88.187:13810	




## mongo
``` sh
# 三个 mongod 随便找个 mongod 进入容器内部
> docker exec -it mongo_mongod_1 mongosh 
> use admin
> config = {
  _id: 'rs01',
  members: [
    { _id: 0, host: '192.168.88.185:3810'},
    { _id: 1, host: '192.168.88.186:3810'},
    { _id: 2, host: '192.168.88.187:3810'}
  ]
}
> rs.initiate(config)
> db.createUser({"user":"root","pwd":"root","roles":["root"]})
> db.auth('root','root')
> db.createUser({ 
    user: "prometheus",
    pwd: "prometheus",
    roles: [
        { role: "read", db: "admin" },
        { role: "readAnyDatabase", db: "admin" },
        { role: "clusterMonitor", db: "admin" }
    ]
});

```