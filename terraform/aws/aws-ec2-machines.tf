terraform {
  required_version = ">= 0.13"
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.7.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "this" {
  id = "vpc-0430bd988526f6db3"
}

#data "aws_subnets" "this" {
#  filter {
#    name = "vpc-id"
#    values = [data.aws_vpc.this.id]
#  }
#  filter {
#    name = "tag:type"
#    values = ["private"]
#  }
#}

resource "aws_key_pair" "this" {
  key_name = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "aws_security_group" "this" {
  vpc_id = data.aws_vpc.this.id
  tags = {
    type = "private"
  }
}

resource "aws_security_group_rule" "outgoing_any" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "incoming_any" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


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

resource "aws_instance" "controller" {
  count = var.flatcar_controller_count
  instance_type = var.instance_type
  user_data     = data.ct_config.k8s-controller.rendered
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  key_name      = aws_key_pair.this.key_name

  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  
  tags = {
    Name = "${var.cluster_name}-${count.index}"
  }
  provisioner "remote-exec" {
    connection {
      host = "${self.public_ip}"
      user = "core"
      private_key = file("${var.ssh_private_key}")
    }

    inline = [
      "echo ${self.public_ip} connecteed",
      "sleep 240",
      "export IS_RUNNING=$(systemctl is-active --quiet k8s-setup && echo true)",
      "if [ $(echo IS_RUNNING) ]; then exit 0; else exit 1; fi",
      ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key} core@${self.public_ip}:/home/core/.kube/config ${var.kubeconfig_destination}"
  }
}

data "ct_config" "k8s-controller" {
  content  = data.template_file.k8s-controller.rendered
}

data "template_file" "k8s-controller" {
  template = file("${path.module}/cl/k8s-controller.yaml.tmpl")
  vars = {
    cni_version = var.cni_version
    release_version = var.release_version
    crictl_version = var.crictl_version
    download_dir = var.download_dir
  }
}


