#!/bin/sh -ex

cd $(dirname $0)/data

source ./scripts/setup_wordpress.sh wordpress 2>&1
