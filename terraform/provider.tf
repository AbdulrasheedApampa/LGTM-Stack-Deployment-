#--------------------------------------------
# Terraform Configuration and Provider Setup
#--------------------------------------------

terraform {
  # Define required providers for this configuration
  required_providers {
    google = {
      source  = "hashicorp/google" # Specifies the official Google Cloud provider from HashiCorp
      version = "~> 6.0"           # Use any version in the 6.x series (compatible updates)
    }
  }

  # Specify the required Terraform version
  required_version = ">= 1.0" # Ensures Terraform CLI version is at least 1.0
}

#--------------------------------------------
# Configure the Google Cloud Provider
#--------------------------------------------
provider "google" {
  project = var.project_id # GCP project ID, passed in via variable
  region  = var.region     # Default region for resources, passed in via variable
}
