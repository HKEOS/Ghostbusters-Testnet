#!/bin/bash

if [[ -f abp_list ]]; then
        rm abp_list;
fi

for file in ~/kbfs/team/eos_ghostbusters/mesh/*.peer_info.signed; do
        [ -e "$file" ] || continue;
        kbuser=$(echo "$file" | sed -e 's/.*mesh\/\(.*\).peer_info.signed*/\1/');
        cat "$file" | keybase verify -S "$kbuser" &>output;
        out=$(<output);
        err=$(echo "$out" | grep "ERR");

        if [[ "$err" == "" ]]; then
                echo "$kbuser";
                peerdata=$(cat ~/kbfs/public/$kbuser/bp_info.json);
                acc=$(echo "$peerdata" | jq -r ".producer_account_name");
                pubkey=$(echo "$peerdata" | jq -r ".producer_public_key");
                if [[ $acc != "" ]] && [[ $pubkey != "" ]]; then
                        echo "$acc,$pubkey" >> abp_list
                fi
        fi
done

echo -e "\n >> ABP List is ready!";
cat abp_list;
