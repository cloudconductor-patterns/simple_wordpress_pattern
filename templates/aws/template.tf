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
  subnet_id = "${element(split(", ", var.subnet_ids), 0)}"
  associate_public_ip_address = true
  tags {
    Name = "WordPressServer"
  }
  user_data = "${template_file.init.rendered}"
}

output "cluster_addresses" {
  value = "${aws_instance.wp_server.private_ip}"
}

output "frontend_addresses" {
  value = "${aws_instance.wp_server.public_ip}"
}
