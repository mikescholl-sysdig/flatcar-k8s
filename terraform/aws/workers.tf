resource "aws_iam_instance_profile" "worker" {
  role = aws_iam_role.worker.name
  name = "${var.cluster_name}-worker-instance-profile"
}

resource "aws_instance" "workers" {
  count = var.flatcar_worker_count
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.worker.name
  user_data     = data.ct_config.k8s-worker.rendered
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  key_name      = aws_key_pair.this.key_name
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  root_block_device {
    volume_size = 100
  }
  tags = {
    Name = "${var.cluster_name}-${count.index}",
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
  depends_on = [
    time_sleep.wait_120_seconds,
    aws_instance.controller
  ]
}

data "ct_config" "k8s-worker" {
  content  = data.template_file.k8s-worker.rendered
}

data "template_file" "k8s-worker" {
  template = file("${path.module}/cl/${var.worker_template_name}.yaml.tmpl")
  vars = {
    cni_version = var.cni_version
    release_version = var.release_version
    crictl_version = var.crictl_version
    download_dir = var.download_dir
    cluster_name = var.cluster_name
  }
}