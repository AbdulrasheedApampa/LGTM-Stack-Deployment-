# DNS A records for accessing Grafana and GitOps UI (agro CD) via domain names
# This Terraform configuration creates DNS A records for Grafana and GitOps services

# Creates an A record for Grafana pointing to the external IP of the LoadBalancer
resource "google_dns_record_set" "grafana" {
  name         = "grafana.one.codcn.com." # Fully qualified domain name for Grafana
  type         = "A"                      # A record maps a domain to an IPv4 address
  ttl          = 300                      # Time to live for DNS cache (in seconds)
  managed_zone = "lgtm-zone"              # Name of the Cloud DNS managed zone
  rrdatas      = ["34.72.125.123"]        # External IP address of the Grafana service
}

# Creates an A record for GitOps (e.g., Argo CD) pointing to the same external IP (ingress-controller)
resource "google_dns_record_set" "gitops" {
  name         = "gitops.one.codcn.com." # Fully qualified domain name for the GitOps UI
  type         = "A"                     # A record for GitOps domain
  ttl          = 300                     # DNS TTL
  managed_zone = "lgtm-zone"             # Same managed DNS zone as Grafana
  rrdatas      = ["34.72.125.123"]       # External IP of the GitOps service
}
