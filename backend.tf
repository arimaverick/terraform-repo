terraform {
  #  backend "gcs" {      
    backend "remote" {
        hostname     = "app.terraform.io"
        organization = "Arimaverick"

        workspaces {
        name = "gh-actions-demo"
        }
    }
}