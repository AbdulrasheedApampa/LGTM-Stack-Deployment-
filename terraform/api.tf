# Enable required Google Cloud APIs for GKE and related services

resource "google_project_service" "container_api" {
  project            = var.project_id
  service            = "container.googleapis.com" # Kubernetes Engine API
  disable_on_destroy = false
}

resource "google_project_service" "logging_api" {
  project            = var.project_id
  service            = "logging.googleapis.com" # Cloud Logging API
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com" # Compute Engine API
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager_api" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com" # Secret Manager API
  disable_on_destroy = false
}

# Add more APIs as needed below, following the same pattern.

