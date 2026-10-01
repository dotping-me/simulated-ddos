#!/usr/bin/bash

TEMPLATE=$1
NUMBEROFBOTS=$2

bash ./scripts/add_ufw_rule.sh
sudo docker compose -f templates/$TEMPLATE/compose.yml up --build -d
sudo docker compose -f templates/bots/compose.yml up --build -d --scale bot=$NUMBEROFBOTS