#!/bin/bash
touch .pwd
export $(cat .env | xargs)

WORK_DIR=$PWD
TOMOCHAIN_DIR="${HOME}/go/src/github.com/tomochain/tomochain"
GO111MODULE=on
cd $TOMOCHAIN_DIR && make tomo
cd $WORK_DIR

ISRESET=false
if [ ! -d ./nodes/1/tomo/chaindata ]
then
    ISRESET=true
    wallet1=$(${TOMOCHAIN_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/1 <(echo ${PRIVATE_KEY_1}) | awk -v FS="({|})" '{print $2}')
    wallet2=$(${TOMOCHAIN_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/2 <(echo ${PRIVATE_KEY_2}) | awk -v FS="({|})" '{print $2}')
    wallet3=$(${TOMOCHAIN_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/3 <(echo ${PRIVATE_KEY_3}) | awk -v FS="({|})" '{print $2}')
    wallet4=$(${TOMOCHAIN_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/4 <(echo ${PRIVATE_KEY_4}) | awk -v FS="({|})" '{print $2}')
    ${TOMOCHAIN_DIR}/build/bin/tomo --datadir ./nodes/1 init ./genesis/testnet.json
    ${TOMOCHAIN_DIR}/build/bin/tomo --datadir ./nodes/2 init ./genesis/testnet.json
    ${TOMOCHAIN_DIR}/build/bin/tomo --datadir ./nodes/3 init ./genesis/testnet.json
    ${TOMOCHAIN_DIR}/build/bin/tomo --datadir ./nodes/4 init ./genesis/testnet.json
else
    wallet1=$(${TOMOCHAIN_DIR}/build/bin/tomo account list --datadir ./nodes/1 | head -n 1 | awk -v FS="({|})" '{print $2}')
    wallet2=$(${TOMOCHAIN_DIR}/build/bin/tomo account list --datadir ./nodes/2 | head -n 1 | awk -v FS="({|})" '{print $2}')
    wallet3=$(${TOMOCHAIN_DIR}/build/bin/tomo account list --datadir ./nodes/3 | head -n 1 | awk -v FS="({|})" '{print $2}')
    wallet4=$(${TOMOCHAIN_DIR}/build/bin/tomo account list --datadir ./nodes/4 | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

VERBOSITY=4

GASPRICE="250000000"

echo Starting netstats ...
if [ "$(docker ps -aq -f name=netstats)" ]; then
    if [ ! "$(docker ps -aq -f 'status=running' -f name=netstats)" ]; then
        docker start netstats
    fi
else
    docker run -d --env WS_SECRET=anna-coal-flee-carrie-zip-hhhh-tarry-laue-felon-rhine --name netstats -p 3004:3000 tomochain/netstats:latest
fi

echo Starting the bootnode ...
pm2 start ${TOMOCHAIN_DIR}/build/bin/bootnode --name bootnode -- -nodekey ./bootnode.key

echo Starting the nodes ...
pm2 start ${TOMOCHAIN_DIR}/build/bin/tomo --name node01 -- \
    --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" \
    --syncmode "full" --datadir ./nodes/1 --networkid 89 --port 30303 \
    --tomox --tomox.datadir "$WORK_DIR/nodes/1/tomox" --tomox.dbengine "leveldb" \
    --announce-txs \
    --tomo-testnet \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --rpcapi "personal,db,eth,net,web3,txpool,miner,tomox" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" --unlock "${wallet1}" \
	--ethstats "sun:anna-coal-flee-carrie-zip-hhhh-tarry-laue-felon-rhine@localhost:3004" \
    --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY}

pm2 start ${TOMOCHAIN_DIR}/build/bin/tomo --name node02 -- \
    --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" \
    --syncmode "full" --datadir ./nodes/2 --networkid 89 --port 30304 \
    --tomo-testnet \
    --tomox --tomox.datadir "$WORK_DIR/nodes/2/tomox" --tomox.dbengine "leveldb" \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8501 --rpcvhosts "*" \
    --unlock "${wallet2}" --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" \
	--ethstats "moon:anna-coal-flee-carrie-zip-hhhh-tarry-laue-felon-rhine@localhost:3004" \
    --verbosity ${VERBOSITY}

pm2 start ${TOMOCHAIN_DIR}/build/bin/tomo --name node03 -- \
    --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" \
    --syncmode "full" --datadir ./nodes/3 --networkid 89 --port 30305 \
    --tomo-testnet \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8548 --rpcvhosts "*" \
    --tomox --tomox.datadir "$WORK_DIR/nodes/3/tomox" --tomox.dbengine "leveldb" \
    --unlock "${wallet3}" --password ./.pwd --mine --gasprice "${GASPRICE}" \
	--ethstats "earth:anna-coal-flee-carrie-zip-hhhh-tarry-laue-felon-rhine@localhost:3004" \
    --targetgaslimit "420000000" --verbosity ${VERBOSITY}

pm2 start ${TOMOCHAIN_DIR}/build/bin/tomo --name node04 -- \
    --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" \
    --syncmode "full" --datadir ./nodes/4 --networkid 89 --port 30306 \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8549 --rpcvhosts "*" \
    --tomo-testnet \
    --gcmode "archive" \
    --rpcapi "personal,db,eth,net,web3,txpool,miner,tomox,debug" \
    --tomox --tomox.datadir "$WORK_DIR/nodes/4/tomox" --tomox.dbengine "mongodb" \
    --unlock "${wallet4}" --password ./.pwd --mine --gasprice "${GASPRICE}" \
    --ethstats "tomox-fullnode:anna-coal-flee-carrie-zip-hhhh-tarry-laue-felon-rhine@localhost:3004" \
    --targetgaslimit "420000000" --verbosity ${VERBOSITY}

if $ISRESET
then
    echo Sleep 20 seconds ...
    sleep 10
    cd ${TOMOCHAIN_DIR}/contracts/tomox/simulation/deploy && go run main.go
    sleep 10
fi
