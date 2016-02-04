variable "vpc_id" {
  description = "VPC ID which is created by common network pattern."
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
  template = "${file("${path.cwd}/init.tpl")}"

  vars {
    wordpress_url = "${var.wordpress_user}"
    wordpress_title = "${var.wordpress_title}"
    wordpress_admin_user = "${var.wordpress_admin_user}"
    wordpress_admin_pswd = "${var.wordpress_admin_pswd}"
    wordpress_admin_email = "${var.wordpress_admin_email}"
  }
}

resource "aws_security_group" "wp_security_group" {
  name = "WordPressSecurityGroup"
  description = "Enable  HTTP access via port 80"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wp_server" {
  ami = "${var.wordpress_image}"
  instance_type = "${var.wordpress_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.wp_security_group.id}", "${var.shared_security_group}"]
  associate_public_ip_address = true
  tags {
    Name = "WordPressServer"
  }
  user_data = "${template_file.init.rendered}"
}

output "cluster_addresses" {
  value = "${join(",", aws_instance.wp_server.*.private_ip)}"
}

output "frontend_addresses" {
  value = "${join(",", aws_instance.wp_server.*.public_ip)}"
}
