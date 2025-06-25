# ===============================
# GKE Cluster and Related Setup
# ===============================

# Create the GKE cluster without the default node pool
resource "google_container_cluster" "gke_cluster" {
  name                     = "gke-cluster"
  location                 = var.region
  remove_default_node_pool = true # Remove the default node pool to create custom ones
  initial_node_count       = 1    # Required, though unused due to custom pool
  network                  = google_compute_network.main_vpc.self_link
  subnetwork               = google_compute_subnetwork.private_subnet.self_link
  networking_mode          = "VPC_NATIVE" # Enable VPC-native IP aliasing
  project                  = var.project_id
  deletion_protection      = false

  # Enable or disable specific GKE add-ons
  addons_config {
    http_load_balancing {
      disabled = true # Disable default HTTP LB (we'll use our own)
    }
    horizontal_pod_autoscaling {
      disabled = false # Enable HPA
    }
  }

  # Use regular release channel for stable updates
  release_channel {
    channel = "REGULAR"
  }

  # Enable Workload Identity for secure GCP resource access from pods
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # IP ranges for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  # Enable private nodes for security and specify master CIDR
  private_cluster_config {
    enable_private_nodes    = true             # Nodes have internal IPs only
    enable_private_endpoint = false            # Allow access to control plane via public endpoint
    master_ipv4_cidr_block  = "192.168.0.0/28" # Reserved block for control plane
  }

  # Allow control plane access only from specific CIDR blocks
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.10.0.0/16"
      display_name = "VPC Internal"
    }
    cidr_blocks {
      cidr_block   = "102.213.87.198/32"
      display_name = "My Public IP"
    }
  }

  # Ensure APIs are enabled before creating the cluster
  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api,
    google_project_service.logging_api,
    google_project_service.secretmanager_api
  ]
}

# ===============================
# GKE Node Pool and IAM Bindings
# ===============================

# Service account for GKE nodes
resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
  project      = var.project_id
}

# Assign necessary IAM roles to GKE node SA
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",       # Needed for Cloud Logging
    "roles/monitoring.metricWriter", # Required for metrics export
    "roles/monitoring.viewer",       # Allows monitoring data access
    "roles/storage.objectViewer",    # Needed to read from GCS (e.g., for configs)
    "roles/storage.objectCreator"    # Needed to push logs/objects
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# Node pool for general workloads
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.gke_cluster.id
  location   = var.region
  node_count = 1

  node_locations = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
    "us-central1-f"
  ]

  management {
    auto_repair  = true # Enable auto-repair
    auto_upgrade = true # Enable auto-upgrade
  }

  node_config {
    machine_type    = "e2-standard-4" # VM type for nodes
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/trace.append"
    ]
    labels = {
      env = "test" # Node labeling
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

# ===============================
# Service Accounts for LGTM Stack
# ===============================

# Loki Service Account for pushing logs to GCS
resource "google_service_account" "loki_sa" {
  account_id   = "loki-sa"
  display_name = "Loki Service Account"
  project      = var.project_id
}

# Grant Loki SA permission to write logs to GCS
resource "google_project_iam_member" "loki_sa_roles" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.loki_sa.email}"
}

# Mimir Service Account for metrics persistence
resource "google_service_account" "mimir_sa" {
  account_id   = "mimir-sa"
  display_name = "Mimir Service Account"
  project      = var.project_id
}

# Grant Mimir SA permission to write metrics to GCS
resource "google_project_iam_member" "mimir_sa_roles" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.mimir_sa.email}"
}

# Allow Loki workload in GKE to impersonate its service account
resource "google_service_account_iam_member" "loki_workload_identity" {
  service_account_id = google_service_account.loki_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[monitoring/loki-stack]"
}
