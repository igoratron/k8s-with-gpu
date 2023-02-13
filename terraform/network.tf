resource "google_project_service" "enable_compute" {
  project = google_project.gareth.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "enable_container" {
  project = google_project.gareth.project_id
  service = "container.googleapis.com"
}

resource "google_compute_network" "main" {
  project                         = google_project.gareth.project_id
  name                            = "main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.enable_compute,
    google_project_service.enable_container
  ]
}

resource "google_compute_subnetwork" "private" {
  project                  = google_project.gareth.project_id
  name                     = "${local.project_id}-private"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = local.gke_location
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${local.project_id}-k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "${local.project_id}-k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

resource "google_compute_router" "router" {
  project = google_project.gareth.project_id
  name    = "router"
  region  = local.gke_location
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  project = google_project.gareth.project_id
  name   = "nat"
  router = google_compute_router.router.name
  region = local.gke_location

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  project = google_project.gareth.project_id
  name    = "nat"
  region  = local.gke_location

  depends_on = [google_project_service.enable_compute]
}

resource "google_compute_firewall" "allow-nginx-ingress-validation" {
  project = google_project.gareth.project_id
  name    = "allow-nginx-ingress-validation"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
