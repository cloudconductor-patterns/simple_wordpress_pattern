variable "vpc_id" {
  description = "VPC ID which is created by common network pattern."
}
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
variable "wordpress_title" {
  description = "Wordpress title."
}
variable "wordpress_admin_user" {
  description = "Wordpress admin user name."
}
variable "wordpress_admin_password" {
  description = "Wordpress admin user password."
}
variable "wordpress_admin_email" {
  description = "Wordpress admin email address."
}
