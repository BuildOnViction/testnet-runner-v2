#!/bin/bash
export $(cat .env | xargs)

WORK_DIR=$PWD
TOMOCHAIN_DIR="${TOMOCHAIN_DIR:-${HOME}/go/src/github.com/tomochain/tomochain}"
TOMOXSDK_DIR="${TOMOXSDK_DIR:-${HOME}/go/src/github.com/tomochain/tomox-sdk}"
TOMOXSDK_UI_DIR="${TOMOXSDK_UI_DIR:-${HOME}/tomox-sdk-ui}"
BOT_DIR="${BOT_DIR:-${HOME}/tomox-market-maker}"
TOMORELAYER_DIR="${TOMORELAYER_DIR:-${HOME}/tomorelayer}"
WALLET_DIR="${WALLET_DIR:-${HOME}/tomowallet-web}"
SCAN_DIR="${SCAN_DIR:-${HOME}/tomoscan}"

echo Starting tomoscan ...
cd ${SCAN_DIR}/client && HOST=0.0.0.0 PORT=3005 pm2 start npm --name tomoscan-client -- run start
cd ${SCAN_DIR}/server && pm2 start npm --name tomoscan-server -- run start
cd ${SCAN_DIR}/server && pm2 start npm --name tomoscan-producer -- run producer
cd ${SCAN_DIR}/server && pm2 start npm --name tomoscan-crawler -- run crawl -i 4
cd ${SCAN_DIR}/server && pm2 start npm --name tomoscan-trade-process -- run tradeProcess

echo Starting tomox-sdk ...
cd ${TOMOXSDK_DIR} && pm2 start ./tomox-sdk --name tomox-sdk
cd ${TOMOXSDK_UI_DIR} && pm2 start npm --name tomox-sdk-ui -- start

echo Starting tomorelayer ...
cd ${TOMORELAYER_DIR} && HOST=0.0.0.0 PORT=3002 pm2 start --name tomorelayer-client npm -- start
cd ${TOMORELAYER_DIR} && ENV_PATH=.env pipenv run pm2 start --name tomorelayer-server python -- ./backend/app.py --port=3003

echo Sleep 30 seconds ...
sleep 30
echo Starting bot ...
cd ${BOT_DIR} && pm2 start cmd.js --name bot_TOMOBTC -- bot TOMO-BTC
cd ${BOT_DIR} && pm2 start cmd.js --name bot_ETHTOMO -- bot ETH-TOMO
cd ${BOT_DIR} && pm2 start cmd.js --name bot_ETHBTC -- bot ETH-BTC
cd ${BOT_DIR} && pm2 start cmd.js --name bot_TOMOUSD -- bot TOMO-USD
cd ${BOT_DIR} && pm2 start cmd.js --name bot_BTCUSD -- bot BTC-USD
cd ${BOT_DIR} && pm2 start cmd.js --name bot_ETHUSD -- bot ETH-USD
