resource "aws_iam_policy" "ssm_policy" {
  name        = "${var.cluster_name}-ssm-policy"
  path        = "/${var.cluster_name}/"
  description = "IAM Policy for K8S Nodes to access SSM"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action = [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
        ]
        Effect   = "Allow"
        Resource = "*"
    },
    {
        Effect = "Allow"
        Action = "ssm:DescribeParameters"
        Resource = "*"
    }
    ]
  })
}

resource "aws_iam_policy" "cloud_provider" {
  name        = "${var.cluster_name}-aws-cloud-provider"
  path        = "/${var.cluster_name}/"
  description = "IAM Policy for K8S Nodes to run aws-cloud-provider"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "iam:CreateServiceLinkedRole",
                "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "*"
    }
    ]
  })
}


resource "aws_iam_policy" "ebs_csi" {
  name        = "${var.cluster_name}-ebs-csi"
  path        = "/${var.cluster_name}/"
  description = "IAM Policy for K8S Nodes to run aws-cloud-provider"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow",
            Action = [
                "ec2:CreateSnapshot",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:ModifyVolume",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications"
            ],
            Resource = "*"
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:CreateTags"
            ],
            Resource = [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ],
            Condition = {
                "StringEquals" = {
                    "ec2:CreateAction" = [
                        "CreateVolume",
                        "CreateSnapshot"
                    ]
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteTags"
            ],
            Resource = [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:CreateVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:CreateVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "aws:RequestTag/CSIVolumeName": "*"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:CreateVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "aws:RequestTag/kubernetes.io/cluster/*": "owned"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "ec2:ResourceTag/CSIVolumeName": "*"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteVolume"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "ec2:ResourceTag/kubernetes.io/cluster/*": "owned"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteSnapshot"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
                }
            }
        },
        {
            Effect = "Allow",
            Action = [
                "ec2:DeleteSnapshot"
            ],
            Resource = "*",
            Condition = {
                "StringLike" = {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        }
    ]
  })
}

resource "aws_iam_role" "controller" {
    name = "${var.cluster_name}-controller-node-role"
    managed_policy_arns = [
        "arn:aws:iam::212717857920:policy/AWSLoadBalancerControllerIAMPolicy",
        aws_iam_policy.ssm_policy.arn,
        aws_iam_policy.cloud_provider.arn,
        aws_iam_policy.ebs_csi.arn
     ]
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
              Service = "ec2.amazonaws.com"
            }
        },
        ]
    })
}

resource "aws_iam_role" "worker" {
    name = "${var.cluster_name}-worker-node-role"
    managed_policy_arns = [
        "arn:aws:iam::212717857920:policy/AWSLoadBalancerControllerIAMPolicy",
        aws_iam_policy.ssm_policy.arn,
        aws_iam_policy.ebs_csi.arn
     ]
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
              Service = "ec2.amazonaws.com"
            }
        },
        ]
    })
}