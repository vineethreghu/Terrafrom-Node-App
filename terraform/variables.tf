/* this file contains all the variables required for the terraform configuration. 
If you want to change any value, you can change it here or in the terraform.tfvars file (that file has highest priority).
*/

variable "ami_id" {
    type = string
    description = "this is the ami value"
    default = "ami-0ecb62995f68bb549"  
}

variable "instance_type" {
    type = string
    description = "this is the instance type"
    default = "t2.micro"
  
}
