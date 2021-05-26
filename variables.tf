variable "region" {
  default     = "ap-south-1"
  description = "AWS Region"
}


variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "tf_run_name" {
  default     = "sandeep-tf"
  description = "Name to identify that it was created by Terraform"
}

variable "pvt-subnet-01-cidr" {
  default     = "10.0.3.0/24"
  description = "Pvt Subnet 01 CIDR"
}

variable "pvt-subnet-02-cidr" {
  default     = "10.0.5.0/24"
  description = "Pvt Subnet 02 CIDR"
}

variable "pvt-subnet-03-cidr" {
  default     = "10.0.7.0/24"
  description = "Pvt Subnet 03 CIDR"
}

variable "pub-subnet-01-cidr" {
  default     = "10.0.2.0/24"
  description = "Pub Subnet 02 CIDR"
}

variable "pub-subnet-02-cidr" {
  default     = "10.0.4.0/24"
  description = "Pub Subnet 02 CIDR"
}

variable "pub-subnet-03-cidr" {
  default     = "10.0.6.0/24"
  description = "Pub Subnet 03 CIDR"
}
