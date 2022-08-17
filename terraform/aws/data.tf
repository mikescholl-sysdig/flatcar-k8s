data "aws_ami" "flatcar_stable_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
  }
}

#resource "random_shuffle" "private_subnet" {
#  input        = [var.private_subnet_ids]
#  result_count = 1
#}
#
#resource "random_shuffle" "public_subnet" {
#  input        = [var.private_subnet_ids]
#  result_count = 1
#}