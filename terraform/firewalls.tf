resource "google_compute_firewall" "allow_internal" {
  name    = "main-vpc-allow-internal"
  network = google_compute_network.main_vpc.id

  # Allow all TCP and UDP traffic within the VPC
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  # Allow ICMP (ping, etc.)
  allow {
    protocol = "icmp"
  }

  # Allow SSH from Google IAP and internal traffic within the VPC
  source_ranges = [
    "10.10.0.0/16",   # Internal VPC range
    "35.235.240.0/20" # Google IAP range for secure SSH access
  ]

  target_tags = ["internal-allowed"]
  description = "Allow internal VPC traffic and SSH via IAP"
}