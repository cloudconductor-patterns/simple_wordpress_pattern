#!/bin/sh -ex

cd $(dirname $0)/data

source ./event_handler.sh wordpress setup 2>&1

if [ ! -d /opt/cloudconductor ]; then
  mkdir -p /opt/cloudconductor
fi

cat <<_EOF_ > /opt/cloudconductor/cfn_parameters
WordPressUrl="http://example.com/wp/"
WordPressTitle="example"
WordPressAdminUser="admin"
WordPressAdminPassword="password"
WordPressAdminEmail="admin@example.com"
_EOF_

which systemctl && systemctl start httpd ||  service httpd start

source ./event_handler.sh wordpress configure 2>&1

source ./event_handler.sh wordpress spec 2>&1
