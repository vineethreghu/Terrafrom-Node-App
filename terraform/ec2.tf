/* 
1. ec2 instance resource
2. new security group resource
    - 22 for ssh
    - 443 for https
    - 3000 for nodejs app // ip:3000
*/

resource "aws_instance" "tf_ec2_instance" {
  ami           = var.ami_id #ubuntu image
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [module.tf_module_ec2_sg.security_group_id]  #[aws_security_group.tf_ec2_sg.id]
  key_name = "terraform-ec2"
  depends_on = [ aws_s3_object.tf_s3_object ]
  user_data = <<-EOF
              #!/bin/bash
              git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
              cd /home/ubuntu/nodejs-mysql
              sudo apt-get update
              sudo apt-get install -y nodejs npm

              echo "DB_HOST=${local.rds_endpoint}" | sudo tee .env
              echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
              sudo echo "DB_PASS=${aws_db_instance.tf_rds_instance.password}" | sudo tee -a .env
              echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
              echo "TABLE_NAME=users" | sudo tee -a .env
              echo "PORT=3000" | sudo tee -a .env

              npm install
              EOF
user_data_replace_on_change = true
  tags = {
    Name = "NodeJS-Terraform-Instance"
  }
}   

/*
# AWS Security Group using terraform resources
resource "aws_security_group" "tf_ec2_sg" {
  name        = "nodejs-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-02123476fdabb8c37"  
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from any IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from any IP
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow Node.js app traffic from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}   
*/

#AWS security group using module

module "tf_module_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"
  vpc_id = "vpc-02123476fdabb8c37"
  name = "tf_module_ec2_sg"
 #ingress_rules = ["https-443-tcp", "ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
    },
    {
        rule        = "https-443-tcp"
        cidr_blocks = "0.0.0.0/0"
    },
    {
        rule        = "ssh-tcp"
        cidr_blocks = "0.0.0.0/0"
    }

  ]
  egress_rules = ["all-all"]

}

#output 
output "ec2_public_ip" {
    value = aws_instance.tf_ec2_instance.public_ip
}
