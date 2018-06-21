#!/bin/bash

KEY=<bot-key>
CHATID=<chat-id>
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"

curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$1" $URL >/dev/null
