variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet1_name" {
  type = string
}

variable "subnet2_name" {
  type = string
}

variable "instance_config" {
  type = object({
    machine_type = string
    image_name   = string
    image_project = string
    boot_disk_size = number
    type        = string
  })
  default = {
    machine_type = "e2-medium"
    image_name   = "ubuntu-1804-bionic-v20210315a"
    image_project = "ubuntu-os-cloud"
    boot_disk_size = 20
    type        = "prod-ssd"
  }
}

variable "ssh_members" {
  type    = list(string)  
  default = ["user:umyfashion@gmail.com","user:arimaverick@gmail.com"]
}