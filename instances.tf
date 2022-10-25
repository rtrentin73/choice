module "ec2_instance" {
  for_each                    = var.vpcs
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 3.0"
  name                        = "${each.value.vpc_name}-linux"
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  key_name                    = "aws-centos"
  subnet_id                   = element(module.vpc[each.value.vpc_name].private_subnets, 2)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh[each.value.vpc_name].id]
  tags = {
    Terraform = "true"
  }
}