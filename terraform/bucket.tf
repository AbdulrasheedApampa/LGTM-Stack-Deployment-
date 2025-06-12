# GCS Buckets for LGTM (Mimir and Loki)

resource "google_storage_bucket" "mimir_bucket" {
  name          = "${var.project_id}-mimir-storage"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

resource "google_storage_bucket" "loki_bucket" {
  name          = "${var.project_id}-loki-storage"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

