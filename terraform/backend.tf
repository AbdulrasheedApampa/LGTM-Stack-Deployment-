terraform {
  backend "gcs" {
    bucket = "dru-interview-one-tfstate"
    prefix = "terraform/state"
  }
}