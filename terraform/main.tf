terraform {
  required_version = ">= 1.0"
}

provider "google" {
  region = "eu-west-2"
  zone   = "eu-west-2-b"
}

data "google_billing_account" "acct" {
  display_name = "My Billing Account"
}

resource "google_project" "gareth" {
  name       = local.project_name
  project_id = local.project_id
  billing_account = data.google_billing_account.acct.id
}
