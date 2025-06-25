# Enable required Google Cloud APIs for GKE and supporting services

# Enables the Kubernetes Engine API, which is necessary for managing GKE clusters
resource "google_project_service" "container_api" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# Enables the Cloud Logging API to allow GKE and other services to send logs to Cloud Logging
resource "google_project_service" "logging_api" {
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# Enables the Compute Engine API, which is required for provisioning GKE nodes and networking resources
resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enables the Secret Manager API, allowing secure storage and access to secrets in GCP
resource "google_project_service" "secretmanager_api" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

