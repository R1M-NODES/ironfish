#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/R1M-NODES/utils/master/common.sh)

printLogo

printGreen "Install docker and docker compose"
bash <(curl -s https://raw.githubusercontent.com/R1M-NODES/utils/master/docker-install.sh)

printGreen "Install and running node"
echo "alias ironfish='docker exec ironfish ./bin/run'" >> $HOME/.bashrc
source $HOME/.bashrc

WORKSPACE=$HOME/ironfish
mkdir $WORKSPACE && chmod 755 $WORKSPACE

sudo tee <<EOF >/dev/null $WORKSPACE/docker-compose.yaml
version: "3.3"
services:
 ironfish:
  container_name: ironfish
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "sed -i 's%REQUEST_BLOCKS_PER_MESSAGE.*%REQUEST_BLOCKS_PER_MESSAGE = 5%' /usr/src/app/node_modules/ironfish/src/syncer.ts && apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish:/root/.ironfish
EOF

source $HOME/.bashrc $HOME/.profile
cd $WORKSPACE && docker compose pull && docker compose up -d

printGreen "Node installed"
printGreen "Create a new account with name wallet for sending and receiving coins: ironfish wallet:create myname"
printGreen "Export an account to a mnemonic 24 word phrase: ironfish wallet:export myname --mnemonic --language=English"
printGreen "Export an account: ironfish wallet:export myname"
printGreen "Display your account address: ironfish wallet:address myname"