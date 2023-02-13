resource "google_project_service" "enable_gke" {
  project = google_project.gareth.project_id
  service = "container.googleapis.com"
}

resource "google_service_account" "gke" {
  account_id   = "gke-service-account"
  display_name = "GKE service account"
  project      = google_project.gareth.project_id
}

resource "google_container_cluster" "primary" {
  name     = "${local.project_id}-cluster"
  location = "${local.gke_location}-a"
  project  = google_project.gareth.project_id
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name = "${local.project_id}-k8s-pod-range"
    services_secondary_range_name = "${local.project_id}-k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
}

resource "google_container_node_pool" "gke_nodes" {
  name       = "${local.project_id}-node-pool"
  cluster    = google_container_cluster.primary.name
  project    = google_project.gareth.project_id
  node_count = 1
  location   = "${local.gke_location}-a"
  node_locations = [
    "europe-west4-b"
  ]

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 64

    service_account = google_service_account.gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    guest_accelerator {
      type  = "nvidia-tesla-t4"
      count = 1
    }
  }
}
