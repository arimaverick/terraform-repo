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

data "google_compute_image" "ubuntu_image" {
  name  = var.instance_config.image_name
  project = var.instance_config.image_project
}

resource "google_service_account" "vm_instance_sa" {
  account_id   = "terraform-sa"
  display_name = "Service Account"
}

resource "google_project_iam_member" "compute_admin" {
  count       = length(var.ssh_members)
  member = var.ssh_members[count.index]
  project   = var.project_id
  role = "roles/compute.admin"
  #service_account_id = google_service_account.vm_instance_sa.id
}

resource "google_service_account_iam_binding" "vm_ssh" {
  members       = var.ssh_members
  role          = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.vm_instance_sa.id
}

data "template_file" "nginx" {
  template = file("${path.module}/files/install_hosted_runner.tpl")

  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}

resource "google_compute_instance" "default" {
  name         = "tf-self-hosted-runner"
  machine_type = var.instance_config.machine_type
  zone         = "europe-west2-a"

  tags = ["http-server","https-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
    }
  }

  network_interface {
    #network = module.vpc.network_name
    network   = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  #metadata_startup_script = file("./files/install-hosted-runner.sh")
  metadata_startup_script = data.template_file.nginx.rendered

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.vm_instance_sa.email
    scopes = ["cloud-platform"]
  }
}

/*
module "vm_compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "6.2.0"
  region = "europe-west2"
  network = module.vpc.network_name
  instance_template = module.vm_instance_template.self_link
  # insert the 2 required variables here
}

data "google_compute_image" "ubuntu_image" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

module "vm_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.2.0"
  machine_type = "n1-standard-1"
  service_account = module.service_accounts.service_account.iam_email
  disk_size_gb = 20
  #source_image = data.google_compute_image.ubuntu_image.self_link
  startup_script = file("./files/install-hosted-runner.sh")
  network        = module.vpc.network_name
  tags        = ["http-server","https-server"]
  # insert the 3 required variables here
}

module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 3.0"
  project_id    = var.project_id
  prefix        = "terraform-compute-sa"
  names         = ["first"]
  display_name  = "Single Account"
  project_roles = [
    "${var.project_id}=>roles/compute.admin",
    "${var.project_id}=>roles/compute.networkAdmin",
    "${var.project_id}=>roles/compute.storageAdmin",
    "${var.project_id}=>roles/storage.admin"
  ]
}*/