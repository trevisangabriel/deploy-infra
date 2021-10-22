provider "aws" {
  region = "sa-east-1"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ou ["099720109477"] ID master com permissão para busca

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"] # exemplo de como listar um nome de AMI - 'aws ec2 describe-images --region us-east-1 --image-ids ami-09e67e426f25ce0d7' https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
  }
}

resource "aws_instance" "maquina_deploy-infra" {
  subnet_id                   = "subnet-0e4c840c1e240f521"
  ami                         = "ami-054a31f1b3bf90920"
  instance_type               = "t2.medium"
  key_name                    = "key-dev-gabriel"
  associate_public_ip_address = true
  root_block_device {
    encrypted   = true
    volume_size = 20
  }
  tags = {
    Name = "maquina_deploy-infra-gabriel"
  }
  vpc_security_group_ids = ["${aws_security_group.acessosmaquina_deploy-infra.id}"]
}

resource "aws_security_group" "acessos-maquina_deploy-infra" {
  name        = "acessos-maquina_deploy-infra"
  description = "acessos-maquina_deploy-infra inbound traffic"
  vpc_id      = "vpc-0a62871521ff123ee"
  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups  = null,
      self             = null
    },
    {
      description = "Libera porta nginx"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0",
        "0.0.0.0/0",
        "0.0.0.0/0",
      ]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups  = null,
      self             = null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups  = null,
      self             = null
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "acessos-maquina_deploy-infra"
  }
}


# terraform refresh para mostrar o ssh
output "maquina_deploy-infra" {
  value = [
    "maquina_deploy-infra - ${aws_instance.maquina_deploy-infra.public_ip} - ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.maquina_deploy-infra.public_dns}"
  ]
}

