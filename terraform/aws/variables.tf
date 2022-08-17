variable "flatcar_controller_count" {
  type = string
  description = "Number of flatcar instances to create"
  default = "1"
}

variable "flatcar_worker_count" {
  type = string
  description = "Number of flatcar instances to create"
  default = "2"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name used as prefix for the machine names"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS Region to use for running the machine"
}


variable "ssh_key_name" {
  type = string
  description = "SSH Public keys for user `core`"
  default = "flatcar-ssh-key"
}

variable "ssh_public_key" {
  type = string
  description = "SSH Public keys for user `core`"
}

variable "ssh_private_key" {
  type = string
  default = "~/.ssh/id_rsa"
  
}

variable "instance_type" {
  type        = string
  default     = "t3a.xlarge"
  description = "Instance type for the machine"
}

variable "controller_instance_type" {
  type        = string
  default     = "t3.large"
  description = "Instance type for the machine"
}

variable "cni_version" {
  type = string
  default = "v1.0.1"
  description = "CNI plugin version to download and install"
}

variable "crictl_version" {
  type = string
  default = "v1.23.0"
  description = "Version of crictl to download and install"
}

variable "release_version" {
  type = string
  default = "v0.14.0"
  description = "Release version to target of kubepkg downloads"
}

variable "download_dir" {
  type = string
  default = "/opt/bin"
}

variable "kubeconfig_destination" {
  type = string
  default = "~/.kube/flatcar_config"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID you wish to deploy flatcar node to."
}

variable "vpc_id" {
  type = string
  description = "VPC ID to create cluster on."
}

variable "worker_template_name" {
  type = string
  description = "String prefix to be used to locate template in the cl directory for workers"
}

variable "controller_template_name" {
  type = string
  description = "String prefix to be used to locate template in the cl directory for controllers"
  
}