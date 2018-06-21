#!/bin/bash

CLEOS=/path/to/cleos.sh
WALLET_PW=<wallet-password>
TELEGRAM=/path/to/Telegram/script
ACCOUNT_NAME=<producer-account-name>

while [ true ]
do
	$CLEOS wallet unlock --password $WALLET_PW
	$CLEOS system claimrewards $ACCOUNT_NAME
	$CLEOS wallet lock
	$TELEGRAM "Update: reward has been claimed"
	sleep 86415
done
