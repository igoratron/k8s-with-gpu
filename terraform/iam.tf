resource "google_service_account" "gke" {
  account_id   = "gke-service-account"
  display_name = "GKE service account"
  project      = google_project.gareth.project_id
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

resource "google_service_account" "github_action" {
  account_id   = "github-action"
  display_name = "Github action service account"
  project      = google_project.gareth.project_id
}

resource "google_artifact_registry_repository_iam_binding" "github_action_image_writer" {
  project = google_artifact_registry_repository.main.project
  location = google_artifact_registry_repository.main.location
  repository = google_artifact_registry_repository.main.name
  role = "roles/artifactregistry.writer"
  members = [
    "serviceAccount:${google_service_account.github_action.email}",
  ]
}

resource "google_project_iam_binding" "github_action_container_developer" {
  project = google_artifact_registry_repository.main.project
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${google_service_account.github_action.email}",
  ]
}

resource "google_project_iam_binding" "github_action_token_creator" {
  project = google_artifact_registry_repository.main.project
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.github_action.email}",
  ]
}

resource "google_service_account_key" "github_action_key" {
  service_account_id = google_service_account.github_action.name
}
