module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.21.0"
  cluster_name    = "themore-cluster"
  cluster_version = "1.28"
  vpc_id          = aws_vpc.themore-vpc.id
  subnet_ids = [
    aws_subnet.public-a.id,
    aws_subnet.public-c.id,
    aws_subnet.private-a.id,
    aws_subnet.private-c.id
  ]
  eks_managed_node_groups = {
    default_node_group = {
      min_size       = 2
      max_size       = 5
      desired_size   = 2
      instance_types = ["t3.small"]
    }
  }
  tags = {
    Environment = "themore"
    Terraform   = "true"
  }
  cluster_endpoint_private_access = true
}

resource "aws_security_group_rule" "eks_cluster_add_access" {
  security_group_id = module.eks.cluster_security_group_id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "eks_node_add_access" {
  security_group_id = module.eks.node_security_group_id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
}
