locals {
  gce_project = "pawalt-roach"
}

provider "google" {
  alias = "use1"
  project = local.gce_project
  region  = "us-east1"
  zone    = "us-east1-b"
}


provider "google" {
  alias = "euw2"
  project = local.gce_project
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

provider "google" {
  alias = "an1"
  project = local.gce_project
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

# provider "google" {
#   alias = "aus1"
#   project = local.gce_project
#   region  = "australia-southeast1"
#   zone    = "australia-southeast1-a"
# }

module "roachcluster-use1" {
  source = "./roachcluster"

  providers = {
    google = google.use1
  }
}

module "roachcluster-euw2" {
  source = "./roachcluster"

  providers = {
    google = google.euw2
  }
}

module "roachcluster-an1" {
  source = "./roachcluster"

  providers = {
    google = google.an1
  }
}

# module "roachcluster-aus1" {
#   source = "./roachcluster"
# 
#   providers = {
#     google = google.aus1
#   }
# }

resource "google_compute_firewall" "default" {
 name    = "roach-fw"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["8080", "26257"]
 }

source_ranges = ["0.0.0.0/0"]

  project = local.gce_project
}

module "inventory" {
  source = "./inventory"

  workers = {
    "us-east1" = module.roachcluster-use1.hosts
    "eu-west2" = module.roachcluster-euw2.hosts
    "asia-northeast1" = module.roachcluster-an1.hosts
#    "australia-southeast1" = module.roachcluster-aus1.hosts
  }

  observers = [
    module.roachcluster-use1.observer_addr,
    module.roachcluster-euw2.observer_addr,
    module.roachcluster-an1.observer_addr,
  ]
}
