#!/bin/bash

get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt < /dev/zero 2> /dev/null
}

BTC_HASH=$(curl -s https://blockchain.info/latestblock | jq .hash | sed 's/"//g');
BTC_HEAD=$(curl -s https://blockchain.info/latestblock | jq .height | sed 's/"//g');

echo "Current Bitcoin Block is: $BTC_HEAD";
echo "Block Hash: $BTC_HASH";
keybase team list-members eos_ghostbusters -j | grep username | cut -d'"' -f 4 | sort > users.txt;

SELECTED_USER=$(shuf -n 1 --random-source=<(get_seeded_random $BTC_HASH) users.txt);

echo "Selected User: $SELECTED_USER";
