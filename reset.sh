#!/bin/bash
rm -rf ./nodes/1
rm -rf ./nodes/2
rm -rf ./nodes/3
rm -rf ./nodes/4
rm -rf ./nodes/5
docker exec -it mongodb mongo --eval "db.dropDatabase()" tomodex
docker exec -it mongodb mongo --eval "db.dropDatabase()" tomoscan
pm2 stop all && pm2 delete -f all

curl -XDELETE "localhost:9200/blocks"
curl -XDELETE "localhost:9200/tokens"
curl -XDELETE "localhost:9200/trc21-tx"
curl -XDELETE "localhost:9200/transactions"
curl -XDELETE "localhost:9200/rewards"
# rm -rf nodes && cp -R backup nodes
