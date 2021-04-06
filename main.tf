locals {
  default_network_name = "private-cloudsql"
  vpc_count = 2
  private_network_name = local.default_network_name
  private_ip_name_cloudsql = "private-ip-poc"
  private_subnetwork_cloudsql = "private-subnetwork-cloudsql"
  network_router = "default-network-router-poc"
  network_router_nat = "default-network-router-nat-poc"
  firewall-rule = "poc-allow-ssh-firewall-rule"
  ip_range = "10.0.0.0/8"
}

resource "random_string" "network_suffixes" {
  count = local.vpc_count
  length = 4
  upper = false
  special = false  
}


resource "google_compute_network" "poc_network_cloudsql" {
  count = local.vpc_count
  name = join("-",[local.private_network_name,random_string.network_suffixes[count.index].result])  
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "private_ip_address" {
  count = local.vpc_count
  name = join("-",[local.private_ip_name_cloudsql,random_string.network_suffixes[count.index].result])  
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version = "IPV4"
  prefix_length = 16
  network = google_compute_network.poc_network_cloudsql[count.index].self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count = local.vpc_count
  provider = google-beta
  network = google_compute_network.poc_network_cloudsql[count.index].self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[count.index].name]
}

/*
resource "google_compute_subnetwork" "private_network_cloudsql" {
  count = local.vpc_count  
  name = join("-",[local.private_subnetwork_cloudsql,random_string.network_suffixes[count.index].result])
  ip_cidr_range = cidrsubnet(local.ip_range,8,count.index)
  network = google_compute_network.poc_network_cloudsql[count.index].self_link
  region = var.region
}
*/
resource "google_compute_firewall" "poc-firewall-rule-cloudsql" {
  count = local.vpc_count
  name =  join("-",[local.firewall-rule,random_string.network_suffixes[count.index].result])
  network = google_compute_network.poc_network_cloudsql[count.index].self_link
  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_router" "router" {
  count = local.vpc_count
  name = join("-",[local.network_router,random_string.network_suffixes[count.index].result])
  network = google_compute_network.poc_network_cloudsql[count.index].self_link
  region = var.region
  bgp {
    asn = 64514  
  }  
}

resource "google_compute_router_nat" "default-cloud-nat-gw" {
  count = local.vpc_count
  name = join("-",[local.network_router_nat,random_string.network_suffixes[count.index].result])
  router = google_compute_router.router[count.index].name
  region = google_compute_router.router[count.index].region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


data "google_compute_image" "image" {
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

data "template_file" "startup" {
  template = file("${path.module}/files/startup.tpl")

  vars = {
    GITHUB_PAT = var.pat
  }
}

data "template_file" "shutdown" {
  template = file("${path.module}/files/shutdown.tpl")

  vars = {
    GITHUB_PAT = var.pat
  }
}

resource "google_compute_instance" "default" {
  name         = "tf-self-hosted-runner"
  machine_type = var.instance_config.machine_type
  zone         = "europe-west1-b"

  tags = ["http-server","https-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
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
    shutdown-script = data.template_file.shutdown.rendered
  }

  #metadata_startup_script = file("./files/install-hosted-runner.sh")
  metadata_startup_script = data.template_file.startup.rendered

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

data "google_compute_image" "image" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

module "vm_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.2.0"
  machine_type = "n1-standard-1"
  service_account = module.service_accounts.service_account.iam_email
  disk_size_gb = 20
  #source_image = data.google_compute_image.image.self_link
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