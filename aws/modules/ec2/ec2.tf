resource "aws_instance" "Brownie_web_server-01" {
    count = length(var.public_subnet_cidr_blocks)
    ami                    = "ami-0c20b8b385217763f"
    instance_type          = "t1.micro"
    subnet_id              = aws_subnet.Brownie_Public_Subnets[count.index].id
    security_groups        = [aws_security_group.Brownie_Public_Network_Security_Group.id]
    key_name               = "prashant-staging-key"
    user_data = <<-EOF
                #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
                EOF
    tags =  {
        realm = "Prashant-test-env"
        Name = "Public Server"
    }

    root_block_device {
        volume_size = 8
        volume_type = "gp3"
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp3"
        volume_size = 8
    }

    volume_tags = {
        realm = "Prashant-test-env"
    }
}


# Create the Public Security Group
resource "aws_security_group" "Brownie_Public_Network_Security_Group" {
  vpc_id       = aws_vpc.Brownie_VPC.id
  name         = "Prashant-test-Env Public Security Group"
  description  = "Prashant-test-Env Public Security Group"
  
  # Allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  } 
  
  # Allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Environment" = var.environment
      "Project"     = "${var.project}-private"
    }
  )
} 

# Private Server
resource "aws_instance" "Brownie_Private_server-01" {
    count = length(var.private_subnet_cidr_blocks)
    ami                    = "ami-0c20b8b385217763f"
    instance_type          = "t1.micro"
    subnet_id              = aws_subnet.Brownie_Private_Subnets[count.index].id
    security_groups        = [aws_security_group.Brownie_Private_Network_Security_Group.id]
    key_name               = "prashant-staging-key"
    user_data = <<-EOF
                #!/bin/bash
                # Turn on password authentication for lab challenge
                echo 'lab-password' | passwd ubuntu --stdin
                sed -i 's|[#]*PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
                systemctl restart sshd.service
                EOF
    tags =  {
        realm = "Prashant-test-env"
        Name = "Private Server"
    }

    root_block_device {
        volume_size = 8
        volume_type = "gp3"
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp3"
        volume_size = 8
    }

    volume_tags = {
        realm = "Prashant-test-env"
    }
}

# Create the Private Security Group
resource "aws_security_group" "Brownie_Private_Network_Security_Group" {
  vpc_id       = aws_vpc.Brownie_VPC.id
  name         = "Prashant-test-Env Private Security Group"
  description  = "Prashant-test-Env Private Security Group"
  
  # Allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  } 
  
  # Allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prashant-test-env"
  }
} 
