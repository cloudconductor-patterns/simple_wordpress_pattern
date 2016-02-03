variable "subnet_ids" {
  description = "Subnet ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "key_name" {
  description = "Name of an existing EC2/OpenStack KeyPair to enable SSH access to the instances."
}
variable "wordpress_image" {
  description = "[computed] Wordpress Image Id. This parameter is automatically filled by CloudConductor."
}
variable "wordpress_instance_type" {
  description = "Wordpress instance type."
  default = "t2.small"
}
variable "wordpress_user" {
  description = "Wordpress user name."
}
variable "wordpress_title" {
  description = "Wordpress title."
}
variable "wordpress_admin_user" {
  description = "Wordpress admin user name."
}
variable "wordpress_admin_pswd" {
  description = "Wordpress admin user password."
}
variable "wordpress_admin_email" {
  description = "Wordpress admin email address."
}

resource "template_file" "init" {
  template = "${file("init.tpl")}"

  vars {
    wordpress_url = "${var.wordpress_user}"
    wordpress_title = "${var.wordpress_title}"
    wordpress_admin_user = "${var.wordpress_admin_user}"
    wordpress_admin_pswd = "${var.wordpress_admin_pswd}"
    wordpress_admin_email = "${var.wordpress_admin_email}"
  }
}

resource "openstack_compute_floatingip_v2" "main" {
  pool = "public"
}

resource "openstack_compute_secgroup_v2" "wp_security_group" {
  name = "WordPressSecurityGroup"
  description = "Enable  HTTP access via port 80"
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "wp_server" {
  name = "WordPressServer"
  image_id = "${var.wp_image}"
  flavor_name = "${var.wp_instance_type}"
  metadata {
    Role = "wordpress"
    Name = "WordPressServer"
  }
  key_pair = "${var.key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.wp_security_group.name}", "${var.shared_security_group}"]
  floating_ip = "${element(openstack_compute_floatingip_v2.main.*.address, count.index)}"
  user_data = "${template_file.init.rendered}"
}

output "cluster_addresses" {
  value = "${openstack_compute_instance_v2.wp_server.*.network.0.fixed_ip_v4}"
}


output "frontend_addresses" {
  value = "${openstack_compute_floatingip_v2.main.*.address}"
}
