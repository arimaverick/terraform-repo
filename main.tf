module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"

    project_id   = var.project_id
    network_name = var.vpc_name
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = var.subnet1_name
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "eu-west1"
        },
        {
            subnet_name           = var.subnet2_name
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "eu-west2"
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