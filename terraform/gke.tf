resource "google_container_cluster" "gke_cluster" {
  name                     = "gke-cluster"
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main_vpc.self_link
  subnetwork               = google_compute_subnetwork.private_subnet.self_link
  networking_mode          = "VPC_NATIVE"
  project                  = var.project_id
  deletion_protection      = false

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "192.168.0.0/28"
  }

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

  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api,
    google_project_service.logging_api,
    google_project_service.secretmanager_api
  ]
}

resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

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
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = "e2-standard-4"
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/trace.append"
    ]
    labels = {
      env = "test"
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