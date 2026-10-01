#!/usr/bin/bash

# This script just properly shuts down everything. Note that it is meant to be run from the project root!

sudo docker compose -f templates/bots/compose.yml down
sudo docker compose -f templates/baseline/compose.yml down
bash ./scripts/delete_ufw_rule.sh