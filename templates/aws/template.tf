variable "vpc_id" {}
variable "shared_security_group" {}
variable "key_name" {}
variable "wp_image" {}
variable "wp_instance_type" {}
variable "wordpress_user" {}
variable "wordpress_title" {}
variable "wordpress_admin_user" {}
variable "wordpress_admin_pswd" {}
variable "wordpress_admin_email" {}

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
  ami = "${var.wp_image}"
  instance_type = "${var.wp_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.wp_security_group.id}", "${var.shared_security_group}"]
  associate_public_ip_address = true
  tags {
    Name = "WordPressServer"
  }
  user_data = "${template_file.init.rendered}"
}

output "cluster_addresses" {
  value = "${aws_instance.wp_server.*.private_ip}"
}

output "frontend_addresses" {
  value = "${aws_instance.wp_server.*.public_ip}"
}
