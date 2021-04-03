resource "random_shuffle" "vpc_list" {
      input = google_compute_network.poc_network_cloudsql[*].self_link
      result_count = 2
}


resource "google_sql_database_instance" "sql-1" {
    #count = local.vpc_count
    name = join("-",["sql",random_string.network_suffixes[0].result])
    #name = "sql-1111"
    database_version = "POSTGRES_11"
    deletion_protection = false
    region = var.region
    depends_on = [google_service_networking_connection.private_vpc_connection]
    settings {
        tier = "db-f1-micro"
        database_flags {
          name = "log_connections"
          value = "on"
        }
        ip_configuration {
          ipv4_enabled = false
          private_network = google_compute_network.poc_network_cloudsql[0].self_link
          #private_network = random_shuffle.vpc_list.result
        }
    }
}

resource "google_sql_database_instance" "sql-2" {
    name = join("-",["sql",random_string.network_suffixes[0].result])
    #name = "sql-2222"
    database_version = "POSTGRES_11"
    deletion_protection = false
    region = var.region
    depends_on = [google_service_networking_connection.private_vpc_connection]
    settings {
        tier = "db-f1-micro"
        database_flags {
          name = "log_connections"
          value = "on"
        }
        ip_configuration {
          ipv4_enabled = false
          private_network = google_compute_network.poc_network_cloudsql[1].self_link
          #private_network = random_shuffle.vpc_list.result
        }
    }
}