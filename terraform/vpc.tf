#--------------------------------------------
# VPC and Subnet Configuration for GCP
#--------------------------------------------

# Creates a custom VPC network named 'main-vpc' with regional routing.
resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false # We define subnets manually

  depends_on = [
    google_project_service.compute_api,
    google_project_service.container_api,
    google_project_service.logging_api,
    google_project_service.secretmanager_api
  ]
}

# Adds a default route for internet-bound traffic via GCP's default internet gateway.
resource "google_compute_route" "default_internet_route" {
  name             = "default-internet-route"
  network          = google_compute_network.main_vpc.id
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

#--------------------------------------------
# Subnets
#--------------------------------------------

# Public Subnet in the main VPC
resource "google_compute_subnetwork" "public_subnet" {
  name                     = "public-subnet"
  ip_cidr_range            = "10.10.0.0/19"
  region                   = var.region
  network                  = google_compute_network.main_vpc.id
  private_ip_google_access = true # Allow instances without external IPs to access Google APIs
  stack_type               = "IPV4_ONLY"

  depends_on = [
    google_compute_network.main_vpc,
    google_project_service.compute_api
  ]
}

# Private Subnet with secondary IP ranges for Kubernetes Pods and Services
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.10.32.0/19"
  region                   = var.region
  network                  = google_compute_network.main_vpc.id
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"

  # Secondary ranges used by GKE
  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "172.16.0.0/14"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "172.20.0.0/18"
  }

  depends_on = [
    google_compute_network.main_vpc,
    google_project_service.compute_api
  ]
}

#--------------------------------------------
# NAT Gateway Setup for Outbound Internet Access
#--------------------------------------------

# Reserve a static external IP address for the NAT Gateway
resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.compute_api,
    google_project_service.container_api,
    google_project_service.logging_api,
    google_project_service.secretmanager_api
  ]
}

# Create a Cloud Router to be used by NAT
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.main_vpc.id
  region  = var.region
}

# Create a NAT Gateway to allow instances in private subnet to access the internet
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Apply NAT to both public and private subnets 
  subnetwork {
    name                    = google_compute_subnetwork.public_subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
