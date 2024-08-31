data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Default VPC"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "tsanghan-ce6-tf"   #Change

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    tsanghan-service = { #task def and service name -> #Change
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {

        ecs-sample = { #container name
          essential = true
          image     = "public.ecr.aws/u2q1a2y8/tsanghan-ce6/hello-node-app:v1"
          port_mappings = [
            {
              name          = "hello-node-app-ecs"  #container name
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
          readonly_root_filesystem = false

        }
      }
      assign_public_ip = true
      deployment_minimum_healthy_percent = 100
      subnet_ids = flatten(data.aws_subnets.public.ids)
      security_group_ids  = [aws_security_group.allow_sg.id]
    }
  }
}

resource "aws_security_group" "allow_sg" {
  name        = "tsanghan_allow_tls"
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #cidr_blocks = [data.aws_vpc.selected.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sg"
  }
}