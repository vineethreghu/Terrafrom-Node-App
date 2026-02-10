/*
1. RDS terraform resource
2. security group
    - 3306
     - security group of ec2 - tf_ec2_sg
     - cidr_blocks = ["local_ip"
3. outputs

command to connect to rds instance: mysql -h nodejs-rds-mysql.c2tk4w46sigh.us-east-1.rds.amazonaws.com -u admin -p
*/

#rds resource
resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage    = 10
  db_name              = "node_demo"
  identifier           = "nodejs-rds-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [ aws_security_group.tf_rds_sg.id ]
}

resource "aws_security_group" "tf_rds_sg" {
  name        = "allow_mysql"
  description = "Allow MySQL traffic"
  vpc_id      = "vpc-02123476fdabb8c37"  
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from any IP
    security_groups = [module.tf_module_ec2_sg.security_group_id] #[aws_security_group.tf_ec2_sg.id] # Allow traffic from EC2 instance
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  rds_endpoint = element(split(":", aws_db_instance.tf_rds_instance.endpoint), 0)
}

output "rds_endpoint" {
    value = local.rds_endpoint
}

output "rds_db_name" {
    value = aws_db_instance.tf_rds_instance.db_name
}

output "rds_username" {
    value = aws_db_instance.tf_rds_instance.username
}