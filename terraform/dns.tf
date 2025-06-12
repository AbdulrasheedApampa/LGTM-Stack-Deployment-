# resource "google_dns_record_set" "grafana" {
#   name         = "grafana.one.codcn.com."
#   type         = "A"
#   ttl          = 300
#   managed_zone = "lgtm-zone" # Name of your existing managed zone
#   rrdatas      = ["<EXTERNAL-IP>"]
# }

resource "google_dns_record_set" "gitops" {
  name         = "gitops.one.codcn.com."
  type         = "A"
  ttl          = 300
  managed_zone = "lgtm-zone"
  rrdatas      = ["35.192.91.249"]
}

# resource "google_dns_record_set" "loki" {
#   name         = "loki.one.codcn.com."
#   type         = "A"
#   ttl          = 300
#   managed_zone = "lgtm-zone"
#   rrdatas      = ["<EXTERNAL-IP>"]
# }