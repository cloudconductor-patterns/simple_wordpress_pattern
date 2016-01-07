#!/bin/sh -ex

cd $(dirname $0)/data

source ./scripts/setup_wordpress.sh wordpress 2>&1

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

source ./scripts/configure_wordpress.sh wordpress 2>&1

source ./scripts/spec_wordpress.sh wordpress 2>&1
