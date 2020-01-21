#!/bin/bash

echo Starting tomoscan ...
cd /home/vagrant/projects/tomoscan/client && HOST=0.0.0.0 PORT=3005 pm2 start npm --name tomoscan-client -- run start
cd /home/vagrant/projects/tomoscan/server && pm2 start npm --name tomoscan-server -- run start
cd /home/vagrant/projects/tomoscan/server && pm2 start npm --name tomoscan-producer -- run producer
cd /home/vagrant/projects/tomoscan/server && pm2 start npm --name tomoscan-crawler -- run crawl -i 4
cd /home/vagrant/projects/tomoscan/server && pm2 start npm --name tomoscan-trade-process -- run tradeProcess

echo Starting tomox-sdk ...
cd /home/vagrant/go/src/github.com/tomochain/tomox-sdk && pm2 start ./tomox-sdk --name tomox-sdk
cd /home/vagrant/projects/tomox-sdk-ui && pm2 start npm --name tomox-sdk-ui -- start

#echo Sleep 30 seconds ...
#sleep 30
#echo Starting bot ...
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_TOMOBTC -- bot TOMO-BTC
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_ETHTOMO -- bot ETH-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_XRPTOMO -- bot XRP-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_LTCTOMO -- bot LTC-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_BNBTOMO -- bot BNB-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_ADATOMO -- bot ADA-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_ETCTOMO -- bot ETC-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_BCHTOMO -- bot BCH-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_EOSTOMO -- bot EOS-TOMO
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_ETHBTC -- bot ETH-BTC 
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_XRPBTC -- bot XRP-BTC 
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_TOMOUSD -- bot TOMO-USD
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_BTCUSD -- bot BTC-USD
#cd /home/vagrant/projects/tomox-market-maker && pm2 start cmd.js --name bot_ETHUSD -- bot ETH-USD
