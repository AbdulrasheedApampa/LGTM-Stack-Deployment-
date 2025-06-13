# Firewall rule to allow internal communication within the VPC and SSH access via Google IAP

resource "google_compute_firewall" "allow_internal" {
  name    = "main-vpc-allow-internal"            
  network = google_compute_network.main_vpc.id   

  # Allow all TCP traffic within the VPC (e.g., service-to-service communication)
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  # Allow all UDP traffic within the VPC
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  # Allow ICMP protocol (e.g., ping)
  allow {
    protocol = "icmp"
  }

  # Define source IP ranges that are allowed by this rule
  source_ranges = [
    "10.10.0.0/16",   # Internal IP range of the VPC
    "35.235.240.0/20" # IP range used by Google IAP for secure SSH tunneling
  ]

  # Apply this firewall rule only to instances with the specified network tag
  target_tags = ["internal-allowed"]

  # Human-readable description of the firewall rule
  description = "Allow internal VPC traffic and SSH via IAP"
}
