#!/bin/bash

sudo wg show ghostbusters | grep -A 2 "peer: " > peers.temp

cmd="$1"

strict="$2"

if [[ $cmd == "remove" ]]; then
 remove=true;
 if [[ $strict == "strict" ]]; then
  strictmode=true;
else
  strictmode=false;
fi
else
 remove=false;
fi

if [[ $strictmode == true ]]; then
  echo "Any offline hosts will be removed!!";
  read -n 1 -s -r -p "Press any key to continue";
  echo -e "\n";
else
  if [[ $remove == true ]]; then
    echo "Offline hosts will be removed! Online hosts with wireguard off will be preserved!";
    read -n 1 -s -r -p "Press any key to continue";
    echo -e "\n";
  fi
fi

while read line; do
 # echo ">> $line";

 if [[ $line == "peer:"* ]]; then
  id=$(echo "$line" | cut -f2 -d" ");
fi

if [[ $line == "allowed ips:"* ]]; then
  ip=$(echo "$line" | cut -f3 -d" " | cut -f1 -d"/");
fi

if [[ $line == "endpoint:"* ]]; then
  endpoint=$(echo "$line" | cut -f2 -d" " | cut -f1 -d":");
fi

if [[ $line == "--" ]]; then
  echo "Testing connection for $id on $ip";
  fping -c1 -t1000 $ip 2>/dev/null 1>/dev/null
  if [ "$?" = 0 ]
  then
   echo "Host found"
 else
   echo "WG not found"
   if [[ $strictmode == true ]]; then
    sudo wg set ghostbusters peer "$id" remove
  else
    echo "Retrying on $endpoint"
    fping -c1 -t1000 $endpoint 2>/dev/null 1>/dev/null
    if [ "$?" = 0 ]
    then
     echo "Public host found, wireguard is down!"
   else
     echo "Server is offline"
     if [[ $remove == true ]]; then
      sudo wg set ghostbusters peer "$id" remove
    fi
  fi
fi
fi

ip="";
id="";
endpoint="";
fi

done < peers.temp

sudo wg show ghostbusters
