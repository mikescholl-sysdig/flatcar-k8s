resource "aws_key_pair" "this" {
  key_name = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  tags = {
    type = "private",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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


resource "aws_iam_instance_profile" "controller" {
  role = aws_iam_role.controller.name
  name = "${var.cluster_name}-controller-instance-profile"
}

resource "aws_instance" "controller" {
  count = var.flatcar_controller_count
  instance_type = var.controller_instance_type
  user_data     = data.ct_config.k8s-controller.rendered
  iam_instance_profile = aws_iam_instance_profile.controller.name
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  key_name      = aws_key_pair.this.key_name
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  root_block_device {
    volume_size = 100
  }
  tags = {
    Name = "${var.cluster_name}-controller-${count.index}",
     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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
  template = file("${path.module}/cl/${var.controller_template_name}.yaml.tmpl")
  vars = {
    cni_version = var.cni_version
    release_version = var.release_version
    crictl_version = var.crictl_version
    download_dir = var.download_dir
    cluster_name = var.cluster_name
  }
}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [aws_instance.controller]
  
  create_duration = "120s"
}



