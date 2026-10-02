#!/usr/bin/bash

# This script just properly shuts down everything. Note that it is meant to be run from the project root!

TEMPLATE=$1

sudo docker compose -f templates/$TEMPLATE/compose.yml down --remove-orphans
bash ./scripts/delete_ufw_rule.sh