resource "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"

  vars {
    wordpress_url = "${var.wordpress_url}"
    wordpress_title = "${var.wordpress_title}"
    wordpress_admin_user = "${var.wordpress_admin_user}"
    wordpress_admin_password = "${var.wordpress_admin_password}"
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
  image_id = "${var.wordpress_image}"
  flavor_name = "${var.wordpress_instance_type}"
  metadata {
    Role = "wordpress"
    Name = "WordPressServer"
  }
  key_pair = "${var.key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.wp_security_group.name}", "${var.shared_security_group}"]
  floating_ip = "${openstack_compute_floatingip_v2.main.address}"
  user_data = "${template_file.init.rendered}"
  network {
    uuid = "${element(split(", ", var.subnet_ids), 0)}"
  }
}

output "cluster_addresses" {
  value = "${openstack_compute_instance_v2.wp_server.network.0.fixed_ip_v4}"
}


output "frontend_addresses" {
  value = "${openstack_compute_floatingip_v2.main.address}"
}
