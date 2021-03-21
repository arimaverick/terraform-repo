module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = var.vpc_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = var.subnet1_name
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "europe-west2"
    },
    {
      subnet_name           = var.subnet2_name
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "europe-west1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    }
  ]
  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "subnet-01-secondary-01"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]

    subnet-02 = []
  }

  routes = [
  ]
}

module "vm_compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "6.2.0"
  region = "europe-west2"
  network = module.vpc.network_name
  instance_template = module.vm_instance_template.self_link
  # insert the 2 required variables here
}

module "vm_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.2.0"
  machine_type = "n1-standard-1"
  service_account = module.service_accounts.email
  disk_size_gb = 20
  source_image = "debian-cloud/debian-9"
  startup_script = file("./files/install-hosted-runner.sh")
  network        = module.vpc.network_name
  # insert the 3 required variables here
}

module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 3.0"
  project_id    = var.project_id
  prefix        = "terraform-compute-sa"
  names         = ["first"]
  project_roles = [
    "roles/compute.admin",
    "roles/compute.networkAdmin",
    "roles/compute.storageAdmin",
    "roles/storage.admin"
  ]
}