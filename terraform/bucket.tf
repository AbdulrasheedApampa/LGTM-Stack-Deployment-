# GCS Buckets for LGTM Stack: Used by Mimir (metrics) and Loki (logs) for persistent storage

# Bucket for storing Mimir data (metrics backend)
resource "google_storage_bucket" "mimir_bucket" {
  name          = "${var.project_id}-mimir-storage" # Globally unique bucket name
  location      = var.region                        # Bucket location 
  force_destroy = true                              # Allows bucket deletion even if it contains objects

  # Enforce uniform access across the bucket (IAM only; no ACLs)
  uniform_bucket_level_access = true

  # Disable object versioning for cost and simplicity
  versioning {
    enabled = false
  }
}

# Bucket for storing Loki data (logs backend)
resource "google_storage_bucket" "loki_bucket" {
  name          = "${var.project_id}-loki-storage" # Globally unique bucket name
  location      = var.region                       # Bucket location 
  force_destroy = true                             # Allows bucket deletion even if it contains objects

  # Enforce uniform access across the bucket (IAM only; no ACLs)
  uniform_bucket_level_access = true

  # Disable object versioning for cost and simplicity
  versioning {
    enabled = false
  }
}
