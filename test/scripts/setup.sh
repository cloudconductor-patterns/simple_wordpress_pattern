#!/bin/sh -ex

cd $(dirname $0)/data

source ./event_handler.sh wordpress setup 2>&1
