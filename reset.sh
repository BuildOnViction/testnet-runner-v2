#!/bin/bash
rm -rf ./nodes/1
rm -rf ./nodes/2
rm -rf ./nodes/3
rm -rf ./nodes/4
rm -rf ./nodes/5
docker exec -it mongodb mongo --eval "db.dropDatabase()" tomodex
docker exec -it mongodb mongo --eval "db.dropDatabase()" tomoscan
pm2 stop all && pm2 delete -f all
# rm -rf nodes && cp -R backup nodes
