#!/bin/sh -e
set -o pipefail
[ -f scripts/functions.sh ] && source scripts/functions.sh

function get_domain() {
  domain=`consul_kv_get "cloudconductor/system_domain" | grep -o '"dns": ".*"' | cut -d '"' -f4`
  if [ -n "${domain}" ]; then
    echo -n "${domain}"
  else
    self_address=`curl -s "http://169.254.169.254/latest/meta-data/public-ipv4"`
    echo -n "$self_address"
  fi
}

function wordpress_first_settings() {
  # Configure WordPress Settings
  load_cfn_parameters
  wordpress_domain=`get_domain`
  sudo -u apache -- /usr/local/bin/wp core install --path=/var/www/wordpress --url="http://${wordpress_domain}" \
    --title="'${WordPressTitle}'" --admin_user="${WordPressAdminUser}" \
    --admin_password="${WordPressAdminPassword}" --admin_email="${WordPressAdminEmail}"
  sudo -u apache -- /usr/local/bin/wp core update --path=/var/www/wordpress
  sudo -u apache -- /usr/local/bin/wp core update-db --path=/var/www/wordpress
  sudo -u apache -- /usr/local/bin/wp plugin update --all --path=/var/www/wordpress
}

function update_apache_virtual_host() {
  server_name=`get_domain`
  if [ -n "${server_name}" ]; then
    cat > /etc/httpd/conf.d/wordpress.conf <<-EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/wordpress"
  ServerName "${server_name}"
</VirtualHost>
EOF
    service_ctl status httpd
    if [ $? -eq 0 ]; then
      service_ctl reload httpd
    else
      service_ctl restart httpd
    fi
  fi
}

function configure_wordpress() {
  if [ ! -f /tmp/.wordpress_installed ]; then
    wordpress_first_settings
    touch /tmp/.wordpress_installed
  fi
  update_apache_virtual_host
}

role=$1

if [ "${role}" == "wordpress" ]; then
  configure_wordpress
else
  echo "Unsupported role '${role}'."
fi
