resource "google_project_service" "enable_artifacts" {
  project = google_project.gareth.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "main" {
  repository_id = "main"
  location      = "europe-west2"
  format        = "DOCKER"
  project       = google_project.gareth.project_id

  depends_on = [
    google_project_service.enable_artifacts
  ]
}

resource "google_artifact_registry_repository_iam_binding" "gke_image_puller" {
  project = google_artifact_registry_repository.main.project
  location = google_artifact_registry_repository.main.location
  repository = google_artifact_registry_repository.main.name
  role = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_service_account.gke.email}",
  ]
}
