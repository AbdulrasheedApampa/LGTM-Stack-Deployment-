output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "mimir_bucket_name" {
  description = "The name of the GCS bucket for Mimir"
  value       = google_storage_bucket.mimir_bucket.name
}

output "loki_bucket_name" {
  description = "The name of the GCS bucket for Loki"
  value       = google_storage_bucket.loki_bucket.name
}

output "gke_service_account_email" {
  description = "The email of the GKE node service account"
  value       = google_service_account.gke_node_sa.email
}