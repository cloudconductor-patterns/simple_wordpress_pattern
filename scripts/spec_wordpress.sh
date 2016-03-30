#!/bin/sh -e
set -o pipefail
[ -f scripts/functions.sh ] && source scripts/functions.sh

function spec_wordpress() {
  # it should response 200 OK
  status_code=`curl -sLI http://localhost/ --noproxy localhost -o /dev/null -w '%{http_code}\n'`
  if [ "${status_code}" != "200" ]; then
    echo "localhost:80 returns ${status_code}" 1>&2
    curl http://localhost/ --noproxy localhost
    exit 1
  fi
}

role=$1

if [ "${role}" == "wordpress" ]; then
  spec_wordpress
else
  echo "Unsupported role '${role}'."
fi
