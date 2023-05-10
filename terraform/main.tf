module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-tf"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    ecsdemo-frontend = { #td name
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {

        ecs-sample = { #container name
          essential = true 
          image     = "public.ecr.aws/docker/library/httpd:latest"
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
          readonly_root_filesystem = false

        }
      }
      assign_public_ip = true
      deployment_minimum_healthy_percent = 100
      subnet_ids = ["subnet-0c236aa7db587a815", "subnet-0b442c55bfcaef886", "subnet-0860c289a56da0f08"]
      security_group_rules = {
        ingress_all = {
          type                     = "ingress"
          from_port                = 0
          to_port                  = 0
          protocol                 = "-1"
          description              = "Allow all"
          cidr_blocks = ["0.0.0.0/0"]
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

}