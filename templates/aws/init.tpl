#!/bin/sh -e

/bin/echo 'WordPressUrl="${wordpress_url}"' >> /opt/cloudconductor/cfn_parameters
/bin/echo 'WordPressTitle="${wordpress_title}"' >> /opt/cloudconductor/cfn_parameters
/bin/echo 'WordPressAdminUser="${wordpress_admin_user}"' >> /opt/cloudconductor/cfn_parameters
/bin/echo 'WordPressAdminPassword="${wordpress_admin_pswd}"' >> /opt/cloudconductor/cfn_parameters
/bin/echo 'WordPressAdminEmail="${wordpress_admin_email}"' >> /opt/cloudconductor/cfn_parameters
