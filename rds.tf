resource "aws_db_instance" "rds_instance" {

  identifier        = "${var.tf_run_name}-rds-instance"
  storage_type      = "gp2"
  allocated_storage = "10"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"
  port              = "3306"
  #db_subnet_group_name = ""


  name                 = "demo_db"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  availability_zone    = "ap-south-1a"
  publicly_accessible  = "false"
  deletion_protection  = "false"
  skip_final_snapshot  = "true"
  tags = {
    Name = "${var.tf_run_name}-rds-instance"
  }
}
