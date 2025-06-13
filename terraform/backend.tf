# Configure the backend for storing Terraform state remotely
terraform {
  backend "gcs" {
    # The name of the GCS bucket where Terraform state files will be stored
    bucket = "dru-interview-one-tfstate"

    # The path within the bucket to store the state file
    prefix = "terraform/state"
  }
}
