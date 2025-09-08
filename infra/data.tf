data "http" "my_ip" {
  url = "https://api.ipify.org"
}

data "aws_subnet" "ec2_subnet" {
  id = var.subnet_id
}