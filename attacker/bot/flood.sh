#!/bin/bash

TARGET=$1
wrk -t1 -c50 -d30s $TARGET
