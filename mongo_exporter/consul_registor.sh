name=mongo-export_xxx
address=192.168.88.xxx
port=3810
consul=192.168.88.185
data="{'id': '${name}' ,'name': '${name}','address': '${address}','port': ${port},'tags': ['mongo-exporter'],'checks': [{'http': 'http://${address}:${port}', 'interval': '5s'}]}"


echo ${data}
# curl -X PUT -d   http://localhost:8500/v1/agent/service/register